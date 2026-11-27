-- ==========================================
-- HOSPITAL MANAGEMENT SYSTEM - MYSQL DDL
-- ==========================================

CREATE DATABASE hospital_management_system;
USE hospital_management_system;

CREATE TABLE departments (
	-- unsigned is for non-negative id(start from 1)
    dept_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    dept_name       VARCHAR(120) NOT NULL,
    dept_location   VARCHAR(150) NULL,
    -- varchar beccause for INT it will delete 0 at the front automatically
    dept_phone_number     VARCHAR(30) NULL,
    -- can be yes/no (if yes active, otherwise not active)
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    -- to show time and date when you insert new row to the department
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (dept_id),
    -- guarantee each department have unique name, NO DUPLICATE DEPARTMENT NAME
    -- -- CONSTRAINT <name> is optional: it names the rule for clearer errors and easier ALTER/DROP later; omitting it lets MySQL generate a default name
    CONSTRAINT uq_departments_name UNIQUE (dept_name)
);

CREATE TABLE doctors (
    doctor_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    dept_id         INT UNSIGNED NOT NULL,
    doctor_name     VARCHAR(120) NOT NULL,
    specialization  VARCHAR(100) NOT NULL,
    phone_number    VARCHAR(30) NULL,
    email           VARCHAR(150) NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (doctor_id),
    CONSTRAINT uq_doctors_email UNIQUE (email),
    CONSTRAINT fk_doctors_department
        FOREIGN KEY (dept_id) REFERENCES departments (dept_id)
        -- -- Syncs dept_id updates(that mean no manually update); blocks deleting a department while doctors still reference it
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE patients (
    patient_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_name    VARCHAR(120) NOT NULL,
    gender          ENUM('Female', 'Male', 'Other') NOT NULL,
    date_of_birth   DATE NOT NULL,
    phone_number    VARCHAR(30) NULL,
    -- TEXT longer suitable for address
    address         TEXT NULL,
    blood_type      ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NULL,
    -- -- Records the date and time when the patient profile was first registered in the system
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (patient_id)
);

CREATE TABLE appointments (
    appointment_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id            INT UNSIGNED NOT NULL,
    doctor_id             INT UNSIGNED NOT NULL,
    appoint_date          DATE NOT NULL,
    appoint_start_time    TIME NOT NULL,
	appoint_end_time	  TIME NOT NULL,
    -- -- 'No-Show' tracks patients who missed their scheduled slot without cancelling in advance
    status          ENUM('Scheduled', 'CHECK-In', 'Completed', 'Cancelled', 'No-Show') NOT NULL DEFAULT 'Scheduled',
	slot_reserved   TINYINT GENERATED ALWAYS AS (
        CASE WHEN status IN ('Cancelled', 'No-Show') THEN NULL ELSE 1 END
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (appointment_id),
    CONSTRAINT chk_appointments_time CHECK (end_time > start_time),
    -- Prevents double-booking the same doctor at the exact same start slot
    CONSTRAINT uq_doctor_timeslot UNIQUE (doctor_id, appoint_date, start_time, slot_reserved),
    -- Prevents double-booking the same patient at the exact same start slot
    CONSTRAINT uq_patient_timeslot UNIQUE (patient_id, appoint_date, start_time, slot_reserved),
    CONSTRAINT fk_appointments_patient
        FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointments_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctors (doctor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointments_created_by
        FOREIGN KEY (created_by) REFERENCES staff (staff_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE diagnoses (
    diagnosis_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    appointment_id  INT UNSIGNED NOT NULL,
    diagnosis_name       VARCHAR(255) NOT NULL,
    notes           TEXT NULL,
    diagnosis_at    DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY (diagnosis_id),
    CONSTRAINT uq_diagnoses_appointment UNIQUE (appointment_id),
    CONSTRAINT fk_diagnoses_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE medicines (
    medicine_id     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name            VARCHAR(150) NOT NULL,
    unit_price      DECIMAL(10, 2) NOT NULL,
	dosage_form     VARCHAR(50) NOT NULL,
    stock_qty       INT UNSIGNED NOT NULL DEFAULT 0,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (medicine_id),
    CONSTRAINT uq_medicines_name UNIQUE (name),
    CONSTRAINT chk_medicines_unit_price CHECK (unit_price >= 0)
) ;

CREATE TABLE prescriptions (
    prescription_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    diagnosis_id    INT UNSIGNED NOT NULL,
    prescribed_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    instructions    TEXT NULL,
    PRIMARY KEY (prescription_id),
    CONSTRAINT fk_prescriptions_diagnosis
        FOREIGN KEY (diagnosis_id) REFERENCES diagnoses (diagnosis_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE prescription_items (
    prescription_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    prescription_id      INT UNSIGNED NOT NULL,
    medicine_id          INT UNSIGNED NOT NULL,
    dose                 VARCHAR(100) NOT NULL,
    duration             VARCHAR(100) NOT NULL,
    quantity             INT UNSIGNED NOT NULL,
    PRIMARY KEY (prescription_item_id),
    CONSTRAINT uq_prescription_medicine UNIQUE (prescription_id, medicine_id),
    -- -- Ensures prescribed quantity is at least 1
-- Links each prescription item to an existing prescription record
    CONSTRAINT chk_rx_items_quantity CHECK (quantity > 0),
    CONSTRAINT fk_rx_items_prescription
        FOREIGN KEY (prescription_id) REFERENCES prescriptions (prescription_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_rx_items_medicine
        FOREIGN KEY (medicine_id) REFERENCES medicines (medicine_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE rooms (
    room_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    room_number     VARCHAR(30) NOT NULL,
    room_type       VARCHAR(50) NOT NULL,
    -- Total number of beds the room can hold
    bed_count       INT UNSIGNED NOT NULL,
    -- Room charge per day for inpatient stays
    daily_rate      DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (room_id),
    CONSTRAINT uq_rooms_number UNIQUE (room_number),
    CONSTRAINT chk_rooms_bed_count CHECK (bed_count > 0),
    CONSTRAINT chk_rooms_daily_rate CHECK (daily_rate >= 0)
);

CREATE TABLE admissions (
    admission_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id      INT UNSIGNED NOT NULL,
    room_id         INT UNSIGNED NOT NULL,
    admit_date      DATE NOT NULL DEFAULT (CURRENT_DATE),
    discharge_date  DATE NULL,
    PRIMARY KEY (admission_id),
    CONSTRAINT chk_discharge_after_admit
        CHECK (discharge_date IS NULL OR discharge_date >= admit_date),
    CONSTRAINT fk_admissions_patient
        FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_admissions_room
        FOREIGN KEY (room_id) REFERENCES rooms (room_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE billings (
    bill_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id      INT UNSIGNED NOT NULL,
    total_amount    DECIMAL(12, 2) NOT NULL,
    bill_date       DATE NOT NULL DEFAULT (CURRENT_DATE),
    -- -- 'Void' marks an erroneous or cancelled bill that should be ignored without deleting the audit record
    payment_status  ENUM('Unpaid', 'Partially Paid', 'Paid', 'Refunded', 'Void') NOT NULL DEFAULT 'Unpaid',
    PRIMARY KEY (bill_id),
    CONSTRAINT chk_billings_total_amount CHECK (total_amount >= 0),
    CONSTRAINT fk_billings_patient
        FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ;
