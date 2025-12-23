CREATE OR REPLACE FUNCTION get_doctor_patient_count(p_doctor_id IN NUMBER) 
RETURN NUMBER AS
    v_total_patients NUMBER;
BEGIN

    SELECT COUNT(DISTINCT patient_id)
    INTO v_total_patients
    FROM Manager.Appointments WHERE doctor_id = p_doctor_id;


    RETURN v_total_patients;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in get_doctor_patient_count: ' || SQLERRM);
        RETURN -1;
END;
/







CREATE OR REPLACE PROCEDURE update_patient_status_by_bill(p_threshold IN NUMBER) AS
    CURSOR c_high_bill_patients IS
        SELECT id, name, status, total_bill 
        FROM User1.Patients 
        WHERE total_bill > p_threshold 
          AND status != 'High-Value';
          
    v_count NUMBER := 0;
BEGIN
    FOR r_pat IN c_high_bill_patients LOOP
        UPDATE User1.Patients
        SET status = 'High-Value'
        WHERE id = r_pat.id;

        INSERT INTO Manager.AuditTrail (
            table_name,
            operation,
            old_data,
            new_data,
            action_date
        ) VALUES (
            'Patients',
            'STATUS_UPDATE',
            'Old Status: ' || r_pat.status || ' | Bill: ' || r_pat.total_bill,
            'New Status: High-Value | Threshold: ' || p_threshold,
            SYSDATE
        );
        
        v_count := v_count + 1;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Process complete. ' || v_count || ' patients updated to High-Value status.');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error in update_patient_status_by_bill: ' || SQLERRM);
END;
/




SET SERVEROUTPUT ON;
SELECT * FROM USER1.PATIENTS;
SELECT * FROM MANAGER.DOCTORS;
SELECT * FROM MANAGER.APPOINTMENTS;


DECLARE
    v_p_count NUMBER;
BEGIN
    v_p_count := get_doctor_patient_count(1);
    DBMS_OUTPUT.PUT_LINE('Unique patients for Doctor 1: ' || v_p_count);

    update_patient_status_by_bill(400);
END;
/

SELECT id, name, total_bill, status FROM User1.Patients;
SELECT * FROM Manager.AuditTrail ORDER BY action_date DESC;

