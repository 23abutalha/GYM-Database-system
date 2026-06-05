-- ============================================================
-- GYM MANAGEMENT DATABASE INITIALIZATION SCRIPT
-- ============================================================

CREATE DATABASE GymManagementDB;
GO
USE GymManagementDB;
GO

-- ============================================================
-- SECTION 1 : SIMPLIFIED DROP EXISTING TABLES (Safe Re-run)
-- ============================================================

DROP TABLE IF EXISTS dbo.Payments;
DROP TABLE IF EXISTS dbo.Attendance;
DROP TABLE IF EXISTS dbo.ClassEnrollments;
DROP TABLE IF EXISTS dbo.GymClasses;
DROP TABLE IF EXISTS dbo.Equipment;
DROP TABLE IF EXISTS dbo.MemberMemberships;
DROP TABLE IF EXISTS dbo.MembershipPlans;
DROP TABLE IF EXISTS dbo.Members;
DROP TABLE IF EXISTS dbo.Trainers;
DROP TABLE IF EXISTS dbo.Staff;
DROP TABLE IF EXISTS dbo.Branches;
GO

-- ============================================================
-- SECTION 2 : RELATIONAL SCHEMA TABLE CREATION (DDL)
-- ============================================================

CREATE TABLE dbo.Branches (
    BranchID      INT           IDENTITY(1,1) PRIMARY KEY,
    BranchName    VARCHAR(100)  NOT NULL,
    City          VARCHAR(80)   NOT NULL,
    Address       VARCHAR(200)  NOT NULL,
    PhoneNumber   VARCHAR(15)   NOT NULL,
    Email         VARCHAR(100)  NOT NULL UNIQUE,
    OpeningTime   VARCHAR(8)    NOT NULL DEFAULT '06:00',
    ClosingTime   VARCHAR(8)    NOT NULL DEFAULT '22:00',
    MonthlyRent   DECIMAL(10,2) NOT NULL CHECK (MonthlyRent > 0),
    IsActive      BIT           NOT NULL DEFAULT 1
);

CREATE TABLE dbo.Staff (
    StaffID       INT           IDENTITY(1,1) PRIMARY KEY,
    BranchID      INT           NOT NULL REFERENCES dbo.Branches(BranchID),
    FirstName     VARCHAR(60)   NOT NULL,
    LastName      VARCHAR(60)   NOT NULL,
    Role          VARCHAR(50)   NOT NULL CHECK (Role IN ('Manager','Receptionist','Janitor','Security')),
    Salary        DECIMAL(10,2) NOT NULL CHECK (Salary >= 0),
    HireDate      DATE          NOT NULL,
    PhoneNumber   VARCHAR(15)   NOT NULL,
    Email         VARCHAR(100)  NOT NULL UNIQUE,
    IsActive      BIT           NOT NULL DEFAULT 1
);

CREATE TABLE dbo.Trainers (
    TrainerID      INT           IDENTITY(1,1) PRIMARY KEY,
    BranchID       INT           NOT NULL REFERENCES dbo.Branches(BranchID),
    FirstName      VARCHAR(60)   NOT NULL,
    LastName       VARCHAR(60)   NOT NULL,
    Specialization VARCHAR(100)  NOT NULL,
    Experience     INT           NOT NULL CHECK (Experience >= 0),
    Salary         DECIMAL(10,2) NOT NULL CHECK (Salary >= 0),
    PhoneNumber    VARCHAR(15)   NOT NULL,
    Email          VARCHAR(100)  NOT NULL UNIQUE,
    Certification  VARCHAR(100),
    IsActive       BIT           NOT NULL DEFAULT 1
);

