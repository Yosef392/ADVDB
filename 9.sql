CREATE OR REPLACE PROCEDURE Issue_Patient_Warnings IS
    v_Warning_Count NUMBER;
    v_Current_Status VARCHAR2(20);
BEGIN
    -- 1. Identify Missed Appointments (Scheduled in the past)
    -- We loop through appointments that have passed but weren't attended or cancelled
    FOR r_Appt IN (
        SELECT id, patient_id, app_date 
        FROM Manager.Appointments 
        WHERE app_date < TRUNC(SYSDATE) 
          AND status = 'Scheduled'
    ) LOOP
        
        -- A. Create the record in the Warnings table
        INSERT INTO Manager.Warnings (patient_id, warning_reason, warning_date)
        VALUES (r_Appt.patient_id, 'Missed appointment on ' || TO_CHAR(r_Appt.app_date, 'YYYY-MM-DD'), SYSDATE);

        -- B. Update Appointment status to 'Missed' so we don't process it twice
        UPDATE Manager.Appointments 
        SET status = 'Missed' 
        WHERE id = r_Appt.id;

        -- C. Log the specific warning in AuditTrail
        INSERT INTO Manager.AuditTrail (
            table_name, operation, old_data, new_data, action_date
        ) VALUES (
            'Warnings',
            'INSERT',
            'Patient ID: ' || r_Appt.patient_id,
            'Reason: Missed Appointment ID ' || r_Appt.id,
            SYSDATE
        );

        -- D. Count total warnings for this patient
        SELECT COUNT(*) INTO v_Warning_Count 
        FROM Manager.Warnings 
        WHERE patient_id = r_Appt.patient_id;

        -- E. If they hit 3 warnings, change status to "Flagged"
        IF v_Warning_Count >= 3 THEN
            -- Get current status for audit logging
            SELECT status INTO v_Current_Status 
            FROM User1.Patients 
            WHERE id = r_Appt.patient_id;

            IF v_Current_Status != 'Flagged' THEN
                UPDATE User1.Patients 
                SET status = 'Flagged' 
                WHERE id = r_Appt.patient_id;

                -- Log the status change in AuditTrail
                INSERT INTO Manager.AuditTrail (
                    table_name, operation, old_data, new_data, action_date
                ) VALUES (
                    'Patients',
                    'STATUS_UPDATE',
                    'Old Status: ' || v_Current_Status,
                    'New Status: Flagged (Total Warnings: ' || v_Warning_Count || ')',
                    SYSDATE
                );
                
                DBMS_OUTPUT.PUT_LINE('Patient ID ' || r_Appt.patient_id || ' has been FLAGGED.');
            END IF;
        END IF;

    END LOOP;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/






SET SERVEROUTPUT ON;

-- Simulate 3 missed appointments for Patient ID 1
INSERT INTO Manager.Appointments (patient_id, doctor_id, app_date, status) VALUES (1, 1, SYSDATE-5, 'Scheduled');
INSERT INTO Manager.Appointments (patient_id, doctor_id, app_date, status) VALUES (1, 1, SYSDATE-4, 'Scheduled');
INSERT INTO Manager.Appointments (patient_id, doctor_id, app_date, status) VALUES (1, 1, SYSDATE-3, 'Scheduled');
COMMIT;

-- Execute procedure
EXEC Issue_Patient_Warnings;

-- Check results
SELECT * FROM Manager.Warnings;
SELECT id, name, status FROM User1.Patients WHERE id = 1;
SELECT * FROM Manager.AuditTrail ORDER BY action_date DESC;