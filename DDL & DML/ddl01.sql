-- ==========================================
-- HOSPITAL MANAGEMENT SYSTEM - MYSQL DDL (revised)
-- ==========================================

CREATE DATABASE hospital_management_system;
USE hospital_management_system;

CREATE TABLE departments (
    -- UNSIGNED = no negative ids; AUTO_INCREMENT starts them at 1
    dept_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    dept_name       VARCHAR(120) NOT NULL,
    dept_location   VARCHAR(150) NULL,
    -- VARCHAR because an INT would drop leading zeros
    phone_number    VARCHAR(30) NULL,
    -- TRUE = active, FALSE = not active
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    -- time and date when the row was inserted
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (dept_id),
    -- no duplicate department names
    -- CONSTRAINT <name> is optional: it names the rule for clearer errors and easier ALTER/DROP later
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
        -- syncs dept_id updates; blocks deleting a department while doctors still reference it
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE patients (
    patient_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_name    VARCHAR(120) NOT NULL,
    gender          ENUM('Female', 'Male', 'Other') NOT NULL,
    date_of_birth   DATE NOT NULL,
    phone_number    VARCHAR(30) NULL,
    -- TEXT is better suited for long addresses
    address         TEXT NULL,
    blood_type      ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NULL,
    -- when the patient profile was first registered
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (patient_id)
);

CREATE TABLE appointments (
    appointment_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id             INT UNSIGNED NOT NULL,
    doctor_id              INT UNSIGNED NOT NULL,
    appointment_date       DATE NOT NULL,
    appointment_start_time TIME NOT NULL,
    appointment_end_time   TIME NOT NULL,
    status                 ENUM('Scheduled','Checked-In','Completed','Cancelled','No-Show')
                           NOT NULL DEFAULT 'Scheduled',
    -- NULL when cancelled/no-show so the slot can be rebooked
    slot_reserved          TINYINT GENERATED ALWAYS AS (
                               CASE WHEN status IN ('Cancelled','No-Show')
                                    THEN NULL ELSE 1 END
                           ) STORED,
    created_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (appointment_id),
    CONSTRAINT chk_appointments_time
        CHECK (appointment_end_time > appointment_start_time),
    CONSTRAINT uq_doctor_timeslot
        UNIQUE (doctor_id,  appointment_date, appointment_start_time, slot_reserved),
    CONSTRAINT uq_patient_timeslot
        UNIQUE (patient_id, appointment_date, appointment_start_time, slot_reserved),
    CONSTRAINT fk_appointments_patient
        FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointments_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctors (doctor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE diagnoses (
    diagnosis_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    appointment_id  INT UNSIGNED NOT NULL,
    diagnosis_name  VARCHAR(255) NOT NULL,
    notes           TEXT NULL,
    diagnosis_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (diagnosis_id),
    CONSTRAINT fk_diagnoses_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE medicines (
    medicine_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    medicine_name   VARCHAR(150) NOT NULL,
    unit_price      DECIMAL(10, 2) NOT NULL,
    dosage_form     VARCHAR(50) NOT NULL,
    stock_qty       INT UNSIGNED NOT NULL DEFAULT 0,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (medicine_id),
    CONSTRAINT uq_medicines_name UNIQUE (medicine_name),
    CONSTRAINT chk_medicines_unit_price CHECK (unit_price >= 0)
);

CREATE TABLE prescriptions (
    prescription_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    diagnosis_id    INT UNSIGNED NOT NULL,
    prescribed_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    -- price at the time of prescribing (snapshot of medicines.unit_price)
    unit_price           DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (prescription_item_id),
    CONSTRAINT uq_prescription_medicine UNIQUE (prescription_id, medicine_id),
    -- prescribed quantity must be at least 1
    CONSTRAINT chk_rx_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_rx_items_unit_price CHECK (unit_price >= 0),
    -- links each item to an existing prescription (items are deleted with their prescription)
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
    room_type       ENUM('General', 'Private', 'Semi-Private', 'ICU', 'Operating', 'Emergency') NOT NULL,
    -- total number of beds the room can hold
    bed_count       INT UNSIGNED NOT NULL,
    -- room charge per day for inpatient stays
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
    doctor_id       INT UNSIGNED NOT NULL,
    reason          VARCHAR(255) NOT NULL,
    admit_date      DATE NOT NULL DEFAULT (CURRENT_DATE),
    discharge_date  DATE NULL,
    -- 1 while still admitted, NULL after discharge: lets a patient have only one open admission
    is_open         TINYINT GENERATED ALWAYS AS (
                        CASE WHEN discharge_date IS NULL THEN 1 ELSE NULL END
                    ) STORED,
    PRIMARY KEY (admission_id),
    CONSTRAINT uq_patient_open_admission UNIQUE (patient_id, is_open),
    CONSTRAINT chk_discharge_after_admit
        CHECK (discharge_date IS NULL OR discharge_date >= admit_date),
    CONSTRAINT fk_admissions_patient
        FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_admissions_room
        FOREIGN KEY (room_id) REFERENCES rooms (room_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_admissions_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctors (doctor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE bills (
    bill_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id      INT UNSIGNED NOT NULL,
    appointment_id  INT UNSIGNED NULL,
    admission_id    INT UNSIGNED NULL,
    total_amount    DECIMAL(12, 2) NOT NULL,
    bill_date       DATE NOT NULL DEFAULT (CURRENT_DATE),
    -- 'Void' marks an erroneous or cancelled bill that should be ignored without deleting the audit record
    payment_status  ENUM('Unpaid', 'Partially Paid', 'Paid', 'Refunded', 'Void') NOT NULL DEFAULT 'Unpaid',
    PRIMARY KEY (bill_id),
    CONSTRAINT chk_bills_total_amount CHECK (total_amount >= 0),
    CONSTRAINT fk_bills_patient
        FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_bills_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_bills_admission
        FOREIGN KEY (admission_id) REFERENCES admissions (admission_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);