CREATE TABLE dbo.Members (
    MemberID         INT           IDENTITY(1,1) PRIMARY KEY,
    BranchID         INT           NOT NULL REFERENCES dbo.Branches(BranchID),
    FirstName        VARCHAR(60)   NOT NULL,
    LastName         VARCHAR(60)   NOT NULL,
    Gender           CHAR(1)       NOT NULL CHECK (Gender IN ('M','F','O')),
    DateOfBirth      DATE          NOT NULL,
    PhoneNumber      VARCHAR(15)   NOT NULL,
    Email            VARCHAR(100)  NOT NULL UNIQUE,
    Address          VARCHAR(200),
    JoinDate         DATE          NOT NULL,
    BloodGroup       VARCHAR(5)    CHECK (BloodGroup IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    EmergencyContact VARCHAR(15)
);

CREATE TABLE dbo.MembershipPlans (
    PlanID        INT           IDENTITY(1,1) PRIMARY KEY,
    PlanName      VARCHAR(80)   NOT NULL UNIQUE,
    DurationDays  INT           NOT NULL CHECK (DurationDays > 0),
    Price         DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Description   VARCHAR(300),
    MaxFreeze     INT           NOT NULL DEFAULT 0 CHECK (MaxFreeze >= 0)
);

CREATE TABLE dbo.MemberMemberships (
    MembershipID  INT           IDENTITY(1,1) PRIMARY KEY,
    MemberID      INT           NOT NULL REFERENCES dbo.Members(MemberID),
    PlanID        INT           NOT NULL REFERENCES dbo.MembershipPlans(PlanID),
    StartDate     DATE          NOT NULL,
    EndDate       DATE          NOT NULL,
    Status        VARCHAR(20)   NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active','Expired','Frozen','Cancelled')),
    FreezeDays    INT           NOT NULL DEFAULT 0 CHECK (FreezeDays >= 0)
);

CREATE TABLE dbo.GymClasses (
    ClassID       INT           IDENTITY(1,1) PRIMARY KEY,
    BranchID      INT           NOT NULL REFERENCES dbo.Branches(BranchID),
    TrainerID     INT           NOT NULL REFERENCES dbo.Trainers(TrainerID),
    ClassName     VARCHAR(100)  NOT NULL,
    ClassType     VARCHAR(60)   NOT NULL CHECK (ClassType IN ('Yoga','Zumba','CrossFit','Pilates','Boxing','Cycling','Strength','Cardio')),
    ScheduleDay   VARCHAR(10)   NOT NULL CHECK (ScheduleDay IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')),
    StartTime     VARCHAR(8)    NOT NULL,
    EndTime       VARCHAR(8)    NOT NULL,
    MaxCapacity   INT           NOT NULL CHECK (MaxCapacity > 0),
    RoomNumber    VARCHAR(10)
);

CREATE TABLE dbo.ClassEnrollments (
    EnrollmentID  INT           IDENTITY(1,1) PRIMARY KEY,
    ClassID       INT           NOT NULL REFERENCES dbo.GymClasses(ClassID),
    MemberID      INT           NOT NULL REFERENCES dbo.Members(MemberID),
    EnrollDate    DATE          NOT NULL,
    Status        VARCHAR(20)   NOT NULL DEFAULT 'Enrolled' CHECK (Status IN ('Enrolled','Dropped','Completed')),
    CONSTRAINT UQ_ClassMember UNIQUE (ClassID, MemberID)
);

CREATE TABLE dbo.Equipment (
    EquipmentID   INT           IDENTITY(1,1) PRIMARY KEY,
    BranchID      INT           NOT NULL REFERENCES dbo.Branches(BranchID),
    EquipmentName VARCHAR(100)  NOT NULL,
    Category      VARCHAR(60)   NOT NULL CHECK (Category IN ('Cardio','Strength','Flexibility','Recovery','Free Weights')),
    PurchaseDate  DATE          NOT NULL,
    Condition     VARCHAR(20)   NOT NULL DEFAULT 'Good' CHECK (Condition IN ('Excellent','Good','Fair','Under Repair','Retired')),
    PurchasePrice DECIMAL(10,2) NOT NULL CHECK (PurchasePrice >= 0),
    WarrantyYears INT           NOT NULL DEFAULT 1 CHECK (WarrantyYears >= 0)
);

CREATE TABLE dbo.Attendance (
    AttendanceID  INT           IDENTITY(1,1) PRIMARY KEY,
    MemberID      INT           NOT NULL REFERENCES dbo.Members(MemberID),
    BranchID      INT           NOT NULL REFERENCES dbo.Branches(BranchID),
    CheckInDate   DATE          NOT NULL,
    CheckInTime   VARCHAR(8)    NOT NULL,
    CheckOutTime  VARCHAR(8),
    Notes         VARCHAR(200)
);

CREATE TABLE dbo.Payments (
    PaymentID     INT           IDENTITY(1,1) PRIMARY KEY,
    MemberID      INT           NOT NULL REFERENCES dbo.Members(MemberID),
    MembershipID  INT           NOT NULL REFERENCES dbo.MemberMemberships(MembershipID),
    Amount        DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    PaymentDate   DATE          NOT NULL,
    PaymentMethod VARCHAR(30)   NOT NULL CHECK (PaymentMethod IN ('Cash','Credit Card','Debit Card','Bank Transfer','Online')),
    Status        VARCHAR(20)   NOT NULL DEFAULT 'Completed' CHECK (Status IN ('Completed','Pending','Refunded','Failed')),
    ReferenceNo   VARCHAR(50)
);
GO

-- ============================================================
-- SECTION 3 : DATA POPULATION (DML)
-- ============================================================

BEGIN TRANSACTION;
BEGIN TRY

-- Branches (5 records)
INSERT INTO dbo.Branches (BranchName, City, Address, PhoneNumber, Email, OpeningTime, ClosingTime, MonthlyRent) VALUES
('FitZone Central',   'Lahore',     '12-A Main Boulevard, Gulberg III',    '042-35771001', 'central@fitzone.pk',   '05:30', '23:00', 180000.00),
('FitZone DHA',       'Lahore',     'Plot 45, Phase 5, DHA',               '042-35882002', 'dha@fitzone.pk',       '06:00', '22:30', 210000.00),
('FitZone Blue Area', 'Islamabad',  'Shop 9, Jinnah Avenue, Blue Area',    '051-28834003', 'bluearea@fitzone.pk',  '06:00', '22:00', 250000.00),
('FitZone Johar',     'Karachi',    '3rd Floor, Ocean Mall, Johar Town',   '021-34455004', 'johar@fitzone.pk',     '07:00', '22:00', 195000.00),
('FitZone Cantt',     'Rawalpindi', 'Mall Road, Saddar Cantt',             '051-55276005', 'cantt@fitzone.pk',     '06:30', '21:30', 160000.00);

-- Staff (8 records)
INSERT INTO dbo.Staff (BranchID, FirstName, LastName, Role, Salary, HireDate, PhoneNumber, Email) VALUES
(1, 'Nadia',  'Akhtar',   'Manager',      95000.00, '2020-03-01', '0300-1112233', 'nadia.akhtar@fitzone.pk'),
(1, 'Faisal', 'Raza',     'Receptionist', 45000.00, '2021-06-15', '0301-2223344', 'faisal.raza@fitzone.pk'),
(2, 'Sana',   'Mehmood',  'Manager',      92000.00, '2019-11-20', '0302-3334455', 'sana.mehmood@fitzone.pk'),
(2, 'Usman',  'Tariq',    'Receptionist', 44000.00, '2022-01-10', '0303-4445566', 'usman.tariq@fitzone.pk'),
(3, 'Hina',   'Zaidi',    'Manager',      98000.00, '2018-07-05', '0304-5556677', 'hina.zaidi@fitzone.pk'),
(4, 'Bilal',  'Chaudhry', 'Manager',      90000.00, '2021-02-28', '0305-6667788', 'bilal.chaudhry@fitzone.pk'),
(5, 'Amna',   'Sheikh',   'Manager',      88000.00, '2020-09-12', '0306-7778899', 'amna.sheikh@fitzone.pk'),
(1, 'Khalid', 'Hussain',  'Security',     38000.00, '2022-05-01', '0307-8889900', 'khalid.hussain@fitzone.pk');

-- Trainers (8 records)
INSERT INTO dbo.Trainers (BranchID, FirstName, LastName, Specialization, Experience, Salary, PhoneNumber, Email, Certification) VALUES
(1, 'Ahmed',  'Nawaz',    'CrossFit & Strength',     6, 75000.00, '0310-1010101', 'ahmed.nawaz@fitzone.pk',    'NASM-CPT'),
(1, 'Zara',   'Ali',      'Yoga & Pilates',           4, 68000.00, '0311-2020202', 'zara.ali@fitzone.pk',       'RYT-200'),
(2, 'Tariq',  'Butt',     'Cardio & Zumba',           5, 70000.00, '0312-3030303', 'tariq.butt@fitzone.pk',     'ACE-GFI'),
(2, 'Maira',  'Qureshi',  'Boxing & MMA',             7, 80000.00, '0313-4040404', 'maira.qureshi@fitzone.pk',  'ISSA-PT'),
(3, 'Hamid',  'Lodhi',    'Cycling & Cardio',         3, 65000.00, '0314-5050505', 'hamid.lodhi@fitzone.pk',    'SPIN-Cert'),
(3, 'Rabia',  'Siddiqui', 'Strength & Conditioning',  8, 85000.00, '0315-6060606', 'rabia.siddiqui@fitzone.pk', 'CSCS'),
(4, 'Adnan',  'Malik',    'Yoga & Flexibility',       5, 69000.00, '0316-7070707', 'adnan.malik@fitzone.pk',    'RYT-500'),
(5, 'Sadia',  'Javed',    'CrossFit & Boxing',        4, 72000.00, '0317-8080808', 'sadia.javed@fitzone.pk',    'CF-L1');

-- Members (15 records)
INSERT INTO dbo.Members (BranchID, FirstName, LastName, Gender, DateOfBirth, PhoneNumber, Email, Address, JoinDate, BloodGroup, EmergencyContact) VALUES
(1,'Ali',     'Hassan',   'M','1995-04-12','0320-0000001','ali.hassan@mail.com',   'House 5, Gulberg II',    '2023-01-15','O+', '0300-1234561'),
(1,'Sara',    'Khan',     'F','1998-07-22','0320-0000002','sara.khan@mail.com',    'Flat 3B, Garden Town',   '2023-02-01','A+', '0300-1234562'),
(1,'Omer',    'Farooq',   'M','1993-11-05','0320-0000003','omer.farooq@mail.com',  '22 Johar Town',          '2023-03-10','B+', '0300-1234563'),
(2,'Ayesha',  'Noor',     'F','2000-01-30','0320-0000004','ayesha.noor@mail.com',  'DHA Phase 6 Blk C',      '2023-01-20','AB+','0300-1234564'),
(2,'Kamran',  'Riaz',     'M','1990-09-14','0320-0000005','kamran.riaz@mail.com',  'Plot 77 DHA Phase 2',    '2023-04-05','O-', '0300-1234565'),
(3,'Fatima',  'Imran',    'F','1997-03-18','0320-0000006','fatima.imran@mail.com', 'F-8/2 Islamabad',        '2023-05-01','B-', '0300-1234566'),
(3,'Zain',    'Ul Abdin', 'M','1996-12-25','0320-0000007','zain.ulabdin@mail.com', 'G-10 Islamabad',         '2023-05-15','A-', '0300-1234567'),
(4,'Maryam',  'Baig',     'F','1999-08-08','0320-0000008','maryam.baig@mail.com',  'Clifton Block 5',        '2023-06-01','O+', '0300-1234568'),
(4,'Haris',   'Ahmed',    'M','1994-06-17','0320-0000009','haris.ahmed@mail.com',  'North Nazimabad',        '2023-06-20','AB-','0300-1234569'),
(5,'Saba',    'Perveen',  'F','2001-02-14','0320-0000010','saba.perveen@mail.com', 'Cantt View Apts',        '2023-07-01','A+', '0300-1234560'),
(1,'Danial',  'Yousuf',   'M','1992-05-29','0320-0000011','danial.yousuf@mail.com','100-B Model Town Ext',   '2023-07-15','B+', '0300-1234511'),
(2,'Nida',    'Waqar',    'F','1999-10-10','0320-0000012','nida.waqar@mail.com',   'DHA Phase 8 Ext',        '2023-08-01','O+', '0300-1234512'),
(3,'Umar',    'Shafiq',   'M','1988-03-03','0320-0000013','umar.shafiq@mail.com',  'I-8 Islamabad',          '2023-08-20','B-', '0300-1234513'),
(4,'Layla',   'Osman',    'F','2002-11-11','0320-0000014','layla.osman@mail.com',  'Defence Housing Karachi','2023-09-05','A-', '0300-1234514'),
(5,'Shahzad', 'Mirza',    'M','1991-07-07','0320-0000015','shahzad.mirza@mail.com','Rawalpindi Cantt',       '2023-09-25','O-', '0300-1234515');

-- Membership Plans (6 records)
INSERT INTO dbo.MembershipPlans (PlanName, DurationDays, Price, Description, MaxFreeze) VALUES
('Monthly Basic',     30,  5000.00,  'Gym access only, no classes',         3),
('Monthly Premium',   30,  8500.00,  'Gym + unlimited group classes',        5),
('Quarterly Basic',   90,  13500.00, 'Gym access for 3 months',             7),
('Quarterly Premium', 90,  22000.00, 'Gym + classes for 3 months',          10),
('Annual Basic',      365, 48000.00, 'Full-year gym access',                14),
('Annual Premium',    365, 72000.00, 'Full-year gym + all classes + PT',    20);

-- Member Memberships (20 records)
INSERT INTO dbo.MemberMemberships (MemberID, PlanID, StartDate, EndDate, Status, FreezeDays) VALUES
(1,2,'2025-01-15','2025-02-14','Expired',0), (1,4,'2025-02-15','2025-05-16','Expired',0),
(2,1,'2025-02-01','2025-03-03','Expired',0), (3,5,'2025-03-10','2026-03-10','Active',0),
(4,2,'2025-01-20','2025-02-19','Expired',0), (5,3,'2025-04-05','2025-07-04','Active',3),
(6,6,'2025-05-01','2026-05-01','Active',0),  (7,1,'2025-05-15','2025-06-14','Expired',0),
(8,4,'2025-06-01','2025-09-01','Active',0),  (9,2,'2025-06-20','2025-07-20','Expired',0),
(10,3,'2025-07-01','2025-09-29','Active',0), (11,6,'2025-07-15','2026-07-15','Active',0),
(12,1,'2025-08-01','2025-08-31','Active',0), (13,5,'2025-08-20','2026-08-20','Active',0),
(14,2,'2025-09-05','2025-10-05','Active',0), (15,4,'2025-09-25','2025-12-24','Active',2),
(2,4,'2025-03-05','2025-06-05','Expired',0), (4,6,'2025-05-01','2026-05-01','Active',0),
(7,3,'2025-07-01','2025-09-29','Active',0),  (9,5,'2025-08-01','2026-08-01','Active',0);

-- Gym Classes (8 records)
INSERT INTO dbo.GymClasses (BranchID, TrainerID, ClassName, ClassType, ScheduleDay, StartTime, EndTime, MaxCapacity, RoomNumber) VALUES
(1,1,'Morning CrossFit',    'CrossFit','Monday',   '07:00','08:00',20,'R-01'),
(1,2,'Evening Yoga',        'Yoga',     'Wednesday','18:00','19:00',15,'R-02'),
(2,3,'Zumba Blast',         'Zumba',    'Tuesday',  '09:00','10:00',25,'R-03'),
(2,4,'Boxing Fundamentals', 'Boxing',   'Thursday', '17:00','18:30',12,'R-04'),
(3,5,'Cycling Power',       'Cycling',  'Friday',   '06:30','07:30',18,'R-05'),
(3,6,'Strength Bootcamp',   'Strength', 'Saturday', '10:00','11:30',16,'R-06'),
(4,7,'Pilates Flow',        'Pilates',  'Monday',   '11:00','12:00',14,'R-07'),
(5,8,'Cardio Burn',         'Cardio',   'Sunday',   '08:00','09:00',22,'R-08');

-- Class Enrollments (20 records)
INSERT INTO dbo.ClassEnrollments (ClassID, MemberID, EnrollDate, Status) VALUES
(1,1,'2025-02-10','Completed'),(1,3,'2025-02-10','Completed'),
(2,2,'2025-03-01','Enrolled'), (2,11,'2025-03-01','Enrolled'),
(3,4,'2025-04-15','Enrolled'), (3,12,'2025-04-15','Enrolled'),
(4,5,'2025-05-01','Enrolled'), (5,6,'2025-05-10','Enrolled'),
(5,13,'2025-05-10','Enrolled'),(6,6,'2025-06-01','Enrolled'),
(7,8,'2025-06-15','Enrolled'), (7,14,'2025-06-15','Enrolled'),
(8,10,'2025-07-01','Enrolled'),(8,15,'2025-07-01','Enrolled'),
(1,11,'2025-07-15','Enrolled'),(2,1,'2025-07-20','Enrolled'),
(3,9,'2025-08-01','Enrolled'), (4,12,'2025-08-05','Enrolled'),
(6,13,'2025-08-10','Enrolled'),(7,9,'2025-08-15','Dropped');

-- Equipment (15 records)
INSERT INTO dbo.Equipment (BranchID, EquipmentName, Category, PurchaseDate, Condition, PurchasePrice, WarrantyYears) VALUES
(1,'Treadmill Pro 3000',      'Cardio',       '2022-01-10','Good',        250000.00,3),
(1,'Olympic Barbell Set',     'Free Weights',  '2021-06-15','Excellent',    85000.00,2),
(1,'Rowing Machine X200',     'Cardio',       '2023-03-20','Excellent',   180000.00,3),
(2,'Leg Press Machine',       'Strength',     '2020-09-05','Fair',        320000.00,5),
(2,'Elliptical Trainer',      'Cardio',       '2022-11-01','Good',        210000.00,3),
(2,'Adjustable Dumbbells',    'Free Weights',  '2023-01-15','Excellent',    95000.00,2),
(3,'Spin Bike Fleet (5)',     'Cardio',       '2023-05-10','Excellent',   375000.00,3),
(3,'Smith Machine',           'Strength',     '2021-08-20','Good',        450000.00,5),
(4,'Cable Crossover Station', 'Strength',     '2022-04-05','Good',        280000.00,4),
(4,'Foam Roller Set',         'Flexibility',  '2023-02-28','Excellent',    25000.00,1),
(5,'Assault Bike',            'Cardio',       '2022-07-14','Good',        155000.00,2),
(5,'Pull-Up Rig',             'Strength',     '2021-12-01','Fair',         95000.00,3),
(1,'Massage Gun Set',         'Recovery',     '2024-01-05','Excellent',    45000.00,1),
(3,'Resistance Band Kit',     'Flexibility',  '2023-09-15','Excellent',    18000.00,1),
(4,'Chest Press Machine',     'Strength',     '2020-06-10','Under Repair', 260000.00,5);

-- Attendance (20 records)
INSERT INTO dbo.Attendance (MemberID, BranchID, CheckInDate, CheckInTime, CheckOutTime) VALUES
(1,1,'2025-03-01','07:05','09:00'), (2,1,'2025-03-01','10:15','11:45'),
(3,1,'2025-03-02','08:00','09:30'), (4,2,'2025-03-02','09:10','10:45'),
(5,2,'2025-03-03','17:05','19:00'), (6,3,'2025-03-03','06:35','08:00'),
(7,3,'2025-03-04','16:50','18:30'), (8,4,'2025-03-04','11:00','12:30'),
(9,4,'2025-03-05','10:00','11:15'), (10,5,'2025-03-05','08:05','09:30'),
(1,1,'2025-03-06','07:00','09:15'), (11,1,'2025-03-06','18:00','20:00'),
(12,2,'2025-03-07','09:00','10:30'),(13,3,'2025-03-07','17:00','18:30'),
(14,4,'2025-03-08','11:15','12:45'),(15,5,'2025-03-08','08:00','09:20'),
(2,1,'2025-03-09','10:00','11:30'), (5,2,'2025-03-10','17:00','18:45'),
(8,4,'2025-03-10','11:00','12:15'), (6,3,'2025-03-11','06:30','07:45');

-- Payments (20 records)
INSERT INTO dbo.Payments (MemberID, MembershipID, Amount, PaymentDate, PaymentMethod, Status, ReferenceNo) VALUES
(1,1,8500.00,'2025-01-15','Credit Card',  'Completed','TXN-10001'),
(1,2,22000.00,'2025-02-15','Bank Transfer','Completed','TXN-10002'),
(2,3,5000.00,'2025-02-01','Cash',         'Completed','TXN-10003'),
(3,4,48000.00,'2025-03-10','Bank Transfer','Completed','TXN-10004'),
(4,5,8500.00,'2025-01-20','Debit Card',   'Completed','TXN-10005'),
(5,6,13500.00,'2025-04-05','Credit Card', 'Completed','TXN-10006'),
(6,7,72000.00,'2025-05-01','Bank Transfer','Completed','TXN-10007'),
(7,8,5000.00,'2025-05-15','Cash',         'Completed','TXN-10008'),
(8,9,22000.00,'2025-06-01','Online',      'Completed','TXN-10009'),
(9,10,8500.00,'2025-06-20','Credit Card', 'Completed','TXN-10010'),
(10,11,13500.00,'2025-07-01','Cash',      'Completed','TXN-10011'),
(11,12,72000.00,'2025-07-15','Bank Transfer','Completed','TXN-10012'),
(12,13,5000.00,'2025-08-01','Debit Card', 'Completed','TXN-10013'),
(13,14,48000.00,'2025-08-20','Credit Card','Completed','TXN-10014'),
(14,15,8500.00,'2025-09-05','Online',     'Completed','TXN-10015'),
(15,16,22000.00,'2025-09-25','Bank Transfer','Completed','TXN-10016'),
(2,17,22000.00,'2025-03-05','Credit Card','Completed','TXN-10017'),
(4,18,72000.00,'2025-05-01','Online',     'Completed','TXN-10018'),
(7,19,13500.00,'2025-07-01','Cash',       'Completed','TXN-10019'),
(9,20,48000.00,'2025-08-01','Bank Transfer','Completed','TXN-10020');

COMMIT TRANSACTION;
    PRINT 'Database initialization and data loading completed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back due to error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Restore message counters for SELECT analysis output views
SET NOCOUNT OFF; 
GO 

-- ============================================================
-- SECTION 4 : SYSTEM DATA QUERIES
-- ============================================================

-- Q-01: List all members and their branch details
SELECT m.MemberID, m.FirstName + ' ' + m.LastName AS FullName,
       m.Gender, m.PhoneNumber, b.BranchName, b.City
FROM   dbo.Members m
JOIN   dbo.Branches b ON b.BranchID = m.BranchID;

-- Q-02: Total numbers of members per branch
SELECT b.BranchName, COUNT(m.MemberID) AS TotalMembers
FROM   dbo.Branches b
LEFT JOIN dbo.Members m ON m.BranchID = b.BranchID
GROUP BY b.BranchName;

-- Q-03: View details of active memberships
SELECT m.FirstName + ' ' + m.LastName AS Member, p.PlanName, mm.Status
FROM   dbo.MemberMemberships mm
JOIN   dbo.Members m ON m.MemberID = mm.MemberID
JOIN   dbo.MembershipPlans p ON p.PlanID = mm.PlanID
WHERE  mm.Status = 'Active';

-- Q-04: Calculate total revenue per branch
SELECT b.BranchName, SUM(py.Amount) AS TotalRevenue
FROM   dbo.Payments py
JOIN   dbo.Members m ON m.MemberID = py.MemberID
JOIN   dbo.Branches b ON b.BranchID = m.BranchID
WHERE  py.Status = 'Completed'
GROUP BY b.BranchName;

-- Q-05: List all active trainers and their salaries
SELECT FirstName, LastName, Specialization, Salary 
FROM   dbo.Trainers 
WHERE  IsActive = 1;

-- Q-06: SIMPLIFIED CLASS LISTINGS (Complex formatting removed)
SELECT c.ClassName, c.ClassType, c.ScheduleDay, 
       t.FirstName + ' ' + t.LastName AS TrainerName, 
       b.BranchName
FROM   dbo.GymClasses c
JOIN   dbo.Trainers t ON c.TrainerID = t.TrainerID
JOIN   dbo.Branches b ON c.BranchID = b.BranchID;

-- Q-07: Find members who have enrolled in any class
SELECT MemberID, FirstName, LastName 
FROM   dbo.Members 
WHERE  MemberID IN (SELECT MemberID FROM dbo.ClassEnrollments);

-- Q-08: Count of equipment items per branch by their condition
SELECT b.BranchName, e.Condition, COUNT(e.EquipmentID) AS AssetCount
FROM   dbo.Equipment e
JOIN   dbo.Branches b ON b.BranchID = e.BranchID
GROUP BY b.BranchName, e.Condition;

-- Q-09: Find members with more than 1 attendance check-in
SELECT m.FirstName, m.LastName, COUNT(a.AttendanceID) AS TotalVisits
FROM   dbo.Attendance a
JOIN   dbo.Members m ON m.MemberID = a.MemberID
GROUP BY m.FirstName, m.LastName
HAVING COUNT(a.AttendanceID) > 1;

-- Q-10: Total payments collected per payment method
SELECT PaymentMethod, COUNT(PaymentID) AS Volume, SUM(Amount) AS Revenue
FROM   dbo.Payments
GROUP BY PaymentMethod;

-- Q-11: List all members on 'Premium' tier plans
SELECT m.FirstName, m.LastName, p.PlanName
FROM   dbo.Members m
JOIN   dbo.MemberMemberships mm ON m.MemberID = mm.MemberID
JOIN   dbo.MembershipPlans p ON p.PlanID = mm.PlanID
WHERE  p.PlanName LIKE '%Premium%';

-- Q-12: List classes where current enrollments have reached or exceeded capacity
SELECT gc.ClassName, gc.MaxCapacity, COUNT(ce.EnrollmentID) AS Enrolled
FROM   dbo.GymClasses gc
JOIN   dbo.ClassEnrollments ce ON ce.ClassID = gc.ClassID
GROUP BY gc.ClassID, gc.ClassName, gc.MaxCapacity
HAVING COUNT(ce.EnrollmentID) >= gc.MaxCapacity;

-- Q-13: List staff members sorted by their roles
SELECT s.FirstName, s.LastName, s.Role, b.BranchName
FROM   dbo.Staff s
JOIN   dbo.Branches b ON b.BranchID = s.BranchID
ORDER BY s.Role;

-- Q-14: Identify members who have never checked in (No attendance record)
SELECT m.MemberID, m.FirstName, m.LastName
FROM   dbo.Members m
LEFT JOIN dbo.Attendance a ON a.MemberID = m.MemberID
WHERE  a.AttendanceID IS NULL;

-- Q-15: Count how many times each membership plan has been purchased
SELECT p.PlanName, COUNT(mm.MembershipID) AS TimesPurchased
FROM   dbo.MembershipPlans p
LEFT JOIN dbo.MemberMemberships mm ON mm.PlanID = p.PlanID
GROUP BY p.PlanName;

-- Q-16: Get a list of equipment requiring repair or retirement
SELECT EquipmentName, Condition, PurchasePrice 
FROM   dbo.Equipment 
WHERE  Condition IN ('Under Repair', 'Retired');

-- Q-17: Track members with expired statuses
SELECT m.FirstName, m.LastName, MAX(mm.EndDate) AS LastExpiry
FROM   dbo.Members m
JOIN   dbo.MemberMemberships mm ON mm.MemberID = m.MemberID
WHERE  mm.Status = 'Expired'
GROUP BY m.MemberID, m.FirstName, m.LastName;

-- Q-18: Identify the highest paid trainer per branch
SELECT t.FirstName, t.Salary, b.BranchName
FROM   dbo.Trainers t
JOIN   dbo.Branches b ON b.BranchID = t.BranchID
WHERE  t.Salary = (SELECT MAX(Salary) FROM dbo.Trainers WHERE BranchID = t.BranchID);

-- Q-19: Monthly broken down transaction logs
SELECT YEAR(PaymentDate) AS Year, MONTH(PaymentDate) AS Month, SUM(Amount) AS Revenue
FROM   dbo.Payments
GROUP BY YEAR(PaymentDate), MONTH(PaymentDate);

-- Q-20: Profile sheet for active members
SELECT m.FirstName, m.LastName, b.BranchName, p.PlanName, gc.ClassName
FROM   dbo.Members m
JOIN   dbo.Branches b ON b.BranchID = m.BranchID
JOIN   dbo.MemberMemberships mm ON mm.MemberID = m.MemberID
JOIN   dbo.MembershipPlans p ON p.PlanID = mm.PlanID
LEFT JOIN dbo.ClassEnrollments ce ON ce.MemberID = m.MemberID
LEFT JOIN dbo.GymClasses gc ON gc.ClassID = ce.ClassID
WHERE  mm.Status = 'Active';

-- Q-21: Estimated monthly operational salary costs per branch
SELECT b.BranchName, b.MonthlyRent + SUM(s.Salary) AS EstimatedCost
FROM   dbo.Branches b
JOIN   dbo.Staff s ON s.BranchID = b.BranchID
GROUP BY b.BranchID, b.BranchName, b.MonthlyRent;

-- Q-22: Emergency listings matching target blood groups
SELECT FirstName, LastName, BloodGroup, EmergencyContact
FROM   dbo.Members
WHERE  BloodGroup IN ('O+', 'AB+');
GO