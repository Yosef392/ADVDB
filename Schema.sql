create table Patients(
    id  int primary key ,
    name varchar(100) not null,
    date_of_birth date,
    status varchar(100), --current status (admitted, discharged,)
    toatal_bill number(12,2) DEFAULT 0
);


create table Doctors (
    id              int PRIMARY KEY,
    name            varchar(100) not null,
    specialty       varchar(100),
);

create table Available_Hours(
    id              int primary key,
    doctor_id       number references Doctors(id) on delete set null,
    weekday         varchar2(10),
    hours_avaliable number
);

create table Appointments (
    id              int primary key,
    patient_id      number references Patients(id) on delete set null,
    doctor_id       number references Doctors(id) on delete set null,
    appointment_date date,
    status          varchar(100)  -- scheduled, completed, canceled
);

create table ptreatments (
id  int    primary key,
patient_id      number references Patients(id) on delete set null,
doctor_id       number references Doctors(id) on delete set null,
treatment_description varchar2(1000),
cost number(10,2)
);

create table Rooms (
    id int primary key,
    type varchar(100),
    capacity number ,
    availability varchar(100) 
);


create table AuditTrail (
id int primary key ,
table_name varchar(100),
operation   varchar(100),
old_data    CLOB,
new_data    CLOB,
timestamp   TIMESTAMP DEFAULT SYSTIMESTAMP,
who_performed varchar(100)
);

create table Warnings(
    id            int  primary key,
    patient_id    int references Patients(id),
    warning_reason varchar(1000),
    warning_date  DATE DEFAULT SYSDATE
);








