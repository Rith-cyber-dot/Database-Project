CREATE DATABASE hospital_management_system;
USE hospital_management_system;

CREATE TABLE Department (
    dept_ID           INT          NOT NULL,
    dept_name         VARCHAR(100) NOT NULL,
    dept_location     VARCHAR(100),
    dept_phoneNumber  VARCHAR(20),
    CONSTRAINT pk_department       PRIMARY KEY (dept_ID),
    CONSTRAINT uq_department_name  UNIQUE (dept_name),
    CONSTRAINT uq_department_phone UNIQUE (dept_phoneNumber)
);

CREATE TABLE Doctor (
    doctor_ID       INT          NOT NULL,
    doctor_name     VARCHAR(100) NOT NULL,
    specialization  VARCHAR(100),
    phone_number    VARCHAR(20),
    email           VARCHAR(100),
    dept_ID         INT          NOT NULL,
    CONSTRAINT pk_doctor       PRIMARY KEY (doctor_ID),
    CONSTRAINT uq_doctor_email UNIQUE (email),
    CONSTRAINT uq_doctor_phone UNIQUE (phone_number),
    CONSTRAINT ck_doctor_email CHECK (email IS NULL OR email LIKE '%_@_%._%'),
    CONSTRAINT fk_doctor_dept  FOREIGN KEY (dept_ID) REFERENCES Department(dept_ID)
);

CREATE TABLE Patient (
    patient_ID     INT          NOT NULL,
    patient_name   VARCHAR(100) NOT NULL,
    gender         VARCHAR(10),
    date_of_birth  DATE,
    phone_number   VARCHAR(20),
    address        VARCHAR(255),
    blood_type     VARCHAR(3),
    CONSTRAINT pk_patient        PRIMARY KEY (patient_ID),
    CONSTRAINT uq_patient_phone  UNIQUE (phone_number),
    CONSTRAINT ck_patient_gender CHECK (gender IN ('Male','Female','Other')),
    CONSTRAINT ck_patient_blood  CHECK (blood_type IN ('A+','A-','B+','B-','AB+','AB-','O+','O-'))
);

CREATE TABLE Appointment (
    appointment_ID  INT         NOT NULL,
    appoint_time    TIME        NOT NULL,
    appoint_date    DATE        NOT NULL,
    doctor_ID       INT         NOT NULL,
    patient_ID      INT         NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT pk_appointment         PRIMARY KEY (appointment_ID),
    CONSTRAINT uq_appointment_slot    UNIQUE (doctor_ID, appoint_date, appoint_time),
    CONSTRAINT ck_appointment_status  CHECK (status IN ('Scheduled','Completed','Cancelled','No-Show')),
    CONSTRAINT fk_appointment_doctor  FOREIGN KEY (doctor_ID)  REFERENCES Doctor(doctor_ID),
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_ID) REFERENCES Patient(patient_ID)
);

CREATE TABLE Diagnosis (
    diagnosis_ID    INT          NOT NULL,
    diagnosis       VARCHAR(255) NOT NULL,
    notes           TEXT,
    diagnosis_date  DATE         NOT NULL,
    appointment_ID  INT          NOT NULL,
    CONSTRAINT pk_diagnosis             PRIMARY KEY (diagnosis_ID),
    CONSTRAINT fk_diagnosis_appointment FOREIGN KEY (appointment_ID) REFERENCES Appointment(appointment_ID)
);

CREATE TABLE Medicine (
    medicine_ID  INT           NOT NULL,
    name         VARCHAR(100)  NOT NULL,
    unit_price   DECIMAL(10,2) NOT NULL,
    stock_qty    INT           NOT NULL DEFAULT 0,
    CONSTRAINT pk_medicine       PRIMARY KEY (medicine_ID),
    CONSTRAINT uq_medicine_name  UNIQUE (name),
    CONSTRAINT ck_medicine_price CHECK (unit_price >= 0),
    CONSTRAINT ck_medicine_stock CHECK (stock_qty >= 0)
);

CREATE TABLE Prescription (
    prescription_ID  INT         NOT NULL,
    diagnosis_ID     INT         NOT NULL,
    medicine_ID      INT         NOT NULL,
    duration         VARCHAR(50),
    dose             VARCHAR(50),
    CONSTRAINT pk_prescription           PRIMARY KEY (prescription_ID),
    CONSTRAINT uq_prescription_diag_med  UNIQUE (diagnosis_ID, medicine_ID),
    CONSTRAINT fk_prescription_diagnosis FOREIGN KEY (diagnosis_ID) REFERENCES Diagnosis(diagnosis_ID),
    CONSTRAINT fk_prescription_medicine  FOREIGN KEY (medicine_ID)  REFERENCES Medicine(medicine_ID)
);

CREATE TABLE Room (
    room_ID      INT         NOT NULL,
    room_number  VARCHAR(10) NOT NULL,
    room_type    VARCHAR(50),
    bed_count    INT         NOT NULL,
    CONSTRAINT pk_room        PRIMARY KEY (room_ID),
    CONSTRAINT uq_room_number UNIQUE (room_number),
    CONSTRAINT ck_room_beds   CHECK (bed_count > 0)
);

CREATE TABLE Admission (
    addmission_ID   INT  NOT NULL,
    patient_ID      INT  NOT NULL,
    room_ID         INT  NOT NULL,
    admit_date      DATE NOT NULL,
    discharge_date  DATE,
    CONSTRAINT pk_admission         PRIMARY KEY (addmission_ID),
    CONSTRAINT ck_admission_dates   CHECK (discharge_date IS NULL OR discharge_date >= admit_date),
    CONSTRAINT fk_admission_patient FOREIGN KEY (patient_ID) REFERENCES Patient(patient_ID),
    CONSTRAINT fk_admission_room    FOREIGN KEY (room_ID)    REFERENCES Room(room_ID)
);

CREATE TABLE Billing (
    bii_ID          INT           NOT NULL,
    patient_ID      INT           NOT NULL,
    total_amount    DECIMAL(10,2) NOT NULL,
    bill_date       DATE          NOT NULL,
    payment_status  VARCHAR(20)   NOT NULL DEFAULT 'Unpaid',
    CONSTRAINT pk_billing         PRIMARY KEY (bii_ID),
    CONSTRAINT ck_billing_amount  CHECK (total_amount >= 0),
    CONSTRAINT ck_billing_status  CHECK (payment_status IN ('Unpaid','Paid','Partial')),
    CONSTRAINT fk_billing_patient FOREIGN KEY (patient_ID) REFERENCES Patient(patient_ID)
);
