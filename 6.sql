CREATE OR REPLACE PROCEDURE Process_Discharge(
    p_Patient_ID IN NUMBER
) AUTHID CURRENT_USER IS
    v_Current_Status VARCHAR2(20);
    v_Room_ID        NUMBER;
    v_Patient_Name   VARCHAR2(50);
BEGIN
    BEGIN
        SELECT status, room_id, name 
        INTO v_Current_Status, v_Room_ID, v_Patient_Name
        FROM User1.Patients 
        WHERE id = p_Patient_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Patient ID ' || p_Patient_ID || ' not found.');
            RETURN;
    END;

    IF v_Current_Status != 'Admitted' THEN
        DBMS_OUTPUT.PUT_LINE('Error: Patient ' || v_Patient_Name || ' is currently ' || v_Current_Status || '. Cannot discharge.');
        RETURN;
    END IF;

    UPDATE User1.Patients 
    SET status = 'Discharged'
    WHERE id = p_Patient_ID;


    IF v_Room_ID IS NOT NULL THEN
        UPDATE User1.Rooms
        SET capacity = capacity + 1,
            availability = 'Available'
        WHERE id = v_Room_ID;
    END IF;

    INSERT INTO Manager.AuditTrail (
        table_name,
        operation,
        old_data,
        new_data,
        action_date
    ) VALUES (
        'Patients',
        'DISCHARGE',
        'Status: Admitted | Room ID: ' || v_Room_ID,
        'Status: Discharged | Patient ID: ' || p_Patient_ID,
        SYSDATE
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Patient ' || v_Patient_Name || ' successfully discharged.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Unexpected Error: ' || SQLERRM);
END;
/

