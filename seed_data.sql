

SET SERVEROUTPUT ON;


CONN Manager/123@//localhost:1521/XEPDB1;

DELETE FROM Manager.AuditTrail;
DELETE FROM Manager.Warnings;
DELETE FROM Manager.Treatments;
DELETE FROM Manager.Appointments;
DELETE FROM Manager.Available_Hours;
DELETE FROM Manager.Doctors;
DELETE FROM User1.Patients;
DELETE FROM User1.Rooms;

COMMIT;



INSERT INTO Manager.Doctors (id, name, specialty) VALUES (1, 'Dr. Gregory House', 'Diagnostician');
INSERT INTO Manager.Doctors (id, name, specialty) VALUES (2, 'Dr. Meredith Grey', 'General Surgery');
INSERT INTO Manager.Doctors (id, name, specialty) VALUES (3, 'Dr. Stephen Strange', 'Neurology');

INSERT INTO Manager.Available_Hours (doctor_id, weekday, hours_available) VALUES (1, 'MONDAY', 5);
INSERT INTO Manager.Available_Hours (doctor_id, weekday, hours_available) VALUES (1, 'WEDNESDAY', 5);
INSERT INTO Manager.Available_Hours (doctor_id, weekday, hours_available) VALUES (2, 'TUESDAY', 8);
INSERT INTO Manager.Available_Hours (doctor_id, weekday, hours_available) VALUES (3, 'FRIDAY', 3);

COMMIT;

-- =======================================================
-- STEP 4: INSERT ROOMS
-- =======================================================
CONN User1/123@//localhost:1521/XEPDB1;

-- Insert Rooms (User1)
-- 2 ICU beds, 2 General beds, 1 VIP bed
INSERT INTO User1.Rooms (type, capacity, availability) VALUES ('ICU', 1, 'Available');
INSERT INTO User1.Rooms (type, capacity, availability) VALUES ('ICU', 1, 'Available');
INSERT INTO User1.Rooms (type, capacity, availability) VALUES ('General', 2, 'Available');
INSERT INTO User1.Rooms (type, capacity, availability) VALUES ('General', 2, 'Available');
INSERT INTO User1.Rooms (type, capacity, availability) VALUES ('VIP', 1, 'Available');

COMMIT;

-- =======================================================
-- STEP 5: INSERT PATIENTS (Triggers Admission Logic)
-- =======================================================
-- Note: The 'trg_patient_admission' trigger will automatically assign room_id 
-- and decrease capacity for 'Admitted' patients.

INSERT INTO User1.Patients (name, date_of_birth, status, total_bill, room_type) 
VALUES ('Alice Smith', DATE '1990-05-15', 'Admitted', 0, 'ICU');

INSERT INTO User1.Patients (name, date_of_birth, status, total_bill, room_type) 
VALUES ('Bob Jones', DATE '1985-08-20', 'Admitted', 0, 'General');

INSERT INTO User1.Patients (name, date_of_birth, status, total_bill, room_type) 
VALUES ('Charlie Brown', DATE '2000-01-01', 'Admitted', 0, 'General');

-- This patient is Discharged, so they won't take up a room (Trigger check)
INSERT INTO User1.Patients (name, date_of_birth, status, total_bill, room_type) 
VALUES ('Diana Prince', DATE '1988-12-12', 'Discharged', 1500, 'VIP');

COMMIT;

-- =======================================================
-- STEP 6: INSERT TREATMENTS & APPOINTMENTS
-- =======================================================
CONN Manager/123@//localhost:1521/XEPDB1;

-- Treatments for Alice (Patient ID will likely be generated as 1, but we use subqueries to be safe if IDs reset)
INSERT INTO Manager.Treatments (patient_id, doctor_id, treatment_description, cost)
VALUES ((SELECT id FROM User1.Patients WHERE name='Alice Smith'), 1, 'MRI Scan', 500);

INSERT INTO Manager.Treatments (patient_id, doctor_id, treatment_description, cost)
VALUES ((SELECT id FROM User1.Patients WHERE name='Alice Smith'), 1, 'Blood Test', 100);

INSERT INTO Manager.Treatments (patient_id, doctor_id, treatment_description, cost)
VALUES ((SELECT id FROM User1.Patients WHERE name='Bob Jones'), 2, 'Surgery', 5000);

-- Future Appointments
INSERT INTO Manager.Appointments (patient_id, doctor_id, app_date, status)
VALUES ((SELECT id FROM User1.Patients WHERE name='Alice Smith'), 1, SYSDATE + 1, 'Scheduled');

INSERT INTO Manager.Appointments (patient_id, doctor_id, app_date, status)
VALUES ((SELECT id FROM User1.Patients WHERE name='Bob Jones'), 2, SYSDATE + 2, 'Scheduled');

COMMIT;

PROMPT Seed Data Inserted Successfully.