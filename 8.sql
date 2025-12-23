CREATE OR REPLACE TYPE t_app_ids IS TABLE OF NUMBER;

CREATE OR REPLACE PROCEDURE Cancel_Appointments_Batch(
    p_ids_to_cancel IN t_app_ids
) IS
    v_current_status  VARCHAR2(20);
    v_doctor_id       NUMBER;
    v_app_date        DATE;
    v_weekday         VARCHAR2(20);
    
    -- Custom exception to trigger rollback
    e_cancel_failed   EXCEPTION;
BEGIN
    -- Input Validation
    IF p_ids_to_cancel IS NULL OR p_ids_to_cancel.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: No Appointment IDs provided.');
        RETURN;
    END IF;

    -- Iterate through each ID in the input parameter
    FOR i IN 1..p_ids_to_cancel.COUNT LOOP
        BEGIN
            -- 1. Check Status and Lock the Row
            SELECT status, doctor_id, app_date
            INTO v_current_status, v_doctor_id, v_app_date
            FROM MANAGER.Appointments
            WHERE id = p_ids_to_cancel(i)
            FOR UPDATE;

            -- 2. Validate: Can only cancel 'Scheduled' appointments
            IF v_current_status != 'Scheduled' THEN
                DBMS_OUTPUT.PUT_LINE('Error: Appointment ID ' || p_ids_to_cancel(i) || 
                                     ' is currently ''' || v_current_status || '''. Cannot cancel.');
                RAISE e_cancel_failed;
            END IF;

            -- 3. Perform Cancellation
            UPDATE MANAGER.Appointments
            SET status = 'Cancelled'
            WHERE id = p_ids_to_cancel(i);

            -- 4. Restore Availability (Reverse of logic in 3.sql)
            v_weekday := TO_CHAR(v_app_date, 'FMDAY');

            UPDATE MANAGER.Available_Hours
            SET hours_avaliable = hours_avaliable + 1
            WHERE doctor_id = v_doctor_id
              AND UPPER(weekday) = UPPER(v_weekday);
            
            -- Cite: Columns based on 1.sql and logic derived from 3.sql
            DBMS_OUTPUT.PUT_LINE('Appointment ID ' || p_ids_to_cancel(i) || ' marked as Cancelled.');

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Error: Appointment ID ' || p_ids_to_cancel(i) || ' not found.');
                RAISE e_cancel_failed;
        END;
    END LOOP;

    -- If we get here, everything worked
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Success: All requested appointments have been cancelled.');

EXCEPTION
    WHEN e_cancel_failed THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transaction Failed: All changes rolled back.');
        
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Unexpected Error: ' || SQLERRM);
END;
/



SELECT * FROM appointments;
SELECT * FROM available_hours;


DECLARE 
arr t_app_ids := t_app_ids(6);
BEGIN
Cancel_Appointments_Batch(arr);
END;
/


