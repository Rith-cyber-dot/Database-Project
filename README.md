# Hospital Management System (HMS)

A relational database project designed to manage hospital operations, including patient registration, doctor appointments, diagnoses, prescriptions, hospital admissions, and billing.

## 1. Project Overview

The **Hospital Management System (HMS)** is a database project developed to organize and manage hospital information in one centralized system.

In traditional hospital workflows, patient records, appointments, prescriptions, and billing information may be stored separately. This can lead to inconsistent data, disconnected records, and inefficient information retrieval.

This project uses a relational database to connect these records, maintain data consistency, and support hospital operations through structured SQL queries.

**Main objective:** Follow a patient's journey from registration to treatment, admission (if necessary), and payment while keeping related information connected and consistent.

## 2. Project Objectives

- Centralize hospital information in a relational database.
- Maintain accurate patient and doctor records.
- Manage appointments and prevent doctor double-booking.
- Record diagnoses and prescribed medicines.
- Track hospital rooms and patient admissions.
- Manage billing and payment statuses.
- Support efficient data retrieval through SQL queries.

## 3. System Users

The system considers six main user roles:

| User | Responsibilities |
|---|---|
| Receptionist | Register patients, manage appointments, and handle admissions. |
| Doctor | View patient history, record diagnoses, and prescribe medicines. |
| Nurse | Check room availability and monitor admissions. |
| Pharmacist | View prescriptions and manage medicine stock. |
| Billing Clerk | Generate bills and update payment records. |
| Administrator | Manage departments, doctors, and hospital information. |

## 4. Database Structure

The database consists of **10 main entities (tables)** organized into three functional areas.

### 4.1 People and Departments

| Entity | Description |
|---|---|
| Patient | Stores patient information and personal details. |
| Department | Organizes doctors according to their specialties. |
| Doctor | Stores doctor information and department assignments. |

### 4.2 Treatment and Medication

| Entity | Description |
|---|---|
| Appointment | Records visits between patients and doctors. |
| Diagnosis | Stores medical findings associated with appointments. |
| Medicine | Maintains the hospital's medicine catalog and stock. |
| Prescription | Connects diagnoses with prescribed medicines, including dosage and duration. |

### 4.3 Admission and Billing

| Entity | Description |
|---|---|
| Room | Stores hospital room information, capacity, and room type. |
| Admission | Records patient stays, room assignments, and discharge dates. |
| Billing | Stores patient charges and payment information. |

## 5. Entity Relationships

The database uses primary keys (PK) and foreign keys (FK) to maintain relationships between entities.

Key relationships include:

- One Department has many Doctors.
- One Patient can have many Appointments.
- One Doctor can handle many Appointments.
- One Appointment has at most one Diagnosis.
- One Diagnosis can have multiple Prescriptions.
- One Medicine can appear in multiple Prescriptions.
- One Patient can have multiple Admissions.
- One Room can have multiple Admissions over time.
- One Patient can have multiple Billing records.

**Many-to-many relationship:** Diagnosis and Medicine are connected through the Prescription junction table.

## 6. Hospital Workflow

The system follows two main patient journeys.

### Outpatient Workflow

1. Patient registration
2. Appointment booking
3. Doctor consultation
4. Diagnosis recording
5. Medicine prescription
6. Pharmacy processing
7. Billing and payment

### Inpatient Workflow

When a patient requires further treatment or observation:

1. Patient admission
2. Room assignment
3. Medical care and treatment
4. Discharge recording
5. Final billing and payment

## 7. Technologies

| Technology | Purpose |
|---|---|
| MySQL | Relational database management system |
| SQL | Database creation, manipulation, and querying |
| ERDPlus | Entity Relationship Diagram and Relational Model design |
| Git & GitHub | Version control and project collaboration |

## 8. Project Structure

```text
Database-Project/
│
├── DDL & DML/
│   └── SQL (DDL).sql
│
├── ERD and RM/
│   ├── ERD.erdplus
│   ├── RM.erdplus
│   └── Requirement Analyse.pdf
│
├── Reference/
│   ├── ENTITY explain.pdf
│   ├── PLAN.pdf
│   ├── Requirement Analyse.pdf
│   ├── Why using Database.pdf
│   └── Work flow.pdf
│
├── Hospital database requirements.pptx
├── Requirement Presentation Script.pdf
├── hospital_database_talk_overview.png
│
└── README.md
```

## 9. Database Setup

**Prerequisite:** MySQL Server and a MySQL client such as MySQL Workbench.

### Step 1: Clone the repository

```bash
git clone https://github.com/Rith-cyber-dot/Database-Project.git
```

### Step 2: Open the project

Open the downloaded project directory.

### Step 3: Open the SQL script

Navigate to:

```text
DDL & DML/SQL (DDL).sql
```

Open the file in MySQL Workbench.

### Step 4: Review and execute

Review the SQL script before execution.

**Important:** The current DDL is an initial draft generated from ERDPlus. Some data types, attributes, and constraints still require correction. It should not yet be considered the finalized database implementation.

The DML implementation and sample data are also part of the planned development work.

## 10. Project Requirements and Deliverables

The project targets the following academic requirements:

- At least 8 database tables.
- At least 25 records in each table.
- Primary keys and foreign keys.
- Appropriate data types and integrity constraints.
- INSERT, UPDATE, and DELETE operations.
- 5–8 meaningful SELECT queries.
- Database implementation screenshots.
- Project documentation and English presentation slides.

## 11. Development Status

| Component | Status |
|---|---|
| Requirement Analysis | Completed |
| Entity Relationship Diagram | Initial design completed |
| Relational Model | Initial design completed |
| DDL Implementation | In progress |
| DML and Sample Data | Pending |
| SELECT Queries | Pending |
| Testing and Validation | Pending |
| Final Report | Pending |
| Presentation Slides | Pending |

## 12. Project Scope

This project focuses on the database design and SQL implementation of a simplified Hospital Management System.

It is an academic database project, not a complete production hospital application. Advanced features such as insurance processing, laboratory management, and user-interface development are outside the current scope.

All sample patient information should be fictional.

---

**Project:** Hospital Management System  
**Category:** Database Design and Analysis  
**Database:** MySQL  
**Repository:** [GitHub - Database Project](https://github.com/Rith-cyber-dot/Database-Project)
