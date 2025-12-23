create or replace procedure generate_performace_report
as

    CURSOR admission_cursor IS
    select count(id) from MANAGER.AuditTrail where operation = 'ADMIT_PATIENT';
    total_admissions number;

    CURSOR discharge_cursor IS
    select count(id) from MANAGER.AuditTrail where operation = 'DISCHARGE';
    total_discharges number;

    CURSOR pateint_stay_cursor IS
    select round(AVG(d.action_date - a.action_date)) as avg_stay_days
    from Manager.AuditTrail a
    JOIN MANAGER.AuditTrail d 
    ON REGEXP_SUBSTR(a.new_data, 'Patient ID: ([0-9]+)...') = REGEXP_SUBSTR(d.new_data, 'Patient ID: ([0-9]+)...')
    where a.operation <> d.operation
    and d.action_date > a.action_date;
    avg_stay_days number;

    CURSOR top_doctors_cursor IS
    select d.name as id, count(d.id) as treatments_count from Manager.Doctors d 
    join Manager.treatments t on d.id = t.doctor_id GROUP BY d.id,d.name order by count(d.id) desc;
    top_doctors top_doctors_cursor%ROWTYPE;

    
BEGIN

    OPEN admission_cursor;
    FETCH admission_cursor into total_admissions;
    DBMS_OUTPUT.PUT_LINE ('Total Admissions = ' || total_admissions);
    close admission_cursor;

    OPEN discharge_cursor;
    FETCH discharge_cursor into total_discharges;
    DBMS_OUTPUT.PUT_LINE ('Total Discharges = ' || total_discharges);
    close discharge_cursor;

    OPEN top_doctors_cursor;
    DBMS_OUTPUT.PUT_LINE ('Top 3 Doctors: ');
    loop
        FETCH top_doctors_cursor into top_doctors;
        EXIT WHEN top_doctors_cursor%ROWCOUNT > 3 OR top_doctors_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE (top_doctors.id || ' ' || top_doctors.treatments_count || ' Treatments');
    end loop;
    close top_doctors_cursor;

    OPEN pateint_stay_cursor;
    FETCH pateint_stay_cursor into avg_stay_days;
    DBMS_OUTPUT.PUT_LINE ('Average patient stay duration (in days) '|| avg_stay_days);
    close pateint_stay_cursor;
end;
/
EXEC generate_performace_report;

