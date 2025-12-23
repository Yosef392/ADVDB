CREATE OR REPLACE TRIGGER User1.trg_patient_admission
BEFORE INSERT ON User1.Patients
FOR EACH ROW
WHEN (NEW.status = 'Admitted')
DECLARE
    v_room_id NUMBER;
    v_count NUMBER;
    v_capacity NUMBER;
BEGIN

    SELECT COUNT(*) INTO v_count
    FROM User1.Rooms
    WHERE type = :NEW.room_type AND availability = 'Available';

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No available room of type ' || :NEW.room_type);
    END IF;

    SELECT id INTO v_room_id
    FROM User1.Rooms
    WHERE type = :NEW.room_type AND availability = 'Available'
    AND ROWNUM = 1
    FOR UPDATE;


    UPDATE User1.Rooms 
    SET capacity = capacity - 1 
    WHERE id = v_room_id;


    SELECT capacity INTO v_capacity 
    FROM User1.Rooms 
    WHERE id = v_room_id;

    IF v_capacity = 0 THEN
        UPDATE User1.Rooms 
        SET availability = 'Full' 
        WHERE id = v_room_id;
    END IF;


    :NEW.room_id := v_room_id;

    INSERT INTO Manager.AuditTrail (
        table_name,
        operation,
        old_data,
        new_data, 
        action_date
    )
    VALUES (
        'Patients/Rooms',
        'ADMIT_PATIENT',
        'Room ID: ' || v_room_id || ' Remaining Capacity: ' || (v_capacity + 1),
        'Patient ID: ' || :NEW.id || ' admitted to room type: ' || :NEW.room_type || ' | Room ID: ' || v_room_id || ' Remaining Capacity: ' || v_capacity,
        SYSDATE
    );
END;
/
SHOW ERRORS;





SELECT * FROM Manager.AuditTrail ORDER BY id DESC;

INSERT INTO user1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('Rejected Patient', DATE '1995-05-05', 'Admitted', 1000, 'VIP');
