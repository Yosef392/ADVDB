CREATE OR REPLACE FUNCTION calculate_total_cost(patientid int)
RETURN NUMBER AS 
    totalbill NUMBER;
BEGIN
    SELECT NVL(SUM(cost), 0) INTO totalbill 
    FROM MANAGER.treatments 
    WHERE patient_id = patientid;

    UPDATE user1.patients 
    SET total_bill = totalbill 
    WHERE id = patientid;

    RETURN totalbill;
END;
/

SET SERVEROUTPUT ON;

DECLARE
    v_total NUMBER;
BEGIN
    v_total := Manager.calculate_total_cost(1);
    
    DBMS_OUTPUT.PUT_LINE('Total Cost calculated: ' || v_total);
END;
/








