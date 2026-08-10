-- Drop all tables
-- Kill the children first
DROP TABLE RentalCollection;
DROP TABLE Shop;
DROP TABLE StaffAllocation;
DROP TABLE Using_Parts;
DROP TABLE Part_Order;
DROP TABLE Maintenance;
DROP TABLE Extension;
DROP TABLE Refund CASCADE CONSTRAINTS;
DROP TABLE BookingDetails;
DROP TABLE Ticket;
DROP TABLE Booking;
DROP TABLE Schedule CASCADE CONSTRAINTS;
DROP TABLE Bus;
DROP TABLE DriverAllocation;
DROP TABLE Part;

-- Then the parents
DROP TABLE Staff;
DROP TABLE Supplier;
DROP TABLE Service_Type;
DROP TABLE Member;
DROP TABLE Driver;
DROP TABLE Bus_Company;

-- Bus Company
CREATE TABLE Bus_Company (
    BusCompanyID   VARCHAR2(8) PRIMARY KEY NOT NULL,
    CompanyName    VARCHAR2(50) NOT NULL,
    Location       VARCHAR2(30) NOT NULL,
    Email          VARCHAR2(40) NOT NULL,
    ContactNo      VARCHAR2(12) NOT NULL,
    CONSTRAINT BusCompanyID_chk CHECK (REGEXP_LIKE(BusCompanyID, '^BC[0-9]{3}$')),
    CONSTRAINT CompanyName_chk CHECK (REGEXP_LIKE(CompanyName, '^[A-Za-z ]+$')),
    CONSTRAINT Email_chk CHECK (REGEXP_LIKE(Email, '.*@.*\..*')),
    CONSTRAINT ContactNo_chk CHECK (REGEXP_LIKE(ContactNo, '^[0-9]{3}[- ]?[0-9]{7}$'))
);	

-- Bus
CREATE TABLE Bus (
    BusID          VARCHAR2(8) PRIMARY KEY ,
    BusCompanyID   VARCHAR2(8) NOT NULL,
    PlateNo        VARCHAR2(8) NOT NULL,
    BusType        VARCHAR2(20) NOT NULL,
    Capacity       NUMBER NOT NULL,
    Status         VARCHAR2(20) NOT NULL,
    FOREIGN KEY (BusCompanyID) REFERENCES Bus_Company(BusCompanyID),
    CONSTRAINT BusID_chk CHECK (REGEXP_LIKE(BusID, '^B[0-9]{4}$')),
    CONSTRAINT PlateNo_chk CHECK (REGEXP_LIKE(PlateNo, '^[a-zA-Z]{3}[0-9]{4}$'))
);

-- Schedule
CREATE TABLE Schedule (
    ScheduleID     VARCHAR2(10) PRIMARY KEY NOT NULL,
    BusID          VARCHAR2(10) NOT NULL,
    DepartureTime  DATE NOT NULL,
    ArrivalTime    DATE NOT NULL,
    Station        VARCHAR2(50) NOT NULL,
    Platform       VARCHAR2(20) NOT NULL,
    Destination    VARCHAR2(50) NOT NULL,
    ScheduleDate   DATE NOT NULL,
    ScheduleStatus VARCHAR2(20) NOT NULL, -- Active/Cancelled
    FOREIGN KEY (BusID) REFERENCES Bus(BusID)
);

-- Driver
CREATE TABLE Driver (
    DriverID       VARCHAR2(10) PRIMARY KEY NOT NULL,
    BusCompanyID   VARCHAR2(8) NOT NULL,
    FullName       VARCHAR2(50) NOT NULL,
    LicenseNumber  VARCHAR2(10) NOT NULL,
    Email          VARCHAR2(40) NOT NULL,
    ContactNo      VARCHAR2(12) NOT NULL,
    FOREIGN KEY (BusCompanyID) REFERENCES Bus_Company(BusCompanyID),
    CONSTRAINT DriverID_chk CHECK (REGEXP_LIKE(DriverID, '^D[0-9]{4}$')),
    CONSTRAINT FullName_chk CHECK (REGEXP_LIKE(FullName, '^[A-Za-z ]+$')),
    CONSTRAINT LicenseNumber_chk CHECK (REGEXP_LIKE(LicenseNumber, '^PSVE[0-9]{4}$'))
);

-- Driver Allocation
CREATE TABLE DriverAllocation (
    DriverID       VARCHAR2(10) NOT NULL,
    ScheduleID     VARCHAR2(10) NOT NULL,
    Shift          VARCHAR2(10) DEFAULT '-',
    PRIMARY KEY (DriverID, ScheduleID),
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    FOREIGN KEY (ScheduleID) REFERENCES Schedule(ScheduleID),
    CONSTRAINT chk_DriverID CHECK (REGEXP_LIKE(DriverID, '^D[0-9]{4}$')),
    CONSTRAINT chk_ScheduleID CHECK (REGEXP_LIKE(ScheduleID, '^SCH[0-9]{4}$'))
);

-- Member
CREATE TABLE Member (
    MemberID        VARCHAR2(8) PRIMARY KEY NOT NULL,
    FullName        VARCHAR2(50) NOT NULL,
    PhoneNo         VARCHAR2(12) NOT NULL,
    Email           VARCHAR2(40) NOT NULL,
    MembershipStatus VARCHAR2(20) NOT NULL,
    JoinDate        DATE,
    CONSTRAINT MemberID_chk CHECK (REGEXP_LIKE(MemberID, '^M[0-9]{4}$'))
);

-- Booking
CREATE TABLE Booking (
    BookingID       VARCHAR2(8) PRIMARY KEY NOT NULL,
    MemberID        VARCHAR2(8) NOT NULL,
    BookingDate     DATE NOT NULL,
    TotalAmount     NUMBER(10, 2) NOT NULL,
    PaymentStatus   VARCHAR2(20) NOT NULL,
    PaymentMethod   VARCHAR2(30) NOT NULL,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    CONSTRAINT BookingID_chk CHECK (REGEXP_LIKE(BookingID, '^BK[0-9]{4}$'))
);

-- Ticket
CREATE TABLE Ticket (
    TicketID        VARCHAR2(10) PRIMARY KEY NOT NULL,
    ScheduleID      VARCHAR2(10) NOT NULL,
    SeatNo          VARCHAR2(5) NOT NULL,
    Fare            NUMBER(8, 2) NOT NULL,
    Status          VARCHAR2(20) NOT NULL, -- Refunded, Active, Past
    ExtendedTrip    CHAR(1) NOT NULL,
    FOREIGN KEY (ScheduleID) REFERENCES Schedule(ScheduleID),
    CONSTRAINT chk_TicketID CHECK (REGEXP_LIKE(TicketID, '^TCK[0-9]{5}$'))
);

-- BookingDetails
CREATE TABLE BookingDetails (
    BookingDetailsID VARCHAR2(10) PRIMARY KEY NOT NULL,
    TicketID         VARCHAR2(10) NOT NULL,
    BookingID        VARCHAR2(10) NOT NULL,
    Price            NUMBER(10, 2) NOT NULL,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    CONSTRAINT chk_BookingDetailsID CHECK (REGEXP_LIKE(BookingDetailsID, '^BD[0-9]{6}$'))
);

-- Extension
CREATE TABLE Extension (
    ExtensionID      VARCHAR2(10) PRIMARY KEY NOT NULL,
    BookingDetailsID VARCHAR2(10),
    NewScheduleID    VARCHAR2(10),
    NewTicketID      VARCHAR(10),
    ExtensionStatus  VARCHAR2(20),
    RequestDate      DATE,
    ApproveDate      DATE,
    ExtensionFee     NUMBER(8, 2) DEFAULT 0,
    Reason           VARCHAR2(100),
    FOREIGN KEY (BookingDetailsID) REFERENCES BookingDetails(BookingDetailsID),
    FOREIGN KEY (NewScheduleID) REFERENCES Schedule(ScheduleID),
    FOREIGN KEY (NewTicketId) REFERENCES Ticket(TicketId)
);

-- Refund
CREATE TABLE Refund (
    RefundID        VARCHAR2(10) PRIMARY KEY NOT NULL,
    BookingDetailsID VARCHAR2(10) NOT NULL,
    RefundDate      DATE NOT NULL,
    RefundAmount    NUMBER(10, 2) NOT NULL,
    RefundStatus    VARCHAR2(20) NOT NULL,
    PaymentMethod   VARCHAR2(30) NOT NULL,
    RefundReason    VARCHAR2(100) NOT NULL,
    FOREIGN KEY (BookingDetailsID) REFERENCES BookingDetails(BookingDetailsID)
);

-- Service_Type
CREATE TABLE Service_Type (
    ServiceTypeID       VARCHAR2(8) PRIMARY KEY NOT NULL,
    ServiceName         VARCHAR2(30) NOT NULL,
    ServiceDescription  VARCHAR2(50) NOT NULL,
    EstimatedDuration   NUMBER NOT NULL,
    StandardCost        NUMBER(10, 2) NOT NULL,
    CONSTRAINT ServiceTypeID_chk CHECK (REGEXP_LIKE(ServiceTypeID, '^SV[0-9]{3}$')),
    CONSTRAINT ServiceName_chk CHECK (REGEXP_LIKE(ServiceName, '^[A-Za-z ]+$'))
);

-- Maintenance
CREATE TABLE Maintenance (
    MaintenanceID   VARCHAR2(10) PRIMARY KEY NOT NULL,
    BusID           VARCHAR2(10) NOT NULL,
    ServiceTypeID   VARCHAR2(10) NOT NULL,
    Cost            NUMBER(10, 2) NOT NULL,
    Notes           VARCHAR2(50) DEFAULT '-',
    ServiceDate     DATE NOT NULL,
    Status          VARCHAR2(20) NOT NULL,
    FOREIGN KEY (BusID) REFERENCES Bus(BusID),
    FOREIGN KEY (ServiceTypeID) REFERENCES Service_Type(ServiceTypeID),
    CONSTRAINT chk_MaintenanceID CHECK (REGEXP_LIKE(MaintenanceID, '^MT[0-9]{5}$'))
);

-- Supplier
CREATE TABLE Supplier (
    SupplierID      VARCHAR2(8) PRIMARY KEY NOT NULL,
    SupplierName    VARCHAR2(30) NOT NULL,
    ContactPerson   VARCHAR2(30) NOT NULL,
    PhoneNo         VARCHAR2(12) NOT NULL,
    Email           VARCHAR2(40) NOT NULL,
    Location        VARCHAR2(40) NOT NULL,
    CONSTRAINT SupplierID_chk CHECK (REGEXP_LIKE(SupplierID, '^SUP[0-9]{3}$')),
    CONSTRAINT SupplierName_chk CHECK (REGEXP_LIKE(SupplierName, '^[A-Za-z &]+$')),
    CONSTRAINT PhoneNo_chk CHECK (REGEXP_LIKE(PhoneNo, '^[0-9]{3}[- ]?[0-9]{7}$'))
);

-- Part Table type 2 baby
CREATE TABLE Part (
    PartKey         NUMBER NOT NULL,
    PartID          VARCHAR2(8) NOT NULL,               
    PartName        VARCHAR2(50) NOT NULL,
    StockQuantity   NUMBER NOT NULL,
    UnitPrice       NUMBER(10,2) NOT NULL, 
    StartDate       DATE NOT NULL,
    EndDate         DATE DEFAULT '31-DEC-9999',
    IsActive        Number(1) DEFAULT 1,
    PRIMARY KEY (PartKey, PartID),
    CONSTRAINT PartID_chk CHECK (REGEXP_LIKE(PartID, '^PRT[0-9]{3}$')),
    CONSTRAINT PartName_chk CHECK (REGEXP_LIKE(PartName, '^[A-Za-z ]+$')),
    CONSTRAINT IsActive_chk CHECK (IsActive IN (0, 1))
);
COLUMN UnitPrice FORMAT A15;

-- Using_Parts
CREATE TABLE Using_Parts (
    MaintenanceID   VARCHAR2(10) NOT NULL,
    PartKey         NUMBER NOT NULL,
    PartID          VARCHAR2(8) NOT NULL,
    QuantityUsed    NUMBER NOT NULL,
    PRIMARY KEY (MaintenanceID, PartID),
    FOREIGN KEY (MaintenanceID) REFERENCES Maintenance(MaintenanceID),
    FOREIGN KEY (PartKey, PartID) REFERENCES Part(PartKey, PartID),
    CONSTRAINT chk_MaintenanceID_UsingParts CHECK (REGEXP_LIKE(MaintenanceID, '^MT[0-9]{5}$')),
    CONSTRAINT chk_PartID CHECK (REGEXP_LIKE(PartID, '^PRT[0-9]{3}$'))
);

-- Part_Order
CREATE TABLE Part_Order (
    OrderID         VARCHAR2(8) PRIMARY KEY NOT NULL,
    OrderDate       DATE NOT NULL,
    PartKey         NUMBER NOT NULL,
    PartID          VARCHAR2(8) NOT NULL,
    SupplierID      VARCHAR2(8) NOT NULL,
    OrderQuantity   NUMBER NOT NULL,
    Price           Number(10,2),
    FOREIGN KEY (PartKey, PartID) REFERENCES Part(PartKey, PartID),
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    CONSTRAINT chk_OrderID CHECK (REGEXP_LIKE(OrderID, '^PO[0-9]{4}$'))
);

-- Staff
CREATE TABLE Staff (
    StaffID         VARCHAR2(8) PRIMARY KEY NOT NULL,
    FullName        VARCHAR2(35) NOT NULL,
    Position        VARCHAR2(20) NOT NULL,
    Salary          NUMBER(10, 2) NOT NULL,
    Email           VARCHAR2(40) NOT NULL,
    PhoneNo         VARCHAR2(12) NOT NULL,
    HireDate        DATE NOT NULL,
    CONSTRAINT StaffID_chk CHECK (REGEXP_LIKE(StaffID, '^STF[0-9]{3}$'))
);

-- StaffAllocation
CREATE TABLE StaffAllocation (
    MaintenanceID   VARCHAR2(10) NOT NULL,
    StaffID         VARCHAR2(10) NOT NULL,
    Role            VARCHAR2(50) NOT NULL,
    WorkedHour      NUMBER NOT NULL,
    PRIMARY KEY (MaintenanceID, StaffID),
    FOREIGN KEY (MaintenanceID) REFERENCES Maintenance(MaintenanceID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT chk_MaintenanceID_StaffAlloc CHECK (REGEXP_LIKE(MaintenanceID, '^MT[0-9]{5}$')),
    CONSTRAINT chk_StaffID CHECK (REGEXP_LIKE(StaffID, '^STF[0-9]{3}$'))
);

-- Shop
CREATE TABLE Shop (
    ShopID          VARCHAR2(8) PRIMARY KEY NOT NULL,
    ShopName        VARCHAR2(50) NOT NULL,
    ShopType        VARCHAR2(20) NOT NULL,
    RentAmount      NUMBER(10, 2) NOT NULL,
    OwnerName       VARCHAR2(50) NOT NULL,
    OwnerContactNo  VARCHAR2(12) NOT NULL,
    CONSTRAINT ShopID_chk CHECK (REGEXP_LIKE(ShopID, '^SHP[0-9]{3}$'))
);

-- Rental Collection
CREATE TABLE RentalCollection (
    CollectionID    VARCHAR2(8) NOT NULL,
    ShopID          VARCHAR2(8) NOT NULL,
    StaffID         VARCHAR2(8) NOT NULL,
    CollectionDate  DATE NOT NULL,
    AmountCollected NUMBER(10, 2) NOT NULL,
    PaymentMethod   VARCHAR2(30) NOT NULL,
    Notes           VARCHAR2(40) DEFAULT '-',
    PRIMARY KEY (CollectionID, ShopID, StaffID),
    FOREIGN KEY (ShopID) REFERENCES Shop(ShopID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT chk_CollectionID CHECK (REGEXP_LIKE(CollectionID, '^COL[0-9]{3}$')),
    CONSTRAINT chk_ShopID CHECK (REGEXP_LIKE(ShopID, '^SHP[0-9]{3}$'))
);

-- Save
COMMIT;

-- Data
-- FORMATTING
SET linesize 1000
SET pagesize 100
SET SERVEROUTPUT ON;

-- TO PREVENT UNINTENTIONAL LINEBREAKS
SET DEFINE OFF;


-- DELETE ALL DATA TO PREVENT DUPLICATES
-- Kill the childrens first
DELETE Refund;
DELETE Extension;
DELETE BookingDetails;
DELETE Part_Order;
DELETE Using_Parts;
DELETE StaffAllocation;
DELETE Ticket;
DELETE DriverAllocation;
DELETE RentalCollection;
DELETE Maintenance;
DELETE Schedule;
DELETE Shop;
DELETE Booking;
DELETE bus;

-- Then the parents
DELETE Part;
DELETE Staff;
DELETE Supplier;
DELETE Service_Type;
DELETE Member;
DELETE Driver;
DELETE Bus_Company;

-- SERVICE TYPE
DROP SEQUENCE service_type_seq;
CREATE SEQUENCE service_type_seq
MINVALUE 1	
MAXVALUE 999
START WITH 1
INCREMENT BY 1
NOCACHE; 

INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Wheel Alignment', 'Ensure vehicle performance and safety', 215, 325.75);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Tire Rotation', 'Ensure vehicle performance and safety', 86, 438.53);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Tire Rotation', 'Check and refill essential fluids', 168, 384.84);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Car Wash', 'System performance optimization', 40, 320.79);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Oil Change', 'System performance optimization', 97, 264.05);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Transmission Service', 'Standard vehicle maintenance service', 42, 449.46);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Engine Diagnostics', 'Preventive maintenance service', 125, 393.15);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Coolant Flush', 'Replacement of worn out components', 113, 392.93);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Brake Inspection', 'Replacement of worn out components', 34, 236.22);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Battery Replacement', 'Check and refill essential fluids', 43, 465.18);

INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Chair Replacement', 'Check and refill essential fluids', 43, 465.18);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Driver Replacement', 'Check and refill essential fluids', 43, 465.18);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Door Replacement', 'Check and refill essential fluids', 43, 465.18);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Light Replacement', 'Check and refill essential fluids', 43, 465.18);
INSERT INTO Service_Type VALUES('SV' || TO_CHAR(service_type_seq.nextval, 'FM000'), 'Brake Replacement', 'Check and refill essential fluids', 43, 465.18);

-- SUPPLIER
DROP SEQUENCE sup_num_seq;
CREATE SEQUENCE sup_num_seq
MINVALUE 1	
MAXVALUE 999
START WITH 1
INCREMENT BY 1
NOCACHE; 

INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Eco Systems', 'Zara Loh', '017-1737200', 'zara.loh@autoparts.my', 'Sabah');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Eco Solutions', 'Aida Lee', '019-6964559', 'aida.lee@autoparts.my', 'Selangor');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Parts Malaysia', 'Jason Loh', '016-4332170', 'jason.loh@autoparts.my', 'Sarawak');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Prime Systems', 'Farah Abdullah', '014-1763420', 'farah.abdullah@autoparts.my', 'Selangor');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Max Systems', 'Kenny Chong', '019-7585038', 'kenny.chong@autoparts.my', 'Sarawak');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Speed Experts', 'Nora Loh', '019-3105137', 'nora.loh@autoparts.my', 'Johor');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Turbo Sdn Bhd', 'Raj Abdullah', '011-1541174', 'raj.abdullah@autoparts.my', 'Perlis');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Tech Solutions', 'Ahmad Abdullah', '012-6097618', 'ahmad.abdullah@autoparts.my', 'Sabah');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Max In Motion', 'John Kumar', '018-2366650', 'john.kumar@autoparts.my', 'Melaka');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Turbo Warehouse', 'Jason Lee', '016-8927675', 'jason.lee@autoparts.my', 'Perlis');

INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Elemis', 'Kieel', '016-8927675', 'jason.lee@autoparts.my', 'Perlis');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'SkinKare', 'Fish', '016-8927675', 'jason.lee@autoparts.my', 'Perlis');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Tarot Card', 'Khiew Jit', '016-8927675', 'jason.lee@autoparts.my', 'Perlis');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Jit', 'Dating', '016-8927675', 'jason.lee@autoparts.my', 'Perlis');
INSERT INTO Supplier VALUES('SUP' || TO_CHAR(sup_num_seq.nextval, 'FM000'), 'Girl', 'Friend', '016-8927675', 'jason.lee@autoparts.my', 'Perlis');

-- STAFF
DROP SEQUENCE staff_num_seq;
CREATE SEQUENCE staff_num_seq
MINVALUE 1 	
MAXVALUE 999
START WITH 1
INCREMENT BY 1
NOCACHE; 

INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Mary Chong', 'Manager', 3226.6, 'mary.chong@example.com', '0195142714', TO_DATE('2020-10-13', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Daniel Teoh', 'Accountant', 5579.31, 'daniel.teoh@example.com', '0114490950', TO_DATE('2020-02-03', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'John Teoh', 'Receptionist', 6195.21, 'john.teoh@example.com', '0128937783', TO_DATE('2019-01-04', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'David Chong', 'Driver', 3299.97, 'david.chong@example.com', '0145019722', TO_DATE('2021-07-16', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Liam Tan', 'Accountant', 4416.03, 'liam.tan@example.com', '0171891500', TO_DATE('2019-06-12', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Liam Lee', 'Receptionist', 3641.31, 'liam.lee@example.com', '0161597900', TO_DATE('2023-08-25', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'David Chan', 'Clerk', 7573.07, 'david.chan@example.com', '0118001435', TO_DATE('2020-05-04', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Emma Wong', 'Manager', 4120.86, 'emma.wong@example.com', '0192518129', TO_DATE('2022-08-31', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Mary Chan', 'Supervisor', 5643.63, 'mary.chan@example.com', '0122000346', TO_DATE('2019-05-23', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Liam Koh', 'Supervisor', 3563.16, 'liam.koh@example.com', '0165814091', TO_DATE('2019-11-23', 'YYYY-MM-DD'));

INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Heng Heng', 'Supervisor', 3563.16, 'liam.koh@example.com', '0165814091', TO_DATE('2019-11-23', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Yun Looong', 'Supervisor', 3563.16, 'liam.koh@example.com', '0165814091', TO_DATE('2019-11-23', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Loong Loong', 'Supervisor', 3563.16, 'liam.koh@example.com', '0165814091', TO_DATE('2019-11-23', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Rap God', 'Supervisor', 3563.16, 'liam.koh@example.com', '0165814091', TO_DATE('2019-11-23', 'YYYY-MM-DD'));
INSERT INTO Staff VALUES('STF' || TO_CHAR(staff_num_seq.nextval, 'FM000'), 'Dating Tutor', 'Supervisor', 3563.16, 'liam.koh@example.com', '0165814091', TO_DATE('2019-11-23', 'YYYY-MM-DD'));


-- MEMBER
DROP SEQUENCE member_num_seq;
CREATE SEQUENCE member_num_seq
MINVALUE 1 	
MAXVALUE 999
START WITH 1
INCREMENT BY 1
NOCACHE; 

INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Alicia Tan Mei Ling', '0123456789', 'aliciatanmeiling@gmail.com', 'Gold', TO_DATE('15-01-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'John Lee Wei Sheng', '0198765432', 'johnleeweisheng@gmail.com', 'Silver', TO_DATE('20-02-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Nurul Izzah Binti Ahmad', '0111234567', 'nurulizzahbintiahmad@gmail.com', 'Bronze', TO_DATE('10-03-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Lim Chee How', '0137894561', 'limcheehow@gmail.com', 'Silver', TO_DATE('05-04-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Siti Aminah Bt Zulkifli', '0147654321', 'sitiaminahbtzulkifli@gmail.com', 'Gold', TO_DATE('01-05-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Daniel Tan Hong Yee', '0163344556', 'danieltanhongyee@gmail.com', 'Bronze', TO_DATE('18-06-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Tan Wei Xin', '0189988776', 'tanweixin@gmail.com', 'Gold', TO_DATE('12-07-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Muhammad Hafiz Bin Saad', '0176655443', 'muhammadhafizbinsaad@gmail.com', 'Bronze', TO_DATE('30-08-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Rachel Ong Li Wen', '0191122334', 'rachelongliwen@gmail.com', 'Silver', TO_DATE('25-09-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Goh Jia Xin', '0125566778', 'gohjiaxin@gmail.com', 'Gold', TO_DATE('09-10-2024', 'DD-MM-YYYY'));

INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Goh', '0125566778', 'gohjewxin@gmail.com', 'Gold', TO_DATE('09-10-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Khiew Jit Chen', '0125566779', 'pophjiaxin@gmail.com', 'Gold', TO_DATE('09-10-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Eq', '0125526778', 'gopjiaxin@gmail.com', 'Gold', TO_DATE('09-10-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Iq', '0125566718', 'gohjizzin@gmail.com', 'Gold', TO_DATE('09-10-2024', 'DD-MM-YYYY'));
INSERT INTO Member VALUES ('M' || TO_CHAR(member_num_seq.nextval, 'FM0000'), 'Qu', '0125566278', 'goheiaxin@gmail.com', 'Gold', TO_DATE('09-10-2024', 'DD-MM-YYYY'));



-- BUS_COMPANY
DROP SEQUENCE bus_company_num_seq;
CREATE SEQUENCE bus_company_num_seq
MINVALUE 1 	
MAXVALUE 999
START WITH 1
INCREMENT BY 1
NOCACHE; 

INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'TransNation Express', 'Kuala Lumpur', 'transnationexpress@gmail.com', '0322345566');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Maju Mover Transport', 'Johor Bahru', 'majumovertransport@gmail.com', '0723456678');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Eastline Travel', 'Kuching', 'eastlinetravel@gmail.com', '0824567890');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Southern Star Coaches', 'Melaka', 'southernstarcoaches@gmail.com', '0623347788');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Borneo Highway Link', 'Kota Kinabalu', 'borneohighwaylink@gmail.com', '0883344556');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Skybus Express', 'Penang', 'skybusexpress@gmail.com', '0421123344');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'MetroLine Travel Services', 'Ipoh', 'metroline.travel.services@gmail.com', '0523344455');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Northern Gateway Buses', 'Alor Setar', 'northerngatewaybuses@gmail.com', '0467788990');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Sabah InterCity Transport', 'Sandakan', 'sabahintercitytransport@gmail.com', '0893345566');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'GoGoBus Malaysia', 'Seremban', 'gogobusmalaysia@gmail.com', '0678899001');

INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'BusTo Heaven', 'Seremban', 'gogobusmalaysia@gmail.com', '0678899001');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Xplore Malaysia', 'Seremban', 'gogobusmalaysia@gmail.com', '0678899001');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Feesh Travel', 'Seremban', 'gogobusmalaysia@gmail.com', '0678899001');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Press Bus', 'Seremban', 'gogobusmalaysia@gmail.com', '0678899001');
INSERT INTO Bus_Company VALUES ('BC' || TO_CHAR(bus_company_num_seq.nextval, 'FM000'), 'Come Come Bus', 'Seremban', 'gogobusmalaysia@gmail.com', '0678899001');


-- DRIVER
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0001', 'BC010', 'Matthew Brown', 'PSVE0001', 'gregory42@example.org', '582576239397');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0002', 'BC007', 'Elizabeth Sullivan', 'PSVE0002', 'brownmelissa@example.org', '573069705878');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0003', 'BC001', 'Candace Henderson', 'PSVE0003', 'hbrown@example.org', '175068673455');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0004', 'BC002', 'Jeffery Wilson', 'PSVE0004', 'zimmermanpaul@example.net', '547315958704');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0005', 'BC010', 'Jose Baker', 'PSVE0005', 'saramoreno@example.net', '667793028927');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0006', 'BC006', 'Erin Lopez', 'PSVE0006', 'davisjessica@example.org', '254043288140');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0007', 'BC002', 'Robert Wright', 'PSVE0007', 'ortegajohn@example.net', '544544276070');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0008', 'BC009', 'Tyler Campbell', 'PSVE0008', 'jennifer04@example.org', '193726328742');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0009', 'BC004', 'Cory Martinez', 'PSVE0009', 'nelsonjessica@example.net', '247659850022');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0010', 'BC004', 'Nicole Willis', 'PSVE0010', 'harrismelissa@example.com', '749733146916');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0011', 'BC007', 'Michael Lowery', 'PSVE0011', 'georgebeth@example.net', '241463484606');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0012', 'BC007', 'Jennifer Caldwell', 'PSVE0012', 'ortizmichael@example.org', '821030433259');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0013', 'BC001', 'Miss Anita Schaefer', 'PSVE0013', 'torreshoward@example.org', '263082606260');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0014', 'BC009', 'Michael Sims', 'PSVE0014', 'cmiller@example.com', '635664349759');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0015', 'BC004', 'Robert Villanueva', 'PSVE0015', 'hernandezashley@example.net', '574835895249');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0016', 'BC008', 'Diane Thomas', 'PSVE0016', 'istewart@example.com', '251676968521');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0017', 'BC001', 'Francisco Lee', 'PSVE0017', 'gary63@example.com', '237922791734');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0018', 'BC006', 'Martin Reyes', 'PSVE0018', 'corey67@example.com', '199151767731');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0019', 'BC002', 'Shawn Jones', 'PSVE0019', 'hectormartinez@example.net', '871822038627');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0020', 'BC008', 'Matthew Edwards', 'PSVE0020', 'james24@example.com', '841734748303');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0021', 'BC007', 'Janet Klein', 'PSVE0021', 'mgonzalez@example.org', '162118029544');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0022', 'BC006', 'Rose Simpson', 'PSVE0022', 'myersdouglas@example.com', '549146161292');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0023', 'BC001', 'Aaron Vega', 'PSVE0023', 'edwinthompson@example.org', '234650943532');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0024', 'BC002', 'Heather Perry', 'PSVE0024', 'singram@example.org', '250998255663');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0025', 'BC010', 'Jamie Stokes', 'PSVE0025', 'mckenzie58@example.com', '906216919874');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0026', 'BC007', 'Mark Richards', 'PSVE0026', 'sweeneyjessica@example.org', '428440571141');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0027', 'BC003', 'Emily White', 'PSVE0027', 'robertsonbernard@example.net', '867734032556');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0028', 'BC008', 'Danny Reyes', 'PSVE0028', 'burtonterri@example.net', '673705019025');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0029', 'BC010', 'Joseph Davis', 'PSVE0029', 'michaelmorgan@example.org', '103101527581');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0030', 'BC001', 'Jerry Rodgers', 'PSVE0030', 'carl79@example.net', '135013756950');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0031', 'BC006', 'Daniel Barnes', 'PSVE0031', 'james99@example.com', '238462577487');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0032', 'BC009', 'Crystal Solomon', 'PSVE0032', 'josephgraves@example.org', '052152778081');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0033', 'BC002', 'Rebecca Williamson', 'PSVE0033', 'fray@example.org', '553811436990');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0034', 'BC004', 'Tara Lopez', 'PSVE0034', 'chavezjason@example.net', '836223737893');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0035', 'BC004', 'Kevin Garza', 'PSVE0035', 'jacoblevy@example.com', '444913724697');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0036', 'BC001', 'Tyler Hodge', 'PSVE0036', 'justin26@example.net', '319211048254');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0037', 'BC008', 'Joshua Brown', 'PSVE0037', 'martineznathan@example.com', '077561178251');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0038', 'BC002', 'Jennifer Hopkins', 'PSVE0038', 'dianegordon@example.net', '176339209620');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0039', 'BC002', 'Kelly Long', 'PSVE0039', 'thomas19@example.org', '828496454184');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0040', 'BC004', 'Susan Blackburn', 'PSVE0040', 'terriruiz@example.net', '712463370161');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0041', 'BC003', 'Daniel Morgan', 'PSVE0041', 'schroederchristopher@example.net', '332768306584');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0042', 'BC002', 'Zachary Wong', 'PSVE0042', 'jensendavid@example.net', '651261358145');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0043', 'BC009', 'Patricia Fisher', 'PSVE0043', 'hweaver@example.org', '623894857488');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0044', 'BC004', 'Rhonda Johnson', 'PSVE0044', 'pearsonjoseph@example.net', '339571512012');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0045', 'BC008', 'Mary Nixon', 'PSVE0045', 'ihorton@example.com', '154016059015');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0046', 'BC005', 'Jeffrey Blackburn', 'PSVE0046', 'fbrown@example.com', '275814660865');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0047', 'BC006', 'Karen Washington', 'PSVE0047', 'donna73@example.net', '147230507448');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0048', 'BC002', 'Roy Johnson', 'PSVE0048', 'gonzalezcourtney@example.org', '754016144055');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0049', 'BC003', 'Jason Olson', 'PSVE0049', 'anthonylopez@example.com', '436069236423');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0050', 'BC003', 'Kristin Castaneda', 'PSVE0050', 'markjimenez@example.com', '194220762901');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0051', 'BC006', 'Erica Brooks', 'PSVE0051', 'justingallagher@example.com', '958377709788');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0052', 'BC006', 'Benjamin Wolfe', 'PSVE0052', 'frankvance@example.com', '467761582109');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0053', 'BC001', 'Mercedes Clark', 'PSVE0053', 'laura93@example.org', '631780806719');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0054', 'BC003', 'Richard Gonzales', 'PSVE0054', 'edward20@example.net', '660980158319');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0055', 'BC004', 'Tasha Harris', 'PSVE0055', 'edwarddiaz@example.net', '334571201336');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0056', 'BC007', 'Jasmine Duarte', 'PSVE0056', 'smunoz@example.com', '513735299353');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0057', 'BC004', 'Tiffany Williams', 'PSVE0057', 'alyssabauer@example.com', '182836557613');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0058', 'BC010', 'Anthony Cole', 'PSVE0058', 'mlopez@example.net', '993085503254');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0059', 'BC008', 'Lauren Hebert', 'PSVE0059', 'cassandra11@example.com', '367447478489');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0060', 'BC004', 'Brianna Doyle', 'PSVE0060', 'vortiz@example.org', '859945648195');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0061', 'BC005', 'John Williams', 'PSVE0061', 'hmurray@example.com', '756266323194');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0062', 'BC010', 'Erica Walters', 'PSVE0062', 'barbaraarmstrong@example.net', '805266410178');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0063', 'BC004', 'James Singleton MD', 'PSVE0063', 'william91@example.org', '905094642281');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0064', 'BC007', 'Paul Hansen DDS', 'PSVE0064', 'orozcorobert@example.org', '689907730423');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0065', 'BC010', 'Spencer Herman', 'PSVE0065', 'janethill@example.com', '312642281234');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0066', 'BC005', 'Jerry Mccann', 'PSVE0066', 'dmclaughlin@example.org', '001457091709');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0067', 'BC006', 'Robert Wagner', 'PSVE0067', 'william22@example.com', '524830088732');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0068', 'BC010', 'Eric Cooper', 'PSVE0068', 'chad58@example.org', '609385529995');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0069', 'BC008', 'Charles Patterson', 'PSVE0069', 'ctaylor@example.net', '151219877652');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0070', 'BC003', 'Traci Bennett', 'PSVE0070', 'gatesalicia@example.org', '215387506626');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0071', 'BC001', 'Joe Aguilar', 'PSVE0071', 'rblankenship@example.com', '672634121488');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0072', 'BC010', 'Jonathan Thomas', 'PSVE0072', 'murrayaustin@example.org', '719841579600');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0073', 'BC002', 'Russell Swanson', 'PSVE0073', 'codygould@example.net', '552691367287');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0074', 'BC004', 'Michelle Lewis', 'PSVE0074', 'shannon57@example.net', '796591554450');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0075', 'BC008', 'Joseph Graham', 'PSVE0075', 'andrew62@example.net', '557418938496');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0076', 'BC005', 'Casey Schwartz', 'PSVE0076', 'rowejustin@example.com', '417625484448');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0077', 'BC003', 'Lynn Wright', 'PSVE0077', 'mkelley@example.org', '218518686597');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0078', 'BC006', 'Gloria Campos', 'PSVE0078', 'ustewart@example.net', '462536600885');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0079', 'BC003', 'Jennifer Mcdowell', 'PSVE0079', 'erivas@example.org', '440745094397');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0080', 'BC005', 'Christine Ross', 'PSVE0080', 'gwendolyncollier@example.net', '199618088121');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0081', 'BC008', 'Bryan Johnson', 'PSVE0081', 'sharonthomas@example.org', '058027326679');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0082', 'BC010', 'Terry Anderson', 'PSVE0082', 'patricia18@example.net', '219874518069');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0083', 'BC002', 'Brandon Robinson', 'PSVE0083', 'joannaprince@example.org', '866795976801');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0084', 'BC004', 'Joseph Montoya', 'PSVE0084', 'savagepaul@example.org', '265985824201');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0085', 'BC002', 'Kenneth Jackson', 'PSVE0085', 'cody19@example.net', '824947412717');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0086', 'BC008', 'Marissa Sexton', 'PSVE0086', 'sarah43@example.com', '512793703961');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0087', 'BC010', 'Amy Stephens', 'PSVE0087', 'barkerleslie@example.com', '003281181078');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0088', 'BC003', 'Justin Caldwell', 'PSVE0088', 'phoover@example.com', '455091389215');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0089', 'BC007', 'Kyle Jacobs', 'PSVE0089', 'nrivera@example.com', '830883321890');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0090', 'BC001', 'Andrea Bauer', 'PSVE0090', 'efields@example.net', '068523451535');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0091', 'BC006', 'Jesse Neal', 'PSVE0091', 'lesterbrittany@example.com', '338862791795');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0092', 'BC006', 'John Moore', 'PSVE0092', 'emilyharmon@example.org', '727930479250');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0093', 'BC004', 'Crystal Jones', 'PSVE0093', 'williamsdanielle@example.net', '670102887705');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0094', 'BC003', 'Melissa Michael', 'PSVE0094', 'kirsten51@example.net', '034351429064');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0095', 'BC005', 'Suzanne Preston', 'PSVE0095', 'zmoore@example.com', '326912105675');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0096', 'BC007', 'Tammie Gonzalez', 'PSVE0096', 'hernandezhannah@example.org', '383315995076');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0097', 'BC004', 'Thomas Arnold', 'PSVE0097', 'lloyderic@example.org', '483211499105');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0098', 'BC006', 'Linda Brennan', 'PSVE0098', 'zdean@example.net', '324340313474');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0099', 'BC004', 'Kathleen Martinez', 'PSVE0099', 'bruce30@example.org', '488994356741');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0100', 'BC005', 'Tim Lowe', 'PSVE0100', 'jbender@example.com', '228627953812');

INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0101', 'BC005', 'Chinny', 'PSVE0100', 'jbender@example.com', '228627953812');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0102', 'BC005', 'Ports', 'PSVE0100', 'jbender@example.com', '228627953812');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0103', 'BC005', 'Lotr', 'PSVE0100', 'jbender@example.com', '228627953812');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0104', 'BC005', 'Lapkd', 'PSVE0100', 'jbender@example.com', '228627953812');
INSERT INTO Driver (DriverID, BusCompanyID, FullName, LicenseNumber, Email, ContactNo) VALUES ('D0105', 'BC005', 'Woeka', 'PSVE0100', 'jbender@example.com', '228627953812');
----------------------------------------------------------------------------------------
-- CHILDREN TABLE
-- ROUND 1
-- BUS

INSERT INTO Bus VALUES ('B0001', 'BC001', 'ABC1234', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0002', 'BC002', 'XYZ5678', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0003', 'BC003', 'JKL8765', 'Standard', 40, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0004', 'BC004', 'MNO4321', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0005', 'BC005', 'PQR2345', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0006', 'BC006', 'TUV6789', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0007', 'BC007', 'DEF1111', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0008', 'BC008', 'GHI2222', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0009', 'BC009', 'LMN3333', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0010', 'BC010', 'OPQ4444', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0011', 'BC001', 'RST5555', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0012', 'BC002', 'UVW6666', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0013', 'BC003', 'XYZ7777', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0014', 'BC004', 'ABC8888', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0015', 'BC005', 'DEF9999', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0016', 'BC006', 'GHI0001', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0017', 'BC007', 'JKL0002', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0018', 'BC008', 'MNO0003', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0019', 'BC009', 'PQR0004', 'Standard', 40, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0020', 'BC010', 'TUV0005', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0021', 'BC001', 'WXY0006', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0022', 'BC002', 'ZAB0007', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0023', 'BC003', 'CDE0008', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0024', 'BC004', 'FGH0009', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0025', 'BC005', 'IJK0010', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0026', 'BC006', 'LMN0011', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0027', 'BC007', 'OPQ0012', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0028', 'BC008', 'RST0013', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0029', 'BC009', 'UVW0014', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0030', 'BC010', 'XYZ0015', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0031', 'BC001', 'ABC0016', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0032', 'BC002', 'DEF0017', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0033', 'BC003', 'GHI0018', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0034', 'BC004', 'JKL0019', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0035', 'BC005', 'MNO0020', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0036', 'BC006', 'PQR0021', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0037', 'BC007', 'STU0022', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0038', 'BC008', 'VWX0023', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0039', 'BC009', 'YZA0024', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0040', 'BC010', 'BCD0025', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0041', 'BC001', 'EFG0026', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0042', 'BC002', 'HIJ0027', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0043', 'BC003', 'KLM0028', 'Standard', 40, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0044', 'BC004', 'NOP0029', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0045', 'BC005', 'QRS0030', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0046', 'BC006', 'TUV0031', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0047', 'BC007', 'WXY0032', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0048', 'BC008', 'ZAB0033', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0049', 'BC009', 'CDE0034', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0050', 'BC010', 'FGH0035', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0051', 'BC001', 'IJK0036', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0052', 'BC002', 'LMN0037', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0053', 'BC003', 'OPQ0038', 'Standard', 40, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0054', 'BC004', 'RST0039', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0055', 'BC005', 'UVW0040', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0056', 'BC006', 'XYZ0041', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0057', 'BC007', 'ABC0042', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0058', 'BC008', 'DEF0043', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0059', 'BC009', 'GHI0044', 'Standard', 40, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0060', 'BC010', 'JKL0045', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0061', 'BC001', 'MNO0046', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0062', 'BC002', 'PQR0047', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0063', 'BC003', 'STU0048', 'Standard', 40, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0064', 'BC004', 'VWX0049', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0065', 'BC005', 'YZA0050', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0066', 'BC006', 'BCD0051', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0067', 'BC007', 'EFG0052', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0068', 'BC008', 'HIJ0053', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0069', 'BC009', 'KLM0054', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0070', 'BC010', 'NOP0055', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0071', 'BC001', 'QRS0056', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0072', 'BC002', 'TUV0057', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0073', 'BC003', 'WXY0058', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0074', 'BC004', 'ZAB0059', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0075', 'BC005', 'CDE0060', 'Standard', 40, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0076', 'BC006', 'FGH0061', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0077', 'BC007', 'IJK0062', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0078', 'BC008', 'LMN0063', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0079', 'BC009', 'OPQ0064', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0080', 'BC010', 'RST0065', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0081', 'BC001', 'UVW0066', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0082', 'BC002', 'XYZ0067', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0083', 'BC003', 'ABC0068', 'Standard', 40, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0084', 'BC004', 'DEF0069', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0085', 'BC005', 'GHI0070', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0086', 'BC006', 'JKL0071', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0087', 'BC007', 'MNO0072', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0088', 'BC008', 'PQR0073', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0089', 'BC009', 'STU0074', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0090', 'BC010', 'VWX0075', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0091', 'BC001', 'YZA0076', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0092', 'BC002', 'BCD0077', 'Double Decker', 70, 'Inactive');
INSERT INTO Bus VALUES ('B0093', 'BC003', 'EFG0078', 'Standard', 40, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0094', 'BC004', 'HIJ0079', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0095', 'BC005', 'KLM0080', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0096', 'BC006', 'NOP0081', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0097', 'BC007', 'QRS0082', 'Standard', 40, 'Active');
INSERT INTO Bus VALUES ('B0098', 'BC008', 'TUV0083', 'Double Decker', 70, 'Under Maintenance');
INSERT INTO Bus VALUES ('B0099', 'BC009', 'WXY0084', 'Standard', 40, 'Inactive');
INSERT INTO Bus VALUES ('B0100', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');

INSERT INTO Bus VALUES ('B0101', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0102', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0103', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0104', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0105', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0106', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0107', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0108', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0109', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0110', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');
INSERT INTO Bus VALUES ('B0111', 'BC010', 'ZAB0085', 'Double Decker', 70, 'Active');

-- BOOKING
INSERT INTO Booking VALUES ('BK0001', 'M0001', TO_DATE('15-01-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0002', 'M0002', TO_DATE('22-02-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0003', 'M0003', TO_DATE('09-03-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'Online Banking');
INSERT INTO Booking VALUES ('BK0004', 'M0004', TO_DATE('17-03-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0005', 'M0005', TO_DATE('03-04-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0006', 'M0006', TO_DATE('25-04-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0007', 'M0007', TO_DATE('11-05-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0008', 'M0008', TO_DATE('08-06-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0009', 'M0009', TO_DATE('19-07-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0010', 'M0010', TO_DATE('02-08-2024', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0011', 'M0001', TO_DATE('14-08-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0012', 'M0002', TO_DATE('27-08-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0013', 'M0003', TO_DATE('05-09-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0014', 'M0004', TO_DATE('15-09-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0015', 'M0005', TO_DATE('28-09-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0016', 'M0006', TO_DATE('07-10-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0017', 'M0007', TO_DATE('20-10-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0018', 'M0008', TO_DATE('01-11-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0019', 'M0009', TO_DATE('11-11-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0020', 'M0010', TO_DATE('23-11-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0021', 'M0001', TO_DATE('03-12-2024', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0022', 'M0002', TO_DATE('16-12-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'Credit Card');
INSERT INTO Booking VALUES ('BK0023', 'M0003', TO_DATE('27-12-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0024', 'M0004', TO_DATE('04-01-2024', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0025', 'M0005', TO_DATE('17-01-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'Credit Card');
INSERT INTO Booking VALUES ('BK0026', 'M0006', TO_DATE('25-01-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0027', 'M0007', TO_DATE('06-02-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0028', 'M0008', TO_DATE('14-02-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'Credit Card');
INSERT INTO Booking VALUES ('BK0029', 'M0009', TO_DATE('20-02-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0030', 'M0010', TO_DATE('28-02-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0031', 'M0001', TO_DATE('07-03-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0032', 'M0002', TO_DATE('15-03-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0033', 'M0003', TO_DATE('22-03-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0034', 'M0004', TO_DATE('30-03-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0035', 'M0005', TO_DATE('05-04-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0036', 'M0006', TO_DATE('13-04-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0037', 'M0007', TO_DATE('20-04-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0038', 'M0008', TO_DATE('27-04-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0039', 'M0009', TO_DATE('05-05-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0040', 'M0010', TO_DATE('12-05-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0041', 'M0001', TO_DATE('19-05-2024', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0042', 'M0002', TO_DATE('25-05-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0043', 'M0003', TO_DATE('02-06-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'Online Banking');
INSERT INTO Booking VALUES ('BK0044', 'M0004', TO_DATE('10-06-2024', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0045', 'M0005', TO_DATE('16-06-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'Credit Card');
INSERT INTO Booking VALUES ('BK0046', 'M0006', TO_DATE('23-06-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0047', 'M0007', TO_DATE('30-06-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0048', 'M0008', TO_DATE('08-07-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0049', 'M0009', TO_DATE('15-07-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0050', 'M0010', TO_DATE('22-07-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0051', 'M0001', TO_DATE('29-07-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0052', 'M0002', TO_DATE('04-08-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0053', 'M0003', TO_DATE('11-08-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0054', 'M0004', TO_DATE('18-08-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0055', 'M0005', TO_DATE('24-08-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0056', 'M0006', TO_DATE('31-08-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0057', 'M0007', TO_DATE('07-09-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0058', 'M0008', TO_DATE('14-09-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0059', 'M0009', TO_DATE('21-09-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0060', 'M0010', TO_DATE('28-09-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');

INSERT INTO Booking VALUES ('BK0061', 'M0001', TO_DATE('05-10-2024', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0062', 'M0002', TO_DATE('12-10-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0063', 'M0003', TO_DATE('19-10-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'Online Banking');
INSERT INTO Booking VALUES ('BK0064', 'M0004', TO_DATE('26-10-2024', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0065', 'M0005', TO_DATE('02-11-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'Credit Card');
INSERT INTO Booking VALUES ('BK0066', 'M0006', TO_DATE('09-11-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0067', 'M0007', TO_DATE('16-11-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0068', 'M0008', TO_DATE('23-11-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0069', 'M0009', TO_DATE('30-11-2024', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0070', 'M0010', TO_DATE('07-12-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');

INSERT INTO Booking VALUES ('BK0071', 'M0001', TO_DATE('14-12-2024', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0072', 'M0002', TO_DATE('21-12-2024', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0073', 'M0003', TO_DATE('28-12-2024', 'DD-MM-YYYY'), 0, 'Cancelled', 'Online Banking');
INSERT INTO Booking VALUES ('BK0074', 'M0004', TO_DATE('04-01-2025', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0075', 'M0005', TO_DATE('11-01-2025', 'DD-MM-YYYY'), 0, 'Cancelled', 'Credit Card');
INSERT INTO Booking VALUES ('BK0076', 'M0006', TO_DATE('18-01-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0077', 'M0007', TO_DATE('25-01-2025', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0078', 'M0008', TO_DATE('01-02-2025', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0079', 'M0009', TO_DATE('08-02-2025', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0080', 'M0010', TO_DATE('15-02-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');

INSERT INTO Booking VALUES ('BK0081', 'M0001', TO_DATE('22-02-2025', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0082', 'M0002', TO_DATE('01-03-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0083', 'M0003', TO_DATE('08-03-2025', 'DD-MM-YYYY'), 0, 'Cancelled', 'Online Banking');
INSERT INTO Booking VALUES ('BK0084', 'M0004', TO_DATE('15-03-2025', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0085', 'M0005', TO_DATE('22-03-2025', 'DD-MM-YYYY'), 0, 'Cancelled', 'Credit Card');
INSERT INTO Booking VALUES ('BK0086', 'M0006', TO_DATE('29-03-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0087', 'M0007', TO_DATE('05-04-2025', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0088', 'M0008', TO_DATE('12-04-2025', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0089', 'M0009', TO_DATE('19-04-2025', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0090', 'M0010', TO_DATE('26-04-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');

INSERT INTO Booking VALUES ('BK0091', 'M0001', TO_DATE('03-05-2025', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0092', 'M0002', TO_DATE('10-05-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0093', 'M0003', TO_DATE('17-05-2025', 'DD-MM-YYYY'), 0, 'Cancelled', 'Online Banking');
INSERT INTO Booking VALUES ('BK0094', 'M0004', TO_DATE('24-05-2025', 'DD-MM-YYYY'), 0, 'Complete', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0095', 'M0005', TO_DATE('31-05-2025', 'DD-MM-YYYY'), 0, 'Cancelled', 'Credit Card');
INSERT INTO Booking VALUES ('BK0096', 'M0006', TO_DATE('07-06-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0097', 'M0007', TO_DATE('14-06-2025', 'DD-MM-YYYY'), 0, 'Complete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0098', 'M0008', TO_DATE('21-06-2025', 'DD-MM-YYYY'), 0, 'Cancelled', 'E-Wallet');
INSERT INTO Booking VALUES ('BK0099', 'M0009', TO_DATE('28-06-2025', 'DD-MM-YYYY'), 0, 'Complete', 'Online Banking');
INSERT INTO Booking VALUES ('BK0100', 'M0010', TO_DATE('05-07-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');

INSERT INTO Booking VALUES ('BK0101', 'M0010', TO_DATE('05-07-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0102', 'M0010', TO_DATE('05-07-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0103', 'M0010', TO_DATE('05-07-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0104', 'M0010', TO_DATE('05-07-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');
INSERT INTO Booking VALUES ('BK0105', 'M0010', TO_DATE('05-07-2025', 'DD-MM-YYYY'), 0, 'Incomplete', 'Credit Card');

-- PART 
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (1, 'PRT001', 'Brake Pad', 199, 92.15, TO_DATE('04-08-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (2, 'PRT002', 'Air Filter', 175, 48.95, TO_DATE('18-11-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (3, 'PRT003', 'Oil Filter', 72, 59.26, TO_DATE('20-07-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (4, 'PRT004', 'Spark Plug', 82, 27.76, TO_DATE('17-08-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (5, 'PRT005', 'Alternator', 69, 53.47, TO_DATE('23-01-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (6, 'PRT006', 'Radiator', 193, 26.95, TO_DATE('28-12-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (7, 'PRT007', 'Fuel Pump', 58, 91.45, TO_DATE('26-06-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (8, 'PRT008', 'Timing Belt', 86, 81.51, TO_DATE('09-07-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (9, 'PRT009', 'Battery', 61, 20.12, TO_DATE('04-09-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (10, 'PRT010', 'AC Compressor', 126, 58.91, TO_DATE('16-04-2023','DD-MM-YYYY'), NULL, 1);

INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (11, 'PRT011', 'AC Fan', 126, 58.91, TO_DATE('16-04-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (12, 'PRT012', 'AC Screw', 126, 58.91, TO_DATE('16-04-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (13, 'PRT013', 'Engine Compressor', 126, 58.91, TO_DATE('16-04-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (14, 'PRT014', 'Tyre Compressor', 126, 58.91, TO_DATE('16-04-2023','DD-MM-YYYY'), NULL, 1);
INSERT INTO Part (PartKey, PartID, PartName, StockQuantity, UnitPrice, StartDate, EndDate, IsActive)
VALUES (15, 'PRT015', 'Chair', 126, 58.91, TO_DATE('16-04-2023','DD-MM-YYYY'), NULL, 1);

-- SHOP
INSERT INTO Shop VALUES ('SHP001', 'John''s FreshMart', 'Grocery', 3944.2, 'John Lee', '0161091045');
INSERT INTO Shop VALUES ('SHP002', 'Zara''s The Daily Bun', 'Bakery', 1504.22, 'Zara Ng', '0188990880');
INSERT INTO Shop VALUES ('SHP003', 'Lily''s Giant', 'Grocery', 3616.16, 'Lily Chong', '0176712713');
INSERT INTO Shop VALUES ('SHP004', 'Sara''s 99 SpeedMart', 'Grocery', 1826.56, 'Sara Lee', '0184312042');
INSERT INTO Shop VALUES ('SHP005', 'Zara''s Hair Nest', 'Salon', 1142.0, 'Zara Wong', '0134825185');
INSERT INTO Shop VALUES ('SHP006', 'Raj''s Bread & Butter', 'Bakery', 1422.17, 'Raj Ong', '0198162739');
INSERT INTO Shop VALUES ('SHP007', 'Sara''s Corner Market', 'Grocery', 2504.4, 'Sara Ng', '0164746772');
INSERT INTO Shop VALUES ('SHP008', 'John''s Rise & Roll', 'Bakery', 1759.27, 'John Chong', '0115233146');
INSERT INTO Shop VALUES ('SHP009', 'John''s Hair Do', 'Salon', 1484.33, 'John Ong', '0160426697');
INSERT INTO Shop VALUES ('SHP010', 'John''s PowerHouse', 'Electronics', 2958.69, 'John Smith', '0189527139');
INSERT INTO Shop VALUES ('SHP011', 'Ali''s Bean Scene', 'Cafe', 1762.99, 'Ali Smith', '0195649391');
INSERT INTO Shop VALUES ('SHP012', 'Jane''s StarBucks', 'Cafe', 2516.58, 'Jane Cena', '0125772482');
INSERT INTO Shop VALUES ('SHP013', 'Ahmad''s Style Avenue', 'Clothing', 2214.11, 'Ahmad Ng', '0114748171');
INSERT INTO Shop VALUES ('SHP014', 'Jane''s Cream Pies', 'Bakery', 1955.5, 'Jane Smith', '0194943058');
INSERT INTO Shop VALUES ('SHP015', 'Zara''s Urban Threads', 'Clothing', 2552.55, 'Zara Lim', '0138965057');
INSERT INTO Shop VALUES ('SHP016', 'Ahmad''s Chic Lane', 'Clothing', 2535.67, 'Ahmad Lim', '0171216161');
INSERT INTO Shop VALUES ('SHP017', 'David''s Brewed Awakening', 'Cafe', 2159.94, 'David Kumar', '0134826685');
INSERT INTO Shop VALUES ('SHP018', 'John''s PanaCity', 'Pharmacy', 1739.23, 'John Wong', '0162698385');
INSERT INTO Shop VALUES ('SHP019', 'Raj''s Sweet Crumbs', 'Bakery', 2142.91, 'Raj Kumar', '0189723514');
INSERT INTO Shop VALUES ('SHP020', 'Zara''s Latte Lounge', 'Cafe', 1796.55, 'Zara Lim', '0175300522');
INSERT INTO Shop VALUES ('SHP021', 'Ahmad''s Best Dengi', 'Electronics', 2883.15, 'Ahmad Lee', '0115822725');
INSERT INTO Shop VALUES ('SHP022', 'Mei''s H&M', 'Clothing', 2890.21, 'Mei Tan', '0144722181');
INSERT INTO Shop VALUES ('SHP023', 'Ahmad''s ZUS COFFEE', 'Cafe', 2515.59, 'Ahmad Lim', '0165190057');
INSERT INTO Shop VALUES ('SHP024', 'John''s Techie Stop', 'Electronics', 3822.46, 'John Cena', '0131724711');
INSERT INTO Shop VALUES ('SHP025', 'Zara''s Glamour Touch', 'Salon', 1272.43, 'Zara Chong', '0181595789');
INSERT INTO Shop VALUES ('SHP026', 'Ali''s Caffeine Corner', 'Cafe', 1588.41, 'Ali Cena', '0166818959');
INSERT INTO Shop VALUES ('SHP027', 'Sara''s Cotton Hub', 'Clothing', 2775.15, 'Sara Ng', '0191032605');
INSERT INTO Shop VALUES ('SHP028', 'Jane''s Daily Needs', 'Grocery', 3131.45, 'Jane Chong', '0147480777');
INSERT INTO Shop VALUES ('SHP029', 'Ali''s GadgetZone', 'Electronics', 3404.9, 'Ali Lee', '0124976294');
INSERT INTO Shop VALUES ('SHP030', 'John''s CarePlus', 'Pharmacy', 3428.76, 'John Smith', '0138142404');
INSERT INTO Shop VALUES ('SHP031', 'John''s Green Basket', 'Grocery', 3466.19, 'John Chong', '0175611002');
INSERT INTO Shop VALUES ('SHP032', 'Lily''s Snip Snip', 'Salon', 1825.53, 'Lily Cena', '0170880582');
INSERT INTO Shop VALUES ('SHP033', 'John''s Tiny', 'Grocery', 2573.71, 'John Wong', '0164810459');
INSERT INTO Shop VALUES ('SHP034', 'Jane''s DC Current', 'Electronics', 2162.7, 'Jane Tan', '0117723278');
INSERT INTO Shop VALUES ('SHP035', 'Zara''s Cloth Land', 'Clothing', 2340.0, 'Zara Chong', '0197451637');
INSERT INTO Shop VALUES ('SHP036', 'Lily''s MediTrust', 'Pharmacy', 3368.98, 'Lily Lim', '0128994435');
INSERT INTO Shop VALUES ('SHP037', 'John''s VoltWorld', 'Electronics', 3725.46, 'John Lee', '0179139093');
INSERT INTO Shop VALUES ('SHP038', 'Sara''s PharmaCare', 'Pharmacy', 3514.1, 'Sara Ng', '0161376606');
INSERT INTO Shop VALUES ('SHP039', 'Zara''s AC Current', 'Electronics', 4542.97, 'Zara Lee', '0169030546');
INSERT INTO Shop VALUES ('SHP040', 'Raj''s Urban Curls', 'Salon', 1931.03, 'Raj Abdullah', '0177182436');
INSERT INTO Shop VALUES ('SHP041', 'Raj''s HealthHub', 'Pharmacy', 3041.62, 'Raj Wong', '0126689334');
INSERT INTO Shop VALUES ('SHP042', 'Raj''s Best Dengi', 'Electronics', 5155.28, 'Raj Ong', '0193224121');
INSERT INTO Shop VALUES ('SHP043', 'Ali''s Sweet Crumbs', 'Bakery', 2433.64, 'Ali Kumar', '0177584760');
INSERT INTO Shop VALUES ('SHP044', 'John''s MediTrust', 'Pharmacy', 3204.92, 'John Lee', '0162914135');
INSERT INTO Shop VALUES ('SHP045', 'John''s Techie Stop #2', 'Electronics', 5295.63, 'John Ong', '0125628653');
INSERT INTO Shop VALUES ('SHP046', 'Lily''s Cream Pies', 'Bakery', 1968.63, 'Lily Ong', '0184047150');
INSERT INTO Shop VALUES ('SHP047', 'Ali''s PharmaCare', 'Pharmacy', 2861.27, 'Ali Chong', '0145704135');
INSERT INTO Shop VALUES ('SHP048', 'Sara''s DC Current', 'Electronics', 5144.27, 'Sara Ong', '0191822059');
INSERT INTO Shop VALUES ('SHP049', 'Sara''s GadgetZone', 'Electronics', 5447.14, 'Sara Kumar', '0196861778');
INSERT INTO Shop VALUES ('SHP050', 'John''s FreshMart #2', 'Grocery', 3923.04, 'John Tan', '0194204245');
INSERT INTO Shop VALUES ('SHP051', 'Zara''s Green Basket', 'Grocery', 2327.59, 'Zara Chong', '0129362454');
INSERT INTO Shop VALUES ('SHP052', 'Sara''s Caffeine Corner', 'Cafe', 1790.67, 'Sara Abdullah', '0128561823');
INSERT INTO Shop VALUES ('SHP053', 'Zara''s HealthHub', 'Pharmacy', 1763.5, 'Zara Wong', '0192809328');
INSERT INTO Shop VALUES ('SHP054', 'Sara''s CarePlus', 'Pharmacy', 1867.36, 'Sara Lee', '0116882926');
INSERT INTO Shop VALUES ('SHP055', 'Raj''s Latte Lounge', 'Cafe', 1592.46, 'Raj Lim', '0160295298');
INSERT INTO Shop VALUES ('SHP056', 'John''s CarePlus #2', 'Pharmacy', 3658.93, 'John Smith', '0142634139');
INSERT INTO Shop VALUES ('SHP057', 'Sara''s CarePlus #2', 'Pharmacy', 3752.82, 'Sara Wong', '0141980531');
INSERT INTO Shop VALUES ('SHP058', 'John''s Techie Stop #3', 'Electronics', 2695.24, 'John Lee', '0126836795');
INSERT INTO Shop VALUES ('SHP059', 'John''s Urban Threads', 'Clothing', 2824.46, 'John Tan', '0191665863');
INSERT INTO Shop VALUES ('SHP060', 'Lily''s FreshMart', 'Grocery', 3495.69, 'Lily Kumar', '0146072026');
INSERT INTO Shop VALUES ('SHP061', 'Ahmad''s Snip Snip', 'Salon', 2161.41, 'Ahmad Ong', '0136263704');
INSERT INTO Shop VALUES ('SHP062', 'Mei''s Caffeine Corner', 'Cafe', 2527.59, 'Mei Lee', '0163231163');
INSERT INTO Shop VALUES ('SHP063', 'John''s PharmaCare', 'Pharmacy', 2119.76, 'John Lim', '0175135863');
INSERT INTO Shop VALUES ('SHP064', 'John''s GadgetZone', 'Electronics', 3555.78, 'John Lim', '0115353855');
INSERT INTO Shop VALUES ('SHP065', 'Zara''s Rise & Roll', 'Bakery', 1569.19, 'Zara Chong', '0121614010');
INSERT INTO Shop VALUES ('SHP066', 'Sara''s Hair Do', 'Salon', 1342.89, 'Sara Smith', '0148918114');
INSERT INTO Shop VALUES ('SHP067', 'Zara''s CarePlus', 'Pharmacy', 3690.86, 'Zara Smith', '0117705296');
INSERT INTO Shop VALUES ('SHP068', 'Zara''s StarBucks', 'Cafe', 2230.92, 'Zara Tan', '0194265526');
INSERT INTO Shop VALUES ('SHP069', 'David''s Green Basket', 'Grocery', 1958.68, 'David Lee', '0124460581');
INSERT INTO Shop VALUES ('SHP070', 'Lily''s StarBucks', 'Cafe', 2635.1, 'Lily Smith', '0136270338');
INSERT INTO Shop VALUES ('SHP071', 'Ahmad''s Latte Lounge', 'Cafe', 2601.58, 'Ahmad Ong', '0185926656');
INSERT INTO Shop VALUES ('SHP072', 'Lily''s Chic Lane', 'Clothing', 3092.06, 'Lily Lim', '0147286404');
INSERT INTO Shop VALUES ('SHP073', 'Sara''s CarePlus #3', 'Pharmacy', 3912.32, 'Sara Chong', '0192240452');
INSERT INTO Shop VALUES ('SHP074', 'John''s Cream Pies', 'Bakery', 1898.48, 'John Ng', '0126902364');
INSERT INTO Shop VALUES ('SHP075', 'Zara''s AC Current #2', 'Electronics', 3539.2, 'Zara Tan', '0162936807');
INSERT INTO Shop VALUES ('SHP076', 'Mei''s Brewed Awakening', 'Cafe', 2887.78, 'Mei Kumar', '0170075667');
INSERT INTO Shop VALUES ('SHP077', 'Ali''s PanaCity', 'Pharmacy', 3678.83, 'Ali Ong', '0142089280');
INSERT INTO Shop VALUES ('SHP078', 'Sara''s Glamour Touch', 'Salon', 1527.44, 'Sara Lee', '0174262707');
INSERT INTO Shop VALUES ('SHP079', 'Raj''s DC Current', 'Electronics', 3303.41, 'Raj Chong', '0181686076');
INSERT INTO Shop VALUES ('SHP080', 'Jane''s Glamour Touch', 'Salon', 2194.86, 'Jane Lee', '0137390244');
INSERT INTO Shop VALUES ('SHP081', 'Lily''s Techie Stop', 'Electronics', 2103.97, 'Lily Ng', '0143694251');
INSERT INTO Shop VALUES ('SHP082', 'Raj''s Snip Snip', 'Salon', 1942.36, 'Raj Tan', '0182532971');
INSERT INTO Shop VALUES ('SHP083', 'Jane''s Rise & Roll', 'Bakery', 2374.66, 'Jane Lee', '0167362790');
INSERT INTO Shop VALUES ('SHP084', 'Mei''s HealthHub', 'Pharmacy', 2758.98, 'Mei Smith', '0110586126');
INSERT INTO Shop VALUES ('SHP085', 'Ali''s Glamour Touch', 'Salon', 1099.0, 'Ali Smith', '0117055769');
INSERT INTO Shop VALUES ('SHP086', 'Sara''s Bread & Butter', 'Bakery', 1272.72, 'Sara Ong', '0171537786');
INSERT INTO Shop VALUES ('SHP087', 'John''s Style Avenue', 'Clothing', 3138.69, 'John Chong', '0141746018');
INSERT INTO Shop VALUES ('SHP088', 'Zara''s Style Avenue', 'Clothing', 3397.71, 'Zara Abdullah', '0190215110');
INSERT INTO Shop VALUES ('SHP089', 'Jane''s HealthHub', 'Pharmacy', 3148.18, 'Jane Chong', '0148332680');
INSERT INTO Shop VALUES ('SHP090', 'Jane''s Brewed Awakening', 'Cafe', 2427.65, 'Jane Kumar', '0114648964');
INSERT INTO Shop VALUES ('SHP091', 'Raj''s Best Dengi #2', 'Electronics', 2960.22, 'Raj Ong', '0145162382');
INSERT INTO Shop VALUES ('SHP092', 'Ali''s PowerHouse', 'Electronics', 2056.82, 'Ali Kumar', '0197328294');
INSERT INTO Shop VALUES ('SHP093', 'Jane''s Chic Lane', 'Clothing', 2401.24, 'Jane Ng', '0164349540');
INSERT INTO Shop VALUES ('SHP094', 'Ahmad''s Cotton Hub', 'Clothing', 2291.18, 'Ahmad Kumar', '0112954807');
INSERT INTO Shop VALUES ('SHP095', 'Jane''s Hair Nest', 'Salon', 1021.72, 'Jane Wong', '0196736440');
INSERT INTO Shop VALUES ('SHP096', 'Zara''s Cotton Hub', 'Clothing', 3067.88, 'Zara Tan', '0161206434');
INSERT INTO Shop VALUES ('SHP097', 'Jane''s Hair Nest #2', 'Salon', 1859.31, 'Jane Tan', '0178632933');
INSERT INTO Shop VALUES ('SHP098', 'Jane''s Chic Lane #2', 'Clothing', 2158.81, 'Jane Ng', '0117809519');
INSERT INTO Shop VALUES ('SHP099', 'John''s PowerHouse #2', 'Electronics', 5349.66, 'John Ong', '0140078021');
INSERT INTO Shop VALUES ('SHP100', 'Lily''s PharmaCare', 'Pharmacy', 3379.41, 'Lily Tan', '0119219564');

INSERT INTO Shop VALUES ('SHP101', 'Jon''s Cotton Hub', 'Clothing', 3067.88, 'Zara Tane', '0161206434');
INSERT INTO Shop VALUES ('SHP102', 'Chinget''s Hair Nest #2', 'Salon', 1859.31, 'Jane Tagn', '0178632933');
INSERT INTO Shop VALUES ('SHP103', 'Ediii''s Chic Lane #2', 'Clothing', 2158.81, 'Jane Ngi', '0117809519');
INSERT INTO Shop VALUES ('SHP104', 'Miiiii''s PowerHouse #2', 'Electronics', 5349.66, 'John Bong', '0140078021');
INSERT INTO Shop VALUES ('SHP105', 'KellI''s PharmaCare', 'Pharmacy', 3379.41, 'Lily TanG', '0119219564');



----------------------------------------------------------------------------------------------------------------------------
-- ROUND 2
-- RentalCollection

INSERT INTO RentalCollection VALUES ('COL001', 'SHP076', 'STF007', DATE '2025-03-15', 4250.25, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL002', 'SHP020', 'STF004', DATE '2023-07-31', 703.99, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL003', 'SHP025', 'STF002', DATE '2023-02-22', 2626.48, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL004', 'SHP056', 'STF010', DATE '2025-02-16', 3969.39, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL005', 'SHP037', 'STF007', DATE '2024-03-26', 528.25, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL006', 'SHP037', 'STF008', DATE '2023-10-20', 3531.53, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL007', 'SHP100', 'STF003', DATE '2023-08-06', 3917.02, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL008', 'SHP014', 'STF004', DATE '2024-06-16', 1250.49, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL009', 'SHP019', 'STF006', DATE '2022-12-23', 4884.67, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL010', 'SHP046', 'STF002', DATE '2025-03-23', 1959.68, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL011', 'SHP004', 'STF001', DATE '2023-09-15', 2291.54, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL012', 'SHP089', 'STF002', DATE '2022-12-05', 4455.56, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL013', 'SHP053', 'STF005', DATE '2023-01-31', 2477.07, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL014', 'SHP071', 'STF001', DATE '2025-05-07', 4579.75, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL015', 'SHP013', 'STF004', DATE '2022-06-08', 3489.44, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL016', 'SHP013', 'STF002', DATE '2024-12-18', 2754.32, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL017', 'SHP061', 'STF007', DATE '2023-08-16', 1871.96, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL018', 'SHP087', 'STF009', DATE '2023-01-19', 4743.55, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL019', 'SHP048', 'STF005', DATE '2023-01-30', 2957.04, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL020', 'SHP028', 'STF006', DATE '2022-02-05', 2723.34, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL021', 'SHP071', 'STF001', DATE '2025-05-09', 2490.69, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL022', 'SHP014', 'STF001', DATE '2023-10-15', 1597.59, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL023', 'SHP088', 'STF006', DATE '2022-08-15', 927.6, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL024', 'SHP032', 'STF002', DATE '2023-03-28', 1452.51, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL025', 'SHP040', 'STF007', DATE '2023-12-23', 819.02, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL026', 'SHP045', 'STF009', DATE '2025-05-15', 4572.85, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL027', 'SHP065', 'STF001', DATE '2023-06-19', 1382.61, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL028', 'SHP056', 'STF006', DATE '2022-12-25', 2361.52, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL029', 'SHP044', 'STF004', DATE '2023-04-28', 961.83, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL030', 'SHP030', 'STF001', DATE '2024-02-06', 3291.59, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL031', 'SHP017', 'STF008', DATE '2023-06-28', 2494.13, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL032', 'SHP027', 'STF007', DATE '2024-06-30', 4069.44, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL033', 'SHP092', 'STF010', DATE '2025-04-12', 2624.08, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL034', 'SHP052', 'STF004', DATE '2024-02-12', 4485.56, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL035', 'SHP080', 'STF002', DATE '2023-09-01', 1181.54, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL036', 'SHP098', 'STF007', DATE '2024-01-23', 592.93, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL037', 'SHP090', 'STF004', DATE '2024-08-25', 2119.72, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL038', 'SHP073', 'STF001', DATE '2025-02-12', 4004.52, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL039', 'SHP084', 'STF006', DATE '2025-02-12', 2478.25, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL040', 'SHP058', 'STF010', DATE '2024-01-27', 1917.22, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL041', 'SHP026', 'STF002', DATE '2025-03-17', 2310.49, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL042', 'SHP053', 'STF002', DATE '2022-02-06', 4949.53, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL043', 'SHP005', 'STF004', DATE '2022-12-13', 1616.88, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL044', 'SHP077', 'STF009', DATE '2022-03-08', 3908.49, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL045', 'SHP069', 'STF007', DATE '2023-09-07', 4984.26, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL046', 'SHP096', 'STF009', DATE '2022-04-09', 2648.64, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL047', 'SHP023', 'STF002', DATE '2024-04-24', 3467.47, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL048', 'SHP024', 'STF009', DATE '2025-03-20', 4330.31, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL049', 'SHP009', 'STF001', DATE '2022-05-22', 4825.0, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL050', 'SHP001', 'STF001', DATE '2024-12-06', 1749.39, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL051', 'SHP015', 'STF003', DATE '2025-06-08', 4702.09, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL052', 'SHP018', 'STF007', DATE '2023-06-04', 3817.68, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL053', 'SHP093', 'STF008', DATE '2023-03-08', 2597.57, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL054', 'SHP030', 'STF005', DATE '2025-01-24', 4576.43, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL055', 'SHP064', 'STF003', DATE '2023-09-19', 2242.23, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL056', 'SHP077', 'STF001', DATE '2023-06-13', 3946.04, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL057', 'SHP060', 'STF004', DATE '2022-10-23', 4301.67, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL058', 'SHP023', 'STF001', DATE '2022-07-30', 4886.84, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL059', 'SHP087', 'STF006', DATE '2024-01-29', 4684.13, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL060', 'SHP064', 'STF009', DATE '2022-06-02', 884.35, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL061', 'SHP085', 'STF010', DATE '2024-11-07', 4550.29, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL062', 'SHP081', 'STF008', DATE '2025-06-27', 2539.81, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL063', 'SHP061', 'STF003', DATE '2023-07-23', 4424.44, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL064', 'SHP024', 'STF005', DATE '2024-12-29', 4539.81, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL065', 'SHP039', 'STF001', DATE '2022-07-21', 4738.12, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL066', 'SHP091', 'STF009', DATE '2023-12-08', 3533.85, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL067', 'SHP046', 'STF003', DATE '2025-01-04', 2144.92, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL068', 'SHP029', 'STF009', DATE '2024-06-17', 2215.29, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL069', 'SHP020', 'STF007', DATE '2022-05-04', 2512.14, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL070', 'SHP093', 'STF004', DATE '2022-09-06', 2034.1, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL071', 'SHP009', 'STF004', DATE '2025-06-27', 2036.67, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL072', 'SHP042', 'STF003', DATE '2025-03-21', 3215.41, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL073', 'SHP048', 'STF005', DATE '2022-12-04', 3398.07, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL074', 'SHP089', 'STF010', DATE '2022-07-29', 1047.52, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL075', 'SHP085', 'STF007', DATE '2025-03-15', 3852.0, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL076', 'SHP030', 'STF007', DATE '2024-06-14', 643.45, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL077', 'SHP045', 'STF003', DATE '2022-06-21', 1001.42, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL078', 'SHP041', 'STF003', DATE '2024-01-18', 1778.28, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL079', 'SHP050', 'STF002', DATE '2022-02-02', 4690.9, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL080', 'SHP073', 'STF001', DATE '2025-05-21', 1521.55, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL081', 'SHP009', 'STF008', DATE '2024-08-08', 4998.14, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL082', 'SHP006', 'STF009', DATE '2024-06-02', 4033.74, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL083', 'SHP011', 'STF006', DATE '2024-07-23', 2171.45, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL084', 'SHP086', 'STF009', DATE '2023-02-25', 4308.86, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL085', 'SHP029', 'STF001', DATE '2022-05-31', 970.17, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL086', 'SHP037', 'STF006', DATE '2025-06-20', 1156.0, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL087', 'SHP034', 'STF010', DATE '2023-07-22', 2702.91, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL088', 'SHP060', 'STF006', DATE '2023-10-11', 2992.11, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL089', 'SHP023', 'STF003', DATE '2025-05-27', 4278.56, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL090', 'SHP027', 'STF007', DATE '2025-01-01', 836.95, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL091', 'SHP068', 'STF001', DATE '2022-11-21', 4774.2, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL092', 'SHP005', 'STF005', DATE '2023-12-09', 3820.44, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL093', 'SHP077', 'STF009', DATE '2025-04-24', 3648.11, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL094', 'SHP099', 'STF006', DATE '2023-06-14', 2210.6, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL095', 'SHP010', 'STF006', DATE '2023-06-09', 1762.2, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL096', 'SHP043', 'STF002', DATE '2022-12-07', 2724.91, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL097', 'SHP090', 'STF002', DATE '2022-01-26', 1512.32, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL098', 'SHP072', 'STF004', DATE '2022-10-21', 1087.45, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL099', 'SHP100', 'STF005', DATE '2023-06-22', 4942.89, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL100', 'SHP095', 'STF003', DATE '2024-01-17', 4731.32, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL101', 'SHP035', 'STF008', DATE '2024-12-31', 2330.41, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL102', 'SHP089', 'STF006', DATE '2024-11-26', 3396.77, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL103', 'SHP062', 'STF004', DATE '2022-06-11', 1649.6, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL104', 'SHP009', 'STF001', DATE '2023-01-04', 851.56, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL105', 'SHP007', 'STF008', DATE '2023-12-11', 1558.59, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL106', 'SHP081', 'STF001', DATE '2023-11-12', 4510.44, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL107', 'SHP039', 'STF010', DATE '2022-02-03', 1350.97, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL108', 'SHP089', 'STF009', DATE '2025-04-13', 1302.06, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL109', 'SHP096', 'STF007', DATE '2022-01-12', 1535.45, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL110', 'SHP004', 'STF008', DATE '2023-11-15', 1733.38, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL111', 'SHP029', 'STF001', DATE '2024-08-08', 3811.23, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL112', 'SHP090', 'STF010', DATE '2023-02-03', 3300.49, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL113', 'SHP016', 'STF008', DATE '2024-08-06', 2059.42, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL114', 'SHP055', 'STF008', DATE '2023-03-29', 1837.66, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL115', 'SHP084', 'STF005', DATE '2023-09-05', 931.12, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL116', 'SHP060', 'STF010', DATE '2024-06-09', 3736.67, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL117', 'SHP045', 'STF002', DATE '2025-05-29', 792.55, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL118', 'SHP007', 'STF008', DATE '2023-12-09', 3866.04, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL119', 'SHP085', 'STF007', DATE '2022-01-08', 4323.4, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL120', 'SHP013', 'STF007', DATE '2022-02-09', 4283.32, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL121', 'SHP034', 'STF005', DATE '2025-04-20', 4458.69, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL122', 'SHP092', 'STF006', DATE '2025-01-22', 3051.9, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL123', 'SHP090', 'STF003', DATE '2024-10-03', 618.8, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL124', 'SHP068', 'STF002', DATE '2023-05-27', 2239.9, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL125', 'SHP005', 'STF005', DATE '2023-08-02', 1396.12, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL126', 'SHP082', 'STF008', DATE '2022-05-09', 1955.64, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL127', 'SHP026', 'STF008', DATE '2022-09-02', 1731.61, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL128', 'SHP047', 'STF004', DATE '2023-07-01', 3699.12, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL129', 'SHP086', 'STF010', DATE '2023-09-23', 2514.3, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL130', 'SHP089', 'STF010', DATE '2022-03-18', 587.99, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL131', 'SHP094', 'STF009', DATE '2023-12-31', 998.21, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL132', 'SHP090', 'STF005', DATE '2022-03-24', 2242.18, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL133', 'SHP078', 'STF005', DATE '2022-01-05', 561.5, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL134', 'SHP045', 'STF008', DATE '2025-04-14', 2673.75, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL135', 'SHP004', 'STF008', DATE '2024-09-27', 4394.74, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL136', 'SHP024', 'STF009', DATE '2024-07-19', 751.67, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL137', 'SHP100', 'STF001', DATE '2023-04-12', 2879.96, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL138', 'SHP033', 'STF001', DATE '2024-11-08', 1769.63, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL139', 'SHP020', 'STF005', DATE '2023-03-31', 2107.81, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL140', 'SHP028', 'STF003', DATE '2023-03-15', 3572.63, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL141', 'SHP091', 'STF002', DATE '2023-12-23', 2771.69, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL142', 'SHP088', 'STF007', DATE '2024-10-14', 4422.24, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL143', 'SHP073', 'STF002', DATE '2024-05-07', 3463.06, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL144', 'SHP070', 'STF006', DATE '2023-06-15', 3495.9, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL145', 'SHP095', 'STF006', DATE '2024-04-28', 1498.55, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL146', 'SHP088', 'STF004', DATE '2024-04-29', 2259.11, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL147', 'SHP049', 'STF010', DATE '2022-01-07', 3001.57, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL148', 'SHP039', 'STF004', DATE '2022-08-28', 1526.74, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL149', 'SHP052', 'STF005', DATE '2025-05-30', 1858.68, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL150', 'SHP080', 'STF008', DATE '2022-12-28', 3724.46, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL151', 'SHP031', 'STF007', DATE '2025-06-19', 2446.19, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL152', 'SHP037', 'STF002', DATE '2024-10-22', 3362.41, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL153', 'SHP086', 'STF002', DATE '2022-06-19', 4313.52, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL154', 'SHP080', 'STF009', DATE '2024-04-09', 2835.65, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL155', 'SHP079', 'STF001', DATE '2023-01-18', 3551.33, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL156', 'SHP027', 'STF002', DATE '2025-01-26', 2029.7, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL157', 'SHP076', 'STF004', DATE '2023-08-17', 4015.88, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL158', 'SHP024', 'STF009', DATE '2023-08-25', 3830.53, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL159', 'SHP090', 'STF002', DATE '2024-10-20', 3457.76, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL160', 'SHP035', 'STF005', DATE '2024-08-11', 4926.1, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL161', 'SHP060', 'STF001', DATE '2025-02-08', 3267.34, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL162', 'SHP021', 'STF009', DATE '2022-07-07', 1772.24, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL163', 'SHP050', 'STF002', DATE '2022-12-16', 2605.79, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL164', 'SHP039', 'STF001', DATE '2024-04-24', 1203.6, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL165', 'SHP054', 'STF001', DATE '2024-11-26', 2138.1, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL166', 'SHP004', 'STF008', DATE '2022-01-13', 2024.93, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL167', 'SHP045', 'STF001', DATE '2024-09-27', 3380.1, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL168', 'SHP084', 'STF001', DATE '2024-04-21', 1642.05, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL169', 'SHP021', 'STF005', DATE '2022-01-25', 3707.12, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL170', 'SHP043', 'STF003', DATE '2024-07-24', 753.31, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL171', 'SHP077', 'STF001', DATE '2022-10-25', 1753.18, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL172', 'SHP065', 'STF006', DATE '2022-07-18', 2084.14, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL173', 'SHP059', 'STF004', DATE '2023-08-30', 2504.1, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL174', 'SHP015', 'STF008', DATE '2025-04-03', 3426.22, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL175', 'SHP074', 'STF010', DATE '2023-06-09', 4451.86, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL176', 'SHP024', 'STF010', DATE '2022-11-03', 2026.38, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL177', 'SHP019', 'STF009', DATE '2022-10-06', 3774.58, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL178', 'SHP099', 'STF009', DATE '2022-07-25', 4523.39, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL179', 'SHP024', 'STF001', DATE '2024-08-05', 4914.63, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL180', 'SHP029', 'STF003', DATE '2025-05-08', 501.78, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL181', 'SHP055', 'STF006', DATE '2022-12-30', 1829.58, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL182', 'SHP088', 'STF001', DATE '2024-06-08', 3232.07, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL183', 'SHP062', 'STF010', DATE '2023-08-21', 4382.15, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL184', 'SHP054', 'STF003', DATE '2022-11-05', 2354.42, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL185', 'SHP062', 'STF004', DATE '2024-06-28', 3684.14, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL186', 'SHP076', 'STF003', DATE '2022-02-19', 3494.68, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL187', 'SHP099', 'STF007', DATE '2022-12-27', 1345.96, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL188', 'SHP067', 'STF001', DATE '2022-04-19', 4455.91, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL189', 'SHP098', 'STF009', DATE '2022-08-15', 3690.46, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL190', 'SHP036', 'STF006', DATE '2023-09-09', 4343.39, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL191', 'SHP039', 'STF005', DATE '2024-06-17', 4788.07, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL192', 'SHP034', 'STF003', DATE '2023-11-24', 632.88, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL193', 'SHP092', 'STF004', DATE '2024-04-20', 4493.23, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL194', 'SHP030', 'STF003', DATE '2022-03-12', 1590.45, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL195', 'SHP063', 'STF006', DATE '2025-03-12', 3870.39, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL196', 'SHP028', 'STF003', DATE '2023-08-24', 607.35, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL197', 'SHP011', 'STF006', DATE '2024-12-09', 2127.7, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL198', 'SHP013', 'STF009', DATE '2025-04-30', 1062.83, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL199', 'SHP062', 'STF008', DATE '2022-05-24', 1608.77, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL200', 'SHP069', 'STF002', DATE '2025-01-18', 2528.5, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL201', 'SHP036', 'STF009', DATE '2022-09-23', 952.59, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL202', 'SHP093', 'STF010', DATE '2023-03-15', 4385.16, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL203', 'SHP037', 'STF001', DATE '2022-03-16', 3999.23, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL204', 'SHP089', 'STF010', DATE '2024-12-09', 3212.09, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL205', 'SHP058', 'STF002', DATE '2022-05-25', 3983.33, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL206', 'SHP021', 'STF004', DATE '2022-09-19', 1464.0, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL207', 'SHP094', 'STF005', DATE '2024-02-04', 4218.04, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL208', 'SHP003', 'STF009', DATE '2022-03-11', 613.65, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL209', 'SHP016', 'STF010', DATE '2022-01-01', 869.34, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL210', 'SHP082', 'STF002', DATE '2023-07-25', 3129.27, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL211', 'SHP052', 'STF010', DATE '2022-09-08', 3333.53, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL212', 'SHP050', 'STF003', DATE '2022-10-16', 2806.98, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL213', 'SHP005', 'STF007', DATE '2024-08-02', 2563.71, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL214', 'SHP079', 'STF007', DATE '2024-02-03', 1885.57, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL215', 'SHP072', 'STF003', DATE '2024-03-07', 722.33, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL216', 'SHP078', 'STF004', DATE '2022-08-17', 3485.39, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL217', 'SHP027', 'STF003', DATE '2023-06-08', 3354.71, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL218', 'SHP077', 'STF004', DATE '2024-06-18', 1958.95, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL219', 'SHP052', 'STF001', DATE '2024-05-04', 2409.85, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL220', 'SHP021', 'STF003', DATE '2023-10-17', 1485.18, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL221', 'SHP067', 'STF005', DATE '2022-04-09', 2293.14, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL222', 'SHP037', 'STF003', DATE '2024-11-26', 3317.06, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL223', 'SHP028', 'STF006', DATE '2022-06-09', 4446.55, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL224', 'SHP018', 'STF009', DATE '2023-10-01', 2617.01, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL225', 'SHP092', 'STF007', DATE '2022-12-31', 854.12, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL226', 'SHP056', 'STF008', DATE '2023-06-03', 3077.03, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL227', 'SHP041', 'STF004', DATE '2025-02-25', 2044.14, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL228', 'SHP003', 'STF002', DATE '2022-09-10', 2788.29, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL229', 'SHP012', 'STF007', DATE '2024-07-23', 1857.87, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL230', 'SHP099', 'STF006', DATE '2022-07-21', 1925.45, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL231', 'SHP002', 'STF007', DATE '2024-02-23', 3589.41, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL232', 'SHP035', 'STF002', DATE '2024-01-08', 1325.6, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL233', 'SHP094', 'STF002', DATE '2022-01-17', 2544.65, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL234', 'SHP063', 'STF009', DATE '2022-01-04', 3619.41, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL235', 'SHP100', 'STF006', DATE '2023-12-17', 4030.44, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL236', 'SHP019', 'STF006', DATE '2024-12-13', 4349.38, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL237', 'SHP074', 'STF009', DATE '2024-03-02', 4033.68, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL238', 'SHP055', 'STF008', DATE '2022-07-05', 1336.7, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL239', 'SHP059', 'STF004', DATE '2022-04-15', 969.38, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL240', 'SHP047', 'STF004', DATE '2022-04-17', 2104.42, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL241', 'SHP003', 'STF005', DATE '2023-03-27', 2369.65, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL242', 'SHP076', 'STF002', DATE '2025-06-10', 1550.39, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL243', 'SHP003', 'STF002', DATE '2023-10-06', 3342.36, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL244', 'SHP034', 'STF010', DATE '2024-01-05', 2947.56, 'eWallet', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL245', 'SHP024', 'STF005', DATE '2024-02-01', 4175.22, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL246', 'SHP018', 'STF003', DATE '2024-04-08', 1914.79, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL247', 'SHP077', 'STF009', DATE '2025-02-06', 954.68, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL248', 'SHP067', 'STF004', DATE '2023-07-16', 3581.28, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL249', 'SHP060', 'STF004', DATE '2024-01-16', 705.1, 'Credit Card', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL250', 'SHP074', 'STF007', DATE '2024-05-29', 4810.27, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL251', 'SHP080', 'STF009', DATE '2022-02-14', 4645.64, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL252', 'SHP042', 'STF005', DATE '2023-08-27', 2760.46, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL253', 'SHP091', 'STF006', DATE '2023-08-31', 2191.75, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL254', 'SHP042', 'STF003', DATE '2023-07-23', 954.96, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL255', 'SHP097', 'STF004', DATE '2025-02-19', 4242.9, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL256', 'SHP009', 'STF002', DATE '2023-10-30', 2204.39, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL257', 'SHP079', 'STF002', DATE '2024-02-18', 3456.96, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL258', 'SHP095', 'STF003', DATE '2023-11-26', 4705.4, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL259', 'SHP019', 'STF003', DATE '2025-06-02', 3900.63, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL260', 'SHP077', 'STF009', DATE '2024-07-14', 2501.9, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL261', 'SHP040', 'STF004', DATE '2022-12-11', 2329.07, 'Credit Card', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL262', 'SHP026', 'STF003', DATE '2022-05-27', 3566.26, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL263', 'SHP010', 'STF008', DATE '2024-07-15', 4736.95, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL264', 'SHP078', 'STF010', DATE '2024-07-28', 3055.15, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL265', 'SHP005', 'STF007', DATE '2022-05-21', 4992.11, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL266', 'SHP079', 'STF009', DATE '2025-06-26', 2147.48, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL267', 'SHP060', 'STF003', DATE '2023-11-20', 1725.46, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL268', 'SHP060', 'STF002', DATE '2024-04-03', 1339.79, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL269', 'SHP043', 'STF004', DATE '2022-03-07', 3632.29, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL270', 'SHP025', 'STF009', DATE '2025-05-13', 4767.28, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL271', 'SHP098', 'STF009', DATE '2022-12-23', 1418.64, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL272', 'SHP074', 'STF005', DATE '2023-06-20', 1880.77, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL273', 'SHP032', 'STF005', DATE '2024-09-12', 3977.7, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL274', 'SHP031', 'STF008', DATE '2025-06-13', 3928.47, 'Bank Transfer', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL275', 'SHP054', 'STF006', DATE '2024-09-29', 1684.14, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL276', 'SHP052', 'STF005', DATE '2025-03-14', 1305.87, 'Cash', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL277', 'SHP070', 'STF006', DATE '2022-07-22', 1203.95, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL278', 'SHP014', 'STF009', DATE '2025-01-13', 4982.15, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL279', 'SHP086', 'STF008', DATE '2022-08-10', 1474.92, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL280', 'SHP072', 'STF009', DATE '2025-03-30', 1094.88, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL281', 'SHP029', 'STF001', DATE '2024-09-29', 2192.6, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL282', 'SHP041', 'STF007', DATE '2023-06-22', 1575.93, 'Credit Card', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL283', 'SHP082', 'STF005', DATE '2024-10-21', 3992.07, 'Bank Transfer', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL284', 'SHP056', 'STF002', DATE '2025-05-04', 2801.71, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL285', 'SHP075', 'STF006', DATE '2022-08-27', 2774.58, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL286', 'SHP041', 'STF006', DATE '2025-01-31', 674.25, 'Cash', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL287', 'SHP057', 'STF005', DATE '2024-01-26', 700.53, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL288', 'SHP009', 'STF006', DATE '2022-06-02', 3190.28, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL289', 'SHP048', 'STF009', DATE '2025-03-08', 4096.82, 'Credit Card', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL290', 'SHP061', 'STF006', DATE '2025-01-24', 1883.57, 'Bank Transfer', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL291', 'SHP037', 'STF004', DATE '2023-09-12', 4921.95, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL292', 'SHP073', 'STF006', DATE '2024-11-01', 4926.18, 'eWallet', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL293', 'SHP017', 'STF006', DATE '2022-07-07', 4739.19, 'Cash', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL294', 'SHP023', 'STF005', DATE '2023-01-22', 4565.94, 'Cash', 'Late payment');
INSERT INTO RentalCollection VALUES ('COL295', 'SHP075', 'STF006', DATE '2024-07-08', 4650.68, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL296', 'SHP087', 'STF007', DATE '2025-05-18', 3501.24, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL297', 'SHP042', 'STF002', DATE '2022-12-09', 3557.52, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL298', 'SHP073', 'STF003', DATE '2024-10-02', 2675.49, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL299', 'SHP029', 'STF005', DATE '2025-03-30', 1072.53, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL300', 'SHP081', 'STF001', DATE '2023-10-13', 1162.03, 'Cash', 'Paid on time');

INSERT INTO RentalCollection VALUES ('COL301', 'SHP087', 'STF007', DATE '2025-05-18', 2501.24, 'Bank Transfer', 'Paid on time');
INSERT INTO RentalCollection VALUES ('COL302', 'SHP042', 'STF002', DATE '2022-12-09', 1557.52, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL303', 'SHP073', 'STF003', DATE '2024-10-02', 5675.49, 'eWallet', DEFAULT);
INSERT INTO RentalCollection VALUES ('COL304', 'SHP029', 'STF005', DATE '2025-03-30', 1072.53, 'eWallet', 'Partial payment');
INSERT INTO RentalCollection VALUES ('COL305', 'SHP081', 'STF001', DATE '2023-10-13', 2162.03, 'Cash', 'Paid on time');

-- Maintenance
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00001', 'B0023', 'SV010', 0.0, DEFAULT, TO_DATE('31-Mar-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00002', 'B0048', 'SV003', 0.0, DEFAULT, TO_DATE('12-Feb-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00003', 'B0008', 'SV006', 0.0, DEFAULT, TO_DATE('23-Apr-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00004', 'B0097', 'SV003', 0.0, DEFAULT, TO_DATE('16-Mar-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00005', 'B0059', 'SV008', 0.0, DEFAULT, TO_DATE('09-Jul-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00006', 'B0032', 'SV006', 0.0, DEFAULT, TO_DATE('13-Dec-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00007', 'B0060', 'SV005', 0.0, DEFAULT, TO_DATE('07-Mar-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00008', 'B0058', 'SV009', 0.0, DEFAULT, TO_DATE('25-Aug-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00009', 'B0077', 'SV002', 0.0, DEFAULT, TO_DATE('16-Apr-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00010', 'B0064', 'SV009', 0.0, DEFAULT, TO_DATE('29-Nov-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00011', 'B0023', 'SV005', 0.0, DEFAULT, TO_DATE('02-Jul-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00012', 'B0041', 'SV010', 0.0, DEFAULT, TO_DATE('06-Sep-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00013', 'B0015', 'SV001', 0.0, DEFAULT, TO_DATE('31-Dec-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00014', 'B0021', 'SV006', 0.0, DEFAULT, TO_DATE('07-Mar-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00015', 'B0009', 'SV005', 0.0, DEFAULT, TO_DATE('21-Mar-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00016', 'B0047', 'SV002', 0.0, DEFAULT, TO_DATE('25-Dec-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00017', 'B0072', 'SV008', 0.0, DEFAULT, TO_DATE('27-May-2023', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00018', 'B0066', 'SV005', 0.0, DEFAULT, TO_DATE('04-Jun-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00019', 'B0028', 'SV008', 0.0, DEFAULT, TO_DATE('30-Jun-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00020', 'B0014', 'SV003', 0.0, DEFAULT, TO_DATE('04-Jul-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00021', 'B0082', 'SV004', 0.0, DEFAULT, TO_DATE('13-Feb-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00022', 'B0055', 'SV007', 0.0, DEFAULT, TO_DATE('31-Aug-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00023', 'B0084', 'SV008', 0.0, DEFAULT, TO_DATE('08-Nov-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00024', 'B0019', 'SV004', 0.0, DEFAULT, TO_DATE('13-Nov-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00025', 'B0009', 'SV005', 0.0, DEFAULT, TO_DATE('19-Mar-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00026', 'B0033', 'SV004', 0.0, DEFAULT, TO_DATE('18-Jan-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00027', 'B0062', 'SV006', 0.0, DEFAULT, TO_DATE('19-Mar-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00028', 'B0008', 'SV006', 0.0, DEFAULT, TO_DATE('09-Oct-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00029', 'B0066', 'SV001', 0.0, DEFAULT, TO_DATE('28-Oct-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00030', 'B0055', 'SV007', 0.0, DEFAULT, TO_DATE('13-Jan-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00031', 'B0059', 'SV003', 0.0, DEFAULT, TO_DATE('08-Dec-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00032', 'B0087', 'SV009', 0.0, DEFAULT, TO_DATE('08-Sep-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00033', 'B0073', 'SV002', 0.0, DEFAULT, TO_DATE('28-Oct-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00034', 'B0058', 'SV007', 0.0, DEFAULT, TO_DATE('18-Oct-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00035', 'B0072', 'SV001', 0.0, DEFAULT, TO_DATE('31-Mar-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00036', 'B0062', 'SV005', 0.0, DEFAULT, TO_DATE('17-Apr-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00037', 'B0079', 'SV007', 0.0, DEFAULT, TO_DATE('15-Oct-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00038', 'B0095', 'SV002', 0.0, DEFAULT, TO_DATE('26-Jul-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00039', 'B0088', 'SV005', 0.0, DEFAULT, TO_DATE('04-Jul-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00040', 'B0062', 'SV010', 0.0, DEFAULT, TO_DATE('05-Jan-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00041', 'B0083', 'SV007', 0.0, DEFAULT, TO_DATE('12-Sep-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00042', 'B0007', 'SV002', 0.0, DEFAULT, TO_DATE('11-Jun-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00043', 'B0081', 'SV004', 0.0, DEFAULT, TO_DATE('30-May-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00044', 'B0080', 'SV005', 0.0, DEFAULT, TO_DATE('21-Dec-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00045', 'B0056', 'SV003', 0.0, DEFAULT, TO_DATE('28-Aug-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00046', 'B0061', 'SV003', 0.0, DEFAULT, TO_DATE('27-Jun-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00047', 'B0059', 'SV002', 0.0, DEFAULT, TO_DATE('21-Apr-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00048', 'B0095', 'SV002', 0.0, DEFAULT, TO_DATE('13-Apr-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00049', 'B0072', 'SV007', 0.0, DEFAULT, TO_DATE('02-Feb-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00050', 'B0034', 'SV008', 0.0, DEFAULT, TO_DATE('09-Aug-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00051', 'B0028', 'SV006', 0.0, DEFAULT, TO_DATE('12-Sep-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00052', 'B0024', 'SV004', 0.0, DEFAULT, TO_DATE('01-Apr-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00053', 'B0002', 'SV001', 0.0, DEFAULT, TO_DATE('30-May-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00054', 'B0014', 'SV002', 0.0, DEFAULT, TO_DATE('11-Sep-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00055', 'B0010', 'SV004', 0.0, DEFAULT, TO_DATE('02-Nov-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00056', 'B0074', 'SV004', 0.0, DEFAULT, TO_DATE('08-Jan-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00057', 'B0029', 'SV002', 0.0, DEFAULT, TO_DATE('19-Oct-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00058', 'B0001', 'SV006', 0.0, DEFAULT, TO_DATE('20-Feb-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00059', 'B0060', 'SV010', 0.0, DEFAULT, TO_DATE('23-Sep-2023', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00060', 'B0097', 'SV002', 0.0, DEFAULT, TO_DATE('08-Jul-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00061', 'B0072', 'SV001', 0.0, DEFAULT, TO_DATE('17-Apr-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00062', 'B0051', 'SV009', 0.0, DEFAULT, TO_DATE('06-Jul-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00063', 'B0036', 'SV004', 0.0, DEFAULT, TO_DATE('30-Aug-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00064', 'B0011', 'SV003', 0.0, DEFAULT, TO_DATE('27-Nov-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00065', 'B0024', 'SV004', 0.0, DEFAULT, TO_DATE('25-Nov-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00066', 'B0096', 'SV008', 0.0, DEFAULT, TO_DATE('03-Sep-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00067', 'B0002', 'SV010', 0.0, DEFAULT, TO_DATE('17-Aug-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00068', 'B0026', 'SV009', 0.0, DEFAULT, TO_DATE('18-May-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00069', 'B0037', 'SV006', 0.0, DEFAULT, TO_DATE('02-Dec-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00070', 'B0064', 'SV004', 0.0, DEFAULT, TO_DATE('15-May-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00071', 'B0052', 'SV010', 0.0, DEFAULT, TO_DATE('20-Feb-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00072', 'B0024', 'SV003', 0.0, DEFAULT, TO_DATE('04-Nov-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00073', 'B0043', 'SV001', 0.0, DEFAULT, TO_DATE('29-Sep-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00074', 'B0071', 'SV003', 0.0, DEFAULT, TO_DATE('06-Jan-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00075', 'B0016', 'SV001', 0.0, DEFAULT, TO_DATE('19-Nov-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00076', 'B0093', 'SV004', 0.0, DEFAULT, TO_DATE('28-Apr-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00077', 'B0064', 'SV010', 0.0, DEFAULT, TO_DATE('16-Jan-2023', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00078', 'B0061', 'SV010', 0.0, DEFAULT, TO_DATE('19-Jan-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00079', 'B0074', 'SV005', 0.0, DEFAULT, TO_DATE('09-Nov-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00080', 'B0031', 'SV006', 0.0, DEFAULT, TO_DATE('10-Jul-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00081', 'B0070', 'SV004', 0.0, DEFAULT, TO_DATE('27-Feb-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00082', 'B0068', 'SV010', 0.0, DEFAULT, TO_DATE('06-Dec-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00083', 'B0036', 'SV009', 0.0, DEFAULT, TO_DATE('18-Jul-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00084', 'B0001', 'SV010', 0.0, DEFAULT, TO_DATE('17-Jun-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00085', 'B0069', 'SV001', 0.0, DEFAULT, TO_DATE('12-May-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00086', 'B0051', 'SV006', 0.0, DEFAULT, TO_DATE('19-Oct-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00087', 'B0095', 'SV003', 0.0, DEFAULT, TO_DATE('24-Mar-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00088', 'B0013', 'SV003', 0.0, DEFAULT, TO_DATE('03-Feb-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00089', 'B0017', 'SV003', 0.0, DEFAULT, TO_DATE('18-May-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00090', 'B0010', 'SV002', 0.0, DEFAULT, TO_DATE('15-Dec-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00091', 'B0004', 'SV002', 0.0, DEFAULT, TO_DATE('29-Aug-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00092', 'B0030', 'SV001', 0.0, DEFAULT, TO_DATE('19-Dec-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00093', 'B0078', 'SV002', 0.0, DEFAULT, TO_DATE('10-Dec-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00094', 'B0001', 'SV004', 0.0, DEFAULT, TO_DATE('24-Aug-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00095', 'B0044', 'SV007', 0.0, DEFAULT, TO_DATE('10-Mar-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00096', 'B0028', 'SV006', 0.0, DEFAULT, TO_DATE('01-Jan-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00097', 'B0023', 'SV004', 0.0, DEFAULT, TO_DATE('18-Mar-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00098', 'B0090', 'SV007', 0.0, DEFAULT, TO_DATE('07-Mar-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00099', 'B0098', 'SV010', 0.0, DEFAULT, TO_DATE('03-Aug-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00100', 'B0067', 'SV010', 0.0, DEFAULT, TO_DATE('28-Mar-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00101', 'B0040', 'SV003', 0.0, DEFAULT, TO_DATE('22-Jul-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00102', 'B0017', 'SV002', 0.0, DEFAULT, TO_DATE('17-Dec-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00103', 'B0034', 'SV001', 0.0, DEFAULT, TO_DATE('23-Aug-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00104', 'B0071', 'SV001', 0.0, DEFAULT, TO_DATE('29-Mar-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00105', 'B0069', 'SV008', 0.0, DEFAULT, TO_DATE('21-Feb-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00106', 'B0061', 'SV004', 0.0, DEFAULT, TO_DATE('20-Aug-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00107', 'B0061', 'SV008', 0.0, DEFAULT, TO_DATE('09-Oct-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00108', 'B0039', 'SV010', 0.0, DEFAULT, TO_DATE('04-May-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00109', 'B0057', 'SV007', 0.0, DEFAULT, TO_DATE('23-Oct-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00110', 'B0082', 'SV005', 0.0, DEFAULT, TO_DATE('18-May-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00111', 'B0024', 'SV007', 0.0, DEFAULT, TO_DATE('09-Sep-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00112', 'B0003', 'SV005', 0.0, DEFAULT, TO_DATE('12-Jun-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00113', 'B0093', 'SV001', 0.0, DEFAULT, TO_DATE('30-Sep-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00114', 'B0030', 'SV009', 0.0, DEFAULT, TO_DATE('24-Apr-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00115', 'B0034', 'SV007', 0.0, DEFAULT, TO_DATE('18-Apr-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00116', 'B0100', 'SV005', 0.0, DEFAULT, TO_DATE('16-Apr-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00117', 'B0054', 'SV007', 0.0, DEFAULT, TO_DATE('24-Dec-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00118', 'B0041', 'SV006', 0.0, DEFAULT, TO_DATE('04-Oct-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00119', 'B0089', 'SV010', 0.0, DEFAULT, TO_DATE('23-Nov-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00120', 'B0054', 'SV001', 0.0, DEFAULT, TO_DATE('08-Oct-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00121', 'B0016', 'SV006', 0.0, DEFAULT, TO_DATE('09-Dec-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00122', 'B0028', 'SV007', 0.0, DEFAULT, TO_DATE('03-Dec-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00123', 'B0048', 'SV006', 0.0, DEFAULT, TO_DATE('02-May-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00124', 'B0092', 'SV010', 0.0, DEFAULT, TO_DATE('29-Jul-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00125', 'B0083', 'SV008', 0.0, DEFAULT, TO_DATE('01-May-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00126', 'B0055', 'SV003', 0.0, DEFAULT, TO_DATE('22-Jan-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00127', 'B0084', 'SV006', 0.0, DEFAULT, TO_DATE('09-Jun-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00128', 'B0009', 'SV006', 0.0, DEFAULT, TO_DATE('07-Jun-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00129', 'B0003', 'SV002', 0.0, DEFAULT, TO_DATE('27-Sep-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00130', 'B0057', 'SV009', 0.0, DEFAULT, TO_DATE('09-Sep-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00131', 'B0091', 'SV010', 0.0, DEFAULT, TO_DATE('31-Dec-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00132', 'B0087', 'SV001', 0.0, DEFAULT, TO_DATE('28-Apr-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00133', 'B0019', 'SV005', 0.0, DEFAULT, TO_DATE('23-Mar-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00134', 'B0002', 'SV007', 0.0, DEFAULT, TO_DATE('19-Nov-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00135', 'B0006', 'SV005', 0.0, DEFAULT, TO_DATE('26-Dec-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00136', 'B0021', 'SV007', 0.0, DEFAULT, TO_DATE('02-Oct-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00137', 'B0011', 'SV006', 0.0, DEFAULT, TO_DATE('16-Oct-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00138', 'B0067', 'SV007', 0.0, DEFAULT, TO_DATE('04-Dec-2023', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00139', 'B0010', 'SV007', 0.0, DEFAULT, TO_DATE('13-Feb-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00140', 'B0014', 'SV010', 0.0, DEFAULT, TO_DATE('20-Aug-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00141', 'B0037', 'SV009', 0.0, DEFAULT, TO_DATE('22-Oct-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00142', 'B0036', 'SV009', 0.0, DEFAULT, TO_DATE('20-Jun-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00143', 'B0095', 'SV003', 0.0, DEFAULT, TO_DATE('15-Feb-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00144', 'B0065', 'SV003', 0.0, DEFAULT, TO_DATE('15-Dec-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00145', 'B0003', 'SV005', 0.0, DEFAULT, TO_DATE('29-Sep-2023', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00146', 'B0005', 'SV006', 0.0, DEFAULT, TO_DATE('21-Mar-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00147', 'B0001', 'SV002', 0.0, DEFAULT, TO_DATE('07-Oct-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00148', 'B0076', 'SV005', 0.0, DEFAULT, TO_DATE('17-May-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00149', 'B0064', 'SV008', 0.0, DEFAULT, TO_DATE('13-May-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00150', 'B0063', 'SV005', 0.0, DEFAULT, TO_DATE('07-Dec-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00151', 'B0085', 'SV010', 0.0, DEFAULT, TO_DATE('28-Feb-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00152', 'B0085', 'SV007', 0.0, DEFAULT, TO_DATE('01-Jul-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00153', 'B0051', 'SV009', 0.0, DEFAULT, TO_DATE('20-May-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00154', 'B0016', 'SV008', 0.0, DEFAULT, TO_DATE('30-Jun-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00155', 'B0003', 'SV003', 0.0, DEFAULT, TO_DATE('12-Mar-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00156', 'B0020', 'SV008', 0.0, DEFAULT, TO_DATE('20-Apr-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00157', 'B0007', 'SV007', 0.0, DEFAULT, TO_DATE('12-May-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00158', 'B0068', 'SV003', 0.0, DEFAULT, TO_DATE('25-Oct-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00159', 'B0039', 'SV004', 0.0, DEFAULT, TO_DATE('01-Apr-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00160', 'B0074', 'SV009', 0.0, DEFAULT, TO_DATE('24-Feb-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00161', 'B0093', 'SV001', 0.0, DEFAULT, TO_DATE('31-Mar-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00162', 'B0025', 'SV002', 0.0, DEFAULT, TO_DATE('10-Feb-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00163', 'B0045', 'SV008', 0.0, DEFAULT, TO_DATE('07-Jan-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00164', 'B0078', 'SV008', 0.0, DEFAULT, TO_DATE('23-Mar-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00165', 'B0071', 'SV004', 0.0, DEFAULT, TO_DATE('25-Aug-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00166', 'B0048', 'SV006', 0.0, DEFAULT, TO_DATE('14-Dec-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00167', 'B0020', 'SV007', 0.0, DEFAULT, TO_DATE('28-Nov-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00168', 'B0078', 'SV003', 0.0, DEFAULT, TO_DATE('05-Sep-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00169', 'B0016', 'SV010', 0.0, DEFAULT, TO_DATE('01-May-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00170', 'B0050', 'SV008', 0.0, DEFAULT, TO_DATE('05-Feb-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00171', 'B0005', 'SV008', 0.0, DEFAULT, TO_DATE('25-Dec-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00172', 'B0031', 'SV009', 0.0, DEFAULT, TO_DATE('01-May-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00173', 'B0026', 'SV010', 0.0, DEFAULT, TO_DATE('13-Nov-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00174', 'B0097', 'SV006', 0.0, DEFAULT, TO_DATE('26-Nov-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00175', 'B0049', 'SV010', 0.0, DEFAULT, TO_DATE('14-Dec-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00176', 'B0082', 'SV008', 0.0, DEFAULT, TO_DATE('01-Sep-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00177', 'B0056', 'SV004', 0.0, DEFAULT, TO_DATE('11-May-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00178', 'B0063', 'SV005', 0.0, DEFAULT, TO_DATE('17-Mar-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00179', 'B0056', 'SV001', 0.0, DEFAULT, TO_DATE('11-Aug-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00180', 'B0079', 'SV005', 0.0, DEFAULT, TO_DATE('12-Apr-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00181', 'B0100', 'SV002', 0.0, DEFAULT, TO_DATE('14-Nov-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00182', 'B0075', 'SV002', 0.0, DEFAULT, TO_DATE('07-Oct-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00183', 'B0063', 'SV004', 0.0, DEFAULT, TO_DATE('15-Oct-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00184', 'B0061', 'SV006', 0.0, DEFAULT, TO_DATE('15-Jul-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00185', 'B0031', 'SV001', 0.0, DEFAULT, TO_DATE('12-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00186', 'B0014', 'SV009', 0.0, DEFAULT, TO_DATE('28-Jul-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00187', 'B0014', 'SV007', 0.0, DEFAULT, TO_DATE('17-Aug-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00188', 'B0009', 'SV004', 0.0, DEFAULT, TO_DATE('15-Jul-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00189', 'B0060', 'SV006', 0.0, DEFAULT, TO_DATE('12-Dec-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00190', 'B0002', 'SV009', 0.0, DEFAULT, TO_DATE('22-Aug-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00191', 'B0033', 'SV004', 0.0, DEFAULT, TO_DATE('16-Mar-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00192', 'B0072', 'SV004', 0.0, DEFAULT, TO_DATE('22-Feb-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00193', 'B0100', 'SV001', 0.0, DEFAULT, TO_DATE('04-Jun-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00194', 'B0071', 'SV009', 0.0, DEFAULT, TO_DATE('19-Jan-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00195', 'B0031', 'SV009', 0.0, DEFAULT, TO_DATE('10-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00196', 'B0084', 'SV007', 0.0, DEFAULT, TO_DATE('15-Aug-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00197', 'B0036', 'SV010', 0.0, DEFAULT, TO_DATE('08-Oct-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00198', 'B0069', 'SV009', 0.0, DEFAULT, TO_DATE('14-Mar-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00199', 'B0062', 'SV006', 0.0, DEFAULT, TO_DATE('01-Mar-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00200', 'B0043', 'SV010', 0.0, DEFAULT, TO_DATE('22-Apr-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00201', 'B0058', 'SV005', 0.0, DEFAULT, TO_DATE('19-Aug-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00202', 'B0028', 'SV003', 0.0, DEFAULT, TO_DATE('02-Apr-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00203', 'B0078', 'SV002', 0.0, DEFAULT, TO_DATE('15-Jul-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00204', 'B0004', 'SV007', 0.0, DEFAULT, TO_DATE('17-Nov-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00205', 'B0052', 'SV003', 0.0, DEFAULT, TO_DATE('22-Apr-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00206', 'B0080', 'SV007', 0.0, DEFAULT, TO_DATE('27-Apr-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00207', 'B0099', 'SV007', 0.0, DEFAULT, TO_DATE('09-Mar-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00208', 'B0079', 'SV006', 0.0, DEFAULT, TO_DATE('15-Feb-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00209', 'B0082', 'SV008', 0.0, DEFAULT, TO_DATE('02-Nov-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00210', 'B0094', 'SV007', 0.0, DEFAULT, TO_DATE('08-Mar-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00211', 'B0089', 'SV009', 0.0, DEFAULT, TO_DATE('14-Feb-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00212', 'B0061', 'SV003', 0.0, DEFAULT, TO_DATE('22-May-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00213', 'B0048', 'SV006', 0.0, DEFAULT, TO_DATE('26-Aug-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00214', 'B0047', 'SV001', 0.0, DEFAULT, TO_DATE('15-Oct-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00215', 'B0026', 'SV009', 0.0, DEFAULT, TO_DATE('19-Oct-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00216', 'B0034', 'SV007', 0.0, DEFAULT, TO_DATE('04-Dec-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00217', 'B0023', 'SV002', 0.0, DEFAULT, TO_DATE('21-Apr-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00218', 'B0063', 'SV002', 0.0, DEFAULT, TO_DATE('31-May-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00219', 'B0041', 'SV010', 0.0, DEFAULT, TO_DATE('11-Apr-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00220', 'B0059', 'SV007', 0.0, DEFAULT, TO_DATE('24-May-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00221', 'B0024', 'SV001', 0.0, DEFAULT, TO_DATE('18-Nov-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00222', 'B0080', 'SV001', 0.0, DEFAULT, TO_DATE('07-Jan-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00223', 'B0049', 'SV003', 0.0, DEFAULT, TO_DATE('05-Mar-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00224', 'B0073', 'SV002', 0.0, DEFAULT, TO_DATE('09-Jul-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00225', 'B0073', 'SV009', 0.0, DEFAULT, TO_DATE('16-Jun-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00226', 'B0074', 'SV007', 0.0, DEFAULT, TO_DATE('01-Mar-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00227', 'B0100', 'SV002', 0.0, DEFAULT, TO_DATE('05-Feb-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00228', 'B0026', 'SV007', 0.0, DEFAULT, TO_DATE('02-Oct-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00229', 'B0041', 'SV006', 0.0, DEFAULT, TO_DATE('29-May-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00230', 'B0040', 'SV005', 0.0, DEFAULT, TO_DATE('17-Dec-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00231', 'B0023', 'SV004', 0.0, DEFAULT, TO_DATE('15-Sep-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00232', 'B0013', 'SV002', 0.0, DEFAULT, TO_DATE('22-Dec-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00233', 'B0035', 'SV009', 0.0, DEFAULT, TO_DATE('20-Apr-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00234', 'B0022', 'SV003', 0.0, DEFAULT, TO_DATE('28-Dec-2023', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00235', 'B0040', 'SV007', 0.0, DEFAULT, TO_DATE('30-Oct-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00236', 'B0040', 'SV003', 0.0, DEFAULT, TO_DATE('10-Nov-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00237', 'B0058', 'SV008', 0.0, DEFAULT, TO_DATE('17-Dec-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00238', 'B0042', 'SV002', 0.0, DEFAULT, TO_DATE('23-Sep-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00239', 'B0041', 'SV010', 0.0, DEFAULT, TO_DATE('24-Jun-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00240', 'B0058', 'SV004', 0.0, DEFAULT, TO_DATE('06-May-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00241', 'B0024', 'SV010', 0.0, DEFAULT, TO_DATE('04-Feb-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00242', 'B0069', 'SV003', 0.0, DEFAULT, TO_DATE('08-Apr-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00243', 'B0089', 'SV002', 0.0, DEFAULT, TO_DATE('07-Aug-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00244', 'B0073', 'SV002', 0.0, DEFAULT, TO_DATE('05-Mar-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00245', 'B0071', 'SV006', 0.0, DEFAULT, TO_DATE('30-Jan-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00246', 'B0052', 'SV004', 0.0, DEFAULT, TO_DATE('26-May-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00247', 'B0021', 'SV001', 0.0, DEFAULT, TO_DATE('08-Nov-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00248', 'B0079', 'SV001', 0.0, DEFAULT, TO_DATE('21-Apr-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00249', 'B0028', 'SV010', 0.0, DEFAULT, TO_DATE('17-Jun-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00250', 'B0018', 'SV010', 0.0, DEFAULT, TO_DATE('24-Nov-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00251', 'B0068', 'SV007', 0.0, DEFAULT, TO_DATE('17-May-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00252', 'B0054', 'SV009', 0.0, DEFAULT, TO_DATE('26-Nov-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00253', 'B0087', 'SV004', 0.0, DEFAULT, TO_DATE('14-Jan-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00254', 'B0083', 'SV005', 0.0, DEFAULT, TO_DATE('27-Jun-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00255', 'B0051', 'SV002', 0.0, DEFAULT, TO_DATE('19-Dec-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00256', 'B0078', 'SV003', 0.0, DEFAULT, TO_DATE('11-Jun-2022', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00257', 'B0005', 'SV002', 0.0, DEFAULT, TO_DATE('17-Dec-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00258', 'B0083', 'SV007', 0.0, DEFAULT, TO_DATE('20-Oct-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00259', 'B0089', 'SV010', 0.0, DEFAULT, TO_DATE('19-Mar-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00260', 'B0081', 'SV005', 0.0, DEFAULT, TO_DATE('22-Apr-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00261', 'B0048', 'SV008', 0.0, DEFAULT, TO_DATE('19-Feb-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00262', 'B0089', 'SV007', 0.0, DEFAULT, TO_DATE('16-Jun-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00263', 'B0004', 'SV005', 0.0, DEFAULT, TO_DATE('19-Feb-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00264', 'B0090', 'SV010', 0.0, DEFAULT, TO_DATE('06-Mar-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00265', 'B0079', 'SV008', 0.0, DEFAULT, TO_DATE('13-Jun-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00266', 'B0007', 'SV007', 0.0, DEFAULT, TO_DATE('30-Nov-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00267', 'B0034', 'SV010', 0.0, DEFAULT, TO_DATE('30-Oct-2020', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00268', 'B0027', 'SV005', 0.0, DEFAULT, TO_DATE('30-May-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00269', 'B0009', 'SV007', 0.0, DEFAULT, TO_DATE('22-Jan-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00270', 'B0020', 'SV001', 0.0, DEFAULT, TO_DATE('05-Mar-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00271', 'B0017', 'SV009', 0.0, DEFAULT, TO_DATE('30-Apr-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00272', 'B0060', 'SV002', 0.0, DEFAULT, TO_DATE('29-Jun-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00273', 'B0009', 'SV002', 0.0, DEFAULT, TO_DATE('14-Apr-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00274', 'B0030', 'SV003', 0.0, DEFAULT, TO_DATE('17-Sep-2021', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00275', 'B0008', 'SV003', 0.0, DEFAULT, TO_DATE('15-Mar-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00276', 'B0009', 'SV008', 0.0, DEFAULT, TO_DATE('11-Dec-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00277', 'B0070', 'SV002', 0.0, DEFAULT, TO_DATE('30-Mar-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00278', 'B0086', 'SV009', 0.0, DEFAULT, TO_DATE('08-Aug-2024', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00279', 'B0023', 'SV003', 0.0, DEFAULT, TO_DATE('26-Jan-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00280', 'B0063', 'SV001', 0.0, DEFAULT, TO_DATE('18-Apr-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00281', 'B0092', 'SV004', 0.0, DEFAULT, TO_DATE('10-Feb-2021', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00282', 'B0095', 'SV009', 0.0, DEFAULT, TO_DATE('16-Nov-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00283', 'B0068', 'SV009', 0.0, DEFAULT, TO_DATE('07-Apr-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00284', 'B0089', 'SV002', 0.0, DEFAULT, TO_DATE('24-Nov-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00285', 'B0010', 'SV009', 0.0, DEFAULT, TO_DATE('14-Oct-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00286', 'B0046', 'SV003', 0.0, DEFAULT, TO_DATE('06-Feb-2025', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00287', 'B0052', 'SV004', 0.0, DEFAULT, TO_DATE('20-Dec-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00288', 'B0095', 'SV009', 0.0, DEFAULT, TO_DATE('04-Feb-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00289', 'B0088', 'SV007', 0.0, DEFAULT, TO_DATE('11-Apr-2023', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00290', 'B0047', 'SV009', 0.0, DEFAULT, TO_DATE('21-Nov-2022', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00291', 'B0062', 'SV001', 0.0, DEFAULT, TO_DATE('31-Aug-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00292', 'B0086', 'SV006', 0.0, DEFAULT, TO_DATE('11-Aug-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00293', 'B0075', 'SV004', 0.0, DEFAULT, TO_DATE('28-Mar-2020', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00294', 'B0085', 'SV008', 0.0, DEFAULT, TO_DATE('01-Oct-2021', 'DD-MON-YYYY'), 'Completed');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00295', 'B0063', 'SV001', 0.0, DEFAULT, TO_DATE('29-Sep-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00296', 'B0019', 'SV002', 0.0, DEFAULT, TO_DATE('17-Aug-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00297', 'B0030', 'SV002', 0.0, DEFAULT, TO_DATE('02-Feb-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00298', 'B0053', 'SV001', 0.0, DEFAULT, TO_DATE('10-Mar-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00299', 'B0069', 'SV005', 0.0, DEFAULT, TO_DATE('20-Feb-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00300', 'B0036', 'SV003', 0.0, DEFAULT, TO_DATE('06-Nov-2023', 'DD-MON-YYYY'), 'Completed');

INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00301', 'B0019', 'SV002', 0.0, DEFAULT, TO_DATE('17-Aug-2024', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00302', 'B0030', 'SV002', 0.0, DEFAULT, TO_DATE('02-Feb-2025', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00303', 'B0053', 'SV001', 0.0, DEFAULT, TO_DATE('10-Mar-2022', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00304', 'B0069', 'SV005', 0.0, DEFAULT, TO_DATE('20-Feb-2020', 'DD-MON-YYYY'), 'Scheduled');
INSERT INTO Maintenance (MaintenanceID, BusID, ServiceTypeID, Cost, Notes, ServiceDate, Status) VALUES ('MT00305', 'B0036', 'SV003', 0.0, DEFAULT, TO_DATE('06-Nov-2023', 'DD-MON-YYYY'), 'Completed');



-- Schedule
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0001', 'B0001', TO_DATE('24-Sep-2026 08:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Sep-2026 09:58', 'DD-MON-YYYY HH24:MI'), 'Sungai Petani', 'Platform 10', 'Gemas', TO_DATE('24-Sep-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0002', 'B0002', TO_DATE('06-Jul-2025 13:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('06-Jul-2025 16:03', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 4', 'Rawang', TO_DATE('06-Jul-2025', 'DD-MON-YYYY'), 'Past');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0003', 'B0003', TO_DATE('22-Jul-2023 10:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('22-Jul-2023 12:40', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 9', 'Batu Gajah', TO_DATE('22-Jul-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0004', 'B0004', TO_DATE('17-May-2026 07:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('17-May-2026 07:47', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 4', 'Sungai Petani', TO_DATE('17-May-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0005', 'B0005', TO_DATE('06-Jul-2023 21:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('07-Jul-2023 01:12', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 4', 'Ipoh', TO_DATE('06-Jul-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0006', 'B0006', TO_DATE('16-Oct-2024 15:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Oct-2024 17:14', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 6', 'Taiping', TO_DATE('16-Oct-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0007', 'B0007', TO_DATE('17-Apr-2023 11:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('17-Apr-2023 15:29', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 9', 'Shah Alam', TO_DATE('17-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0008', 'B0008', TO_DATE('27-Apr-2024 11:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Apr-2024 14:37', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 10', 'Pasir Gudang', TO_DATE('27-Apr-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0009', 'B0009', TO_DATE('07-Dec-2024 21:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Dec-2024 00:23', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 7', 'Kajang', TO_DATE('07-Dec-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0010', 'B0010', TO_DATE('23-Oct-2027 22:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Oct-2027 02:00', 'DD-MON-YYYY HH24:MI'), 'Sungai Petani', 'Platform 2', 'Gemas', TO_DATE('23-Oct-2027', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0011', 'B0011', TO_DATE('12-May-2026 14:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-May-2026 15:13', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 11', 'Kuala Lumpur Central', TO_DATE('12-May-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0012', 'B0012', TO_DATE('19-Jan-2026 09:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Jan-2026 09:59', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 3', 'Alor Setar', TO_DATE('19-Jan-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0013', 'B0013', TO_DATE('08-Aug-2023 19:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Aug-2023 23:50', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 1', 'Gemas', TO_DATE('08-Aug-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0014', 'B0014', TO_DATE('15-Sep-2023 19:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('15-Sep-2023 22:43', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 10', 'Alor Setar', TO_DATE('15-Sep-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0015', 'B0015', TO_DATE('07-Sep-2023 11:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('07-Sep-2023 14:59', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 1', 'Batu Gajah', TO_DATE('07-Sep-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0016', 'B0016', TO_DATE('16-Jan-2025 09:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Jan-2025 13:11', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 4', 'Kajang', TO_DATE('16-Jan-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0017', 'B0017', TO_DATE('24-Jan-2023 11:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Jan-2023 12:32', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 4', 'Batu Gajah', TO_DATE('24-Jan-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0018', 'B0018', TO_DATE('11-Feb-2023 07:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-Feb-2023 11:11', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 10', 'Alor Setar', TO_DATE('11-Feb-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0019', 'B0019', TO_DATE('10-Mar-2026 21:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('10-Mar-2026 23:17', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 7', 'Butterworth', TO_DATE('10-Mar-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0020', 'B0020', TO_DATE('21-Jul-2025 19:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-Jul-2025 20:47', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 1', 'Muar', TO_DATE('21-Jul-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0021', 'B0021', TO_DATE('27-Sep-2023 20:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Sep-2023 22:14', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 10', 'Gemas', TO_DATE('27-Sep-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0022', 'B0022', TO_DATE('01-Jul-2024 22:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Jul-2024 23:43', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 6', 'Gemas', TO_DATE('01-Jul-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0023', 'B0023', TO_DATE('09-Apr-2025 10:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Apr-2025 14:47', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 1', 'Batu Gajah', TO_DATE('09-Apr-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0024', 'B0024', TO_DATE('18-Nov-2025 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-Nov-2025 17:29', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 5', 'Pasir Gudang', TO_DATE('18-Nov-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0025', 'B0025', TO_DATE('25-Jun-2023 08:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Jun-2023 11:40', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 1', 'Melaka Sentral', TO_DATE('25-Jun-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0026', 'B0026', TO_DATE('24-May-2023 05:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-May-2023 08:31', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 11', 'KLIA Transit', TO_DATE('24-May-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0027', 'B0027', TO_DATE('15-Aug-2023 09:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('15-Aug-2023 13:02', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 2', 'Pasir Gudang', TO_DATE('15-Aug-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0028', 'B0028', TO_DATE('18-Apr-2025 14:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-Apr-2025 16:26', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 12', 'Batu Gajah', TO_DATE('18-Apr-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0029', 'B0029', TO_DATE('07-May-2025 22:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-May-2025 00:37', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 8', 'Melaka Sentral', TO_DATE('07-May-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0030', 'B0030', TO_DATE('18-Jun-2026 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-Jun-2026 23:26', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 12', 'Muar', TO_DATE('18-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0031', 'B0031', TO_DATE('12-Jul-2024 10:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Jul-2024 15:07', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 10', 'Gemas', TO_DATE('12-Jul-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0032', 'B0032', TO_DATE('30-Oct-2025 16:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-Oct-2025 18:44', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 8', 'Kuala Lumpur Central', TO_DATE('30-Oct-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0033', 'B0033', TO_DATE('12-Jul-2025 16:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Jul-2025 17:58', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 9', 'Taiping', TO_DATE('12-Jul-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0034', 'B0034', TO_DATE('30-Dec-2025 12:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-Dec-2025 13:09', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 4', 'Seremban', TO_DATE('30-Dec-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0035', 'B0035', TO_DATE('19-Dec-2025 21:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Dec-2025 23:54', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 8', 'Pasir Gudang', TO_DATE('19-Dec-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0036', 'B0036', TO_DATE('27-Nov-2024 17:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Nov-2024 18:38', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 8', 'Putrajaya', TO_DATE('27-Nov-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0037', 'B0037', TO_DATE('17-Dec-2025 19:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('17-Dec-2025 22:32', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 3', 'Ipoh', TO_DATE('17-Dec-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0038', 'B0038', TO_DATE('19-Mar-2025 14:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Mar-2025 18:49', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 7', 'Gemas', TO_DATE('19-Mar-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0039', 'B0039', TO_DATE('07-Apr-2023 12:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('07-Apr-2023 14:11', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 9', 'Pasir Gudang', TO_DATE('07-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0040', 'B0040', TO_DATE('26-Nov-2023 15:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('26-Nov-2023 16:35', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 6', 'Sungai Petani', TO_DATE('26-Nov-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0041', 'B0041', TO_DATE('27-Feb-2025 20:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Feb-2025 22:04', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 3', 'Pasir Gudang', TO_DATE('27-Feb-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0042', 'B0042', TO_DATE('28-May-2023 13:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('28-May-2023 17:02', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 9', 'Muar', TO_DATE('28-May-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0043', 'B0043', TO_DATE('19-Apr-2025 07:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Apr-2025 09:53', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 9', 'Kuala Lumpur Central', TO_DATE('19-Apr-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0044', 'B0044', TO_DATE('01-Jul-2026 12:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Jul-2026 16:09', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 5', 'Kajang', TO_DATE('01-Jul-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0045', 'B0045', TO_DATE('24-Jun-2023 14:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Jun-2023 18:28', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 8', 'Putrajaya', TO_DATE('24-Jun-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0046', 'B0046', TO_DATE('19-Sep-2023 07:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Sep-2023 11:09', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 7', 'Sungai Petani', TO_DATE('19-Sep-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0047', 'B0047', TO_DATE('01-Jun-2024 17:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Jun-2024 20:52', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 4', 'Putrajaya', TO_DATE('01-Jun-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0048', 'B0048', TO_DATE('11-Feb-2024 11:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-Feb-2024 14:14', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 1', 'Johor Bahru Sentral', TO_DATE('11-Feb-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0049', 'B0049', TO_DATE('11-Mar-2026 17:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-Mar-2026 21:52', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 4', 'Putrajaya', TO_DATE('11-Mar-2026', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0050', 'B0050', TO_DATE('09-Aug-2025 11:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Aug-2025 13:58', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 2', 'Sungai Petani', TO_DATE('09-Aug-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0051', 'B0051', TO_DATE('27-Nov-2025 14:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Nov-2025 19:03', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 6', 'Butterworth', TO_DATE('27-Nov-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0052', 'B0052', TO_DATE('22-Sep-2024 13:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('22-Sep-2024 17:56', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 12', 'KLIA Transit', TO_DATE('22-Sep-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0053', 'B0053', TO_DATE('31-Jul-2023 21:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Aug-2023 01:56', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 5', 'Muar', TO_DATE('31-Jul-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0054', 'B0054', TO_DATE('02-Aug-2024 18:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Aug-2024 21:15', 'DD-MON-YYYY HH24:MI'), 'Sungai Petani', 'Platform 2', 'Muar', TO_DATE('02-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0055', 'B0055', TO_DATE('13-Apr-2025 17:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Apr-2025 21:40', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 3', 'Johor Bahru Sentral', TO_DATE('13-Apr-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0056', 'B0056', TO_DATE('10-Feb-2026 11:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('10-Feb-2026 12:11', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 2', 'Shah Alam', TO_DATE('10-Feb-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0057', 'B0057', TO_DATE('13-Sep-2025 14:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Sep-2025 17:14', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 6', 'Taiping', TO_DATE('13-Sep-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0058', 'B0058', TO_DATE('13-Sep-2024 18:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Sep-2024 22:19', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 3', 'Seremban', TO_DATE('13-Sep-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0059', 'B0059', TO_DATE('03-Oct-2024 18:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('03-Oct-2024 22:23', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 8', 'Ipoh', TO_DATE('03-Oct-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0060', 'B0060', TO_DATE('07-Oct-2024 18:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('07-Oct-2024 23:25', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 7', 'Kuala Lumpur Central', TO_DATE('07-Oct-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0061', 'B0061', TO_DATE('09-Jun-2025 06:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Jun-2025 07:36', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 1', 'Putrajaya', TO_DATE('09-Jun-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0062', 'B0062', TO_DATE('12-Jul-2026 15:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Jul-2026 19:35', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 10', 'Ipoh', TO_DATE('12-Jul-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0063', 'B0063', TO_DATE('03-Apr-2026 15:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('03-Apr-2026 20:00', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 8', 'Pasir Gudang', TO_DATE('03-Apr-2026', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0064', 'B0064', TO_DATE('06-Jun-2023 12:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('06-Jun-2023 17:23', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 8', 'Shah Alam', TO_DATE('06-Jun-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0065', 'B0065', TO_DATE('20-Mar-2025 18:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Mar-2025 18:54', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 1', 'Gemas', TO_DATE('20-Mar-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0066', 'B0066', TO_DATE('19-Dec-2024 10:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Dec-2024 15:22', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 4', 'Shah Alam', TO_DATE('19-Dec-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0067', 'B0067', TO_DATE('10-Feb-2026 15:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('10-Feb-2026 16:43', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 2', 'Muar', TO_DATE('10-Feb-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0068', 'B0068', TO_DATE('30-Aug-2025 21:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-Aug-2025 23:55', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 9', 'Pasir Gudang', TO_DATE('30-Aug-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0069', 'B0069', TO_DATE('01-Sep-2023 11:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Sep-2023 13:54', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 8', 'Taiping', TO_DATE('01-Sep-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0070', 'B0070', TO_DATE('18-Aug-2025 17:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-Aug-2025 22:27', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 9', 'Kajang', TO_DATE('18-Aug-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0071', 'B0071', TO_DATE('31-Jan-2024 08:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('31-Jan-2024 13:15', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 6', 'Butterworth', TO_DATE('31-Jan-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0072', 'B0072', TO_DATE('17-Apr-2025 18:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('17-Apr-2025 20:27', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 11', 'Kuala Lumpur Central', TO_DATE('17-Apr-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0073', 'B0073', TO_DATE('10-Mar-2025 22:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-Mar-2025 02:06', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 5', 'Shah Alam', TO_DATE('10-Mar-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0074', 'B0074', TO_DATE('04-Oct-2024 14:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('04-Oct-2024 16:11', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 9', 'Rawang', TO_DATE('04-Oct-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0075', 'B0075', TO_DATE('01-Nov-2025 17:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Nov-2025 20:57', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 3', 'Ipoh', TO_DATE('01-Nov-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0076', 'B0076', TO_DATE('30-Mar-2026 20:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-Mar-2026 21:45', 'DD-MON-YYYY HH24:MI'), 'Sungai Petani', 'Platform 11', 'Melaka Sentral', TO_DATE('30-Mar-2026', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0077', 'B0077', TO_DATE('04-Aug-2024 06:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('04-Aug-2024 07:03', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 12', 'Putrajaya', TO_DATE('04-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0078', 'B0078', TO_DATE('28-Jan-2026 20:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('28-Jan-2026 21:48', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 7', 'Pasir Gudang', TO_DATE('28-Jan-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0079', 'B0079', TO_DATE('02-Jul-2026 14:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Jul-2026 18:14', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 2', 'Sungai Petani', TO_DATE('02-Jul-2026', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0080', 'B0080', TO_DATE('04-Jan-2026 16:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('04-Jan-2026 20:18', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 2', 'Kuala Lumpur Central', TO_DATE('04-Jan-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0081', 'B0081', TO_DATE('14-Aug-2024 21:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('15-Aug-2024 02:08', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 8', 'Taiping', TO_DATE('14-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0082', 'B0082', TO_DATE('02-Mar-2024 09:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Mar-2024 14:27', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 5', 'Ipoh', TO_DATE('02-Mar-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0083', 'B0083', TO_DATE('08-Mar-2023 06:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Mar-2023 08:16', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 7', 'Gemas', TO_DATE('08-Mar-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0084', 'B0084', TO_DATE('10-May-2025 12:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('10-May-2025 15:05', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 8', 'Melaka Sentral', TO_DATE('10-May-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0085', 'B0085', TO_DATE('27-Aug-2023 20:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Aug-2023 23:48', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 9', 'Alor Setar', TO_DATE('27-Aug-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0086', 'B0086', TO_DATE('14-Jun-2025 06:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Jun-2025 11:34', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 5', 'Taiping', TO_DATE('14-Jun-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0087', 'B0087', TO_DATE('13-May-2023 15:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-May-2023 19:33', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 1', 'Seremban', TO_DATE('13-May-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0088', 'B0088', TO_DATE('05-May-2024 06:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('05-May-2024 10:12', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 8', 'Pasir Gudang', TO_DATE('05-May-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0089', 'B0089', TO_DATE('21-Dec-2025 17:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-Dec-2025 18:14', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 12', 'Rawang', TO_DATE('21-Dec-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0090', 'B0090', TO_DATE('22-Oct-2024 10:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('22-Oct-2024 14:25', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 9', 'Butterworth', TO_DATE('22-Oct-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0091', 'B0091', TO_DATE('25-Nov-2025 10:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Nov-2025 13:34', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 2', 'KLIA Transit', TO_DATE('25-Nov-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0092', 'B0092', TO_DATE('04-May-2024 19:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('05-May-2024 00:31', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 4', 'Pasir Gudang', TO_DATE('04-May-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0093', 'B0093', TO_DATE('10-Dec-2023 17:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('10-Dec-2023 18:01', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 4', 'Pasir Gudang', TO_DATE('10-Dec-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0094', 'B0094', TO_DATE('30-Dec-2025 16:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-Dec-2025 17:04', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 6', 'Muar', TO_DATE('30-Dec-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0095', 'B0095', TO_DATE('12-Jul-2024 21:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Jul-2024 22:21', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 3', 'Seremban', TO_DATE('12-Jul-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0096', 'B0096', TO_DATE('18-Jun-2026 22:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Jun-2026 01:15', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 10', 'Butterworth', TO_DATE('18-Jun-2026', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0097', 'B0097', TO_DATE('01-Nov-2023 21:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Nov-2023 23:38', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 8', 'Taiping', TO_DATE('01-Nov-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0098', 'B0098', TO_DATE('05-Apr-2023 12:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('05-Apr-2023 13:37', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 2', 'Gemas', TO_DATE('05-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0099', 'B0099', TO_DATE('14-Jul-2025 16:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Jul-2025 20:00', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 10', 'Rawang', TO_DATE('14-Jul-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0100', 'B0100', TO_DATE('10-Apr-2024 15:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('10-Apr-2024 15:59', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 11', 'Taiping', TO_DATE('10-Apr-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0101', 'B0001', TO_DATE('24-Feb-2026 09:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Feb-2026 11:54', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 1', 'Putrajaya', TO_DATE('24-Feb-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0102', 'B0002', TO_DATE('06-Jul-2025 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('07-Jul-2025 01:02', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 9', 'Melaka Sentral', TO_DATE('06-Jul-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0103', 'B0003', TO_DATE('20-Aug-2024 12:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Aug-2024 13:04', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 3', 'Taiping', TO_DATE('20-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0104', 'B0004', TO_DATE('25-Jul-2023 16:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Jul-2023 18:01', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 3', 'Alor Setar', TO_DATE('25-Jul-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0105', 'B0005', TO_DATE('17-Jun-2026 11:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('17-Jun-2026 14:49', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 4', 'Gemas', TO_DATE('17-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0106', 'B0006', TO_DATE('23-May-2025 19:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('23-May-2025 22:21', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 11', 'Alor Setar', TO_DATE('23-May-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0107', 'B0007', TO_DATE('26-May-2023 19:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-May-2023 00:18', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 4', 'Sungai Petani', TO_DATE('26-May-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0108', 'B0008', TO_DATE('16-Oct-2023 17:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Oct-2023 20:21', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 3', 'Alor Setar', TO_DATE('16-Oct-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0109', 'B0009', TO_DATE('25-Feb-2025 06:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Feb-2025 10:43', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 3', 'Kuala Lumpur Central', TO_DATE('25-Feb-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0110', 'B0010', TO_DATE('19-Jun-2026 13:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Jun-2026 15:26', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 5', 'Muar', TO_DATE('19-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0111', 'B0011', TO_DATE('04-Feb-2024 19:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('04-Feb-2024 21:51', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 4', 'Gemas', TO_DATE('04-Feb-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0112', 'B0012', TO_DATE('24-Mar-2024 19:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Mar-2024 22:27', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 7', 'Ipoh', TO_DATE('24-Mar-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0113', 'B0013', TO_DATE('18-Apr-2023 12:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-Apr-2023 12:50', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 7', 'Johor Bahru Sentral', TO_DATE('18-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0114', 'B0014', TO_DATE('16-Aug-2024 09:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Aug-2024 10:37', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 9', 'Seremban', TO_DATE('16-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0115', 'B0015', TO_DATE('24-Nov-2025 10:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Nov-2025 15:06', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 12', 'Melaka Sentral', TO_DATE('24-Nov-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0116', 'B0016', TO_DATE('25-Jan-2024 20:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('26-Jan-2024 00:03', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 3', 'Rawang', TO_DATE('25-Jan-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0117', 'B0017', TO_DATE('02-Jan-2025 18:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Jan-2025 21:48', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 11', 'Rawang', TO_DATE('02-Jan-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0118', 'B0018', TO_DATE('09-Dec-2024 14:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Dec-2024 15:47', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 1', 'Melaka Sentral', TO_DATE('09-Dec-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0119', 'B0019', TO_DATE('21-Feb-2023 18:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-Feb-2023 20:59', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 4', 'KLIA Transit', TO_DATE('21-Feb-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0120', 'B0020', TO_DATE('29-Mar-2025 18:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('29-Mar-2025 20:26', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 11', 'Seremban', TO_DATE('29-Mar-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0121', 'B0021', TO_DATE('14-Jun-2026 08:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Jun-2026 09:46', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 2', 'Butterworth', TO_DATE('14-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0122', 'B0022', TO_DATE('18-Apr-2023 15:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-Apr-2023 18:19', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 3', 'Pasir Gudang', TO_DATE('18-Apr-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0123', 'B0023', TO_DATE('05-Jul-2025 13:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('05-Jul-2025 15:31', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 3', 'Johor Bahru Sentral', TO_DATE('05-Jul-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0124', 'B0024', TO_DATE('28-Apr-2024 11:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('28-Apr-2024 13:29', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 4', 'Melaka Sentral', TO_DATE('28-Apr-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0125', 'B0025', TO_DATE('07-Jun-2026 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('07-Jun-2026 17:33', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 11', 'Shah Alam', TO_DATE('07-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0126', 'B0026', TO_DATE('18-Sep-2024 18:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-Sep-2024 20:15', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 2', 'Ipoh', TO_DATE('18-Sep-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0127', 'B0027', TO_DATE('15-Jun-2026 18:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('15-Jun-2026 20:47', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 4', 'Alor Setar', TO_DATE('15-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0128', 'B0028', TO_DATE('31-Dec-2023 10:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('31-Dec-2023 15:23', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 11', 'Batu Gajah', TO_DATE('31-Dec-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0129', 'B0029', TO_DATE('25-Nov-2024 12:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Nov-2024 15:12', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 4', 'Rawang', TO_DATE('25-Nov-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0130', 'B0030', TO_DATE('19-Sep-2023 19:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Sep-2023 22:19', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 7', 'Butterworth', TO_DATE('19-Sep-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0131', 'B0031', TO_DATE('13-Aug-2025 17:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Aug-2025 21:29', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 2', 'Sungai Petani', TO_DATE('13-Aug-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0132', 'B0032', TO_DATE('31-Oct-2024 22:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Nov-2024 01:08', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 12', 'Taiping', TO_DATE('31-Oct-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0133', 'B0033', TO_DATE('28-Jan-2026 20:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('28-Jan-2026 23:23', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 1', 'Ipoh', TO_DATE('28-Jan-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0134', 'B0034', TO_DATE('27-May-2024 20:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-May-2024 21:03', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 3', 'Seremban', TO_DATE('27-May-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0135', 'B0035', TO_DATE('01-Sep-2024 14:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Sep-2024 17:36', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 1', 'Taiping', TO_DATE('01-Sep-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0136', 'B0036', TO_DATE('11-Jan-2024 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Jan-2024 02:52', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 1', 'Kajang', TO_DATE('11-Jan-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0137', 'B0037', TO_DATE('12-Feb-2025 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Feb-2025 21:37', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 10', 'Kuala Lumpur Central', TO_DATE('12-Feb-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0138', 'B0038', TO_DATE('30-Mar-2026 14:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-Mar-2026 16:20', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 10', 'Batu Gajah', TO_DATE('30-Mar-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0139', 'B0039', TO_DATE('19-Mar-2023 17:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Mar-2023 22:12', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 8', 'KLIA Transit', TO_DATE('19-Mar-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0140', 'B0040', TO_DATE('27-Sep-2023 08:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Sep-2023 10:03', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 3', 'Pasir Gudang', TO_DATE('27-Sep-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0141', 'B0041', TO_DATE('02-Jul-2023 05:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Jul-2023 08:20', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 3', 'Gemas', TO_DATE('02-Jul-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0142', 'B0042', TO_DATE('14-Aug-2023 12:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Aug-2023 14:46', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 7', 'Melaka Sentral', TO_DATE('14-Aug-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0143', 'B0043', TO_DATE('22-Mar-2025 17:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('22-Mar-2025 18:22', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 11', 'Ipoh', TO_DATE('22-Mar-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0144', 'B0044', TO_DATE('27-Dec-2024 14:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Dec-2024 18:01', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 3', 'Kuala Lumpur Central', TO_DATE('27-Dec-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0145', 'B0045', TO_DATE('06-Jan-2026 07:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('06-Jan-2026 11:36', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 5', 'Melaka Sentral', TO_DATE('06-Jan-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0146', 'B0046', TO_DATE('20-Jul-2025 17:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Jul-2025 19:40', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 3', 'Shah Alam', TO_DATE('20-Jul-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0147', 'B0047', TO_DATE('28-Nov-2024 18:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('28-Nov-2024 21:18', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 7', 'Taiping', TO_DATE('28-Nov-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0148', 'B0048', TO_DATE('12-Jun-2023 13:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Jun-2023 16:00', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 7', 'Gemas', TO_DATE('12-Jun-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0149', 'B0049', TO_DATE('09-Nov-2025 15:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Nov-2025 19:45', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 4', 'Gemas', TO_DATE('09-Nov-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0150', 'B0050', TO_DATE('26-Jan-2025 20:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('26-Jan-2025 21:47', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 2', 'Ipoh', TO_DATE('26-Jan-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0151', 'B0051', TO_DATE('13-Jun-2023 07:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Jun-2023 07:53', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 9', 'Batu Gajah', TO_DATE('13-Jun-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0152', 'B0052', TO_DATE('10-Apr-2024 14:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('10-Apr-2024 16:36', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 5', 'Gemas', TO_DATE('10-Apr-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0153', 'B0053', TO_DATE('12-Jul-2024 21:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Jul-2024 00:01', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 4', 'Seremban', TO_DATE('12-Jul-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0154', 'B0054', TO_DATE('16-Jul-2023 12:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Jul-2023 12:49', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 5', 'Kajang', TO_DATE('16-Jul-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0155', 'B0055', TO_DATE('10-Feb-2026 17:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('10-Feb-2026 22:08', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 3', 'Pasir Gudang', TO_DATE('10-Feb-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0156', 'B0056', TO_DATE('01-Apr-2024 12:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Apr-2024 12:31', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 2', 'Rawang', TO_DATE('01-Apr-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0157', 'B0057', TO_DATE('14-Mar-2024 11:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Mar-2024 13:20', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 4', 'Kajang', TO_DATE('14-Mar-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0158', 'B0058', TO_DATE('27-Dec-2023 15:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Dec-2023 18:21', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 8', 'Johor Bahru Sentral', TO_DATE('27-Dec-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0159', 'B0059', TO_DATE('24-Nov-2023 11:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Nov-2023 12:54', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 11', 'KLIA Transit', TO_DATE('24-Nov-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0160', 'B0060', TO_DATE('27-Jun-2026 21:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Jun-2026 23:14', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 2', 'Muar', TO_DATE('27-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0161', 'B0061', TO_DATE('12-Apr-2026 08:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Apr-2026 12:01', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 3', 'Taiping', TO_DATE('12-Apr-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0162', 'B0062', TO_DATE('27-Oct-2025 08:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Oct-2025 12:23', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 3', 'Taiping', TO_DATE('27-Oct-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0163', 'B0063', TO_DATE('26-May-2023 16:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('26-May-2023 18:18', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 11', 'Gemas', TO_DATE('26-May-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0164', 'B0064', TO_DATE('12-Apr-2023 21:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Apr-2023 01:29', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 11', 'Taiping', TO_DATE('12-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0165', 'B0065', TO_DATE('13-Nov-2023 11:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Nov-2023 12:37', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 7', 'Gemas', TO_DATE('13-Nov-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0166', 'B0066', TO_DATE('30-May-2024 10:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-May-2024 11:33', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 5', 'Johor Bahru Sentral', TO_DATE('30-May-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0167', 'B0067', TO_DATE('09-Dec-2025 13:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Dec-2025 14:22', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 7', 'Kuala Lumpur Central', TO_DATE('09-Dec-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0168', 'B0068', TO_DATE('17-Sep-2024 15:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('17-Sep-2024 16:12', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 2', 'Sungai Petani', TO_DATE('17-Sep-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0169', 'B0069', TO_DATE('23-May-2023 16:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('23-May-2023 17:45', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 12', 'Kajang', TO_DATE('23-May-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0170', 'B0070', TO_DATE('15-Aug-2024 14:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('15-Aug-2024 16:09', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 9', 'Rawang', TO_DATE('15-Aug-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0171', 'B0071', TO_DATE('16-Jun-2026 06:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Jun-2026 08:43', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 3', 'Alor Setar', TO_DATE('16-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0172', 'B0072', TO_DATE('24-Jun-2023 10:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Jun-2023 14:38', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 10', 'Sungai Petani', TO_DATE('24-Jun-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0173', 'B0073', TO_DATE('12-Jun-2023 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Jun-2023 20:32', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 4', 'Kuala Lumpur Central', TO_DATE('12-Jun-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0174', 'B0074', TO_DATE('13-Nov-2023 07:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Nov-2023 10:19', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 3', 'Pasir Gudang', TO_DATE('13-Nov-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0175', 'B0075', TO_DATE('11-Jul-2023 12:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-Jul-2023 15:34', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 4', 'Ipoh', TO_DATE('11-Jul-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0176', 'B0076', TO_DATE('05-Dec-2023 18:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('05-Dec-2023 18:43', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 6', 'Melaka Sentral', TO_DATE('05-Dec-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0177', 'B0077', TO_DATE('01-Aug-2023 16:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Aug-2023 18:49', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 6', 'Seremban', TO_DATE('01-Aug-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0178', 'B0078', TO_DATE('24-Aug-2023 05:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Aug-2023 08:12', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 1', 'Seremban', TO_DATE('24-Aug-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0179', 'B0079', TO_DATE('11-Oct-2024 12:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-Oct-2024 14:25', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 12', 'Muar', TO_DATE('11-Oct-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0180', 'B0080', TO_DATE('26-Dec-2023 14:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('26-Dec-2023 15:30', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 4', 'Taiping', TO_DATE('26-Dec-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0181', 'B0081', TO_DATE('27-Jul-2025 16:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Jul-2025 17:19', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 1', 'Johor Bahru Sentral', TO_DATE('27-Jul-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0182', 'B0082', TO_DATE('08-Apr-2023 15:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Apr-2023 16:45', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 6', 'Pasir Gudang', TO_DATE('08-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0183', 'B0083', TO_DATE('12-Jul-2023 20:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Jul-2023 00:04', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 2', 'Batu Gajah', TO_DATE('12-Jul-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0184', 'B0084', TO_DATE('20-Jan-2025 11:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Jan-2025 13:01', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 3', 'Alor Setar', TO_DATE('20-Jan-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0185', 'B0085', TO_DATE('18-Oct-2025 12:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-Oct-2025 17:24', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 6', 'Rawang', TO_DATE('18-Oct-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0186', 'B0086', TO_DATE('02-Feb-2026 12:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Feb-2026 17:05', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 1', 'Alor Setar', TO_DATE('02-Feb-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0187', 'B0087', TO_DATE('23-Dec-2024 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Dec-2024 02:48', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 10', 'Kajang', TO_DATE('23-Dec-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0188', 'B0088', TO_DATE('13-Oct-2024 15:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Oct-2024 19:35', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 7', 'Sungai Petani', TO_DATE('13-Oct-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0189', 'B0089', TO_DATE('23-Jul-2024 21:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Jul-2024 02:10', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 4', 'Taiping', TO_DATE('23-Jul-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0190', 'B0090', TO_DATE('24-Feb-2026 09:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Feb-2026 11:43', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 5', 'Kajang', TO_DATE('24-Feb-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0191', 'B0091', TO_DATE('20-Oct-2024 08:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Oct-2024 10:30', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 5', 'Kajang', TO_DATE('20-Oct-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0192', 'B0092', TO_DATE('01-Aug-2024 17:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Aug-2024 20:32', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 11', 'Taiping', TO_DATE('01-Aug-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0193', 'B0093', TO_DATE('19-Feb-2025 19:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Feb-2025 23:55', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 7', 'Alor Setar', TO_DATE('19-Feb-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0194', 'B0094', TO_DATE('30-May-2025 11:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-May-2025 13:05', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 9', 'Melaka Sentral', TO_DATE('30-May-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0195', 'B0095', TO_DATE('28-Oct-2023 20:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('28-Oct-2023 23:42', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 9', 'Ipoh', TO_DATE('28-Oct-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0196', 'B0096', TO_DATE('29-Apr-2023 19:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('29-Apr-2023 23:32', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 7', 'Sungai Petani', TO_DATE('29-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0197', 'B0097', TO_DATE('27-Feb-2026 16:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Feb-2026 17:25', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 8', 'Taiping', TO_DATE('27-Feb-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0198', 'B0098', TO_DATE('12-Jun-2025 20:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Jun-2025 23:30', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 9', 'Shah Alam', TO_DATE('12-Jun-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0199', 'B0099', TO_DATE('13-May-2026 10:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-May-2026 13:43', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 10', 'Sungai Petani', TO_DATE('13-May-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0200', 'B0100', TO_DATE('31-Jul-2023 21:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Aug-2023 00:34', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 6', 'Kuala Lumpur Central', TO_DATE('31-Jul-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0201', 'B0001', TO_DATE('16-Oct-2025 06:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Oct-2025 10:14', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 6', 'Melaka Sentral', TO_DATE('16-Oct-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0202', 'B0002', TO_DATE('23-Jan-2024 11:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('23-Jan-2024 12:19', 'DD-MON-YYYY HH24:MI'), 'Johor Bahru Sentral', 'Platform 12', 'KLIA Transit', TO_DATE('23-Jan-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0203', 'B0003', TO_DATE('01-May-2025 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-May-2025 17:46', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 8', 'Seremban', TO_DATE('01-May-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0204', 'B0004', TO_DATE('21-Dec-2024 19:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-Dec-2024 20:10', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 1', 'Kuala Lumpur Central', TO_DATE('21-Dec-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0205', 'B0005', TO_DATE('24-Feb-2023 11:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Feb-2023 12:50', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 3', 'Putrajaya', TO_DATE('24-Feb-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0206', 'B0006', TO_DATE('19-Feb-2023 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Feb-2023 17:43', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 12', 'Alor Setar', TO_DATE('19-Feb-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0207', 'B0007', TO_DATE('02-Nov-2023 17:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Nov-2023 21:10', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 11', 'Putrajaya', TO_DATE('02-Nov-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0208', 'B0008', TO_DATE('31-May-2024 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('31-May-2024 20:52', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 6', 'Rawang', TO_DATE('31-May-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0209', 'B0009', TO_DATE('16-Mar-2026 08:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Mar-2026 09:24', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 6', 'Shah Alam', TO_DATE('16-Mar-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0210', 'B0010', TO_DATE('04-May-2026 21:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('04-May-2026 22:10', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 2', 'Muar', TO_DATE('04-May-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0211', 'B0011', TO_DATE('14-Jul-2023 15:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Jul-2023 20:41', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 10', 'Gemas', TO_DATE('14-Jul-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0212', 'B0012', TO_DATE('24-Dec-2025 15:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Dec-2025 19:39', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 6', 'Ipoh', TO_DATE('24-Dec-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0213', 'B0013', TO_DATE('15-Sep-2023 13:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('15-Sep-2023 16:19', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 3', 'Butterworth', TO_DATE('15-Sep-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0214', 'B0014', TO_DATE('21-May-2025 15:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-May-2025 16:51', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 9', 'Batu Gajah', TO_DATE('21-May-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0215', 'B0015', TO_DATE('11-Feb-2026 19:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-Feb-2026 19:48', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 2', 'Melaka Sentral', TO_DATE('11-Feb-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0216', 'B0016', TO_DATE('15-Aug-2024 12:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('15-Aug-2024 13:53', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 12', 'Kajang', TO_DATE('15-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0217', 'B0017', TO_DATE('02-Jan-2023 10:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Jan-2023 13:39', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 11', 'Ipoh', TO_DATE('02-Jan-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0218', 'B0018', TO_DATE('20-Feb-2026 12:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Feb-2026 16:10', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 4', 'Melaka Sentral', TO_DATE('20-Feb-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0219', 'B0019', TO_DATE('21-Aug-2024 13:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-Aug-2024 15:07', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 6', 'Rawang', TO_DATE('21-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0220', 'B0020', TO_DATE('17-Jun-2024 19:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('17-Jun-2024 23:00', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 5', 'Pasir Gudang', TO_DATE('17-Jun-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0221', 'B0021', TO_DATE('30-May-2025 12:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-May-2025 13:50', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 4', 'Putrajaya', TO_DATE('30-May-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0222', 'B0022', TO_DATE('11-Oct-2023 07:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-Oct-2023 08:37', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 7', 'Johor Bahru Sentral', TO_DATE('11-Oct-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0223', 'B0023', TO_DATE('14-Jan-2026 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Jan-2026 17:18', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 2', 'Alor Setar', TO_DATE('14-Jan-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0224', 'B0024', TO_DATE('10-Sep-2023 11:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('10-Sep-2023 12:19', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 11', 'Johor Bahru Sentral', TO_DATE('10-Sep-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0225', 'B0025', TO_DATE('21-Dec-2023 11:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-Dec-2023 11:43', 'DD-MON-YYYY HH24:MI'), 'Sungai Petani', 'Platform 3', 'Alor Setar', TO_DATE('21-Dec-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0226', 'B0026', TO_DATE('19-Jan-2025 06:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-Jan-2025 08:48', 'DD-MON-YYYY HH24:MI'), 'Sungai Petani', 'Platform 12', 'Muar', TO_DATE('19-Jan-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0227', 'B0027', TO_DATE('13-Dec-2025 11:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Dec-2025 14:42', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 3', 'Alor Setar', TO_DATE('13-Dec-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0228', 'B0028', TO_DATE('03-Aug-2024 10:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('03-Aug-2024 13:52', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 12', 'Sungai Petani', TO_DATE('03-Aug-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0229', 'B0029', TO_DATE('16-Apr-2024 19:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Apr-2024 21:09', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 3', 'Gemas', TO_DATE('16-Apr-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0230', 'B0030', TO_DATE('02-Jan-2025 13:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Jan-2025 17:13', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 8', 'Johor Bahru Sentral', TO_DATE('02-Jan-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0231', 'B0031', TO_DATE('09-Mar-2024 06:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Mar-2024 08:51', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 1', 'Muar', TO_DATE('09-Mar-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0232', 'B0032', TO_DATE('09-Jan-2025 17:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Jan-2025 21:14', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 10', 'Putrajaya', TO_DATE('09-Jan-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0233', 'B0033', TO_DATE('08-Jun-2025 10:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Jun-2025 12:55', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 7', 'Seremban', TO_DATE('08-Jun-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0234', 'B0034', TO_DATE('06-Mar-2023 12:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('06-Mar-2023 13:18', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 3', 'Seremban', TO_DATE('06-Mar-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0235', 'B0035', TO_DATE('08-Apr-2026 11:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Apr-2026 15:50', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 2', 'Taiping', TO_DATE('08-Apr-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0236', 'B0036', TO_DATE('09-Sep-2023 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Sep-2023 17:20', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 3', 'Alor Setar', TO_DATE('09-Sep-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0237', 'B0037', TO_DATE('28-Feb-2025 17:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('28-Feb-2025 19:45', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 8', 'Ipoh', TO_DATE('28-Feb-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0238', 'B0038', TO_DATE('08-Aug-2024 12:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Aug-2024 17:07', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 12', 'Seremban', TO_DATE('08-Aug-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0239', 'B0039', TO_DATE('14-Mar-2023 07:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Mar-2023 10:29', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 9', 'Seremban', TO_DATE('14-Mar-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0240', 'B0040', TO_DATE('08-Jun-2024 17:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Jun-2024 19:16', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 9', 'Muar', TO_DATE('08-Jun-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0241', 'B0041', TO_DATE('12-Sep-2023 19:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Sep-2023 23:50', 'DD-MON-YYYY HH24:MI'), 'Seremban', 'Platform 8', 'Shah Alam', TO_DATE('12-Sep-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0242', 'B0042', TO_DATE('14-Nov-2024 16:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Nov-2024 18:22', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 12', 'Ipoh', TO_DATE('14-Nov-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0243', 'B0043', TO_DATE('21-Sep-2023 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-Sep-2023 18:27', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 5', 'KLIA Transit', TO_DATE('21-Sep-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0244', 'B0044', TO_DATE('20-Feb-2025 05:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Feb-2025 09:15', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 5', 'Alor Setar', TO_DATE('20-Feb-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0245', 'B0045', TO_DATE('23-Jun-2024 15:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('23-Jun-2024 19:55', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 9', 'Putrajaya', TO_DATE('23-Jun-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0246', 'B0046', TO_DATE('28-Jun-2026 17:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('28-Jun-2026 20:24', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 9', 'Muar', TO_DATE('28-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0247', 'B0047', TO_DATE('24-Nov-2023 05:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('24-Nov-2023 09:35', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 8', 'Gemas', TO_DATE('24-Nov-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0248', 'B0048', TO_DATE('17-Apr-2025 08:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('17-Apr-2025 12:10', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 5', 'Batu Gajah', TO_DATE('17-Apr-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0249', 'B0049', TO_DATE('01-Dec-2023 20:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Dec-2023 21:22', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 6', 'Putrajaya', TO_DATE('01-Dec-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0250', 'B0050', TO_DATE('10-May-2023 20:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-May-2023 01:12', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 2', 'Putrajaya', TO_DATE('10-May-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0251', 'B0051', TO_DATE('18-Aug-2023 17:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-Aug-2023 19:30', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 9', 'Alor Setar', TO_DATE('18-Aug-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0252', 'B0052', TO_DATE('27-Nov-2025 21:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Nov-2025 22:51', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 2', 'KLIA Transit', TO_DATE('27-Nov-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0253', 'B0053', TO_DATE('01-Aug-2024 06:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Aug-2024 10:36', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 1', 'Putrajaya', TO_DATE('01-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0254', 'B0054', TO_DATE('07-Aug-2025 12:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('07-Aug-2025 14:55', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 12', 'Melaka Sentral', TO_DATE('07-Aug-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0255', 'B0055', TO_DATE('07-Dec-2024 16:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('07-Dec-2024 18:34', 'DD-MON-YYYY HH24:MI'), 'Taiping', 'Platform 8', 'Batu Gajah', TO_DATE('07-Dec-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0256', 'B0056', TO_DATE('27-Oct-2024 11:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Oct-2024 15:02', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 9', 'Melaka Sentral', TO_DATE('27-Oct-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0257', 'B0057', TO_DATE('25-Jun-2025 10:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Jun-2025 14:02', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 11', 'Ipoh', TO_DATE('25-Jun-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0258', 'B0058', TO_DATE('12-Oct-2023 19:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('12-Oct-2023 22:23', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 7', 'Sungai Petani', TO_DATE('12-Oct-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0259', 'B0059', TO_DATE('20-Oct-2023 17:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Oct-2023 19:46', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 8', 'Gemas', TO_DATE('20-Oct-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0260', 'B0060', TO_DATE('11-Apr-2025 11:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('11-Apr-2025 14:47', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 8', 'Putrajaya', TO_DATE('11-Apr-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0261', 'B0061', TO_DATE('20-Mar-2026 14:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Mar-2026 19:08', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 8', 'KLIA Transit', TO_DATE('20-Mar-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0262', 'B0062', TO_DATE('20-Jan-2024 07:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Jan-2024 10:10', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 5', 'Shah Alam', TO_DATE('20-Jan-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0263', 'B0063', TO_DATE('20-May-2023 22:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-May-2023 02:48', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 6', 'Taiping', TO_DATE('20-May-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0264', 'B0064', TO_DATE('14-Mar-2024 07:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('14-Mar-2024 11:19', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 8', 'Rawang', TO_DATE('14-Mar-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0265', 'B0065', TO_DATE('06-Dec-2023 16:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('06-Dec-2023 20:18', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 3', 'Rawang', TO_DATE('06-Dec-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0266', 'B0066', TO_DATE('08-Aug-2023 13:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Aug-2023 15:22', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 3', 'Putrajaya', TO_DATE('08-Aug-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0267', 'B0067', TO_DATE('28-Feb-2024 09:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('28-Feb-2024 13:23', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 5', 'Ipoh', TO_DATE('28-Feb-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0268', 'B0068', TO_DATE('30-Aug-2023 10:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-Aug-2023 12:50', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 4', 'Melaka Sentral', TO_DATE('30-Aug-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0269', 'B0069', TO_DATE('13-Dec-2024 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Dec-2024 20:04', 'DD-MON-YYYY HH24:MI'), 'Gemas', 'Platform 3', 'Ipoh', TO_DATE('13-Dec-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0270', 'B0070', TO_DATE('25-Jan-2023 08:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Jan-2023 12:36', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 7', 'Gemas', TO_DATE('25-Jan-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0271', 'B0071', TO_DATE('08-Aug-2024 22:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Aug-2024 23:20', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 3', 'Taiping', TO_DATE('08-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0272', 'B0072', TO_DATE('30-Jun-2024 16:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-Jun-2024 18:51', 'DD-MON-YYYY HH24:MI'), 'Putrajaya', 'Platform 8', 'Pasir Gudang', TO_DATE('30-Jun-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0273', 'B0073', TO_DATE('30-Apr-2023 07:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('30-Apr-2023 11:30', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 4', 'Pasir Gudang', TO_DATE('30-Apr-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0274', 'B0074', TO_DATE('13-Aug-2023 07:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('13-Aug-2023 08:26', 'DD-MON-YYYY HH24:MI'), 'Sungai Petani', 'Platform 6', 'Johor Bahru Sentral', TO_DATE('13-Aug-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0275', 'B0075', TO_DATE('01-Apr-2023 22:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Apr-2023 02:40', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 2', 'Muar', TO_DATE('01-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0276', 'B0076', TO_DATE('29-Aug-2023 11:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('29-Aug-2023 13:49', 'DD-MON-YYYY HH24:MI'), 'Kajang', 'Platform 7', 'Batu Gajah', TO_DATE('29-Aug-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0277', 'B0077', TO_DATE('30-Dec-2024 22:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('31-Dec-2024 02:08', 'DD-MON-YYYY HH24:MI'), 'Shah Alam', 'Platform 12', 'Sungai Petani', TO_DATE('30-Dec-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0278', 'B0078', TO_DATE('04-Jun-2026 16:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('04-Jun-2026 19:57', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 8', 'Pasir Gudang', TO_DATE('04-Jun-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0279', 'B0079', TO_DATE('07-Sep-2023 17:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('07-Sep-2023 18:38', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 12', 'Melaka Sentral', TO_DATE('07-Sep-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0280', 'B0080', TO_DATE('19-May-2025 18:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-May-2025 20:05', 'DD-MON-YYYY HH24:MI'), 'Alor Setar', 'Platform 12', 'Pasir Gudang', TO_DATE('19-May-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0281', 'B0081', TO_DATE('03-Jun-2024 22:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('04-Jun-2024 01:10', 'DD-MON-YYYY HH24:MI'), 'Sungai Petani', 'Platform 6', 'Alor Setar', TO_DATE('03-Jun-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0282', 'B0082', TO_DATE('04-Aug-2024 15:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('04-Aug-2024 16:23', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 12', 'Alor Setar', TO_DATE('04-Aug-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0283', 'B0083', TO_DATE('06-Oct-2023 11:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('06-Oct-2023 11:48', 'DD-MON-YYYY HH24:MI'), 'Ipoh', 'Platform 3', 'Taiping', TO_DATE('06-Oct-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0284', 'B0084', TO_DATE('16-Jan-2023 13:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('16-Jan-2023 17:11', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 11', 'Ipoh', TO_DATE('16-Jan-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0285', 'B0085', TO_DATE('16-Apr-2024 21:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('17-Apr-2024 00:12', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 11', 'Batu Gajah', TO_DATE('16-Apr-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0286', 'B0086', TO_DATE('09-Jun-2024 10:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('09-Jun-2024 15:26', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 4', 'Muar', TO_DATE('09-Jun-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0287', 'B0087', TO_DATE('20-Apr-2025 18:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('20-Apr-2025 20:02', 'DD-MON-YYYY HH24:MI'), 'KLIA Transit', 'Platform 12', 'Shah Alam', TO_DATE('20-Apr-2025', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0288', 'B0088', TO_DATE('21-Jun-2024 05:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-Jun-2024 08:33', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 6', 'Putrajaya', TO_DATE('21-Jun-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0289', 'B0089', TO_DATE('25-Jan-2023 14:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Jan-2023 16:39', 'DD-MON-YYYY HH24:MI'), 'Melaka Sentral', 'Platform 4', 'Shah Alam', TO_DATE('25-Jan-2023', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0290', 'B0090', TO_DATE('21-Mar-2026 06:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('21-Mar-2026 07:59', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 8', 'Pasir Gudang', TO_DATE('21-Mar-2026', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0291', 'B0091', TO_DATE('27-Aug-2025 19:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('27-Aug-2025 19:57', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 9', 'Gemas', TO_DATE('27-Aug-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0292', 'B0092', TO_DATE('19-May-2024 06:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('19-May-2024 08:36', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 10', 'Johor Bahru Sentral', TO_DATE('19-May-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0293', 'B0093', TO_DATE('18-May-2025 05:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('18-May-2025 09:46', 'DD-MON-YYYY HH24:MI'), 'Butterworth', 'Platform 1', 'Pasir Gudang', TO_DATE('18-May-2025', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0294', 'B0094', TO_DATE('25-Apr-2023 12:00', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Apr-2023 14:09', 'DD-MON-YYYY HH24:MI'), 'Pasir Gudang', 'Platform 5', 'KLIA Transit', TO_DATE('25-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0295', 'B0095', TO_DATE('08-Oct-2024 17:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('08-Oct-2024 21:53', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 11', 'KLIA Transit', TO_DATE('08-Oct-2024', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0296', 'B0096', TO_DATE('03-Dec-2024 21:15', 'DD-MON-YYYY HH24:MI'), TO_DATE('03-Dec-2024 21:47', 'DD-MON-YYYY HH24:MI'), 'Muar', 'Platform 10', 'Kajang', TO_DATE('03-Dec-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0297', 'B0097', TO_DATE('25-Apr-2023 10:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('25-Apr-2023 15:10', 'DD-MON-YYYY HH24:MI'), 'Batu Gajah', 'Platform 6', 'Pasir Gudang', TO_DATE('25-Apr-2023', 'DD-MON-YYYY'), 'Cancelled');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0298', 'B0098', TO_DATE('03-Feb-2024 18:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('03-Feb-2024 20:50', 'DD-MON-YYYY HH24:MI'), 'Rawang', 'Platform 10', 'Shah Alam', TO_DATE('03-Feb-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0299', 'B0099', TO_DATE('01-Feb-2024 12:30', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Feb-2024 15:28', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 2', 'Seremban', TO_DATE('01-Feb-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0300', 'B0100', TO_DATE('30-Sep-2024 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('01-Oct-2024 00:32', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 3', 'Johor Bahru Sentral', TO_DATE('30-Sep-2024', 'DD-MON-YYYY'), 'Active');

INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0301', 'B0099', TO_DATE('29-Jul-2024 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('31-Jul-2024 00:32', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 1', 'Pasir Gudang', TO_DATE('30-Sep-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0302', 'B0098', TO_DATE('30-Jan-2024 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('02-Oct-2024 00:32', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 2', 'KLIA Transit', TO_DATE('30-Sep-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0303', 'B0097', TO_DATE('22-Feb-2024 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('23-Feb-2024 22:45', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 3', 'Ipoh', TO_DATE('30-Sep-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0304', 'B0091', TO_DATE('30-Aug-2024 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('31-Aug-2024 22:45', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 3', 'Batu Gajah', TO_DATE('30-Sep-2024', 'DD-MON-YYYY'), 'Active');
INSERT INTO Schedule (ScheduleID, BusID, DepartureTime, ArrivalTime, Station, Platform, Destination, ScheduleDate, ScheduleStatus) VALUES ('SCH0305', 'B0090', TO_DATE('03-Sep-2022 22:45', 'DD-MON-YYYY HH24:MI'), TO_DATE('04-Sep-2022 22:45', 'DD-MON-YYYY HH24:MI'), 'Kuala Lumpur Central', 'Platform 5', 'Gemas', TO_DATE('30-Sep-2024', 'DD-MON-YYYY'), 'Active');

-----
-- Round 3
-- Trigger(Kenny)
CREATE OR REPLACE TRIGGER trg_UpdateDriverShift
BEFORE INSERT OR UPDATE ON DriverAllocation
FOR EACH ROW
DECLARE
    v_departureTime Schedule.DepartureTime%TYPE;
    v_time          NUMBER;
BEGIN
    SELECT DepartureTime INTO v_departureTime
    FROM Schedule
    WHERE ScheduleID = :NEW.ScheduleID;

    v_time := TO_NUMBER(TO_CHAR(v_departureTime, 'HH24MI'));

    IF v_time BETWEEN 500 AND 1159 THEN
        :NEW.Shift := 'Morning';
    ELSIF v_time BETWEEN 1200 AND 1659 THEN
        :NEW.Shift := 'Afternoon';
    ELSIF v_time BETWEEN 1700 AND 2059 THEN
        :NEW.Shift := 'Evening';
    ELSE
        :NEW.Shift := 'Night';
    END IF;

END;
/

-- Driver Allocation
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0001', 'SCH0001');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0002', 'SCH0002');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0003', 'SCH0003');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0004', 'SCH0004');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0005', 'SCH0005');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0006', 'SCH0006');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0007', 'SCH0007');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0008', 'SCH0008');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0009', 'SCH0009');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0010', 'SCH0010');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0011', 'SCH0011');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0012', 'SCH0012');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0013', 'SCH0013');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0014', 'SCH0014');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0015', 'SCH0015');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0016', 'SCH0016');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0017', 'SCH0017');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0018', 'SCH0018');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0019', 'SCH0019');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0020', 'SCH0020');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0021', 'SCH0021');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0022', 'SCH0022');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0023', 'SCH0023');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0024', 'SCH0024');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0025', 'SCH0025');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0026', 'SCH0026');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0027', 'SCH0027');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0028', 'SCH0028');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0029', 'SCH0029');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0030', 'SCH0030');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0031', 'SCH0031');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0032', 'SCH0032');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0033', 'SCH0033');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0034', 'SCH0034');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0035', 'SCH0035');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0036', 'SCH0036');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0037', 'SCH0037');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0038', 'SCH0038');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0039', 'SCH0039');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0040', 'SCH0040');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0041', 'SCH0041');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0042', 'SCH0042');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0043', 'SCH0043');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0044', 'SCH0044');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0045', 'SCH0045');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0046', 'SCH0046');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0047', 'SCH0047');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0048', 'SCH0048');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0049', 'SCH0049');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0050', 'SCH0050');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0051', 'SCH0051');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0052', 'SCH0052');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0053', 'SCH0053');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0054', 'SCH0054');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0055', 'SCH0055');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0056', 'SCH0056');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0057', 'SCH0057');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0058', 'SCH0058');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0059', 'SCH0059');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0060', 'SCH0060');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0061', 'SCH0061');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0062', 'SCH0062');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0063', 'SCH0063');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0064', 'SCH0064');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0065', 'SCH0065');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0066', 'SCH0066');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0067', 'SCH0067');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0068', 'SCH0068');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0069', 'SCH0069');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0070', 'SCH0070');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0071', 'SCH0071');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0072', 'SCH0072');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0073', 'SCH0073');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0074', 'SCH0074');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0075', 'SCH0075');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0076', 'SCH0076');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0077', 'SCH0077');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0078', 'SCH0078');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0079', 'SCH0079');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0080', 'SCH0080');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0081', 'SCH0081');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0082', 'SCH0082');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0083', 'SCH0083');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0084', 'SCH0084');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0085', 'SCH0085');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0086', 'SCH0086');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0087', 'SCH0087');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0088', 'SCH0088');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0089', 'SCH0089');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0090', 'SCH0090');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0091', 'SCH0091');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0092', 'SCH0092');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0093', 'SCH0093');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0094', 'SCH0094');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0095', 'SCH0095');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0096', 'SCH0096');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0097', 'SCH0097');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0098', 'SCH0098');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0099', 'SCH0099');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0100', 'SCH0100');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0001', 'SCH0101');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0002', 'SCH0102');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0003', 'SCH0103');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0004', 'SCH0104');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0005', 'SCH0105');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0006', 'SCH0106');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0007', 'SCH0107');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0008', 'SCH0108');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0009', 'SCH0109');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0010', 'SCH0110');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0011', 'SCH0111');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0012', 'SCH0112');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0013', 'SCH0113');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0014', 'SCH0114');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0015', 'SCH0115');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0016', 'SCH0116');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0017', 'SCH0117');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0018', 'SCH0118');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0019', 'SCH0119');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0020', 'SCH0120');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0021', 'SCH0121');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0022', 'SCH0122');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0023', 'SCH0123');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0024', 'SCH0124');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0025', 'SCH0125');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0026', 'SCH0126');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0027', 'SCH0127');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0028', 'SCH0128');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0029', 'SCH0129');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0030', 'SCH0130');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0031', 'SCH0131');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0032', 'SCH0132');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0033', 'SCH0133');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0034', 'SCH0134');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0035', 'SCH0135');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0036', 'SCH0136');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0037', 'SCH0137');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0038', 'SCH0138');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0039', 'SCH0139');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0040', 'SCH0140');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0041', 'SCH0141');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0042', 'SCH0142');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0043', 'SCH0143');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0044', 'SCH0144');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0045', 'SCH0145');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0046', 'SCH0146');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0047', 'SCH0147');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0048', 'SCH0148');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0049', 'SCH0149');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0050', 'SCH0150');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0051', 'SCH0151');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0052', 'SCH0152');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0053', 'SCH0153');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0054', 'SCH0154');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0055', 'SCH0155');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0056', 'SCH0156');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0057', 'SCH0157');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0058', 'SCH0158');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0059', 'SCH0159');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0060', 'SCH0160');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0061', 'SCH0161');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0062', 'SCH0162');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0063', 'SCH0163');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0064', 'SCH0164');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0065', 'SCH0165');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0066', 'SCH0166');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0067', 'SCH0167');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0068', 'SCH0168');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0069', 'SCH0169');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0070', 'SCH0170');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0071', 'SCH0171');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0072', 'SCH0172');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0073', 'SCH0173');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0074', 'SCH0174');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0075', 'SCH0175');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0076', 'SCH0176');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0077', 'SCH0177');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0078', 'SCH0178');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0079', 'SCH0179');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0080', 'SCH0180');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0081', 'SCH0181');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0082', 'SCH0182');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0083', 'SCH0183');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0084', 'SCH0184');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0085', 'SCH0185');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0086', 'SCH0186');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0087', 'SCH0187');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0088', 'SCH0188');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0089', 'SCH0189');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0090', 'SCH0190');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0091', 'SCH0191');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0092', 'SCH0192');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0093', 'SCH0193');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0094', 'SCH0194');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0095', 'SCH0195');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0096', 'SCH0196');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0097', 'SCH0197');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0098', 'SCH0198');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0099', 'SCH0199');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0100', 'SCH0200');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0001', 'SCH0201');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0002', 'SCH0202');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0003', 'SCH0203');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0004', 'SCH0204');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0005', 'SCH0205');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0006', 'SCH0206');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0007', 'SCH0207');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0008', 'SCH0208');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0009', 'SCH0209');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0010', 'SCH0210');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0011', 'SCH0211');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0012', 'SCH0212');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0013', 'SCH0213');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0014', 'SCH0214');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0015', 'SCH0215');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0016', 'SCH0216');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0017', 'SCH0217');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0018', 'SCH0218');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0019', 'SCH0219');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0020', 'SCH0220');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0021', 'SCH0221');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0022', 'SCH0222');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0023', 'SCH0223');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0024', 'SCH0224');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0025', 'SCH0225');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0026', 'SCH0226');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0027', 'SCH0227');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0028', 'SCH0228');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0029', 'SCH0229');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0030', 'SCH0230');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0031', 'SCH0231');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0032', 'SCH0232');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0033', 'SCH0233');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0034', 'SCH0234');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0035', 'SCH0235');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0036', 'SCH0236');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0037', 'SCH0237');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0038', 'SCH0238');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0039', 'SCH0239');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0040', 'SCH0240');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0041', 'SCH0241');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0042', 'SCH0242');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0043', 'SCH0243');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0044', 'SCH0244');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0045', 'SCH0245');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0046', 'SCH0246');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0047', 'SCH0247');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0048', 'SCH0248');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0049', 'SCH0249');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0050', 'SCH0250');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0051', 'SCH0251');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0052', 'SCH0252');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0053', 'SCH0253');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0054', 'SCH0254');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0055', 'SCH0255');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0056', 'SCH0256');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0057', 'SCH0257');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0058', 'SCH0258');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0059', 'SCH0259');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0060', 'SCH0260');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0061', 'SCH0261');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0062', 'SCH0262');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0063', 'SCH0263');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0064', 'SCH0264');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0065', 'SCH0265');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0066', 'SCH0266');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0067', 'SCH0267');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0068', 'SCH0268');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0069', 'SCH0269');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0070', 'SCH0270');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0071', 'SCH0271');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0072', 'SCH0272');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0073', 'SCH0273');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0074', 'SCH0274');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0075', 'SCH0275');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0076', 'SCH0276');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0077', 'SCH0277');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0078', 'SCH0278');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0079', 'SCH0279');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0080', 'SCH0280');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0081', 'SCH0281');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0082', 'SCH0282');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0083', 'SCH0283');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0084', 'SCH0284');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0085', 'SCH0285');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0086', 'SCH0286');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0087', 'SCH0287');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0088', 'SCH0288');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0089', 'SCH0289');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0090', 'SCH0290');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0091', 'SCH0291');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0092', 'SCH0292');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0093', 'SCH0293');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0094', 'SCH0294');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0095', 'SCH0295');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0096', 'SCH0296');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0097', 'SCH0297');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0098', 'SCH0298');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0099', 'SCH0299');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0100', 'SCH0300');

INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0101', 'SCH0211');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0102', 'SCH0110');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0103', 'SCH0300');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0104', 'SCH0290');
INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES ('D0105', 'SCH0190');

-- Ticket
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00001', 'SCH0001', 'A8', 20, 'Active', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00002', 'SCH0002', 'E14', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00003', 'SCH0003', 'D1', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00004', 'SCH0004', 'E14', 20, 'Available', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00005', 'SCH0005', 'A1', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00006', 'SCH0006', 'C10', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00007', 'SCH0007', 'C15', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00008', 'SCH0008', 'B12', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00009', 'SCH0009', 'H9', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00010', 'SCH0010', 'D10', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00011', 'SCH0011', 'D19', 20, 'Available', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00012', 'SCH0012', 'D17', 20, 'Active', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00013', 'SCH0013', 'G20', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00014', 'SCH0014', 'F15', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00015', 'SCH0015', 'F11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00016', 'SCH0016', 'G6', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00017', 'SCH0017', 'H4', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00018', 'SCH0018', 'B20', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00019', 'SCH0019', 'F1', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00020', 'SCH0020', 'G10', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00021', 'SCH0021', 'C12', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00022', 'SCH0022', 'A14', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00023', 'SCH0023', 'B12', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00024', 'SCH0024', 'G15', 20, 'Active', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00025', 'SCH0025', 'F11', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00026', 'SCH0026', 'A5', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00027', 'SCH0027', 'D12', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00028', 'SCH0028', 'H2', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00029', 'SCH0029', 'A17', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00030', 'SCH0030', 'A5', 20, 'Available', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00031', 'SCH0031', 'B2', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00032', 'SCH0032', 'F2', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00033', 'SCH0033', 'A13', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00034', 'SCH0034', 'A15', 20, 'Active', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00035', 'SCH0035', 'H18', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00036', 'SCH0036', 'A13', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00037', 'SCH0037', 'B9', 20, 'Active', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00038', 'SCH0038', 'H15', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00039', 'SCH0039', 'D20', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00040', 'SCH0040', 'G8', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00041', 'SCH0041', 'C7', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00042', 'SCH0042', 'A17', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00043', 'SCH0043', 'H13', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00044', 'SCH0044', 'H1', 20, 'Available', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00045', 'SCH0045', 'E10', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00046', 'SCH0046', 'F16', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00047', 'SCH0047', 'B11', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00048', 'SCH0048', 'H16', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00049', 'SCH0049', 'H5', 20, 'Available', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00050', 'SCH0050', 'A16', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00051', 'SCH0051', 'F11', 20, 'Active', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00052', 'SCH0052', 'B12', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00053', 'SCH0053', 'D9', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00054', 'SCH0054', 'E4', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00055', 'SCH0055', 'F14', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00056', 'SCH0056', 'A15', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00057', 'SCH0057', 'D5', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00058', 'SCH0058', 'D12', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00059', 'SCH0059', 'G10', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00060', 'SCH0060', 'E3', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00061', 'SCH0061', 'G19', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00062', 'SCH0062', 'C6', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00063', 'SCH0063', 'A17', 20, 'Active', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00064', 'SCH0064', 'F10', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00065', 'SCH0065', 'D16', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00066', 'SCH0066', 'G6', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00067', 'SCH0067', 'H19', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00068', 'SCH0068', 'E1', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00069', 'SCH0069', 'E6', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00070', 'SCH0070', 'C1', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00071', 'SCH0071', 'B1', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00072', 'SCH0072', 'A11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00073', 'SCH0073', 'C3', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00074', 'SCH0074', 'H14', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00075', 'SCH0075', 'H16', 20, 'Active', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00076', 'SCH0076', 'H1', 20, 'Active', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00077', 'SCH0077', 'C11', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00078', 'SCH0078', 'H9', 20, 'Active', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00079', 'SCH0079', 'G10', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00080', 'SCH0080', 'B2', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00081', 'SCH0081', 'H6', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00082', 'SCH0082', 'G2', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00083', 'SCH0083', 'F11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00084', 'SCH0084', 'G9', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00085', 'SCH0085', 'G6', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00086', 'SCH0086', 'D9', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00087', 'SCH0087', 'D3', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00088', 'SCH0088', 'F15', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00089', 'SCH0089', 'H17', 20, 'Active', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00090', 'SCH0090', 'A18', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00091', 'SCH0091', 'B11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00092', 'SCH0092', 'A14', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00093', 'SCH0093', 'G18', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00094', 'SCH0094', 'C5', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00095', 'SCH0095', 'B20', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00096', 'SCH0096', 'B17', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00097', 'SCH0097', 'F19', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00098', 'SCH0098', 'E20', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00099', 'SCH0099', 'F16', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00100', 'SCH0100', 'E1', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00101', 'SCH0101', 'D11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00102', 'SCH0102', 'F15', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00103', 'SCH0103', 'G10', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00104', 'SCH0104', 'C14', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00105', 'SCH0105', 'B6', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00106', 'SCH0106', 'G4', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00107', 'SCH0107', 'C11', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00108', 'SCH0108', 'A12', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00109', 'SCH0109', 'G7', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00110', 'SCH0110', 'C5', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00111', 'SCH0111', 'H3', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00112', 'SCH0112', 'E9', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00113', 'SCH0113', 'B19', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00114', 'SCH0114', 'C19', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00115', 'SCH0115', 'F16', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00116', 'SCH0116', 'A3', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00117', 'SCH0117', 'A2', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00118', 'SCH0118', 'H4', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00119', 'SCH0119', 'H3', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00120', 'SCH0120', 'H3', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00121', 'SCH0121', 'C6', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00122', 'SCH0122', 'A9', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00123', 'SCH0123', 'H15', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00124', 'SCH0124', 'B7', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00125', 'SCH0125', 'C18', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00126', 'SCH0126', 'H7', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00127', 'SCH0127', 'D3', 20, 'Active', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00128', 'SCH0128', 'G14', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00129', 'SCH0129', 'H18', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00130', 'SCH0130', 'A1', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00131', 'SCH0131', 'E17', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00132', 'SCH0132', 'C19', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00133', 'SCH0133', 'C16', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00134', 'SCH0134', 'C2', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00135', 'SCH0135', 'A11', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00136', 'SCH0136', 'D13', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00137', 'SCH0137', 'D4', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00138', 'SCH0138', 'A5', 20, 'Active', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00139', 'SCH0139', 'E2', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00140', 'SCH0140', 'G5', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00141', 'SCH0141', 'G20', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00142', 'SCH0142', 'A14', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00143', 'SCH0143', 'D8', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00144', 'SCH0144', 'F19', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00145', 'SCH0145', 'A5', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00146', 'SCH0146', 'E10', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00147', 'SCH0147', 'F9', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00148', 'SCH0148', 'A8', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00149', 'SCH0149', 'D3', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00150', 'SCH0150', 'C9', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00151', 'SCH0151', 'F9', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00152', 'SCH0152', 'D11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00153', 'SCH0153', 'F11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00154', 'SCH0154', 'C15', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00155', 'SCH0155', 'G15', 20, 'Available', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00156', 'SCH0156', 'H19', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00157', 'SCH0157', 'C15', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00158', 'SCH0158', 'G18', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00159', 'SCH0159', 'B13', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00160', 'SCH0160', 'E11', 20, 'Available', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00161', 'SCH0161', 'C11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00162', 'SCH0162', 'G12', 20, 'Available', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00163', 'SCH0163', 'E12', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00164', 'SCH0164', 'B19', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00165', 'SCH0165', 'F2', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00166', 'SCH0166', 'F2', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00167', 'SCH0167', 'B9', 20, 'Available', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00168', 'SCH0168', 'D3', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00169', 'SCH0169', 'D5', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00170', 'SCH0170', 'B11', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00171', 'SCH0171', 'F14', 20, 'Available', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00172', 'SCH0172', 'C4', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00173', 'SCH0173', 'F15', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00174', 'SCH0174', 'D19', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00175', 'SCH0175', 'A13', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00176', 'SCH0176', 'B9', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00177', 'SCH0177', 'F19', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00178', 'SCH0178', 'G14', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00179', 'SCH0179', 'B11', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00180', 'SCH0180', 'E12', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00181', 'SCH0181', 'G3', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00182', 'SCH0182', 'C20', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00183', 'SCH0183', 'E1', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00184', 'SCH0184', 'H12', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00185', 'SCH0185', 'C15', 20, 'Available', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00186', 'SCH0186', 'B17', 20, 'Active', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00187', 'SCH0187', 'H15', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00188', 'SCH0188', 'F9', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00189', 'SCH0189', 'H6', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00190', 'SCH0190', 'F20', 20, 'Active', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00191', 'SCH0191', 'A8', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00192', 'SCH0192', 'B14', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00193', 'SCH0193', 'E4', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00194', 'SCH0194', 'A4', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00195', 'SCH0195', 'C14', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00196', 'SCH0196', 'E11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00197', 'SCH0197', 'A13', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00198', 'SCH0198', 'F18', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00199', 'SCH0199', 'F14', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00200', 'SCH0200', 'E14', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00201', 'SCH0201', 'F1', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00202', 'SCH0202', 'G5', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00203', 'SCH0203', 'B1', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00204', 'SCH0204', 'G17', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00205', 'SCH0205', 'D5', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00206', 'SCH0206', 'D20', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00207', 'SCH0207', 'G4', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00208', 'SCH0208', 'H16', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00209', 'SCH0209', 'A20', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00210', 'SCH0210', 'E20', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00211', 'SCH0211', 'A16', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00212', 'SCH0212', 'C17', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00213', 'SCH0213', 'B3', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00214', 'SCH0214', 'G11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00215', 'SCH0215', 'H3', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00216', 'SCH0216', 'D6', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00217', 'SCH0217', 'H1', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00218', 'SCH0218', 'F11', 20, 'Available', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00219', 'SCH0219', 'G4', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00220', 'SCH0220', 'B19', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00221', 'SCH0221', 'H11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00222', 'SCH0222', 'F2', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00223', 'SCH0223', 'E17', 20, 'Active', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00224', 'SCH0224', 'G2', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00225', 'SCH0225', 'E1', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00226', 'SCH0226', 'A10', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00227', 'SCH0227', 'B17', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00228', 'SCH0228', 'E11', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00229', 'SCH0229', 'G19', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00230', 'SCH0230', 'F16', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00231', 'SCH0231', 'E16', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00232', 'SCH0232', 'A17', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00233', 'SCH0233', 'D15', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00234', 'SCH0234', 'G18', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00235', 'SCH0235', 'B18', 20, 'Available', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00236', 'SCH0236', 'H10', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00237', 'SCH0237', 'F20', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00238', 'SCH0238', 'D13', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00239', 'SCH0239', 'A5', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00240', 'SCH0240', 'H19', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00241', 'SCH0241', 'A20', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00242', 'SCH0242', 'A3', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00243', 'SCH0243', 'C9', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00244', 'SCH0244', 'E15', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00245', 'SCH0245', 'B4', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00246', 'SCH0246', 'C18', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00247', 'SCH0247', 'A5', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00248', 'SCH0248', 'E3', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00249', 'SCH0249', 'E19', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00250', 'SCH0250', 'H5', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00251', 'SCH0251', 'H17', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00252', 'SCH0252', 'E6', 20, 'Active', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00253', 'SCH0253', 'F15', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00254', 'SCH0254', 'G6', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00255', 'SCH0255', 'A12', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00256', 'SCH0256', 'H2', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00257', 'SCH0257', 'E19', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00258', 'SCH0258', 'B18', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00259', 'SCH0259', 'G3', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00260', 'SCH0260', 'C4', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00261', 'SCH0261', 'H11', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00262', 'SCH0262', 'D12', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00263', 'SCH0263', 'H6', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00264', 'SCH0264', 'H3', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00265', 'SCH0265', 'A6', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00266', 'SCH0266', 'A12', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00267', 'SCH0267', 'F11', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00268', 'SCH0268', 'H6', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00269', 'SCH0269', 'E14', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00270', 'SCH0270', 'B20', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00271', 'SCH0271', 'G9', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00272', 'SCH0272', 'H1', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00273', 'SCH0273', 'E16', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00274', 'SCH0274', 'B13', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00275', 'SCH0275', 'E15', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00276', 'SCH0276', 'A18', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00277', 'SCH0277', 'B16', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00278', 'SCH0278', 'C2', 20, 'Available', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00279', 'SCH0279', 'F15', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00280', 'SCH0280', 'E2', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00281', 'SCH0281', 'G13', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00282', 'SCH0282', 'E3', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00283', 'SCH0283', 'A7', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00284', 'SCH0284', 'E13', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00285', 'SCH0285', 'G7', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00286', 'SCH0286', 'A13', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00287', 'SCH0287', 'H11', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00288', 'SCH0288', 'C1', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00289', 'SCH0289', 'F16', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00290', 'SCH0290', 'H16', 20, 'Active', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00291', 'SCH0291', 'E6', 20, 'Available', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00292', 'SCH0292', 'H12', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00293', 'SCH0293', 'D17', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00294', 'SCH0294', 'A5', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00295', 'SCH0295', 'B4', 20, 'Past', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00296', 'SCH0296', 'C10', 20, 'Past', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00297', 'SCH0297', 'E19', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00298', 'SCH0298', 'A18', 20, 'Refunded', 'Y');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00299', 'SCH0299', 'B11', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00300', 'SCH0300', 'C3', 20, 'Refunded', 'N');

INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00301', 'SCH0300', 'C4', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00302', 'SCH0300', 'C5', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00303', 'SCH0300', 'C6', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00304', 'SCH0300', 'C7', 20, 'Refunded', 'N');
INSERT INTO Ticket (TicketID, ScheduleID, SeatNo, Fare, Status, ExtendedTrip) VALUES ('TCK00305', 'SCH0300', 'C8', 20, 'Refunded', 'N');

-- Staff Allocation
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00050', 'STF003', 'Operator', 3.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00201', 'STF008', 'Operator', 7.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00045', 'STF010', 'Engineer', 2.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00134', 'STF002', 'Operator', 1.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00005', 'STF001', 'Mechanic', 6.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00168', 'STF003', 'Technician', 2.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00186', 'STF004', 'Mechanic', 6.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00096', 'STF004', 'Supervisor', 5.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00160', 'STF007', 'Cleaner', 5.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00085', 'STF003', 'Engineer', 6.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00110', 'STF007', 'Cleaner', 3.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00199', 'STF001', 'Cleaner', 3.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00240', 'STF002', 'Mechanic', 7.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00164', 'STF004', 'Inspector', 2.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00030', 'STF006', 'Engineer', 3.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00106', 'STF009', 'Electrician', 7.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00140', 'STF001', 'Operator', 1.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00010', 'STF007', 'Cleaner', 1.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00054', 'STF010', 'Cleaner', 7.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00161', 'STF010', 'Engineer', 1.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00117', 'STF006', 'Operator', 2.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00054', 'STF006', 'Mechanic', 1.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00204', 'STF006', 'Cleaner', 6.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00250', 'STF008', 'Mechanic', 5.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00122', 'STF001', 'Engineer', 4.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00086', 'STF010', 'Engineer', 6.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00059', 'STF009', 'Cleaner', 4.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00081', 'STF003', 'Mechanic', 2.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00271', 'STF001', 'Technician', 3.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00223', 'STF010', 'Operator', 3.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00028', 'STF008', 'Cleaner', 7.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00018', 'STF002', 'Inspector', 6.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00015', 'STF001', 'Operator', 5.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00148', 'STF010', 'Supervisor', 5.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00073', 'STF003', 'Inspector', 5.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00221', 'STF001', 'Cleaner', 1.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00025', 'STF010', 'Technician', 7.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00098', 'STF004', 'Technician', 6.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00255', 'STF007', 'Electrician', 4.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00089', 'STF009', 'Engineer', 4.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00235', 'STF003', 'Mechanic', 4.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00274', 'STF010', 'Engineer', 1.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00119', 'STF006', 'Mechanic', 5.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00190', 'STF004', 'Operator', 4.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00122', 'STF002', 'Supervisor', 6.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00220', 'STF007', 'Inspector', 2.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00150', 'STF010', 'Technician', 5.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00073', 'STF010', 'Inspector', 2.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00112', 'STF005', 'Cleaner', 5.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00234', 'STF010', 'Technician', 3.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00287', 'STF006', 'Mechanic', 6.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00296', 'STF001', 'Operator', 4.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00300', 'STF004', 'Cleaner', 6.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00159', 'STF009', 'Mechanic', 6.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00191', 'STF007', 'Engineer', 4.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00166', 'STF001', 'Technician', 1.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00218', 'STF007', 'Electrician', 2.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00023', 'STF001', 'Technician', 7.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00106', 'STF007', 'Supervisor', 5.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00242', 'STF010', 'Supervisor', 2.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00107', 'STF007', 'Supervisor', 7.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00224', 'STF002', 'Electrician', 2.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00208', 'STF005', 'Technician', 2.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00256', 'STF006', 'Electrician', 5.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00270', 'STF010', 'Cleaner', 7.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00194', 'STF009', 'Operator', 4.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00203', 'STF006', 'Cleaner', 2.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00242', 'STF001', 'Mechanic', 2.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00109', 'STF008', 'Supervisor', 5.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00213', 'STF007', 'Mechanic', 3.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00067', 'STF010', 'Inspector', 4.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00288', 'STF007', 'Electrician', 1.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00169', 'STF009', 'Supervisor', 8.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00299', 'STF009', 'Technician', 6.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00123', 'STF005', 'Electrician', 2.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00121', 'STF002', 'Technician', 2.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00155', 'STF002', 'Mechanic', 6.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00164', 'STF001', 'Electrician', 6.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00173', 'STF010', 'Supervisor', 5.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00289', 'STF007', 'Inspector', 3.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00147', 'STF008', 'Technician', 1.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00174', 'STF005', 'Inspector', 6.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00153', 'STF006', 'Electrician', 6.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00157', 'STF005', 'Mechanic', 7.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00142', 'STF008', 'Engineer', 7.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00023', 'STF010', 'Technician', 2.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00150', 'STF003', 'Technician', 6.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00285', 'STF008', 'Technician', 4.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00278', 'STF004', 'Inspector', 3.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00175', 'STF009', 'Cleaner', 7.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00013', 'STF009', 'Inspector', 5.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00294', 'STF005', 'Supervisor', 5.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00228', 'STF006', 'Engineer', 7.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00005', 'STF003', 'Inspector', 4.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00176', 'STF008', 'Mechanic', 2.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00077', 'STF008', 'Technician', 5.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00185', 'STF010', 'Inspector', 5.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00154', 'STF002', 'Cleaner', 6.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00172', 'STF004', 'Electrician', 3.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00287', 'STF009', 'Mechanic', 5.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00286', 'STF006', 'Technician', 5.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00088', 'STF008', 'Electrician', 2.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00159', 'STF003', 'Mechanic', 7.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00297', 'STF003', 'Supervisor', 6.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00203', 'STF003', 'Inspector', 4.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00188', 'STF003', 'Operator', 2.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00247', 'STF005', 'Inspector', 5.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00171', 'STF005', 'Cleaner', 5.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00211', 'STF001', 'Supervisor', 3.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00258', 'STF010', 'Supervisor', 1.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00150', 'STF004', 'Inspector', 2.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00029', 'STF007', 'Cleaner', 6.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00211', 'STF007', 'Mechanic', 6.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00109', 'STF004', 'Engineer', 6.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00061', 'STF008', 'Cleaner', 7.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00279', 'STF006', 'Technician', 8.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00145', 'STF003', 'Electrician', 6.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00275', 'STF002', 'Operator', 5.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00029', 'STF006', 'Cleaner', 5.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00291', 'STF005', 'Electrician', 4.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00175', 'STF008', 'Cleaner', 5.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00134', 'STF004', 'Engineer', 7.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00035', 'STF002', 'Technician', 3.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00290', 'STF010', 'Technician', 5.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00014', 'STF005', 'Mechanic', 1.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00141', 'STF002', 'Operator', 6.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00078', 'STF003', 'Operator', 3.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00174', 'STF006', 'Inspector', 4.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00203', 'STF010', 'Technician', 6.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00039', 'STF002', 'Mechanic', 3.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00157', 'STF007', 'Inspector', 3.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00179', 'STF010', 'Operator', 7.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00258', 'STF003', 'Engineer', 1.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00197', 'STF005', 'Electrician', 2.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00185', 'STF006', 'Technician', 2.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00262', 'STF008', 'Inspector', 4.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00082', 'STF003', 'Supervisor', 3.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00274', 'STF009', 'Cleaner', 5.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00250', 'STF001', 'Engineer', 6.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00081', 'STF006', 'Engineer', 3.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00179', 'STF001', 'Supervisor', 6.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00177', 'STF006', 'Technician', 3.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00250', 'STF009', 'Cleaner', 7.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00095', 'STF008', 'Supervisor', 2.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00182', 'STF010', 'Technician', 6.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00271', 'STF007', 'Operator', 3.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00102', 'STF005', 'Electrician', 4.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00040', 'STF001', 'Operator', 5.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00263', 'STF006', 'Technician', 5.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00074', 'STF004', 'Mechanic', 3.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00134', 'STF007', 'Cleaner', 4.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00155', 'STF008', 'Electrician', 4.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00215', 'STF010', 'Cleaner', 7.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00066', 'STF001', 'Technician', 2.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00056', 'STF010', 'Supervisor', 4.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00059', 'STF004', 'Inspector', 5.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00235', 'STF001', 'Operator', 6.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00060', 'STF003', 'Inspector', 3.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00270', 'STF003', 'Technician', 3.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00112', 'STF010', 'Mechanic', 5.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00051', 'STF003', 'Electrician', 5.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00130', 'STF010', 'Mechanic', 2.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00141', 'STF008', 'Electrician', 6.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00108', 'STF008', 'Engineer', 4.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00220', 'STF006', 'Mechanic', 6.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00155', 'STF004', 'Supervisor', 3.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00136', 'STF005', 'Engineer', 3.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00104', 'STF005', 'Mechanic', 3.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00042', 'STF007', 'Electrician', 5.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00073', 'STF004', 'Operator', 3.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00087', 'STF010', 'Supervisor', 4.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00100', 'STF005', 'Supervisor', 3.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00287', 'STF010', 'Mechanic', 3.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00083', 'STF003', 'Electrician', 4.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00282', 'STF010', 'Electrician', 5.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00039', 'STF003', 'Technician', 1.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00163', 'STF003', 'Engineer', 3.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00170', 'STF001', 'Electrician', 8.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00292', 'STF003', 'Inspector', 5.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00017', 'STF001', 'Inspector', 5.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00106', 'STF006', 'Operator', 6.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00111', 'STF004', 'Technician', 4.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00148', 'STF009', 'Mechanic', 4.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00050', 'STF006', 'Mechanic', 3.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00074', 'STF010', 'Electrician', 7.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00102', 'STF004', 'Electrician', 2.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00013', 'STF001', 'Inspector', 3.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00105', 'STF006', 'Mechanic', 3.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00210', 'STF006', 'Supervisor', 2.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00044', 'STF004', 'Technician', 4.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00158', 'STF001', 'Operator', 6.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00090', 'STF007', 'Engineer', 5.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00287', 'STF001', 'Cleaner', 4.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00029', 'STF001', 'Mechanic', 6.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00119', 'STF001', 'Operator', 7.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00184', 'STF005', 'Mechanic', 1.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00023', 'STF009', 'Mechanic', 2.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00192', 'STF002', 'Mechanic', 4.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00297', 'STF004', 'Technician', 4.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00139', 'STF006', 'Electrician', 6.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00026', 'STF001', 'Cleaner', 6.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00051', 'STF009', 'Operator', 1.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00135', 'STF002', 'Engineer', 5.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00229', 'STF004', 'Inspector', 2.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00019', 'STF001', 'Supervisor', 7.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00054', 'STF002', 'Engineer', 3.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00271', 'STF010', 'Engineer', 3.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00295', 'STF010', 'Mechanic', 4.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00057', 'STF002', 'Operator', 4.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00193', 'STF009', 'Inspector', 2.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00257', 'STF009', 'Operator', 7.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00130', 'STF001', 'Cleaner', 6.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00215', 'STF003', 'Cleaner', 1.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00065', 'STF003', 'Technician', 1.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00082', 'STF002', 'Mechanic', 3.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00079', 'STF008', 'Mechanic', 4.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00171', 'STF006', 'Mechanic', 2.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00007', 'STF004', 'Cleaner', 6.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00273', 'STF004', 'Technician', 4.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00014', 'STF001', 'Electrician', 2.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00029', 'STF008', 'Technician', 7.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00155', 'STF003', 'Cleaner', 6.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00292', 'STF009', 'Technician', 5.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00169', 'STF006', 'Mechanic', 5.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00006', 'STF006', 'Technician', 3.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00207', 'STF010', 'Engineer', 5.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00223', 'STF002', 'Supervisor', 7.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00118', 'STF010', 'Mechanic', 1.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00165', 'STF007', 'Operator', 2.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00036', 'STF002', 'Technician', 4.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00290', 'STF009', 'Supervisor', 7.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00060', 'STF006', 'Supervisor', 3.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00127', 'STF003', 'Engineer', 4.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00004', 'STF008', 'Mechanic', 5.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00231', 'STF002', 'Mechanic', 2.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00250', 'STF007', 'Electrician', 3.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00112', 'STF006', 'Inspector', 5.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00236', 'STF009', 'Mechanic', 4.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00096', 'STF001', 'Cleaner', 5.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00120', 'STF007', 'Mechanic', 4.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00280', 'STF003', 'Operator', 4.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00124', 'STF002', 'Cleaner', 4.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00104', 'STF004', 'Inspector', 6.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00280', 'STF008', 'Cleaner', 7.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00103', 'STF009', 'Technician', 2.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00174', 'STF009', 'Engineer', 3.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00001', 'STF004', 'Technician', 3.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00253', 'STF009', 'Cleaner', 7.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00249', 'STF005', 'Inspector', 6.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00121', 'STF003', 'Operator', 2.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00059', 'STF007', 'Supervisor', 7.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00291', 'STF004', 'Operator', 3.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00079', 'STF006', 'Electrician', 4.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00170', 'STF003', 'Supervisor', 7.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00231', 'STF008', 'Inspector', 2.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00011', 'STF007', 'Engineer', 2.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00058', 'STF008', 'Inspector', 3.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00231', 'STF001', 'Supervisor', 4.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00217', 'STF009', 'Cleaner', 5.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00249', 'STF002', 'Inspector', 6.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00042', 'STF006', 'Supervisor', 3.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00214', 'STF008', 'Inspector', 2.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00168', 'STF008', 'Engineer', 3.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00118', 'STF007', 'Inspector', 2.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00188', 'STF007', 'Supervisor', 6.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00225', 'STF001', 'Technician', 2.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00059', 'STF001', 'Inspector', 4.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00096', 'STF005', 'Electrician', 1.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00263', 'STF009', 'Electrician', 3.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00080', 'STF004', 'Mechanic', 1.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00282', 'STF005', 'Engineer', 2.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00230', 'STF009', 'Supervisor', 2.4);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00053', 'STF005', 'Operator', 3.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00190', 'STF010', 'Mechanic', 7.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00072', 'STF008', 'Inspector', 4.6);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00078', 'STF008', 'Technician', 6.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00020', 'STF009', 'Cleaner', 3.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00023', 'STF004', 'Technician', 3.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00218', 'STF001', 'Inspector', 5.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00280', 'STF006', 'Electrician', 1.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00033', 'STF009', 'Technician', 4.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00177', 'STF008', 'Engineer', 1.0);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00261', 'STF008', 'Cleaner', 3.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00011', 'STF010', 'Inspector', 1.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00069', 'STF003', 'Inspector', 5.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00128', 'STF007', 'Supervisor', 2.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00006', 'STF003', 'Electrician', 6.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00233', 'STF001', 'Supervisor', 6.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00067', 'STF002', 'Technician', 1.9);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00196', 'STF010', 'Supervisor', 2.7);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00194', 'STF001', 'Technician', 6.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00143', 'STF001', 'Engineer', 2.3);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00184', 'STF008', 'Inspector', 1.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00224', 'STF003', 'Inspector', 3.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00022', 'STF001', 'Technician', 2.2);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00008', 'STF010', 'Technician', 1.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00127', 'STF008', 'Cleaner', 1.5);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00246', 'STF006', 'Mechanic', 4.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00257', 'STF002', 'Engineer', 1.1);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00086', 'STF001', 'Supervisor', 3.8);

INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00301', 'STF001', 'Supervisor', 3.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00302', 'STF002', 'Supervisor', 3.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00303', 'STF002', 'Supervisor', 3.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00304', 'STF001', 'Supervisor', 3.8);
INSERT INTO StaffAllocation (MaintenanceID, StaffID, Role, WorkedHour) VALUES ('MT00305', 'STF001', 'Scammer', 3.8);


-- Edison was here :D
-- Using Parts
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00035', 4, 'PRT004', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00172', 9, 'PRT009', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00070', 5, 'PRT005', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00286', 10, 'PRT010', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00109', 3, 'PRT003', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00151', 7, 'PRT007', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00057', 3, 'PRT003', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00230', 10, 'PRT010', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00063', 7, 'PRT007', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00276', 9, 'PRT009', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00219', 7, 'PRT007', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00070', 4, 'PRT004', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00019', 2, 'PRT002', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00255', 7, 'PRT007', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00230', 7, 'PRT007', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00192', 9, 'PRT009', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00178', 7, 'PRT007', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00106', 2, 'PRT002', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00095', 5, 'PRT005', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00291', 5, 'PRT005', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00260', 9, 'PRT009', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00113', 4, 'PRT004', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00265', 8, 'PRT008', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00224', 2, 'PRT002', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00086', 2, 'PRT002', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00158', 2, 'PRT002', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00105', 4, 'PRT004', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00243', 10, 'PRT010', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00114', 9, 'PRT009', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00226', 3, 'PRT003', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00161', 1, 'PRT001', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00010', 2, 'PRT002', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00174', 9, 'PRT009', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00135', 4, 'PRT004', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00277', 9, 'PRT009', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00095', 2, 'PRT002', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00043', 6, 'PRT006', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00297', 7, 'PRT007', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00298', 10, 'PRT010', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00197', 1, 'PRT001', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00099', 4, 'PRT004', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00024', 1, 'PRT001', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00067', 9, 'PRT009', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00261', 4, 'PRT004', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00027', 2, 'PRT002', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00082', 6, 'PRT006', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00265', 2, 'PRT002', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00123', 8, 'PRT008', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00069', 4, 'PRT004', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00027', 3, 'PRT003', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00007', 9, 'PRT009', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00022', 3, 'PRT003', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00133', 3, 'PRT003', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00048', 10, 'PRT010', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00259', 5, 'PRT005', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00181', 5, 'PRT005', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00202', 7, 'PRT007', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00279', 8, 'PRT008', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00244', 1, 'PRT001', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00262', 7, 'PRT007', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00103', 10, 'PRT010', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00173', 8, 'PRT008', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00291', 7, 'PRT007', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00052', 2, 'PRT002', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00088', 5, 'PRT005', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00113', 7, 'PRT007', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00123', 1, 'PRT001', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00028', 10, 'PRT010', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00013', 7, 'PRT007', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00009', 6, 'PRT006', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00118', 3, 'PRT003', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00167', 8, 'PRT008', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00293', 9, 'PRT009', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00253', 8, 'PRT008', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00044', 6, 'PRT006', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00198', 8, 'PRT008', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00248', 1, 'PRT001', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00001', 7, 'PRT007', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00254', 3, 'PRT003', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00114', 7, 'PRT007', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00127', 8, 'PRT008', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00114', 5, 'PRT005', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00061', 4, 'PRT004', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00299', 6, 'PRT006', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00288', 1, 'PRT001', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00059', 7, 'PRT007', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00163', 8, 'PRT008', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00195', 3, 'PRT003', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00134', 5, 'PRT005', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00117', 3, 'PRT003', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00190', 5, 'PRT005', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00002', 2, 'PRT002', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00117', 9, 'PRT009', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00134', 9, 'PRT009', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00150', 10, 'PRT010', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00249', 1, 'PRT001', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00298', 7, 'PRT007', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00179', 5, 'PRT005', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00218', 1, 'PRT001', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00002', 4, 'PRT004', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00235', 10, 'PRT010', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00165', 2, 'PRT002', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00159', 5, 'PRT005', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00212', 4, 'PRT004', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00160', 1, 'PRT001', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00162', 10, 'PRT010', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00151', 2, 'PRT002', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00251', 7, 'PRT007', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00126', 3, 'PRT003', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00292', 9, 'PRT009', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00165', 4, 'PRT004', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00134', 10, 'PRT010', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00237', 3, 'PRT003', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00012', 2, 'PRT002', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00036', 2, 'PRT002', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00103', 1, 'PRT001', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00134', 1, 'PRT001', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00003', 8, 'PRT008', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00020', 9, 'PRT009', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00232', 7, 'PRT007', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00064', 6, 'PRT006', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00062', 3, 'PRT003', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00254', 2, 'PRT002', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00056', 7, 'PRT007', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00093', 4, 'PRT004', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00119', 2, 'PRT002', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00058', 10, 'PRT010', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00286', 2, 'PRT002', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00065', 8, 'PRT008', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00188', 5, 'PRT005', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00105', 3, 'PRT003', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00018', 3, 'PRT003', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00188', 2, 'PRT002', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00125', 2, 'PRT002', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00065', 7, 'PRT007', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00092', 4, 'PRT004', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00118', 9, 'PRT009', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00204', 5, 'PRT005', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00073', 9, 'PRT009', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00295', 8, 'PRT008', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00161', 10, 'PRT010', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00160', 9, 'PRT009', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00196', 8, 'PRT008', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00140', 8, 'PRT008', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00046', 7, 'PRT007', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00005', 8, 'PRT008', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00277', 4, 'PRT004', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00066', 10, 'PRT010', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00131', 9, 'PRT009', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00133', 8, 'PRT008', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00182', 9, 'PRT009', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00046', 4, 'PRT004', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00032', 1, 'PRT001', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00093', 7, 'PRT007', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00225', 3, 'PRT003', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00063', 1, 'PRT001', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00025', 6, 'PRT006', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00050', 4, 'PRT004', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00273', 9, 'PRT009', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00007', 6, 'PRT006', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00216', 10, 'PRT010', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00026', 6, 'PRT006', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00120', 4, 'PRT004', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00280', 10, 'PRT010', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00016', 5, 'PRT005', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00111', 1, 'PRT001', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00246', 5, 'PRT005', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00158', 9, 'PRT009', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00127', 1, 'PRT001', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00116', 7, 'PRT007', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00198', 2, 'PRT002', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00124', 10, 'PRT010', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00146', 5, 'PRT005', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00162', 4, 'PRT004', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00249', 5, 'PRT005', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00290', 4, 'PRT004', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00099', 7, 'PRT007', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00220', 6, 'PRT006', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00100', 10, 'PRT010', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00045', 6, 'PRT006', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00123', 7, 'PRT007', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00148', 2, 'PRT002', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00226', 4, 'PRT004', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00220', 2, 'PRT002', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00012', 8, 'PRT008', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00070', 7, 'PRT007', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00107', 5, 'PRT005', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00135', 1, 'PRT001', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00240', 6, 'PRT006', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00244', 4, 'PRT004', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00031', 1, 'PRT001', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00225', 6, 'PRT006', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00014', 4, 'PRT004', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00281', 10, 'PRT010', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00285', 4, 'PRT004', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00205', 8, 'PRT008', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00080', 4, 'PRT004', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00145', 5, 'PRT005', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00164', 2, 'PRT002', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00147', 5, 'PRT005', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00274', 6, 'PRT006', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00169', 6, 'PRT006', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00273', 7, 'PRT007', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00244', 3, 'PRT003', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00061', 1, 'PRT001', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00024', 7, 'PRT007', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00294', 4, 'PRT004', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00115', 7, 'PRT007', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00026', 2, 'PRT002', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00146', 1, 'PRT001', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00257', 3, 'PRT003', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00284', 9, 'PRT009', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00250', 10, 'PRT010', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00040', 8, 'PRT008', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00253', 1, 'PRT001', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00224', 5, 'PRT005', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00038', 6, 'PRT006', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00207', 1, 'PRT001', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00189', 8, 'PRT008', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00051', 5, 'PRT005', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00138', 4, 'PRT004', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00290', 1, 'PRT001', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00214', 1, 'PRT001', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00018', 10, 'PRT010', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00194', 8, 'PRT008', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00219', 10, 'PRT010', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00098', 7, 'PRT007', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00111', 10, 'PRT010', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00015', 7, 'PRT007', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00142', 5, 'PRT005', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00264', 7, 'PRT007', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00074', 9, 'PRT009', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00017', 6, 'PRT006', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00030', 7, 'PRT007', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00087', 2, 'PRT002', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00132', 3, 'PRT003', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00274', 10, 'PRT010', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00154', 4, 'PRT004', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00140', 9, 'PRT009', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00297', 5, 'PRT005', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00288', 9, 'PRT009', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00247', 6, 'PRT006', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00221', 10, 'PRT010', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00222', 2, 'PRT002', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00062', 9, 'PRT009', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00008', 7, 'PRT007', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00287', 9, 'PRT009', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00030', 10, 'PRT010', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00260', 5, 'PRT005', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00197', 8, 'PRT008', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00283', 6, 'PRT006', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00217', 2, 'PRT002', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00171', 7, 'PRT007', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00204', 6, 'PRT006', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00194', 2, 'PRT002', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00140', 2, 'PRT002', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00261', 3, 'PRT003', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00223', 8, 'PRT008', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00266', 5, 'PRT005', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00044', 3, 'PRT003', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00250', 1, 'PRT001', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00176', 7, 'PRT007', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00124', 8, 'PRT008', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00050', 8, 'PRT008', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00048', 4, 'PRT004', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00181', 9, 'PRT009', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00113', 1, 'PRT001', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00300', 2, 'PRT002', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00284', 4, 'PRT004', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00091', 10, 'PRT010', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00239', 3, 'PRT003', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00217', 8, 'PRT008', 6);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00220', 9, 'PRT009', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00065', 2, 'PRT002', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00064', 5, 'PRT005', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00227', 2, 'PRT002', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00027', 9, 'PRT009', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00066', 7, 'PRT007', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00051', 4, 'PRT004', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00057', 2, 'PRT002', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00005', 1, 'PRT001', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00147', 7, 'PRT007', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00300', 5, 'PRT005', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00164', 7, 'PRT007', 3);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00153', 9, 'PRT009', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00246', 2, 'PRT002', 2);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00136', 5, 'PRT005', 8);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00273', 10, 'PRT010', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00025', 10, 'PRT010', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00124', 5, 'PRT005', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00126', 1, 'PRT001', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00099', 9, 'PRT009', 9);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00291', 10, 'PRT010', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00252', 3, 'PRT003', 10);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00289', 3, 'PRT003', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00017', 1, 'PRT001', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00077', 3, 'PRT003', 1);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00212', 1, 'PRT001', 7);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00091', 5, 'PRT005', 4);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00022', 9, 'PRT009', 5);

INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00301', 9, 'PRT009', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00302', 9, 'PRT009', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00303', 9, 'PRT009', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00304', 9, 'PRT009', 5);
INSERT INTO Using_Parts (MaintenanceID, PartKey, PartID, QuantityUsed) VALUES ('MT00305', 9, 'PRT009', 2);



-- Part Order
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0001', TO_DATE('2025-09-16', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP006', 6, 371.70);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0002', TO_DATE('2024-01-31', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP006', 100, 17771.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0003', TO_DATE('2025-03-17', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP002', 85, 32645.10);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0004', TO_DATE('2024-05-20', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP007', 68, 17475.32);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0005', TO_DATE('2024-09-20', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP009', 64, 18707.20);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0006', TO_DATE('2025-09-15', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP004', 49, 2009.98);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0007', TO_DATE('2024-07-03', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP010', 36, 3214.80);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0008', TO_DATE('2024-09-03', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP005', 88, 31769.76);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0009', TO_DATE('2024-11-28', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP004', 43, 10198.74);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0010', TO_DATE('2024-05-31', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP008', 56, 4702.32);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0011', TO_DATE('2024-10-10', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP005', 87, 3149.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0012', TO_DATE('2024-10-30', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP006', 21, 5685.75);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0013', TO_DATE('2024-11-25', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP001', 96, 46942.08);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0014', TO_DATE('2024-08-25', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP010', 94, 18427.76);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0015', TO_DATE('2024-09-14', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP004', 13, 518.31);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0016', TO_DATE('2025-07-04', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP010', 91, 25167.87);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0017', TO_DATE('2024-01-07', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP007', 72, 12853.44);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0018', TO_DATE('2025-01-01', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP005', 22, 8691.54);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0019', TO_DATE('2025-04-07', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP007', 88, 9765.36);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0020', TO_DATE('2024-06-17', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP010', 9, 2650.59);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0021', TO_DATE('2025-02-06', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP008', 41, 13504.58);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0022', TO_DATE('2025-04-28', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP010', 70, 19462.80);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0023', TO_DATE('2025-03-21', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP006', 4, 684.04);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0024', TO_DATE('2024-01-22', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP004', 64, 17047.04);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0025', TO_DATE('2024-07-08', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP005', 88, 36862.32);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0026', TO_DATE('2024-06-18', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP004', 50, 11179.50);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0027', TO_DATE('2025-11-03', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP004', 48, 20443.20);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0028', TO_DATE('2025-03-21', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP005', 24, 9363.12);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0029', TO_DATE('2024-10-19', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP006', 76, 32548.52);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0030', TO_DATE('2025-03-05', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP003', 31, 4680.69);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0031', TO_DATE('2025-04-19', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP004', 9, 540.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0032', TO_DATE('2025-03-06', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP009', 1, 261.38);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0033', TO_DATE('2024-02-05', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP007', 19, 5763.27);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0034', TO_DATE('2025-04-04', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP006', 1, 82.14);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0035', TO_DATE('2024-02-27', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP009', 35, 5391.05);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0036', TO_DATE('2025-07-22', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP001', 95, 24070.15);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0037', TO_DATE('2024-11-27', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP007', 56, 19020.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0038', TO_DATE('2024-01-18', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP002', 95, 23587.55);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0039', TO_DATE('2024-10-28', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP006', 58, 10631.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0040', TO_DATE('2024-02-29', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP002', 38, 17685.20);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0041', TO_DATE('2024-11-10', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP007', 94, 17573.30);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0042', TO_DATE('2025-07-20', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP004', 54, 7254.90);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0043', TO_DATE('2025-06-29', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP003', 35, 2151.10);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0044', TO_DATE('2025-01-02', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP007', 49, 6462.61);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0045', TO_DATE('2024-06-08', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP005', 15, 3361.65);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0046', TO_DATE('2025-08-04', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP006', 91, 39975.39);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0047', TO_DATE('2024-02-03', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP006', 85, 29400.65);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0048', TO_DATE('2024-04-20', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP003', 40, 19082.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0049', TO_DATE('2024-01-20', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP002', 15, 4934.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0050', TO_DATE('2025-06-23', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP002', 43, 10181.54);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0051', TO_DATE('2025-09-03', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP009', 9, 4197.42);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0052', TO_DATE('2025-08-13', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP005', 69, 15901.74);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0053', TO_DATE('2024-05-22', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP006', 37, 13044.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0054', TO_DATE('2025-12-15', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP008', 23, 8285.06);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0055', TO_DATE('2024-01-14', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP007', 46, 11678.94);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0056', TO_DATE('2024-04-30', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP004', 48, 10441.92);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0057', TO_DATE('2024-04-01', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP008', 10, 2067.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0058', TO_DATE('2024-03-24', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP010', 22, 6381.98);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0059', TO_DATE('2024-09-30', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP006', 47, 15772.73);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0060', TO_DATE('2025-09-28', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP007', 36, 13456.08);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0061', TO_DATE('2025-09-07', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP003', 28, 7119.84);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0062', TO_DATE('2025-10-04', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP004', 56, 18450.32);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0063', TO_DATE('2025-12-16', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP009', 31, 4018.22);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0064', TO_DATE('2025-11-02', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP006', 67, 11055.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0065', TO_DATE('2025-09-30', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP009', 100, 27307.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0066', TO_DATE('2024-11-07', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP010', 64, 20688.64);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0067', TO_DATE('2025-07-29', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP004', 65, 29179.80);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0068', TO_DATE('2025-04-16', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP007', 81, 10204.38);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0069', TO_DATE('2024-08-07', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP004', 72, 24865.92);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0070', TO_DATE('2025-11-24', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP002', 21, 10039.05);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0071', TO_DATE('2025-10-07', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP001', 39, 7294.56);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0072', TO_DATE('2024-01-25', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP004', 1, 181.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0073', TO_DATE('2024-06-17', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP004', 28, 4470.48);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0074', TO_DATE('2025-08-13', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP004', 79, 15971.43);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0075', TO_DATE('2025-11-11', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP001', 83, 27447.27);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0076', TO_DATE('2025-12-08', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP010', 5, 2218.45);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0077', TO_DATE('2024-10-06', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP008', 83, 26898.64);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0078', TO_DATE('2024-05-06', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP007', 73, 26664.71);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0079', TO_DATE('2024-01-08', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP002', 25, 11160.75);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0080', TO_DATE('2025-03-20', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP003', 44, 21145.52);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0081', TO_DATE('2024-08-22', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP009', 31, 3976.99);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0082', TO_DATE('2025-10-15', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP004', 48, 12961.92);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0083', TO_DATE('2024-03-30', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP004', 10, 4138.10);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0084', TO_DATE('2024-04-03', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP003', 52, 12117.56);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0085', TO_DATE('2025-02-24', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP005', 29, 6195.56);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0086', TO_DATE('2024-01-31', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP006', 42, 4165.14);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0087', TO_DATE('2025-07-09', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP003', 79, 1152.61);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0088', TO_DATE('2024-04-29', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP009', 67, 21639.66);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0089', TO_DATE('2025-03-03', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP005', 98, 44117.64);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0090', TO_DATE('2025-03-11', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP004', 66, 6652.80);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0091', TO_DATE('2025-09-14', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP006', 26, 12576.98);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0092', TO_DATE('2024-12-14', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP009', 74, 16743.98);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0093', TO_DATE('2025-07-14', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP010', 18, 2952.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0094', TO_DATE('2025-07-03', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP003', 97, 3535.65);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0095', TO_DATE('2025-05-28', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP008', 76, 37465.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0096', TO_DATE('2025-09-09', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP005', 52, 25165.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0097', TO_DATE('2025-09-26', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP010', 69, 32020.83);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0098', TO_DATE('2024-08-18', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP006', 27, 7255.17);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0099', TO_DATE('2024-03-21', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP004', 20, 5076.20);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0100', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 93, 20845.95);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0101', TO_DATE('2024-12-24', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP007', 77, 7646.87);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0102', TO_DATE('2025-07-03', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP003', 46, 748.88);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0103', TO_DATE('2024-11-15', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP005', 23, 3081.77);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0104', TO_DATE('2025-06-28', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP008', 86, 39437.88);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0105', TO_DATE('2025-11-03', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP010', 50, 22494.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0106', TO_DATE('2025-02-09', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP008', 75, 4999.50);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0107', TO_DATE('2024-10-18', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP009', 45, 9923.85);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0108', TO_DATE('2025-10-10', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP007', 39, 9709.83);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0109', TO_DATE('2025-09-12', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP006', 22, 654.06);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0110', TO_DATE('2024-01-18', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP001', 13, 2591.03);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0111', TO_DATE('2025-08-17', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP002', 52, 24372.92);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0112', TO_DATE('2024-05-23', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP006', 33, 2011.02);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0113', TO_DATE('2024-07-08', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP007', 55, 17136.35);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0114', TO_DATE('2025-07-17', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP007', 40, 19748.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0115', TO_DATE('2025-05-15', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP008', 19, 5894.37);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0116', TO_DATE('2024-04-06', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP001', 5, 1387.60);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0117', TO_DATE('2024-06-25', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP004', 93, 27886.05);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0118', TO_DATE('2025-02-05', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP007', 94, 28344.76);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0119', TO_DATE('2024-11-09', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP007', 19, 8084.12);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0120', TO_DATE('2025-09-20', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP004', 85, 16953.25);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0121', TO_DATE('2024-07-23', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP004', 61, 19520.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0122', TO_DATE('2025-06-16', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP006', 28, 6899.48);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0123', TO_DATE('2025-07-15', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP003', 98, 20371.26);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0124', TO_DATE('2024-02-23', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP001', 81, 24230.34);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0125', TO_DATE('2025-10-06', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP008', 12, 3437.16);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0126', TO_DATE('2024-05-06', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP009', 94, 26582.26);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0127', TO_DATE('2025-08-27', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP002', 100, 33873.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0128', TO_DATE('2024-02-10', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP002', 58, 9020.16);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0129', TO_DATE('2025-02-27', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP006', 97, 39935.87);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0130', TO_DATE('2024-07-04', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP008', 31, 8441.92);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0131', TO_DATE('2025-10-26', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP009', 90, 16077.60);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0132', TO_DATE('2024-03-13', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP009', 62, 21320.56);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0133', TO_DATE('2024-10-09', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP006', 16, 4030.08);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0134', TO_DATE('2025-12-05', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP006', 26, 3244.54);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0135', TO_DATE('2024-10-30', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP005', 29, 6807.46);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0136', TO_DATE('2025-06-09', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP003', 85, 35205.30);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0137', TO_DATE('2024-02-25', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP006', 57, 26032.47);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0138', TO_DATE('2024-09-16', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP010', 39, 15393.69);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0139', TO_DATE('2025-03-05', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP004', 98, 36519.70);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0140', TO_DATE('2025-05-16', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP007', 100, 7201.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0141', TO_DATE('2024-09-15', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP007', 76, 14721.20);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0142', TO_DATE('2025-11-24', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP008', 18, 1701.54);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0143', TO_DATE('2024-10-19', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP003', 99, 39912.84);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0144', TO_DATE('2024-07-22', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP006', 48, 12035.04);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0145', TO_DATE('2025-03-04', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP004', 60, 10387.20);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0146', TO_DATE('2025-12-30', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP007', 30, 14558.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0147', TO_DATE('2025-12-31', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP005', 61, 13199.79);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0148', TO_DATE('2025-08-06', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP008', 53, 23074.08);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0149', TO_DATE('2025-09-13', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP010', 25, 9272.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0150', TO_DATE('2024-03-10', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP007', 77, 19630.38);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0151', TO_DATE('2025-10-14', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 66, 10331.64);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0152', TO_DATE('2024-08-23', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP005', 88, 4292.64);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0153', TO_DATE('2025-10-15', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 65, 18392.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0154', TO_DATE('2025-08-20', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP005', 35, 5258.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0155', TO_DATE('2024-03-28', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP008', 22, 4666.64);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0156', TO_DATE('2024-10-16', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP002', 72, 5065.20);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0157', TO_DATE('2025-06-12', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP006', 69, 9501.30);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0158', TO_DATE('2024-03-30', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP004', 92, 24473.84);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0159', TO_DATE('2025-06-20', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP001', 44, 1719.52);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0160', TO_DATE('2025-08-19', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP008', 50, 20199.50);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0161', TO_DATE('2025-09-01', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP008', 46, 10935.58);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0162', TO_DATE('2024-08-15', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP001', 39, 4273.23);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0163', TO_DATE('2025-06-16', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP006', 72, 27205.20);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0164', TO_DATE('2024-06-04', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP010', 56, 3792.32);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0165', TO_DATE('2025-01-12', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP004', 45, 19177.65);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0166', TO_DATE('2024-08-11', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP004', 89, 41417.04);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0167', TO_DATE('2024-10-16', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP009', 98, 43320.90);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0168', TO_DATE('2024-08-28', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP006', 61, 22250.36);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0169', TO_DATE('2025-05-17', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP001', 23, 3491.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0170', TO_DATE('2024-02-11', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP002', 6, 1349.22);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0171', TO_DATE('2024-12-28', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP007', 21, 1313.13);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0172', TO_DATE('2025-09-21', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP003', 77, 9982.28);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0173', TO_DATE('2025-08-05', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP003', 10, 4120.90);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0174', TO_DATE('2024-02-29', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP002', 57, 23832.84);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0175', TO_DATE('2025-07-07', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP006', 85, 27714.25);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0176', TO_DATE('2025-04-26', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP007', 77, 27354.25);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0177', TO_DATE('2024-10-13', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP005', 55, 26062.85);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0178', TO_DATE('2024-07-10', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP002', 33, 6763.02);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0179', TO_DATE('2024-09-30', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP007', 61, 26979.69);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0180', TO_DATE('2024-07-09', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP010', 8, 2649.44);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0181', TO_DATE('2025-12-07', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP005', 84, 31136.28);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0182', TO_DATE('2025-08-01', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP008', 1, 302.43);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0183', TO_DATE('2024-03-11', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP007', 30, 4564.50);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0184', TO_DATE('2025-09-09', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP003', 9, 2164.77);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0185', TO_DATE('2024-02-13', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP009', 25, 4153.25);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0186', TO_DATE('2024-01-07', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP008', 13, 655.85);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0187', TO_DATE('2025-09-01', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP009', 98, 7468.58);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0188', TO_DATE('2024-04-26', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP008', 92, 4804.24);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0189', TO_DATE('2025-03-02', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP004', 9, 4243.86);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0190', TO_DATE('2024-03-17', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP008', 7, 3145.45);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0191', TO_DATE('2025-11-18', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP004', 15, 4853.25);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0192', TO_DATE('2024-07-07', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP008', 40, 3264.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0193', TO_DATE('2025-11-16', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP007', 73, 24563.04);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0194', TO_DATE('2025-07-23', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP009', 61, 19562.70);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0195', TO_DATE('2025-12-15', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP002', 84, 12327.84);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0196', TO_DATE('2024-06-12', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP003', 38, 18028.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0197', TO_DATE('2025-03-29', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP001', 37, 7973.87);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0198', TO_DATE('2024-08-23', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP009', 35, 10233.30);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0199', TO_DATE('2024-02-22', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP002', 83, 9416.35);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0200', TO_DATE('2024-03-02', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP003', 82, 20480.32);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0201', TO_DATE('2024-11-12', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP008', 92, 15462.44);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0202', TO_DATE('2024-02-10', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP003', 72, 24626.88);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0203', TO_DATE('2024-08-21', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP010', 100, 33346.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0204', TO_DATE('2024-11-14', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP005', 39, 19461.78);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0205', TO_DATE('2025-06-03', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP005', 88, 42401.04);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0206', TO_DATE('2025-03-07', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP007', 32, 9705.92);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0207', TO_DATE('2025-08-29', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP003', 24, 5372.40);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0208', TO_DATE('2025-09-22', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP002', 34, 8871.28);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0209', TO_DATE('2025-08-04', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP006', 67, 14380.21);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0210', TO_DATE('2025-10-09', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP010', 38, 18979.10);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0211', TO_DATE('2024-09-16', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP008', 36, 2162.88);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0212', TO_DATE('2024-03-08', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP001', 85, 37385.55);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0213', TO_DATE('2024-06-07', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP009', 7, 2334.64);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0214', TO_DATE('2025-11-23', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP006', 73, 21114.52);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0215', TO_DATE('2024-05-01', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP010', 5, 1663.10);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0216', TO_DATE('2025-10-30', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP007', 89, 29658.36);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0217', TO_DATE('2025-03-15', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP006', 75, 3384.75);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0218', TO_DATE('2025-07-11', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP001', 49, 20544.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0219', TO_DATE('2025-06-21', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP010', 73, 27915.93);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0220', TO_DATE('2025-11-23', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP010', 6, 2114.28);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0221', TO_DATE('2024-10-25', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP003', 24, 5797.68);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0222', TO_DATE('2025-11-27', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP007', 1, 68.56);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0223', TO_DATE('2024-07-01', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP007', 90, 42429.60);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0224', TO_DATE('2024-02-14', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP007', 28, 4299.12);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0225', TO_DATE('2025-08-10', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP003', 69, 31991.16);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0226', TO_DATE('2024-12-22', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP010', 56, 9487.52);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0227', TO_DATE('2025-05-15', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP008', 19, 3166.16);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0228', TO_DATE('2025-08-27', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP006', 61, 14529.59);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0229', TO_DATE('2024-01-11', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP005', 80, 17969.60);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0230', TO_DATE('2025-11-27', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP008', 68, 17460.36);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0231', TO_DATE('2025-02-03', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP006', 21, 1284.57);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0232', TO_DATE('2024-04-02', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP001', 85, 20514.75);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0233', TO_DATE('2025-12-05', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP002', 54, 25398.90);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0234', TO_DATE('2025-10-27', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP005', 77, 11705.54);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0235', TO_DATE('2025-10-27', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP009', 33, 10581.12);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0236', TO_DATE('2025-09-27', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP003', 47, 23171.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0237', TO_DATE('2025-03-26', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP006', 60, 19665.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0238', TO_DATE('2025-05-16', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP001', 13, 2588.17);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0239', TO_DATE('2024-08-09', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP009', 93, 3553.53);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0240', TO_DATE('2024-02-28', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP010', 8, 548.96);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0241', TO_DATE('2025-03-07', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP007', 3, 232.11);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0242', TO_DATE('2025-04-07', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP010', 28, 6366.64);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0243', TO_DATE('2024-09-03', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP004', 10, 4914.60);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0244', TO_DATE('2025-01-06', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP005', 66, 30049.80);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0245', TO_DATE('2025-11-07', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP005', 100, 12787.00);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0246', TO_DATE('2025-07-03', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP003', 15, 4983.75);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0247', TO_DATE('2024-11-15', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP004', 88, 39727.60);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0248', TO_DATE('2025-09-15', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP008', 42, 13392.96);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0249', TO_DATE('2025-01-27', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP001', 3, 953.34);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0250', TO_DATE('2025-09-20', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP007', 60, 16366.20);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0251', TO_DATE('2024-05-09', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP003', 64, 22213.12);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0252', TO_DATE('2024-07-16', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP002', 19, 8061.70);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0253', TO_DATE('2025-05-02', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP009', 91, 41853.63);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0254', TO_DATE('2024-05-21', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP010', 95, 8324.85);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0255', TO_DATE('2024-07-09', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP002', 52, 20707.96);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0256', TO_DATE('2024-02-07', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP008', 51, 4679.76);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0257', TO_DATE('2024-08-27', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 88, 21750.08);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0258', TO_DATE('2024-11-18', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP010', 25, 11003.25);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0259', TO_DATE('2024-04-01', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP002', 53, 13712.16);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0260', TO_DATE('2025-06-13', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP001', 5, 1917.45);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0261', TO_DATE('2024-11-12', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP003', 64, 23642.88);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0262', TO_DATE('2024-02-28', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP003', 47, 17110.35);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0263', TO_DATE('2025-09-15', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP003', 39, 2483.13);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0264', TO_DATE('2024-08-10', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP009', 59, 22222.35);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0265', TO_DATE('2025-03-25', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP004', 78, 37258.26);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0266', TO_DATE('2024-03-14', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP001', 81, 20875.32);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0267', TO_DATE('2024-07-08', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP008', 32, 5891.84);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0268', TO_DATE('2025-10-09', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP009', 43, 13141.23);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0269', TO_DATE('2025-06-13', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP007', 34, 940.44);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0270', TO_DATE('2025-04-30', 'YYYY-MM-DD'), 3, 'PRT003', 'SUP005', 73, 8681.16);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0271', TO_DATE('2024-01-04', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP006', 50, 8425.50);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0272', TO_DATE('2025-01-28', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP006', 79, 36678.12);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0273', TO_DATE('2024-01-30', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP002', 38, 10402.12);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0274', TO_DATE('2024-01-07', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP003', 24, 1276.08);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0275', TO_DATE('2024-10-31', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP010', 11, 4629.57);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0276', TO_DATE('2025-04-02', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP001', 39, 3860.61);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0277', TO_DATE('2024-01-20', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP003', 88, 24625.92);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0278', TO_DATE('2024-07-03', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP006', 27, 2339.01);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0279', TO_DATE('2025-05-11', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP006', 2, 733.84);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0280', TO_DATE('2025-12-23', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP007', 67, 1873.99);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0281', TO_DATE('2025-01-16', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP010', 51, 3402.21);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0282', TO_DATE('2024-09-26', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP008', 26, 1831.96);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0283', TO_DATE('2025-10-02', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP002', 18, 2183.04);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0284', TO_DATE('2024-09-07', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP005', 3, 1454.31);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0285', TO_DATE('2025-07-17', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP007', 2, 148.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0286', TO_DATE('2024-08-02', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP006', 78, 2465.58);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0287', TO_DATE('2024-03-10', 'YYYY-MM-DD'), 6, 'PRT006', 'SUP009', 17, 1534.08);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0288', TO_DATE('2025-06-17', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP002', 94, 18638.32);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0289', TO_DATE('2024-11-29', 'YYYY-MM-DD'), 5, 'PRT005', 'SUP008', 47, 16317.93);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0290', TO_DATE('2025-01-25', 'YYYY-MM-DD'), 4, 'PRT004', 'SUP009', 76, 15353.52);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0291', TO_DATE('2024-01-12', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP007', 66, 3974.52);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0292', TO_DATE('2025-05-13', 'YYYY-MM-DD'), 1, 'PRT001', 'SUP002', 91, 40950.91);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0293', TO_DATE('2025-02-15', 'YYYY-MM-DD'), 10, 'PRT010', 'SUP006', 48, 16177.92);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0294', TO_DATE('2025-01-11', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP005', 45, 11659.05);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0295', TO_DATE('2025-03-01', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP003', 93, 6130.56);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0296', TO_DATE('2024-03-30', 'YYYY-MM-DD'), 8, 'PRT008', 'SUP008', 88, 43902.32);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0297', TO_DATE('2025-11-14', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP008', 64, 29777.28);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0298', TO_DATE('2024-07-30', 'YYYY-MM-DD'), 9, 'PRT009', 'SUP010', 74, 12239.60);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0299', TO_DATE('2025-04-28', 'YYYY-MM-DD'), 2, 'PRT002', 'SUP010', 62, 20322.98);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0300', TO_DATE('2024-01-24', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 71, 7335.72);

INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0301', TO_DATE('2024-01-24', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 71, 7335.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0302', TO_DATE('2024-01-24', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 71, 7335.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0305', TO_DATE('2024-01-24', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 71, 7335.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0304', TO_DATE('2024-01-24', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 71, 7335.72);
INSERT INTO Part_Order (OrderID, OrderDate, PartKey, PartID, SupplierID, OrderQuantity, Price) VALUES ('PO0303', TO_DATE('2024-01-24', 'YYYY-MM-DD'), 7, 'PRT007', 'SUP004', 71, 7335.72);


----------------------------------------------------------------------------------------------------------------------------
-- ROUND 3
-- Booking Details
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000001', 'TCK00001', 'BK0051', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000002', 'TCK00002', 'BK0007', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000003', 'TCK00003', 'BK0020', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000004', 'TCK00004', 'BK0068', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000005', 'TCK00005', 'BK0073', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000006', 'TCK00006', 'BK0018', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000007', 'TCK00007', 'BK0044', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000008', 'TCK00008', 'BK0040', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000009', 'TCK00009', 'BK0047', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000010', 'TCK00010', 'BK0083', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000011', 'TCK00011', 'BK0028', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000012', 'TCK00012', 'BK0029', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000013', 'TCK00013', 'BK0048', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000014', 'TCK00014', 'BK0046', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000015', 'TCK00015', 'BK0066', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000016', 'TCK00016', 'BK0076', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000017', 'TCK00017', 'BK0051', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000018', 'TCK00018', 'BK0011', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000019', 'TCK00019', 'BK0066', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000020', 'TCK00020', 'BK0072', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000021', 'TCK00021', 'BK0081', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000022', 'TCK00022', 'BK0089', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000023', 'TCK00023', 'BK0064', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000024', 'TCK00024', 'BK0010', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000025', 'TCK00025', 'BK0078', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000026', 'TCK00026', 'BK0046', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000027', 'TCK00027', 'BK0061', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000028', 'TCK00028', 'BK0027', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000029', 'TCK00029', 'BK0024', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000030', 'TCK00030', 'BK0041', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000031', 'TCK00031', 'BK0054', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000032', 'TCK00032', 'BK0016', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000033', 'TCK00033', 'BK0046', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000034', 'TCK00034', 'BK0012', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000035', 'TCK00035', 'BK0029', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000036', 'TCK00036', 'BK0039', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000037', 'TCK00037', 'BK0005', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000038', 'TCK00038', 'BK0075', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000039', 'TCK00039', 'BK0091', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000040', 'TCK00040', 'BK0024', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000041', 'TCK00041', 'BK0088', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000042', 'TCK00042', 'BK0055', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000043', 'TCK00043', 'BK0015', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000044', 'TCK00044', 'BK0066', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000045', 'TCK00045', 'BK0058', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000046', 'TCK00046', 'BK0071', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000047', 'TCK00047', 'BK0025', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000048', 'TCK00048', 'BK0007', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000049', 'TCK00049', 'BK0096', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000050', 'TCK00050', 'BK0022', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000051', 'TCK00051', 'BK0047', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000052', 'TCK00052', 'BK0039', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000053', 'TCK00053', 'BK0011', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000054', 'TCK00054', 'BK0044', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000055', 'TCK00055', 'BK0064', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000056', 'TCK00056', 'BK0008', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000057', 'TCK00057', 'BK0005', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000058', 'TCK00058', 'BK0077', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000059', 'TCK00059', 'BK0091', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000060', 'TCK00060', 'BK0086', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000061', 'TCK00061', 'BK0005', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000062', 'TCK00062', 'BK0060', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000063', 'TCK00063', 'BK0096', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000064', 'TCK00064', 'BK0011', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000065', 'TCK00065', 'BK0057', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000066', 'TCK00066', 'BK0081', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000067', 'TCK00067', 'BK0008', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000068', 'TCK00068', 'BK0068', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000069', 'TCK00069', 'BK0068', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000070', 'TCK00070', 'BK0033', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000071', 'TCK00071', 'BK0091', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000072', 'TCK00072', 'BK0003', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000073', 'TCK00073', 'BK0097', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000074', 'TCK00074', 'BK0096', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000075', 'TCK00075', 'BK0009', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000076', 'TCK00076', 'BK0068', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000077', 'TCK00077', 'BK0067', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000078', 'TCK00078', 'BK0028', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000079', 'TCK00079', 'BK0029', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000080', 'TCK00080', 'BK0029', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000081', 'TCK00081', 'BK0002', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000082', 'TCK00082', 'BK0088', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000083', 'TCK00083', 'BK0002', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000084', 'TCK00084', 'BK0086', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000085', 'TCK00085', 'BK0023', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000086', 'TCK00086', 'BK0083', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000087', 'TCK00087', 'BK0071', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000088', 'TCK00088', 'BK0088', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000089', 'TCK00089', 'BK0071', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000090', 'TCK00090', 'BK0092', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000091', 'TCK00091', 'BK0094', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000092', 'TCK00092', 'BK0080', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000093', 'TCK00093', 'BK0082', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000094', 'TCK00094', 'BK0088', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000095', 'TCK00095', 'BK0081', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000096', 'TCK00096', 'BK0052', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000097', 'TCK00097', 'BK0025', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000098', 'TCK00098', 'BK0017', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000099', 'TCK00099', 'BK0036', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000100', 'TCK00100', 'BK0097', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000101', 'TCK00101', 'BK0030', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000102', 'TCK00102', 'BK0050', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000103', 'TCK00103', 'BK0059', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000104', 'TCK00104', 'BK0077', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000105', 'TCK00105', 'BK0078', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000106', 'TCK00106', 'BK0096', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000107', 'TCK00107', 'BK0044', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000108', 'TCK00108', 'BK0016', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000109', 'TCK00109', 'BK0047', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000110', 'TCK00110', 'BK0089', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000111', 'TCK00111', 'BK0084', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000112', 'TCK00112', 'BK0100', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000113', 'TCK00113', 'BK0036', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000114', 'TCK00114', 'BK0036', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000115', 'TCK00115', 'BK0013', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000116', 'TCK00116', 'BK0019', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000117', 'TCK00117', 'BK0053', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000118', 'TCK00118', 'BK0010', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000119', 'TCK00119', 'BK0011', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000120', 'TCK00120', 'BK0053', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000121', 'TCK00121', 'BK0031', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000122', 'TCK00122', 'BK0063', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000123', 'TCK00123', 'BK0080', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000124', 'TCK00124', 'BK0086', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000125', 'TCK00125', 'BK0034', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000126', 'TCK00126', 'BK0029', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000127', 'TCK00127', 'BK0024', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000128', 'TCK00128', 'BK0069', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000129', 'TCK00129', 'BK0041', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000130', 'TCK00130', 'BK0082', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000131', 'TCK00131', 'BK0067', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000132', 'TCK00132', 'BK0065', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000133', 'TCK00133', 'BK0068', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000134', 'TCK00134', 'BK0053', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000135', 'TCK00135', 'BK0100', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000136', 'TCK00136', 'BK0024', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000137', 'TCK00137', 'BK0084', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000138', 'TCK00138', 'BK0035', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000139', 'TCK00139', 'BK0063', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000140', 'TCK00140', 'BK0095', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000141', 'TCK00141', 'BK0080', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000142', 'TCK00142', 'BK0053', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000143', 'TCK00143', 'BK0034', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000144', 'TCK00144', 'BK0060', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000145', 'TCK00145', 'BK0071', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000146', 'TCK00146', 'BK0099', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000147', 'TCK00147', 'BK0055', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000148', 'TCK00148', 'BK0089', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000149', 'TCK00149', 'BK0087', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000150', 'TCK00150', 'BK0053', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000151', 'TCK00151', 'BK0066', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000152', 'TCK00152', 'BK0082', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000153', 'TCK00153', 'BK0038', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000154', 'TCK00154', 'BK0064', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000155', 'TCK00155', 'BK0070', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000156', 'TCK00156', 'BK0097', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000157', 'TCK00157', 'BK0001', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000158', 'TCK00158', 'BK0083', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000159', 'TCK00159', 'BK0046', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000160', 'TCK00160', 'BK0064', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000161', 'TCK00161', 'BK0034', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000162', 'TCK00162', 'BK0068', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000163', 'TCK00163', 'BK0054', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000164', 'TCK00164', 'BK0038', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000165', 'TCK00165', 'BK0042', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000166', 'TCK00166', 'BK0004', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000167', 'TCK00167', 'BK0059', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000168', 'TCK00168', 'BK0001', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000169', 'TCK00169', 'BK0100', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000170', 'TCK00170', 'BK0097', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000171', 'TCK00171', 'BK0040', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000172', 'TCK00172', 'BK0032', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000173', 'TCK00173', 'BK0094', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000174', 'TCK00174', 'BK0021', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000175', 'TCK00175', 'BK0016', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000176', 'TCK00176', 'BK0017', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000177', 'TCK00177', 'BK0086', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000178', 'TCK00178', 'BK0091', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000179', 'TCK00179', 'BK0063', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000180', 'TCK00180', 'BK0012', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000181', 'TCK00181', 'BK0052', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000182', 'TCK00182', 'BK0005', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000183', 'TCK00183', 'BK0082', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000184', 'TCK00184', 'BK0080', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000185', 'TCK00185', 'BK0084', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000186', 'TCK00186', 'BK0028', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000187', 'TCK00187', 'BK0032', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000188', 'TCK00188', 'BK0048', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000189', 'TCK00189', 'BK0074', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000190', 'TCK00190', 'BK0051', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000191', 'TCK00191', 'BK0036', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000192', 'TCK00192', 'BK0031', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000193', 'TCK00193', 'BK0045', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000194', 'TCK00194', 'BK0021', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000195', 'TCK00195', 'BK0047', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000196', 'TCK00196', 'BK0054', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000197', 'TCK00197', 'BK0050', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000198', 'TCK00198', 'BK0039', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000199', 'TCK00199', 'BK0014', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000200', 'TCK00200', 'BK0096', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000201', 'TCK00201', 'BK0056', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000202', 'TCK00202', 'BK0023', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000203', 'TCK00203', 'BK0085', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000204', 'TCK00204', 'BK0076', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000205', 'TCK00205', 'BK0034', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000206', 'TCK00206', 'BK0066', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000207', 'TCK00207', 'BK0079', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000208', 'TCK00208', 'BK0028', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000209', 'TCK00209', 'BK0072', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000210', 'TCK00210', 'BK0049', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000211', 'TCK00211', 'BK0052', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000212', 'TCK00212', 'BK0003', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000213', 'TCK00213', 'BK0022', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000214', 'TCK00214', 'BK0097', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000215', 'TCK00215', 'BK0020', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000216', 'TCK00216', 'BK0016', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000217', 'TCK00217', 'BK0083', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000218', 'TCK00218', 'BK0010', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000219', 'TCK00219', 'BK0099', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000220', 'TCK00220', 'BK0013', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000221', 'TCK00221', 'BK0001', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000222', 'TCK00222', 'BK0010', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000223', 'TCK00223', 'BK0080', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000224', 'TCK00224', 'BK0080', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000225', 'TCK00225', 'BK0028', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000226', 'TCK00226', 'BK0010', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000227', 'TCK00227', 'BK0033', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000228', 'TCK00228', 'BK0035', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000229', 'TCK00229', 'BK0006', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000230', 'TCK00230', 'BK0050', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000231', 'TCK00231', 'BK0053', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000232', 'TCK00232', 'BK0086', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000233', 'TCK00233', 'BK0013', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000234', 'TCK00234', 'BK0012', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000235', 'TCK00235', 'BK0095', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000236', 'TCK00236', 'BK0098', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000237', 'TCK00237', 'BK0025', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000238', 'TCK00238', 'BK0058', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000239', 'TCK00239', 'BK0021', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000240', 'TCK00240', 'BK0058', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000241', 'TCK00241', 'BK0064', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000242', 'TCK00242', 'BK0081', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000243', 'TCK00243', 'BK0052', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000244', 'TCK00244', 'BK0001', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000245', 'TCK00245', 'BK0053', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000246', 'TCK00246', 'BK0074', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000247', 'TCK00247', 'BK0031', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000248', 'TCK00248', 'BK0033', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000249', 'TCK00249', 'BK0046', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000250', 'TCK00250', 'BK0076', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000251', 'TCK00251', 'BK0006', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000252', 'TCK00252', 'BK0034', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000253', 'TCK00253', 'BK0070', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000254', 'TCK00254', 'BK0089', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000255', 'TCK00255', 'BK0068', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000256', 'TCK00256', 'BK0003', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000257', 'TCK00257', 'BK0010', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000258', 'TCK00258', 'BK0097', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000259', 'TCK00259', 'BK0044', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000260', 'TCK00260', 'BK0085', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000261', 'TCK00261', 'BK0072', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000262', 'TCK00262', 'BK0098', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000263', 'TCK00263', 'BK0051', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000264', 'TCK00264', 'BK0046', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000265', 'TCK00265', 'BK0005', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000266', 'TCK00266', 'BK0002', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000267', 'TCK00267', 'BK0093', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000268', 'TCK00268', 'BK0039', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000269', 'TCK00269', 'BK0099', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000270', 'TCK00270', 'BK0029', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000271', 'TCK00271', 'BK0043', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000272', 'TCK00272', 'BK0059', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000273', 'TCK00273', 'BK0074', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000274', 'TCK00274', 'BK0073', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000275', 'TCK00275', 'BK0072', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000276', 'TCK00276', 'BK0038', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000277', 'TCK00277', 'BK0035', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000278', 'TCK00278', 'BK0015', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000279', 'TCK00279', 'BK0035', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000280', 'TCK00280', 'BK0063', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000281', 'TCK00281', 'BK0068', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000282', 'TCK00282', 'BK0086', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000283', 'TCK00283', 'BK0009', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000284', 'TCK00284', 'BK0080', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000285', 'TCK00285', 'BK0056', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000286', 'TCK00286', 'BK0044', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000287', 'TCK00287', 'BK0096', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000288', 'TCK00288', 'BK0036', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000289', 'TCK00289', 'BK0064', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000290', 'TCK00290', 'BK0036', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000291', 'TCK00291', 'BK0055', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000292', 'TCK00292', 'BK0069', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000293', 'TCK00293', 'BK0018', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000294', 'TCK00294', 'BK0034', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000295', 'TCK00295', 'BK0031', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000296', 'TCK00296', 'BK0091', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000297', 'TCK00297', 'BK0100', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000298', 'TCK00298', 'BK0001', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000299', 'TCK00299', 'BK0027', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000300', 'TCK00300', 'BK0074', 20);

INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000305', 'TCK00301', 'BK0074', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000304', 'TCK00302', 'BK0074', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000303', 'TCK00303', 'BK0074', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000302', 'TCK00304', 'BK0074', 20);
INSERT INTO BookingDetails (BookingDetailsID, TicketID, BookingID, Price) VALUES ('BD000301', 'TCK00305', 'BK0074', 20);

----------------------------------------------------------------------------------------------------------------------------
-- ROUND 4
-- Trigger (Edison)
CREATE OR REPLACE TRIGGER trg_Edison_Extension 
BEFORE UPDATE OR INSERT ON Extension
FOR EACH ROW
DECLARE
    v_TicketID       Ticket.TicketID%TYPE;
    v_Status         Ticket.Status%TYPE;
    v_Extended       Ticket.ExtendedTrip%TYPE;
    v_Fare           Ticket.Fare%TYPE;
    v_SeatNo         Ticket.SeatNo%TYPE; 
    v_MaxNum         NUMBER;
    v_NewTicket      VARCHAR2(20);
    v_OldDestination VARCHAR2(50);
    v_OldStation     VARCHAR2(50);
    v_OldScheduleID  VARCHAR2(50);
    v_NewScheduleID  VARCHAR2(50);
    v_DepartureDate  DATE;

BEGIN
    -- Find the original ticket
    SELECT BD.TicketID
    INTO v_TicketID
    FROM BookingDetails BD
    WHERE BD.BookingDetailsID = :NEW.BookingDetailsID;

    -- Get old schedule info
    SELECT Status, T.ScheduleID, ExtendedTrip, Fare, SeatNo, 
           S.Destination, S.Station, S.ScheduleDate
    INTO v_Status, v_OldScheduleID, v_Extended, v_Fare, v_SeatNo, 
         v_OldDestination, v_OldStation, v_DepartureDate
    FROM Ticket T
    JOIN Schedule S ON T.ScheduleID = S.ScheduleID
    WHERE TicketID = v_TicketID;

    -- Rule 1: cannot extend refunded ticket
    IF UPPER(v_Status) = 'REFUNDED' THEN
        :NEW.ExtensionStatus := 'REJECTED';
        :NEW.ExtensionFee    := 0;
        RETURN;
    END IF;

    -- Rule 2: only 1 extension allowed
    IF v_Extended = 'Y' THEN
        :NEW.ExtensionStatus := 'REJECTED';
        :NEW.ExtensionFee    := 0;
        RETURN;
    END IF;

    -- Rule 3: must request at least 2 days before departure
    IF :NEW.RequestDate > (v_DepartureDate - 2) THEN
        :NEW.ExtensionStatus := 'REJECTED';
        :NEW.ExtensionFee    := 0;
        RETURN;
    END IF;

    -- Auto-pick a new schedule (same route, active, different schedule ID)
    BEGIN
        SELECT ScheduleID
        INTO v_NewScheduleID
        FROM (
            SELECT ScheduleID
            FROM Schedule
            WHERE ScheduleID <> v_OldScheduleID
              AND UPPER(ScheduleStatus) = 'ACTIVE'
              AND UPPER(Station) = UPPER(v_OldStation)
              AND UPPER(Destination) = UPPER(v_OldDestination)
            ORDER BY ScheduleDate, DepartureTime
        )
        WHERE ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            :NEW.ExtensionStatus := 'REJECTED';
            :NEW.ExtensionFee    := 0;
            RETURN;
    END;

    -- Generate new ticketID
    SELECT MAX(TO_NUMBER(SUBSTR(TicketID, 4)))
    INTO v_MaxNum
    FROM Ticket;

    v_NewTicket := 'TCK' || LPAD(v_MaxNum + 1, 5, '0');

    -- Save the chosen schedule back into Extension row
    :NEW.NewTicketID := v_NewTicket;
    :NEW.NewScheduleID  := v_NewScheduleID;
    :NEW.ExtensionStatus := 'APPROVED';
    :NEW.ApproveDate     := SYSDATE;
    :NEW.ExtensionFee    := v_Fare + 5;   -- fixed RM5.00 extra charge

    -- Update original ticket
    UPDATE Ticket
    SET ExtendedTrip = 'Y', Status = 'Past'
    WHERE TicketID = v_TicketID;

    -- Create a new ticket under the new schedule
    INSERT INTO Ticket (
        TicketID,
        ScheduleID,
        SeatNo,
        Fare,
        Status,
        ExtendedTrip
    ) VALUES (
        v_NewTicket,
        v_NewScheduleID,
        v_SeatNo, 
        v_Fare + 5,   -- new fare = old fare + RM5.00
        'Active',
        'Y'
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'Unexpected error in ticket extension: ' || SQLERRM);
END;
/


-- Extension 
INSERT INTO Extension VALUES ('EX000001', 'BD000078', NULL, NULL, NULL, TO_DATE('2024-06-02', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000002', 'BD000071', NULL, NULL, NULL,TO_DATE('2024-07-10', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000003', 'BD000046', NULL, NULL, NULL, TO_DATE('2024-03-10', 'YYYY-MM-DD'), NULL, 0, 'Other');
INSERT INTO Extension VALUES ('EX000004', 'BD000258', NULL, NULL, NULL, TO_DATE('2024-05-03', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000005', 'BD000055', NULL, NULL, NULL, TO_DATE('2024-06-10', 'YYYY-MM-DD'), NULL, 0, 'Rescheduled travel');
INSERT INTO Extension VALUES ('EX000006', 'BD000116', NULL, NULL, NULL, TO_DATE('2024-03-29', 'YYYY-MM-DD'), NULL, 0, 'Rescheduled travel');
INSERT INTO Extension VALUES ('EX000007', 'BD000273', NULL, NULL, NULL, TO_DATE('2024-12-01', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000008', 'BD000146', NULL, NULL, NULL, TO_DATE('2024-06-07', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000009', 'BD000156', NULL, NULL, NULL, TO_DATE('2024-05-30', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000010', 'BD000119', NULL, NULL, NULL, TO_DATE('2024-01-27', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000011', 'BD000203', NULL, NULL, NULL, TO_DATE('2024-11-22', 'YYYY-MM-DD'), NULL, 0, 'Rescheduled travel');
INSERT INTO Extension VALUES ('EX000012', 'BD000152', NULL, NULL, NULL, TO_DATE('2024-05-10', 'YYYY-MM-DD'), NULL, 0, 'Traffic delay');
INSERT INTO Extension VALUES ('EX000013', 'BD000263', NULL, NULL, NULL, TO_DATE('2024-04-23', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000014', 'BD000021', NULL, NULL, NULL, TO_DATE('2024-05-26', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000015', 'BD000290', NULL, NULL, NULL, TO_DATE('2024-01-25', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000016', 'BD000051', NULL, NULL, NULL, TO_DATE('2024-08-09', 'YYYY-MM-DD'), NULL, 0, 'Other');
INSERT INTO Extension VALUES ('EX000017', 'BD000200', NULL, NULL, NULL, TO_DATE('2024-12-16', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000018', 'BD000151', NULL, NULL, NULL, TO_DATE('2024-12-05', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000019', 'BD000189', NULL, NULL, NULL, TO_DATE('2024-07-17', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000020', 'BD000093', NULL, NULL, NULL, TO_DATE('2024-10-21', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000021', 'BD000163', NULL, NULL, NULL, TO_DATE('2024-04-02', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000022', 'BD000124', NULL, NULL, NULL, TO_DATE('2024-04-14', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000023', 'BD000057', NULL, NULL, NULL, TO_DATE('2024-10-28', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000024', 'BD000163', NULL, NULL, NULL, TO_DATE('2024-07-02', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000025', 'BD000102', NULL, NULL, NULL, TO_DATE('2024-12-08', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000026', 'BD000049', NULL, NULL, NULL, TO_DATE('2024-12-04', 'YYYY-MM-DD'), NULL, 0, 'Other');
INSERT INTO Extension VALUES ('EX000027', 'BD000262', NULL, NULL, NULL, TO_DATE('2024-02-08', 'YYYY-MM-DD'), NULL, 0, 'Traffic delay');
INSERT INTO Extension VALUES ('EX000028', 'BD000204', NULL, NULL, NULL, TO_DATE('2024-07-15', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000029', 'BD000281', NULL, NULL, NULL, TO_DATE('2024-09-27', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000030', 'BD000258', NULL, NULL, NULL, TO_DATE('2024-05-11', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000031', 'BD000242', NULL, NULL, NULL, TO_DATE('2024-08-08', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000032', 'BD000111', NULL, NULL, NULL, TO_DATE('2024-04-22', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000033', 'BD000037', NULL, NULL, NULL, TO_DATE('2024-10-11', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000034', 'BD000175', NULL, NULL, NULL, TO_DATE('2024-06-04', 'YYYY-MM-DD'), NULL, 0, 'Traffic delay');
INSERT INTO Extension VALUES ('EX000035', 'BD000048', NULL, NULL, NULL, TO_DATE('2024-12-21', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000036', 'BD000072', NULL, NULL, NULL, TO_DATE('2024-07-04', 'YYYY-MM-DD'), NULL, 0, 'Other');
INSERT INTO Extension VALUES ('EX000037', 'BD000126', NULL, NULL, NULL, TO_DATE('2024-08-24', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000038', 'BD000244', NULL, NULL, NULL, TO_DATE('2024-01-20', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000039', 'BD000247', NULL, NULL, NULL, TO_DATE('2024-07-25', 'YYYY-MM-DD'), NULL, 0, 'Traffic delay');
INSERT INTO Extension VALUES ('EX000040', 'BD000084', NULL, NULL, NULL, TO_DATE('2024-05-20', 'YYYY-MM-DD'), NULL, 0, 'Other');
INSERT INTO Extension VALUES ('EX000041', 'BD000107', NULL, NULL, NULL, TO_DATE('2024-07-24', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000042', 'BD000170', NULL, NULL, NULL, TO_DATE('2024-12-04', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000043', 'BD000201', NULL, NULL, NULL, TO_DATE('2024-08-27', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000044', 'BD000228', NULL, NULL, NULL, TO_DATE('2024-01-14', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000045', 'BD000121', NULL, NULL, NULL, TO_DATE('2024-10-01', 'YYYY-MM-DD'), NULL, 0, 'Other');
INSERT INTO Extension VALUES ('EX000046', 'BD000178', NULL, NULL, NULL, TO_DATE('2024-02-22', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000047', 'BD000105', NULL, NULL, NULL, TO_DATE('2024-01-27', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000048', 'BD000048', NULL, NULL, NULL, TO_DATE('2024-06-02', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000049', 'BD000120', NULL, NULL, NULL, TO_DATE('2024-08-08', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000050', 'BD000131', NULL, NULL, NULL, TO_DATE('2024-04-22', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000051', 'BD000295', NULL, NULL, NULL, TO_DATE('2024-02-05', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000052', 'BD000105', NULL, NULL, NULL, TO_DATE('2024-03-21', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000053', 'BD000260', NULL, NULL, NULL, TO_DATE('2024-12-06', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000054', 'BD000260', NULL, NULL, NULL, TO_DATE('2024-03-16', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000055', 'BD000112', NULL, NULL, NULL, TO_DATE('2024-10-14', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000056', 'BD000104', NULL, NULL, NULL, TO_DATE('2024-03-29', 'YYYY-MM-DD'), NULL, 0, 'Rescheduled travel');
INSERT INTO Extension VALUES ('EX000057', 'BD000273', NULL, NULL, NULL, TO_DATE('2024-12-06', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000058', 'BD000118', NULL, NULL, NULL, TO_DATE('2024-10-25', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000059', 'BD000032', NULL, NULL, NULL, TO_DATE('2024-11-01', 'YYYY-MM-DD'), NULL, 0, 'Rescheduled travel');
INSERT INTO Extension VALUES ('EX000060', 'BD000114', NULL, NULL, NULL, TO_DATE('2024-10-12', 'YYYY-MM-DD'), NULL, 0, 'Traffic delay');
INSERT INTO Extension VALUES ('EX000061', 'BD000295', NULL, NULL, NULL, TO_DATE('2024-11-10', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000062', 'BD000216', NULL, NULL, NULL, TO_DATE('2024-12-06', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000063', 'BD000230', NULL, NULL, NULL, TO_DATE('2024-10-19', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000064', 'BD000260', NULL, NULL, NULL, TO_DATE('2024-02-21', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000065', 'BD000277', NULL, NULL, NULL, TO_DATE('2024-11-25', 'YYYY-MM-DD'), NULL, 0, 'Rescheduled travel');
INSERT INTO Extension VALUES ('EX000066', 'BD000165', NULL, NULL, NULL, TO_DATE('2024-01-27', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000067', 'BD000019', NULL, NULL, NULL, TO_DATE('2024-06-08', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000068', 'BD000011', NULL, NULL, NULL, TO_DATE('2024-02-12', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000069', 'BD000063', NULL, NULL, NULL, TO_DATE('2024-09-22', 'YYYY-MM-DD'), NULL, 0, 'Traffic delay');
INSERT INTO Extension VALUES ('EX000070', 'BD000175', NULL, NULL, NULL, TO_DATE('2024-02-07', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000071', 'BD000064', NULL, NULL, NULL, TO_DATE('2024-07-27', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000072', 'BD000019', NULL, NULL, NULL, TO_DATE('2024-04-12', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000073', 'BD000247', NULL, NULL, NULL, TO_DATE('2024-01-27', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000074', 'BD000200', NULL, NULL, NULL, TO_DATE('2024-02-09', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000075', 'BD000047', NULL, NULL, NULL, TO_DATE('2024-12-10', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000076', 'BD000148', NULL, NULL, NULL, TO_DATE('2024-09-27', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000077', 'BD000080', NULL, NULL, NULL, TO_DATE('2024-04-24', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000078', 'BD000168', NULL, NULL, NULL, TO_DATE('2024-07-23', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000079', 'BD000261', NULL, NULL, NULL, TO_DATE('2024-08-15', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000080', 'BD000091', NULL, NULL, NULL, TO_DATE('2024-08-14', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000081', 'BD000107', NULL, NULL, NULL, TO_DATE('2024-06-26', 'YYYY-MM-DD'), NULL, 0, 'Late arrival at station');
INSERT INTO Extension VALUES ('EX000082', 'BD000295', NULL, NULL, NULL, TO_DATE('2024-09-02', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000083', 'BD000202', NULL, NULL, NULL, TO_DATE('2024-09-20', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000084', 'BD000012', NULL, NULL, NULL, TO_DATE('2024-09-09', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000085', 'BD000012', NULL, NULL, NULL, TO_DATE('2024-08-10', 'YYYY-MM-DD'), NULL, 0, 'Missed bus');
INSERT INTO Extension VALUES ('EX000086', 'BD000243', NULL, NULL, NULL, TO_DATE('2024-08-15', 'YYYY-MM-DD'), NULL, 0, 'Family emergency');
INSERT INTO Extension VALUES ('EX000087', 'BD000015', NULL, NULL, NULL, TO_DATE('2024-11-01', 'YYYY-MM-DD'), NULL, 0, 'Change of plans');
INSERT INTO Extension VALUES ('EX000088', 'BD000205', NULL, NULL, NULL, TO_DATE('2024-04-25', 'YYYY-MM-DD'), NULL, 0, 'Other');
INSERT INTO Extension VALUES ('EX000089', 'BD000046', NULL, NULL, NULL, TO_DATE('2024-11-02', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000090', 'BD000146', NULL, NULL, NULL, TO_DATE('2024-12-25', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000091', 'BD000046', NULL, NULL, NULL, TO_DATE('2024-02-02', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000092', 'BD000071', NULL, NULL, NULL, TO_DATE('2024-07-14', 'YYYY-MM-DD'), NULL, 0, 'Rescheduled travel');
INSERT INTO Extension VALUES ('EX000093', 'BD000071', NULL, NULL, NULL, TO_DATE('2024-02-11', 'YYYY-MM-DD'), NULL, 0, 'Rescheduled travel');
INSERT INTO Extension VALUES ('EX000094', 'BD000090', NULL, NULL, NULL, TO_DATE('2024-02-27', 'YYYY-MM-DD'), NULL, 0, 'Medical reason');
INSERT INTO Extension VALUES ('EX000095', 'BD000151', NULL, NULL, NULL, TO_DATE('2024-11-12', 'YYYY-MM-DD'), NULL, 0, 'Rescheduled travel');
INSERT INTO Extension VALUES ('EX000096', 'BD000282', NULL, NULL, NULL, TO_DATE('2024-12-24', 'YYYY-MM-DD'), NULL, 0, 'Other');
INSERT INTO Extension VALUES ('EX000097', 'BD000141', NULL, NULL, NULL, TO_DATE('2024-09-23', 'YYYY-MM-DD'), NULL, 0, 'Traffic delay');
INSERT INTO Extension VALUES ('EX000098', 'BD000046', NULL, NULL, NULL, TO_DATE('2024-10-06', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000099', 'BD000118', NULL, NULL, NULL, TO_DATE('2024-11-01', 'YYYY-MM-DD'), NULL, 0, 'Other');
INSERT INTO Extension VALUES ('EX000100', 'BD000218', NULL, NULL, NULL, TO_DATE('2024-05-08', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');

INSERT INTO Extension VALUES ('EX000101', 'BD000300', NULL, NULL, NULL, TO_DATE('2024-05-08', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000102', 'BD000299', NULL, NULL, NULL, TO_DATE('2024-05-08', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000103', 'BD000300', NULL, NULL, NULL, TO_DATE('2024-05-08', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000104', 'BD000218', NULL, NULL, NULL, TO_DATE('2024-05-08', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');
INSERT INTO Extension VALUES ('EX000105', 'BD000218', NULL, NULL, NULL, TO_DATE('2024-05-08', 'YYYY-MM-DD'), NULL, 0, 'Work commitment');

-- Refund
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0001', 'BD000143', TO_DATE('26-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0002', 'BD000021', TO_DATE('24-Oct-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0003', 'BD000300', TO_DATE('26-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0004', 'BD000220', TO_DATE('17-Apr-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0005', 'BD000293', TO_DATE('12-Apr-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0006', 'BD000251', TO_DATE('01-Jun-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0007', 'BD000041', TO_DATE('27-Jun-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'E-Wallet', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0008', 'BD000158', TO_DATE('12-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0009', 'BD000154', TO_DATE('05-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0010', 'BD000205', TO_DATE('03-Sep-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0011', 'BD000038', TO_DATE('12-Mar-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0012', 'BD000179', TO_DATE('12-Jan-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0013', 'BD000137', TO_DATE('01-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0014', 'BD000001', TO_DATE('05-Jun-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0015', 'BD000120', TO_DATE('25-Aug-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0016', 'BD000275', TO_DATE('20-Oct-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0017', 'BD000016', TO_DATE('23-Nov-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0018', 'BD000181', TO_DATE('07-Oct-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0019', 'BD000048', TO_DATE('28-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0020', 'BD000083', TO_DATE('19-Jul-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0021', 'BD000145', TO_DATE('18-Mar-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0022', 'BD000267', TO_DATE('18-Apr-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0023', 'BD000001', TO_DATE('24-May-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0024', 'BD000098', TO_DATE('20-Jan-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0025', 'BD000026', TO_DATE('07-Jan-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0026', 'BD000249', TO_DATE('23-Aug-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0027', 'BD000219', TO_DATE('13-Jul-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'E-Wallet', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0028', 'BD000293', TO_DATE('03-May-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0029', 'BD000210', TO_DATE('23-Aug-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0030', 'BD000005', TO_DATE('07-Sep-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0031', 'BD000123', TO_DATE('04-Jul-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0032', 'BD000231', TO_DATE('29-Jun-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0033', 'BD000038', TO_DATE('06-Apr-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0034', 'BD000139', TO_DATE('28-Jul-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0035', 'BD000141', TO_DATE('06-Jan-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0036', 'BD000163', TO_DATE('17-Feb-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0037', 'BD000122', TO_DATE('25-Jul-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0038', 'BD000251', TO_DATE('10-Oct-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0039', 'BD000115', TO_DATE('19-Sep-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0040', 'BD000086', TO_DATE('03-Jun-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0041', 'BD000224', TO_DATE('18-Nov-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0042', 'BD000215', TO_DATE('08-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0043', 'BD000121', TO_DATE('30-Sep-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0044', 'BD000134', TO_DATE('05-Oct-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0045', 'BD000216', TO_DATE('01-Dec-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0046', 'BD000031', TO_DATE('30-Sep-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0047', 'BD000239', TO_DATE('05-Jul-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0048', 'BD000237', TO_DATE('04-Aug-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0049', 'BD000028', TO_DATE('27-Mar-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'E-Wallet', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0050', 'BD000057', TO_DATE('19-Jun-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0051', 'BD000098', TO_DATE('05-Feb-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0052', 'BD000236', TO_DATE('30-May-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0053', 'BD000109', TO_DATE('30-Aug-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0054', 'BD000080', TO_DATE('31-Mar-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0055', 'BD000236', TO_DATE('11-Jan-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0056', 'BD000145', TO_DATE('03-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0057', 'BD000017', TO_DATE('07-Jun-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0058', 'BD000149', TO_DATE('22-Jun-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'E-Wallet', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0059', 'BD000226', TO_DATE('16-Jul-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0060', 'BD000130', TO_DATE('24-Nov-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0061', 'BD000118', TO_DATE('27-Jul-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0062', 'BD000299', TO_DATE('20-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0063', 'BD000254', TO_DATE('23-Jul-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0064', 'BD000234', TO_DATE('23-Aug-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0065', 'BD000068', TO_DATE('21-Oct-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0066', 'BD000014', TO_DATE('23-Mar-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0067', 'BD000286', TO_DATE('08-Jun-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0068', 'BD000150', TO_DATE('16-Jan-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0069', 'BD000203', TO_DATE('05-Mar-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0070', 'BD000234', TO_DATE('27-Jul-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0071', 'BD000032', TO_DATE('14-Jun-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0072', 'BD000298', TO_DATE('20-Feb-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0073', 'BD000156', TO_DATE('05-Mar-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0074', 'BD000175', TO_DATE('21-Oct-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0075', 'BD000287', TO_DATE('07-May-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'Online Banking', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0076', 'BD000286', TO_DATE('26-May-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0077', 'BD000179', TO_DATE('01-Dec-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0078', 'BD000258', TO_DATE('31-Mar-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0079', 'BD000298', TO_DATE('30-Oct-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0080', 'BD000297', TO_DATE('14-Dec-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0081', 'BD000224', TO_DATE('17-Dec-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0082', 'BD000055', TO_DATE('18-Apr-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0083', 'BD000060', TO_DATE('10-Nov-2024', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0084', 'BD000292', TO_DATE('08-Jul-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0085', 'BD000261', TO_DATE('26-Jan-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0086', 'BD000246', TO_DATE('06-Aug-2025', 'DD-MON-YYYY'), 0, 'Rejected', 'E-Wallet', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0087', 'BD000022', TO_DATE('21-Aug-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0088', 'BD000125', TO_DATE('27-Jun-2025', 'DD-MON-YYYY'), 14, 'Approved', 'E-Wallet', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0089', 'BD000145', TO_DATE('19-Sep-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0090', 'BD000105', TO_DATE('08-Jan-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0091', 'BD000206', TO_DATE('25-Aug-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'E-Wallet', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0092', 'BD000225', TO_DATE('23-Aug-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0093', 'BD000214', TO_DATE('20-Dec-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0094', 'BD000207', TO_DATE('29-Jan-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0095', 'BD000230', TO_DATE('06-May-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0096', 'BD000068', TO_DATE('24-Jun-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Payment issue');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0097', 'BD000285', TO_DATE('24-Oct-2024', 'DD-MON-YYYY'), 0, 'Rejected', 'Credit Card', 'Duplicate booking');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0098', 'BD000268', TO_DATE('19-Mar-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Credit Card', 'Event cancelled');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0099', 'BD000050', TO_DATE('23-Sep-2024', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0100', 'BD000212', TO_DATE('10-Feb-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');

INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0101', 'BD000212', TO_DATE('10-Feb-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0102', 'BD000212', TO_DATE('10-Feb-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0103', 'BD000212', TO_DATE('10-Feb-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0104', 'BD000212', TO_DATE('10-Feb-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');
INSERT INTO Refund (RefundID, BookingDetailsID, RefundDate, RefundAmount, RefundStatus, PaymentMethod, RefundReason) VALUES ('R0105', 'BD000212', TO_DATE('10-Feb-2025', 'DD-MON-YYYY'), 14, 'Approved', 'Online Banking', 'Customer request');


----------------------------------------------------------------------------------------
-- SEE DATA COUNT;
-- CANT USE PUT_LINE OUTSIDE OF A PROCEDURE, SO... USE IT LOL
DECLARE
  -- Phase 1: Independent Tables
  v_staff_count        NUMBER;
  v_supplier_count     NUMBER;
  v_service_type_count NUMBER;
  v_member_count       NUMBER;
  v_driver_count       NUMBER;
  v_company_count      NUMBER;
  
  -- Phase 2: First Level Dependencies
  v_bus_count          NUMBER;
  v_booking_count      NUMBER;
  v_part_count         NUMBER;
  v_shop_count         NUMBER;
  
  -- Phase 3: Second Level Dependencies
  v_schedule_count     NUMBER;
  v_maintenance_count  NUMBER;
  v_rental_count       NUMBER;
  
  -- Phase 4: Third Level Dependencies
  v_driver_alloc_count NUMBER;
  v_ticket_count       NUMBER;
  v_staff_alloc_count  NUMBER;
  v_using_parts_count  NUMBER;
  v_part_order_count   NUMBER;
  
  -- Phase 5: Fourth Level Dependencies
  v_booking_details_count NUMBER;
  
  -- Phase 6: Final Level Dependencies
  v_extension_count    NUMBER;
  v_refund_count       NUMBER;

BEGIN
  -- Face 1: insert intoi count something sometiong Tables
  SELECT COUNT(*) INTO v_staff_count        FROM Staff;
  SELECT COUNT(*) INTO v_supplier_count     FROM Supplier;
  SELECT COUNT(*) INTO v_service_type_count FROM Service_Type;
  SELECT COUNT(*) INTO v_member_count       FROM Member;
  SELECT COUNT(*) INTO v_driver_count       FROM Driver;
  SELECT COUNT(*) INTO v_company_count      FROM Bus_Company;
  SELECT COUNT(*) INTO v_bus_count          FROM Bus;
  SELECT COUNT(*) INTO v_booking_count      FROM Booking;
  SELECT COUNT(*) INTO v_part_count         FROM Part;
  SELECT COUNT(*) INTO v_shop_count         FROM Shop;
  SELECT COUNT(*) INTO v_schedule_count     FROM Schedule;
  SELECT COUNT(*) INTO v_maintenance_count  FROM Maintenance;
  SELECT COUNT(*) INTO v_rental_count       FROM RentalCollection;
  SELECT COUNT(*) INTO v_driver_alloc_count FROM DriverAllocation;
  SELECT COUNT(*) INTO v_ticket_count       FROM Ticket;
  SELECT COUNT(*) INTO v_staff_alloc_count  FROM StaffAllocation;
  SELECT COUNT(*) INTO v_using_parts_count  FROM Using_Parts;
  SELECT COUNT(*) INTO v_part_order_count   FROM Part_Order;
  SELECT COUNT(*) INTO v_booking_details_count FROM BookingDetails;
  SELECT COUNT(*) INTO v_extension_count    FROM Extension;
  SELECT COUNT(*) INTO v_refund_count       FROM Refund;

  -- Display Results
  DBMS_OUTPUT.PUT_LINE(chr(10));
  DBMS_OUTPUT.PUT_LINE('   ===== PARENT TABLES =====');
  DBMS_OUTPUT.PUT_LINE('Staff              : ' || v_staff_count);
  DBMS_OUTPUT.PUT_LINE('Supplier           : ' || v_supplier_count);
  DBMS_OUTPUT.PUT_LINE('Service_Type       : ' || v_service_type_count);
  DBMS_OUTPUT.PUT_LINE('Member             : ' || v_member_count);
  DBMS_OUTPUT.PUT_LINE('Bus_Company        : ' || v_company_count);
 DBMS_OUTPUT.PUT_LINE('Part               : ' || v_part_count);
  
  DBMS_OUTPUT.PUT_LINE(chr(10));
  DBMS_OUTPUT.PUT_LINE('   ===== AFTER PARENTS =====');
  DBMS_OUTPUT.PUT_LINE('Driver             : ' || v_driver_count);
  DBMS_OUTPUT.PUT_LINE('Bus                : ' || v_bus_count);
  DBMS_OUTPUT.PUT_LINE('Booking            : ' || v_booking_count);
  DBMS_OUTPUT.PUT_LINE('Shop               : ' || v_shop_count);
  
  DBMS_OUTPUT.PUT_LINE(chr(10));
  DBMS_OUTPUT.PUT_LINE('   ===== AFTER AFTER PARENTS =====');
  DBMS_OUTPUT.PUT_LINE('Schedule           : ' || v_schedule_count);
  DBMS_OUTPUT.PUT_LINE('Maintenance        : ' || v_maintenance_count);
  DBMS_OUTPUT.PUT_LINE('RentalCollection   : ' || v_rental_count);
  
  DBMS_OUTPUT.PUT_LINE(chr(10));
  DBMS_OUTPUT.PUT_LINE('   ===== AFTER AFTER AFTER PARENTS =====');
  DBMS_OUTPUT.PUT_LINE('DriverAllocation   : ' || v_driver_alloc_count);
  DBMS_OUTPUT.PUT_LINE('Ticket             : ' || v_ticket_count);
  DBMS_OUTPUT.PUT_LINE('StaffAllocation    : ' || v_staff_alloc_count);
  DBMS_OUTPUT.PUT_LINE('Using_Parts        : ' || v_using_parts_count);
  DBMS_OUTPUT.PUT_LINE('Part_Order         : ' || v_part_order_count);
  
  DBMS_OUTPUT.PUT_LINE(chr(10));
  DBMS_OUTPUT.PUT_LINE('   ===== AFTER AFTER AFTER AFTER PARENTS =====');
  DBMS_OUTPUT.PUT_LINE('BookingDetails     : ' || v_booking_details_count);
  
  DBMS_OUTPUT.PUT_LINE(chr(10));
  DBMS_OUTPUT.PUT_LINE('   ===== AFTER AFTER AFTER AFTER AFTER PARENTS =====');
  DBMS_OUTPUT.PUT_LINE('Extension          : ' || v_extension_count);
  DBMS_OUTPUT.PUT_LINE('Refund             : ' || v_refund_count);

  DBMS_OUTPUT.PUT_LINE(chr(10));

  DBMS_OUTPUT.PUT_LINE('Thats all');
END;
/
