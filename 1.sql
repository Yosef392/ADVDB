CONN SYS AS SYSDBA
SHOW CON_NAME;
--
ALTER PLUGGABLE DATABASE XEPDB1 OPEN;
--
SHOW PDBS;
ALTER SESSION SET CONTAINER = XEPDB1;
SHOW CON_NAME;
--------------------------------------
CREATE USER MANAGER IDENTIFIED BY 123;
ALTER USER Manager QUOTA UNLIMITED ON USERS;
--
CREATE ROLE Manager_Role;
--
SET ROLE DBA;
--
GRANT ADMINISTER DATABASE TRIGGER TO MANAGER;
GRANT CREATE SESSION,
      CREATE USER,
      CREATE TABLE,
      CREATE VIEW,
      CREATE PROCEDURE,
      CREATE TRIGGER,
      GRANT ANY PRIVILEGE,
      GRANT ANY OBJECT PRIVILEGE,
      ADMINISTER DATABASE TRIGGER,
      CREATE SEQUENCE ,
      CREATE FUNCTION,
      DBA
TO Manager_Role;
GRANT CREATE FUNCTION TO MANAGER_ROLE
--
GRANT Manager_Role , DBA  TO MANAGER;
--------------------------------------
CONN MANAGER/123@//localhost:1521/ORCLPDB 
SHOW USER
--------------------------------------
CREATE USER User1 IDENTIFIED BY 123;
ALTER USER User1 QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION, CREATE TABLE ,CREATE SEQUENCE TO User1;
--
CREATE USER User2 IDENTIFIED BY 123;
ALTER USER User2 QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION ,CREATE SEQUENCE  TO User2;
--
CONN User1/123@//localhost:1521/XEPDB1
SHOW USER
--
CREATE TABLE Rooms (
  id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  type VARCHAR2(20),
  capacity NUMBER,
  availability VARCHAR2(15) --availability VARCHAR2(15) CHECK (availability IN ('Available','Full'))
);
--drop table Rooms
CREATE TABLE Patients (
  id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR2(50),
  date_of_birth DATE,
  status VARCHAR2(20),
  total_bill NUMBER,
  room_type VARCHAR2(20),
  room_id NUMBER REFERENCES User1.Rooms()
);
GRANT REFERENCES ON User1.Patients TO Manager;



--drop table user1.doctors
CONN Manager/123@//localhost:1521/ORCLPDB 
GRANT INSERT, SELECT ON User1.Patients TO User2;
GRANT INSERT, SELECT, UPDATE ON User1.Rooms TO User2;
--
create table Doctors (
    id              int PRIMARY KEY,
    name            varchar(100) not null,
    specialty       varchar(100),
);


CREATE TABLE Appointments (
id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
patient_id NUMBER REFERENCES User1.Patients(id),
doctor_id NUMBER REFERENCES Manager.Doctors(id),
app_date DATE,
status VARCHAR2(20)
);

create table Available_Hours(
    id              int primary key GENERATED ALWAYS AS IDENTITY,
    doctor_id       number references Doctors(id) on delete set null,
    weekday         varchar2(10),
    hours_available number
);
--
CREATE TABLE AuditTrail (
  id NUMBER GENERATED ALWAYS AS IDENTITY,
  table_name VARCHAR2(50),
  operation VARCHAR2(50),
  old_data VARCHAR2(200),
  new_data VARCHAR2(200),
  action_date DATE
);

CREATE TABLE treatments(
  id NUMBER GENERATED ALWAYS AS IDENTITY,
    patient_id NUMBER REFERENCES USer1.patients(id),
    doctor_id NUMBER REFERENCES MANAGER.doctors(id),
    treatment_description VARCHAR(255),
    cost NUMBER
);
--
CONN User2/123@//localhost:1521/ORCLPDB 
SHOW USER
--

