create or replace procedure generate_performace_report
as

    CURSOR admission_cursor IS
    select count(id) from MANAGER.AuditTrail where operation = 'ADMIT_PATIENT';
    total_admissions number;

    CURSOR discharge_cursor IS
    select count(id) from MANAGER.AuditTrail where operation = 'DISCHARGE';
    total_discharges number;

    CURSOR top_doctors_cursor IS
    select d.id, count(d.id) as treatments_count from Manager.Doctors d join Manager.treatments t on d.id = t.doctor_id GROUP BY d.id order by count(d.id) ;
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

    OPEN discharge_cursor;
    DBMS_OUTPUT.PUT_LINE ('Top 3 Doctors: \n');
    loop
        FETCH top_doctors_cursor into top_doctors;
        EXIT WHEN top_doctors_cursor %ROWCOUNT > 3;
        DBMS_OUTPUT.PUT_LINE (top_doctors.id || ' ' || top_doctors.treatments_count || ' Treatments');
    end loop;
    close top_doctors_cursor;
end;
/

EXEC generate_performace_report;

