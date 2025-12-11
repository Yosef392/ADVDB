CREATE OR REPLACE FUNCTION calculate_total_cost(patient_id int)
RETURN NUMBER AS total_bill NUMBER;
BEGIN
SELECT sum(cost) into total_bill FROM treatments WHERE patient_id = patiend_id;
UPDATE patients SET total_bill = total_bill WHERE id = patient_id;
RETURN total_bill;
END;