INSERT INTO User1.Rooms (type,capacity,availability) VALUES ('ICU',     1,'Available');
INSERT INTO User1.Rooms (type,capacity,availability) VALUES ('ICU',     1,'Full');
INSERT INTO User1.Rooms (type,capacity,availability) VALUES ('General', 2,'Available');
INSERT INTO User1.Rooms (type,capacity,availability) VALUES ('General', 3,'Available');
INSERT INTO User1.Rooms (type,capacity,availability) VALUES ('VIP',     1,'Available');
--
INSERT INTO User1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('Ali',   DATE '2000-05-10','Admitted',   1,'ICU');
INSERT INTO User1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('Sara',  DATE '1999-03-22','Admitted',   0,'ICU');
INSERT INTO User1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('Omar',  DATE '2001-11-01','Discharged', 500,'General');
INSERT INTO User1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('Mona',  DATE '1998-07-15','Admitted',   200,'General');
INSERT INTO User1.Patients (name,date_of_birth,status,total_bill,room_type) VALUES ('Youssef',DATE '2002-01-30','Flagged',  0,'VIP');
--
COMMIT;
---------------------------------------------------------------------------

CONN Manager/123@//localhost:1521/ORCLPDB
drop trigger trg_audit_user_and_role;
--
CREATE OR REPLACE TRIGGER trg_audit_user_and_role
AFTER CREATE OR GRANT ON DATABASE
DECLARE
    -- Variables to hold the list of privileges/roles granted
    v_priv_list  DBMS_STANDARD.ORA_NAME_LIST_T;
    v_n          PLS_INTEGER;
    v_priv_name  VARCHAR2(200);
BEGIN
    /* ===============================
       1. Check for CREATE USER
    ================================ */
    IF ORA_SYSEVENT = 'CREATE' AND ORA_DICT_OBJ_TYPE = 'USER' THEN
        INSERT INTO AuditTrail (
            table_name,
            operation,
            old_data,
            new_data,
            action_date
        )
        VALUES (
            'DBA_USERS',
            'CREATE_USER',
            NULL,
            ORA_DICT_OBJ_NAME, -- The new user's name
            SYSDATE
        );

    /* ===============================
       2. Check for GRANT
    ================================ */
    ELSIF ORA_SYSEVENT = 'GRANT' THEN
        -- Get the list of privileges or roles being granted
        v_n := ORA_PRIVILEGE_LIST(v_priv_list);

        -- Typically only one is granted at a time, but we grab the first one for the log
        IF v_n > 0 THEN
            v_priv_name := v_priv_list(1); 
        END IF;

        INSERT INTO AuditTrail (
            table_name,
            operation,
            old_data,
            new_data,
            action_date
        )
        VALUES (
            'DBA_ROLE_PRIVS',
            'GRANT',
            'Executed by: ' || ORA_LOGIN_USER,
            -- Logic: If Object Name exists (e.g. Table), show it. 
            -- If not, show the Privilege/Role Name (e.g. DBA).
            CASE 
                WHEN ORA_DICT_OBJ_NAME IS NOT NULL THEN 
                     'Obj: ' || ORA_DICT_OBJ_NAME || ' | Priv: ' || v_priv_name
                ELSE 
                     'System Priv/Role: ' || v_priv_name
            END,
            SYSDATE
        );
    END IF;
END;
/


-- Test your trigger
CREATE USER test_trigger_1 IDENTIFIED BY password1;
GRANT CONNECT TO test_trigger_1;

-- Check results
SELECT * FROM MANAGER.AuditTrail ORDER BY action_date DESC;
drop user test_trigger_1;
DELETE FROM audittrail;
----------------------------------------------------------------------------------------------
Grant create trigger to User1
--
grant insert on Manager.AuditTrail to User1
GRANT ADMINISTER DATABASE TRIGGER TO User1;
--
CONN User1/123@//localhost:1521/ORCLPDB 
SHOW USER
--
GRANT SELECT, UPDATE ON User1.Rooms TO Manager;
--
-- drop trigger User1.trg_patient_admission
--
CONN Manager/123@//localhost:1521/ORCLPDB 
SHOW USER
GRANT INSERT ON Manager.AuditTrail TO User1;









    










