CREATE OR REPLACE FUNCTION calculate_total_cost(patientid int)
RETURN NUMBER AS totalbill NUMBER;
BEGIN
SELECT sum(cost) into totalbill FROM treatments WHERE patient_id = patiendid;
UPDATE patients SET total_bill = totalbill WHERE id = patientid;
RETURN total_bill;
END;

