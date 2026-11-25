create database Hospital_management_system;
use Hospital_management_system;

CREATE TABLE PATIENT
(
  patient_ID INT NOT NULL,
  patient_name varchar(100) NOT NULL,
  gender varchar(20) NOT NULL,
  phone_number INT NOT NULL,
  address varchar(100) NOT NULL,
  blood_type varchar(100) NOT NULL,
  PRIMARY KEY (patient_ID)
);

-- Below DDL is not accurate yet, mostly is its datatype of each attribule is wrong!! --
CREATE TABLE DEPARTMENT
(
  dept_ID INT NOT NULL,
  dept_name INT NOT NULL,
  dept_location INT NOT NULL,
  dept_phoneNumber INT NOT NULL,
  PRIMARY KEY (dept_ID)
);

CREATE TABLE DOCTOR
(
  doctor_ID INT NOT NULL,
  doctor_name INT NOT NULL,
  specialization INT NOT NULL,
  phone_number INT NOT NULL,
  email INT NOT NULL,
  dept_ID INT NOT NULL,
  PRIMARY KEY (doctor_ID),
  FOREIGN KEY (dept_ID) REFERENCES DEPARTMENT(dept_ID)
);

CREATE TABLE APPOINTMENT
(
  appointment_ID INT NOT NULL,
  appoint_time INT NOT NULL,
  appoint_date INT NOT NULL,
  status INT NOT NULL,
  patient_ID INT NOT NULL,
  doctor_ID INT NOT NULL,
  PRIMARY KEY (appointment_ID),
  FOREIGN KEY (patient_ID) REFERENCES PATIENT(patient_ID),
  FOREIGN KEY (doctor_ID) REFERENCES DOCTOR(doctor_ID)
);

CREATE TABLE DIAGNOSIS
(
  diagnosis INT NOT NULL,
  notes INT NOT NULL,
  diagnosis_date INT NOT NULL,
  diagnosis_ID INT NOT NULL,
  appointment_ID INT NOT NULL,
  PRIMARY KEY (diagnosis_ID),
  FOREIGN KEY (appointment_ID) REFERENCES APPOINTMENT(appointment_ID)
);

CREATE TABLE MEDICINE
(
  medicine_ID INT NOT NULL,
  name INT NOT NULL,
  unit_price INT NOT NULL,
  stock_qty_ INT NOT NULL,
  PRIMARY KEY (medicine_ID)
);

CREATE TABLE PRESCRIPTION
(
  prescription_ID INT NOT NULL,
  diagnosis_ID INT NOT NULL,
  medicine_ID INT NOT NULL,
  PRIMARY KEY (prescription_ID),
  FOREIGN KEY (diagnosis_ID) REFERENCES DIAGNOSIS(diagnosis_ID),
  FOREIGN KEY (medicine_ID) REFERENCES MEDICINE(medicine_ID)
);

CREATE TABLE ROOM
(
  room_ID INT NOT NULL,
  room_number INT NOT NULL,
  room_type INT NOT NULL,
  bed_count INT NOT NULL,
  PRIMARY KEY (room_ID),
  UNIQUE (room_number)
);

CREATE TABLE ADMISSION
(
  addmission_ID INT NOT NULL,
  patient_ID_(FK) INT NOT NULL,
  room_ID_(FK) INT NOT NULL,
  admit_date INT NOT NULL,
  discharge_date INT NOT NULL,
  room_ID INT NOT NULL,
  patient_ID INT NOT NULL,
  PRIMARY KEY (addmission_ID),
  FOREIGN KEY (room_ID) REFERENCES ROOM(room_ID),
  FOREIGN KEY (patient_ID) REFERENCES PATIENT(patient_ID)
);

CREATE TABLE BILLING
(
  bii_ID INT NOT NULL,
  total_amount INT NOT NULL,
  bill_date INT NOT NULL,
  payment_status INT NOT NULL,
  patient_ID INT NOT NULL,
  PRIMARY KEY (bii_ID),
  FOREIGN KEY (patient_ID) REFERENCES PATIENT(patient_ID)
);