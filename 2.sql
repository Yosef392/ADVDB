CREATE OR REPLACE TRIGGER patient_addmission
BEFORE INSERT ON EMPLOYEE 
FOR EACH ROW
DECLARE
available_rooms INTEGER;
BEGIN
SELECT SUM(availability) INTO available_rooms FROM Rooms WHERE type = :NEW.room_type;

IF available_rooms = 0 THEN
  RAISE_APPLICATION_ERROR(-20001, 'No rooms available for this type');
    END IF;
END;