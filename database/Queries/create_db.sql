-- 1. Create Database
CREATE DATABASE [Auto Business]
GO

USE [Auto Business]
GO


-- 2. Create Tables

-- Table: Company
CREATE TABLE Company (
    CompanyID INT PRIMARY KEY,
    CompanyName NVARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100),
    Address NVARCHAR(200),
    TaxNumber BIGINT NOT NULL UNIQUE,
)

-- Table: Supplier
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY,
    CompanyID INT,
    SupplierName NVARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100),
    Address NVARCHAR(200),
    TaxNumber BIGINT NOT NULL
    FOREIGN KEY (CompanyID) REFERENCES Company(CompanyID),
)

-- Table: Employee
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    CompanyID INT,
    EmployeeName NVARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100),
    JobTitle NVARCHAR(50),
    Salary DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (CompanyID) REFERENCES Company(CompanyID),
    CONSTRAINT CK_Salary CHECK (Salary > 0)
)

-- Table: Customer
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CompanyID INT,
    CustomerName NVARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    Email VARCHAR(100),
    Address NVARCHAR(200),
    FOREIGN KEY (CompanyID) REFERENCES Company(CompanyID),
)

-- Table: Vehicle
CREATE TABLE Vehicle (
    VehicleID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    LicensePlate VARCHAR(20) NOT NULL UNIQUE,
    Brand NVARCHAR(50) NOT NULL,
    ModelYear INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT CK_ModelYear CHECK (ModelYear BETWEEN 1900 AND 2100)
)

-- Table: Product
CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Type NVARCHAR(50),
    ItemPrice DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    CONSTRAINT CK_Stock_NonNegative CHECK (StockQuantity >= 0)
)

-- Table: PurchaseOrder
CREATE TABLE PurchaseOrder (
    PurchaseOrderID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    EmployeeID INT NOT NULL,
    PurchaseDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
)

