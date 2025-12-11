CREATE OR REPLACE TRIGGER patient_admission
BEFORE INSERT ON Patients
FOR EACH ROW
DECLARE
    roomid INT;
    available_rooms    NUMBER;
BEGIN

    SELECT SUM(availability)
    INTO available_rooms
    FROM Rooms
    WHERE room_type = :NEW.room_type;

    IF available_rooms IS NULL OR available_rooms = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No available rooms of the selected type.');
    END IF;
    SELECT room_id
    INTO roomid
    FROM Rooms
    WHERE room_type = :NEW.room_type
      AND availability > 0
      ORDER BY room_id
    FETCH FIRST 1 ROWS ONLY;

    :NEW.room_id := roomid;  
    UPDATE Rooms
    SET availability = availability - 1
    WHERE room_id = roomid;


    INSERT INTO AuditTrail (table_name, operation, old_data, new_data, "timestamp") 
    VALUES (
        'patients',
        'admission',
        NULL,
       'admitted to ' ||  :NEW.room_id,
       SYSDATE
    );

END;
/
