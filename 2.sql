-------------------------------------------------------------2. Patient Admission Validation
CREATE OR REPLACE TRIGGER User1.trg_patient_admission
BEFORE INSERT ON User1.Patients
FOR EACH ROW
WHEN (NEW.status = 'Admitted')
DECLARE
v_room_id NUMBER;
v_count NUMBER;
v_capacity NUMBER;
BEGIN
-- Check for available room
SELECT COUNT(*) INTO v_count
FROM User1.Rooms
WHERE type = :NEW.room_type AND availability = 'Available';
IF v_count = 0 THEN
RAISE_APPLICATION_ERROR(-20001, 'No available room of type ' || :NEW.room_type);
END IF;
-- Lock and get the first available room ID
SELECT id INTO v_room_id
FROM User1.Rooms
WHERE type = :NEW.room_type AND availability = 'Available'
AND ROWNUM = 1
FOR UPDATE;
-- Update the room availability
select * from User1.Rooms --work
SELECT * FROM MANAGER.audittrail;
SELECT * FROM MANAGER.available_hours;
SELECT * FROM MANAGER.available_hours
SELECT * FROM MANAGER.appointments;
SELECT * FROM appointments;
SELECT * FROM Manager.doctors;
SELECT * FROM Manager.doctors
SELECT * FROM user1.PAtients
UPDATE User1.rooms SET capacity = capacity-1 WHERE id = v_room_id;
SELECT capacity into v_capacity FROM User1.rooms WHERE id = v_room_id;
IF v_capacity = 0
THEN
UPDATE User1.Rooms SET availability = 'Full' WHERE id = v_room_id;
END IF;

-- Log the admission and room assignment in AuditTrail
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
'Room ID: ' || v_room_id || ' Remaining Capacity: ' || (v_capacity+1),
'Patient ID: ' || :NEW.id || ' admitted to room type: ' || :NEW.room_type || ' | Room ID: ' || v_room_id || ' Remaining Capacity: ' || v_capacity,
SYSDATE
);
END;
/
SHOW ERRORS;

--INSERT INTO user1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('New VIP Patient', DATE '1990-01-01', 'Admitted', 1000, 'VIP');
--
---- Verify the room status changed to 'Full'
--SELECT * FROM user1.Rooms;
--INSERT INTO user1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('New GENERAL Patient', DATE '1991-01-01', 'Admitted', 1000, 'General');
--SELECT * FROM User1.Patients
--INSERT INTO user1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('New GENERAL Patient1', DATE '1991-01-01', 'Admitted', 1000, 'General');

-- Verify the audit log
SELECT * FROM Manager.AuditTrail ORDER BY id DESC;

INSERT INTO user1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('Rejected Patient', DATE '1995-05-05', 'Admitted', 1000, 'VIP');
