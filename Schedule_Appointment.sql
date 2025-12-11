Create Sequence Appoinment_ID start with 1 increment by 1;
    
Create or replace procedure Schedule_Appointment(Patient_ID int,APP_Doctor_ID int,Appoinment_Date DATE) AS
    App_WeekDay varchar2(10);
    Avaliable number;
begin
    App_WeekDay  := TO_CHAR(Appoinment_Date,'FMDAY');
    select count(*) into Avaliable FROM Available_Hours where doctor_id = APP_Doctor_ID and
    ( App_WeekDay = weekday 
    and
    hours_avaliable > 0
    );
    if Avaliable > 0
    then
        insert into appointments values (Appoinment_ID.NEXTVAL,Patient_ID,APP_Doctor_ID,Appoinment_Date,'Scheduled');
        update Available_Hours set hours_avaliable = hours_avaliable - 1 where  doctor_id = APP_Doctor_ID and weekday = App_WeekDay;
        DBMS_OUTPUT.PUT_LINE('Appointment scheduled successfully.');
    else
        DBMS_OUTPUT.PUT_LINE('Doctor Unavailable on ' || App_WeekDay);
    END IF;
end;
/