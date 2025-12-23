SET SERVEROUTPUT ON;

INSERT INTO Manager.Doctors (name, specialty) VALUES ('Dr. Gregory House', 'Diagnostician');
INSERT INTO Manager.Doctors (name, specialty) VALUES ('Dr. Helal Ahmed', 'General Surgery');
INSERT INTO Manager.Doctors (name, specialty) VALUES ('Dr. Toaa', 'Neurology');

SELECT * FROM MANAGER.doctors;

INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (1, 'MONDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (1, 'TUESDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (1, 'WEDNESDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (1, 'THURSDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (1, 'FRIDAY', 8);

INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (2, 'MONDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (2, 'TUESDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (2, 'WEDNESDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (2, 'THURSDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (2, 'FRIDAY', 8);


INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (3, 'MONDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (3, 'TUESDAY', 2);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (3, 'WEDNESDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (3, 'THURSDAY', 8);
INSERT INTO MANAGER.Available_Hours (doctor_id, weekday, hours_available) VALUES (3, 'FRIDAY', 8);


COMMIT;

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