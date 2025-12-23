CREATE OR REPLACE PROCEDURE Schedule_Appointment(
    p_Patient_ID IN NUMBER,
    p_APP_Doctor_ID IN NUMBER,
    p_Appoinment_Date IN DATE
) AS
    v_App_WeekDay VARCHAR2(20);
    v_Available   NUMBER;
    v_P_Exists    NUMBER;
    v_D_Exists    NUMBER;
BEGIN

    IF p_Appoinment_Date < TRUNC(SYSDATE) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Cannot schedule appointments in the past.');
        RETURN; -- Exit the procedure
    END IF;

    SELECT COUNT(*) INTO v_P_Exists FROM User1.Patients WHERE id = p_Patient_ID;
    IF v_P_Exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Patient ID ' || p_Patient_ID || ' not found.');
        RETURN;
    END IF;

    -- 3. Validate Doctor ID
    SELECT COUNT(*) INTO v_D_Exists FROM Manager.Doctors WHERE id = p_APP_Doctor_ID;
    IF v_D_Exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Doctor ID ' || p_APP_Doctor_ID || ' not found.');
        RETURN;
    END IF;

    -- 4. Proceed with Scheduling Logic
    v_App_WeekDay := TO_CHAR(p_Appoinment_Date, 'FMDAY');

    SELECT COUNT(*) 
    INTO v_Available 
    FROM MANAGER.Available_Hours 
    WHERE doctor_id = p_APP_Doctor_ID 
      AND UPPER(weekday) = UPPER(v_App_WeekDay)
      AND hours_avaliable > 0;

    IF v_Available > 0 THEN
        INSERT INTO MANAGER.Appointments (patient_id, doctor_id, app_date, status) 
        VALUES (p_Patient_ID, p_APP_Doctor_ID, p_Appoinment_Date, 'Scheduled');

        UPDATE MANAGER.Available_Hours 
        SET hours_avaliable = hours_avaliable - 1 
        WHERE doctor_id = p_APP_Doctor_ID 
          AND UPPER(weekday) = UPPER(v_App_WeekDay);

        DBMS_OUTPUT.PUT_LINE('Appointment scheduled successfully for ' || v_App_WeekDay);
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Doctor Unavailable on ' || v_App_WeekDay);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Unexpected Error: ' || SQLERRM);
END;
/


SET SERVEROUTPUT ON;

SELECT * FROM MANAGER.audittrail;
CONN User2/123@//localhost:1521/XEPDB1 
SHOW USER
--
INSERT INTO User1.Patients VALUES (19,'Youssef',DATE '2002-01-30','Admitted',  0,'General');
INSERT INTO User1.Rooms VALUES (6,'REG',     1,'Full');
--
select * from User1.Rooms --work
select * from Manager.AuditTrail; --not work;
--
