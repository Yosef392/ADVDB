create or replace procedure generate_performace_report()
as

    CURSOR admission_cursor IS
    select id from MANAGER.AuditTrail where operation = 'ADMIT_PATIENT';

    CURSOR discharge_cursor IS
    select id from MANAGER.AuditTrail where operation = 'DISCHARGE';

    admissions MANAGER.AuditTrail.id%TYPE;
    total_admissions number;

    discharges MANAGER.AuditTrail.id%TYPE;
    total_discharges number;
    
BEGIN

    OPEN admission_cursor;
    FETCH admission_cursor into admission;
    select count(id) into total_admissions;
    DBMS_OUTPUT.PUT_LINE ('Total Admissions = ' || total_admissions);
    close admission_cursor;

    OPEN discharge_cursor;
    FETCH discharge_cursor into discharge;
    select count(id) into total_discharges;
    DBMS_OUTPUT.PUT_LINE ('Total Discharges = ' || total_discharges);
    close discharge_cursor;
end;
/