-- Table: PurchaseDetail
CREATE TABLE PurchaseDetail (
    PurchaseDetailID INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,
    TotalAmount AS (UnitPrice * Quantity),
    FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrder(PurchaseOrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT CK_PurchaseQty CHECK (Quantity > 0)
)

-- Table: SaleOrder
CREATE TABLE SaleOrder (
    SaleOrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    SaleDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
)

-- Table: SaleDetail
CREATE TABLE SaleDetail (
    SaleDetailID INT IDENTITY(1,1) PRIMARY KEY,
    SaleOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,
    TotalAmount AS (UnitPrice * Quantity),
    FOREIGN KEY (SaleOrderID) REFERENCES SaleOrder(SaleOrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT CK_SaleQty CHECK (Quantity > 0)
)

-- Table: Invoice
CREATE TABLE Invoice (
    InvoiceNumber INT IDENTITY(1,1) PRIMARY KEY,
    SaleOrderID INT NOT NULL UNIQUE,
    IssueDate SMALLDATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SaleOrderID) REFERENCES SaleOrder(SaleOrderID)
)

-- Table: Accounting
CREATE TABLE Accounting (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    TransactionDate SMALLDATETIME DEFAULT GETDATE(),
    Amount DECIMAL(12, 2) NOT NULL,
    TransactionType NVARCHAR(20) CHECK (TransactionType IN ('Gelir', 'Gider')),
    PurchaseOrderID INT NULL,
    SaleOrderID INT NULL,
    FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrder(PurchaseOrderID),
    FOREIGN KEY (SaleOrderID) REFERENCES SaleOrder(SaleOrderID)
)

CREATE INDEX IX_Vehicle_Brand ON Vehicle(Brand)
CREATE INDEX IX_Customer_Name ON Customer(CustomerName)
CREATE INDEX IX_Product_Name ON Product(ProductName)
GO


-- 3. Insert Data

INSERT INTO Company (CompanyID, CompanyName, PhoneNumber, Email, Address, TaxNumber)
VALUES (1, 'Demirhan Otomotiv', '0262 646 4069', 'yakupdemirhan@hotmail.com', 'Tatlýkuyu Mah. Güney Yanyol Cd. Gebze Center Yaný No: 296 41000 Gebze/Kocaeli', 2870043113);

INSERT INTO Supplier (SupplierID, CompanyID, SupplierName, PhoneNumber, Email, Address, TaxNumber)
VALUES 
(001, 1, 'OTO ÝSMAÝL OTOMOTÝV SAN VE TÝC LTD ÞTÝ', '444 7 965', 'info@otoismail.com.tr', 'Ferhatpaþa Mah. Ataþehir/ÝSTANBUL', 6490013444),
(002, 1, 'Bosch Otomotiv', '0212 111 2233', 'contact@bosch.com', 'Maslak, Ýstanbul', 1234567890),
(003, 1, 'Castrol Madeni Yaðlar', '0212 222 3344', 'info@castrol.com.tr', 'Beþiktaþ, Ýstanbul', 0987654321),
(004, 1, 'Mais Motorlu Araçlar', '0216 333 4455', 'satis@mais.com.tr', 'Ümraniye, Ýstanbul', 1357902468),
(005, 1, 'Lassa Lastik', '0262 444 5566', 'info@lassa.com', 'Ýzmit, Kocaeli', 0246813579);

INSERT INTO Employee (EmployeeID, CompanyID, EmployeeName, PhoneNumber, Email, JobTitle, Salary)
VALUES
(101, 1, 'Berat Demirhan', '0500 000 0000', 'berat.demirhan@gmail.com', 'Usta', 50000.00),
(202, 1, 'Ali Doðan Pekdaþ', '0500 000 0001', 'ali.pekdas@gmail.com', 'Kalfa', 40000.00),
(303, 1, 'Ebubekir Baðdaþ', '0500 000 0002', 'ebubekir.bagdas@gmail.com', 'Çýrak', 30000.00),
(404, 1, 'Mehmet Yýlmaz', '0500 000 0003', 'mehmet.yýlmaz@gmail.com', 'Satýþ Temsilcisi', 35000.00),
(505, 1, 'Ayþe Kaya', '0500 000 0004', 'ayse.kaya@gmail.com', 'Muhasebe', 45000.00);

INSERT INTO Customer (CompanyID, CustomerName, PhoneNumber, Email, Address) VALUES
(1, 'Ahmet Yýlmaz', '0500 000 0001', 'ahmet.y@gmail.com', 'Gebze, Kocaeli'),
(1, 'Mehmet Öztürk', '0500 000 0002', 'mehmet.o@gmail.com', 'Darýca, Kocaeli'),
(1, 'Ayþe Demir', '0500 000 0003', 'ayse.d@gmail.com', 'Çayýrova, Kocaeli'),
(1, 'Fatma Kara', '0500 000 0004', 'fatma.k@gmail.com', 'Tuzla, Ýstanbul'),
(1, 'Mustafa Çelik', '0500 000 0005', 'mustafa.c@gmail.com', 'Pendik, Ýstanbul'),
(1, 'Zeynep Þahin', '0500 000 0006', 'zeynep.s@gmail.com', 'Kartal, Ýstanbul'),
(1, 'Ali Koç', '0500 000 0007', 'ali.k@gmail.com', 'Maltepe, Ýstanbul'),
(1, 'Veli Bakýr', '0500 000 0008', 'veli.b@gmail.com', 'Gebze, Kocaeli'),
(1, 'Hasan Hüseyin', '0500 000 0009', 'hasan.h@gmail.com', 'Dilovasý, Kocaeli'),
(1, 'Emine Can', '0500 000 0010', 'emine.c@gmail.com', 'Körfez, Kocaeli'),
(1, 'Oðuzhan Yýldýz', '0500 000 0011', 'oguz.y@gmail.com', 'Ýzmit, Kocaeli'),
(1, 'Burak Yýlmaz', '0500 000 0012', 'burak.y@gmail.com', 'Baþiskele, Kocaeli'),
(1, 'Selin Aksoy', '0500 000 0013', 'selin.a@gmail.com', 'Gebze, Kocaeli'),
(1, 'Deniz Gezgin', '0500 000 0014', 'deniz.g@gmail.com', 'Üsküdar, Ýstanbul'),
(1, 'Cem Karaca', '0500 000 0015', 'cem.k@gmail.com', 'Kadýköy, Ýstanbul'),
(1, 'Barýþ Manço', '0500 000 0016', 'baris.m@gmail.com', 'Moda, Ýstanbul'),
(1, 'Sezen Aksu', '0500 000 0017', 'sezen.a@gmail.com', 'Sarýyer, Ýstanbul'),
(1, 'Tarkan Tevetoðlu', '0500 000 0018', 'tarkan@gmail.com', 'Beykoz, Ýstanbul'),
(1, 'Sertab Erener', '0500 000 0019', 'sertab@gmail.com', 'Niþantaþý, Ýstanbul'),
(1, 'Kenan Doðulu', '0500 000 0020', 'kenan@gmail.com', 'Bebek, Ýstanbul'),
(1, 'Müslüm Gürses', '0500 000 0021', 'muslum@gmail.com', 'Baðcýlar, Ýstanbul'),
(1, 'Ferdi Tayfur', '0500 000 0022', 'ferdi@gmail.com', 'Adana, Türkiye'),
(1, 'Ýbrahim Tatlýses', '0500 000 0023', 'ibo@gmail.com', 'Þanlýurfa, Türkiye'),
(1, 'Neþet Ertaþ', '0500 000 0024', 'bozkýr@gmail.com', 'Etiler, Ýstanbul'),
(1, 'Ajda Pekkan', '0500 000 0025', 'superstar@gmail.com', 'Arnavutköy, Ýstanbul');

INSERT INTO Vehicle (CustomerID, LicensePlate, Brand, ModelYear) VALUES
(1, '41 ABC 001', 'Fiat Egea', 2020),
(2, '41 ABC 002', 'Renault Clio', 2019),
(3, '41 ABC 003', 'Fiat Doblo', 2021),
(4, '34 XYZ 004', 'Hyundai Accent', 2018),
(5, '34 XYZ 005', 'Renault Megane', 2017),
(6, '34 XYZ 006', 'Ford Focus', 2020),
(7, '34 XYZ 007', 'Toyota Corolla', 2022),
(8, '41 ABC 008', 'Honda Civic', 2021),
(9, '41 ABC 009', 'Volkswagen Passat', 2019),
(10, '63 ABC 010', 'Opel Astra', 2018),
(11, '63 ABC 011', 'Hyundai i20', 2022),
(12, '63 ABC 012', 'Nissan Qashqai', 2020),
(13, '63 ABC 013', 'Peugeot 3008', 2021),
(14, '34 XYZ 014', 'Citroen C3', 2019),
(15, '34 XYZ 015', 'Dacia Duster', 2018),
(16, '34 XYZ 016', 'Fiat Fiorino', 2017),
(17, '34 XYZ 017', 'Renault Symbol', 2016),
(18, '44 XYZ 018', 'BMW 320i', 2015),
(19, '44 XYZ 019', 'Mercedes C180', 2018),
(20, '44 XYZ 020', 'Audi A3', 2020),
(21, '44 XYZ 021', 'Skoda Octavia', 2019),
(22, '44 XYZ 022', 'Seat Leon', 2018),
(23, '44 XYZ 023', 'Kia Sportage', 2021),
(24, '44 XYZ 024', 'Volvo XC40', 2022),
(25, '44 XYZ 025', 'Tofaþ Þahin', 1998);

INSERT INTO Product (ProductName, Type, ItemPrice, StockQuantity) VALUES
('BANDO 4PK0915 KANALLI KAYIS FIORINO', 'Kayýþ', 151.55, 10),
('DELPHI HDF913 YAKIT FILTRESI CLIO', 'Filtre', 791.80, 50),
('ESER 11515911 FAR SAG FIAT EGEA', 'Aydýnlatma', 2881.29, 5),
('ESER 11515922 FAR SOL FIAT EGEA', 'Aydýnlatma', 2881.29, 5),
('ESER 1900141 SINYAL LAMBASI ON SAG TOFAS', 'Aydýnlatma', 164.65, 20),
('ESER 1900142 SINYAL LAMBASI ON SOL TOFAS', 'Aydýnlatma', 164.65, 20),
('FKK 9136 AMORTISOR TAKOZU ON DOBLO', 'Süspansiyon', 206.39, 15),
('GUA 40439 ROLANTI AYAR VALFI RENAULT', 'Motor', 528.30, 8),
('GVA 1129022 AYNA CAMI SOL FIORINO', 'Kaporta', 413.42, 12),
('KAYA KR458 ON CAMURLUK SINYALI SOL MEGANE', 'Kaporta', 120.43, 30),
('KAYA KR459 ON CAMURLUK SINYALI SAG MEGANE', 'Kaporta', 120.43, 30),
('MANN HU7032Z YAG FILTRESI ASTRA', 'Filtre', 172.77, 100),
('MANN W8017 YAG FILTRESI I20', 'Filtre', 453.58, 80),
('SNR M255.06 AMORTISOR RULMANI TRAFIC', 'Süspansiyon', 526.10, 10),
('WEGNA WC3241 POLEN FILTRESI ACCENT', 'Filtre', 76.33, 60),
('Castrol Edge 5W-30 Motor Yaðý 4L', 'Yað', 850.00, 40),
('Bosch Silecek Takýmý', 'Aksesuar', 250.00, 50),
('Mutlu Akü 60 Amper', 'Elektrik', 2200.00, 15),
('Michelin 205/55 R16 Yaz Lastiði', 'Lastik', 1800.00, 40),
('Balata Spreyi', 'Bakým', 75.00, 100),
('Antifriz 3L Kýrmýzý', 'Sývý', 200.00, 60),
('Cam Suyu 5L', 'Sývý', 50.00, 150),
('Paspas Seti Üniversal', 'Aksesuar', 400.00, 25),
('Direksiyon Kýlýfý', 'Aksesuar', 150.00, 30),
('NGK Buji Takýmý', 'Ateþleme', 600.00, 20);

INSERT INTO PurchaseOrder (SupplierID, EmployeeID, PurchaseDate) VALUES
(001, 101, '2025-10-25'),
(002, 202, '2025-10-20');

INSERT INTO PurchaseDetail (PurchaseOrderID, ProductID, UnitPrice, Quantity) VALUES
(1, 1, 151.55, 2),
(1, 2, 791.80, 50),
(1, 3, 2881.29, 2),
(1, 4, 2881.29, 2),
(1, 5, 164.65, 1),
(1, 6, 164.65, 1),
(1, 7, 206.39, 2),
(1, 8, 528.30, 1),
(2, 9, 413.42, 1),
(2, 10, 120.43, 2),
(2, 12, 172.77, 5),
(2, 17, 200.00, 50),
(2, 25, 450.00, 20);

INSERT INTO SaleOrder (CustomerID, SaleDate) VALUES
(1, '2025-11-01'), 
(2, '2025-11-01'), 
(3, '2025-11-02'), 
(4, '2025-11-02'), 
(5, '2025-11-03'),
(6, '2025-11-03'), 
(7, '2025-11-04'), 
(8, '2025-11-04'), 
(9, '2025-11-05'), 
(10, '2025-11-05'),
(11, '2025-11-06'), 
(12, '2025-11-06'), 
(13, '2025-11-07'), 
(14, '2025-11-07'), 
(15, '2025-11-08'),
(16, '2025-11-08'), 
(17, '2025-11-09'), 
(18, '2025-11-09'), 
(19, '2025-11-10'), 
(20, '2025-11-10'),
(21, '2025-11-11'),
(22, '2025-11-11'), 
(23, '2025-11-12'), 
(24, '2025-11-12'), 
(25, '2025-11-13');

INSERT INTO SaleDetail (SaleOrderID, ProductID, UnitPrice, Quantity) VALUES
(1, 16, 1200.00, 1), (1, 20, 100.00, 1),
(2, 12, 250.00, 1),
(3, 3, 3500.00, 1),
(4, 18, 2500.00, 1),
(5, 15, 120.00, 1),
(6, 17, 300.00, 1),
(7, 19, 2000.00, 4),
(8, 21, 250.00, 2),
(9, 23, 500.00, 1),
(10, 1, 250.00, 1),
(11, 2, 900.00, 1),
(12, 25, 750.00, 1),
(13, 14, 600.00, 2),
(14, 22, 75.00, 2),
(15, 5, 250.00, 1),
(16, 6, 250.00, 1),
(17, 11, 200.00, 1),
(18, 16, 1200.00, 1),
(19, 13, 600.00, 1),
(20, 24, 200.00, 1),
(21, 4, 3500.00, 1),
(22, 7, 300.00, 2),
(23, 8, 700.00, 1),
(24, 9, 500.00, 1),
(25, 10, 200.00, 1);

INSERT INTO Invoice (SaleOrderID, IssueDate) VALUES
(1, '2025-11-01'), 
(2, '2025-11-01'), 
(3, '2025-11-02'), 
(4, '2025-11-02'), 
(5, '2025-11-03'),
(6, '2025-11-03'), 
(7, '2025-11-04'), 
(8, '2025-11-04'), 
(9, '2025-11-05'), 
(10, '2025-11-05'),
(11, '2025-11-06'), 
(12, '2025-11-06'), 
(13, '2025-11-07'), 
(14, '2025-11-07'), 
(15, '2025-11-08'),
(16, '2025-11-08'), 
(17, '2025-11-09'), 
(18, '2025-11-09'), 
(19, '2025-11-10'), 
(20, '2025-11-10'),
(21, '2025-11-11'), 
(22, '2025-11-11'), 
(23, '2025-11-12'), 
(24, '2025-11-12'), 
(25, '2025-11-13');

INSERT INTO Accounting (TransactionDate, Amount, TransactionType, SaleOrderID, PurchaseOrderID) VALUES
('2025-11-01', 1300.00, 'Gelir', 1, NULL),
('2025-11-01', 250.00, 'Gelir', 2, NULL),
('2025-11-02', 3500.00, 'Gelir', 3, NULL),
('2025-11-02', 2500.00, 'Gelir', 4, NULL),
('2025-11-03', 120.00, 'Gelir', 5, NULL),
('2025-11-03', 300.00, 'Gelir', 6, NULL),
('2025-11-04', 8000.00, 'Gelir', 7, NULL),
('2025-11-04', 500.00, 'Gelir', 8, NULL),
('2025-11-05', 500.00, 'Gelir', 9, NULL),
('2025-11-05', 250.00, 'Gelir', 10, NULL),
('2025-11-06', 900.00, 'Gelir', 11, NULL),
('2025-11-06', 750.00, 'Gelir', 12, NULL),
('2025-11-07', 1200.00, 'Gelir', 13, NULL),
('2025-11-07', 150.00, 'Gelir', 14, NULL),
('2025-11-08', 250.00, 'Gelir', 15, NULL),
('2025-11-08', 250.00, 'Gelir', 16, NULL),
('2025-11-09', 200.00, 'Gelir', 17, NULL),
('2025-11-09', 1200.00, 'Gelir', 18, NULL),
('2025-11-10', 600.00, 'Gelir', 19, NULL),
('2025-11-10', 200.00, 'Gelir', 20, NULL),
('2025-11-11', 3500.00, 'Gelir', 21, NULL),
('2025-11-11', 600.00, 'Gelir', 22, NULL),
('2025-11-12', 700.00, 'Gelir', 23, NULL),
('2025-11-12', 500.00, 'Gelir', 24, NULL),
('2025-11-13', 200.00, 'Gelir', 25, NULL),
('2025-10-25', 10500.00, 'Gider', NULL, 1),
('2025-10-20', 19000.00, 'Gider', NULL, 2);
GO