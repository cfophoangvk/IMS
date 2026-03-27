USE master;
GO
ALTER DATABASE [IMS] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS IMS;
GO
CREATE DATABASE IMS;
GO
USE IMS;
GO

CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL, -- IT Admin, System Admin, Nhân viên kho, Quản lý kho, Chủ DN
    Description NVARCHAR(255)
);

CREATE TABLE Warehouses (
    WarehouseId INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseCode VARCHAR(20) UNIQUE NOT NULL,
    WarehouseName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(255),
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    RoleId INT FOREIGN KEY REFERENCES Roles(RoleId),
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    IsFirstLogin BIT NOT NULL DEFAULT 1,
    WarehouseId INT FOREIGN KEY REFERENCES Warehouses(WarehouseId),
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

-- CREATE TABLE Partners (
--     PartnerId INT IDENTITY(1,1) PRIMARY KEY,
--     PartnerType TINYINT, -- 1: Supplier (Nhà cung cấp), 2: Customer (Khách hàng)
--     PartnerName NVARCHAR(150) NOT NULL,
--     Phone VARCHAR(20),
--     Email VARCHAR(100),
--     Status BIT DEFAULT 1,
--     CreatedBy INT,
--     CreatedDate DATETIME DEFAULT GETDATE(),
--     UpdatedBy INT,
--     UpdatedDate DATETIME
-- );

CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

CREATE TABLE Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode VARCHAR(50) UNIQUE NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    CategoryId INT FOREIGN KEY REFERENCES Categories(CategoryId),
    Unit NVARCHAR(20), -- Đơn vị tính (Cái, Hộp, Kg...)
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

CREATE TABLE InventoryTransactions (
    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
    TransactionCode VARCHAR(50) UNIQUE NOT NULL,
    TransactionType TINYINT NOT NULL, -- 1: Nhập ngoài, 2: Xuất ngoài, 3: Nhập nội bộ, 4: Xuất nội bộ
    TransactionDate DATETIME NOT NULL,
    FromWarehouseId INT NULL FOREIGN KEY REFERENCES Warehouses(WarehouseId),
    ToWarehouseId INT NULL FOREIGN KEY REFERENCES Warehouses(WarehouseId),
    -- PartnerId INT NULL FOREIGN KEY REFERENCES Partners(PartnerId), -- NCC hoặc Khách hàng
    PartnerId INT NULL, -- chưa làm bảng Partner
    Notes NVARCHAR(500),
    ApprovalStatus TINYINT DEFAULT 0, -- 0: Pending (Chưa duyệt), 1: Approved (Đã duyệt/Chốt số liệu), 2: Rejected
    ApprovedBy INT NULL FOREIGN KEY REFERENCES Users(UserId),
    ApprovedDate DATETIME NULL,
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

CREATE TABLE TransactionDetails (
    DetailId INT IDENTITY(1,1) PRIMARY KEY,
    TransactionId INT FOREIGN KEY REFERENCES InventoryTransactions(TransactionId),
    ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
    Quantity DECIMAL(18,2) NOT NULL,
    Price DECIMAL(18,2) NULL,
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

-- Bảng lưu Tồn kho hiện tại
CREATE TABLE InventoryBalances (
    BalanceId INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseId INT FOREIGN KEY REFERENCES Warehouses(WarehouseId),
    ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
    Quantity DECIMAL(18,2) DEFAULT 0,
    UpdatedBy INT,
    UpdatedDate DATETIME DEFAULT GETDATE()
);

-- Bảng Chốt sổ ngày
CREATE TABLE DailyClosings (
    ClosingId INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseId INT FOREIGN KEY REFERENCES Warehouses(WarehouseId),
    ClosingDate DATE NOT NULL, -- Ngày thực hiện chốt sổ (VD: 25/10/2023)
    TotalProducts INT, -- Thông tin tham khảo: Tổng số mã SP có trong kho lúc chốt
    IsClosed BIT DEFAULT 1,
    CreatedBy INT FOREIGN KEY REFERENCES Users(UserId), -- Người chốt sổ
    CreatedDate DATETIME DEFAULT GETDATE(), -- Thời điểm bấm nút chốt sổ
    UpdatedBy INT,
    UpdatedDate DATETIME
);
GO

INSERT INTO Roles (RoleName, Description) VALUES
('IT Admin', N'Administrator'),
('System Admin', N'Quản trị hệ thống'),
('Employee', N'Nhân viên kho'),
('Manager', N'Quản lý kho'),
('Business Owner', N'Chủ doanh nghiệp');

SET IDENTITY_INSERT [dbo].[Users] ON
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin], [WarehouseId]) VALUES 
(1, 1, N'admin', N'$2a$10$odQnplXlA.njrqB9jKevSuXz10GaA163IGS23Xl6UyrX0w/vM.9sq', N'Quản trị viên IT', N'admin@ims.com', 1, NULL, CAST(N'2026-03-22T09:05:32.850' AS DateTime), NULL, NULL, 0, NULL),
(2, 2, N'hoangvk3', N'$2a$10$mah4xjLdvvFKhq5AoGQDtOzGZmh4euZqCGR3fwHmTfgd7c3joPcl6', N'Vũ Khánh Hoàng', N'hieuthien20042004@gmail.com', 1, 1, CAST(N'2026-03-22T12:24:57.553' AS DateTime), 1, CAST(N'2026-03-22T13:32:52.460' AS DateTime), 0, NULL),
(3, 4, N'hoangvk2', N'$2a$10$mToJ3j7e4Kpnm6EIdiNqMuFk/w81vEbA.3P4FG9f9AEAXsv5CPmdm', N'Vũ Khánh Hoàn', N'hoangvkhe180563@fpt.edu.vn', 1, 1, CAST(N'2026-03-22T12:29:43.943' AS DateTime), 1, CAST(N'2026-03-22T13:02:03.017' AS DateTime), 1, NULL),
(4, 5, N'hainv', N'$2a$10$L/aUuDl61TPlW0LUWllB9.3xccf0SicyGeW.5bAo5dxuuuBxGhvRq', N'Nguyễn Văn Hải', N'hainvhe172343@fpt.edu.vn', 1, 1, CAST(N'2026-03-22T12:36:51.873' AS DateTime), 1, CAST(N'2026-03-22T12:48:11.207' AS DateTime), 1, NULL),
(5, 3, N'nghianv', N'$2a$10$eTZwVd2VMVvdaTE4qI9E8O7YDNW7IVtEWzYd1b7aCeLncigpHquRW', N'Nguyễn Văn Nghĩa', N'nghianv@example.com', 1, 1, CAST(N'2026-03-22T13:03:24.633' AS DateTime), NULL, NULL, 1, NULL),
(6, 3, N'nghiadt', N'$2a$10$ME9bIDAJxVld1MalLSnm8u0ybIekrXy..QoApnQ6eildw4wM4T.b6', N'Đàm Trung Nghĩa', N'nghiadt@example.com', 1, 1, CAST(N'2026-03-22T13:03:24.773' AS DateTime), NULL, NULL, 1, NULL),
(7, 2, N'anhtd64', N'$2a$10$qTkbapXln1BdGjGjU9jLfOeaZb.GRxNc4QKOiWjMJ0qtnLlMqScM.', N'Trần Duy Anh', N'anhtd64@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.170' AS DateTime), NULL, NULL, 1, NULL),
(8, 3, N'anlt36', N'$2a$10$znlqrcZYqmLBggCapgswtOyb1ICYZQWfGdT19e5XReuw1JDqj7aUa', N'Lê Thanh An', N'anlt36@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.270' AS DateTime), NULL, NULL, 1, NULL),
(9, 3, N'thangnd76', N'$2a$10$txHL7AyahmrzK0vWclj95.a31NOb7Ps.YPcoWMM8RHrqh5KX6HmMK', N'Nguyễn Đức Thắng', N'thangnd76@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.367' AS DateTime), NULL, NULL, 1, NULL),
(10, 3, N'giangch2', N'$2a$10$WAmB.rga1SlsIgp4/F/tp.2I6F3.juRJobA81L8SR.4iTUwMyvzIq', N'Chu Hoàng Giang', N'giangch2@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.467' AS DateTime), NULL, NULL, 1, NULL),
(11, 5, N'linhvk', N'$2a$10$PgJsaRwle3L7PwtAQnyvTeW2AWFTtjYm3Ver1duM1ILl18aRRhU7i', N'Vũ Khánh Linh', N'linhvk@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.550' AS DateTime), NULL, NULL, 1, NULL);
SET IDENTITY_INSERT [dbo].[Users] OFF
GO

INSERT INTO Warehouses (WarehouseCode, WarehouseName, Location, Status, CreatedBy) VALUES
('KHO-HN1', N'Kho Tổng Hà Nội', N'KCN Thăng Long, Đông Anh, Hà Nội', 1, 1),
('KHO-HCM', N'Kho Trung tâm TP.HCM', N'KCN Tân Bình, Quận Tân Phú, TP.HCM', 1, 1),
('KHO-DN', N'Kho Đà Nẵng', N'KCN Hòa Khánh, Quận Liên Chiểu, Đà Nẵng', 1, 1),
('KHO-CT', N'Kho Cần Thơ', N'KCN Trà Nóc, Quận Bình Thủy, Cần Thơ', 1, 1);
GO

INSERT INTO Categories (CategoryName, Status, CreatedBy) VALUES
(N'Xi măng', 1, 2),
(N'Cát - Đá xây dựng', 1, 3),
(N'Gạch xây', 1, 2),
(N'Sắt - Thép', 1, 3),
(N'Sơn nước & Chống thấm', 1, 2),
(N'Thiết bị vệ sinh', 1, 3),
(N'Gạch ốp lát', 1, 2),
(N'Vật tư điện nước', 1, 3);
GO

INSERT INTO Products (ProductCode, ProductName, CategoryId, Unit, Status, CreatedBy) VALUES
('XM-HT1', N'Xi măng Hà Tiên 1 PCB40', 1, N'Bao', 1, 2),
('XM-HOL', N'Xi măng Holcim Power-S', 1, N'Bao', 1, 2),
('XM-INSEE', N'Xi măng INSEE Wall Pro', 1, N'Bao', 1, 2),

('CAT-VANG', N'Cát vàng xây tô', 2, N'm³', 1, 3),
('CAT-DEN', N'Cát đen san lấp', 2, N'm³', 1, 3),
('DA-1X2', N'Đá 1x2 (dùng cho bê tông)', 2, N'm³', 1, 3),
('DA-4X6', N'Đá 4x6 (dùng cho móng)', 2, N'm³', 1, 3),

('GACH-4LO', N'Gạch Tuynel 4 lỗ (8x8x18cm)', 3, N'Viên', 1, 2),
('GACH-2LO', N'Gạch Tuynel 2 lỗ (5.5x9.5x20.5cm)', 3, N'Viên', 1, 2),
('GACH-DAC', N'Gạch đặc', 3, N'Viên', 1, 2),
('GACH-AAC', N'Gạch bê tông khí chưng áp (AAC) 600x200x100mm', 3, N'Viên', 1, 2),

('THEP-D6-HV', N'Thép cuộn phi 6 Hòa Phát', 4, N'Kg', 1, 3),
('THEP-D10-PMN', N'Thép cây vằn D10 Pomina', 4, N'Cây', 1, 3),
('THEP-HOP-50X100', N'Thép hộp 50x100x1.8mm', 4, N'Cây', 1, 3),
('THEP-V5', N'Thép V5', 4, N'Cây', 1, 3),

('SON-DULUX-NT', N'Sơn nội thất Dulux EasyClean lau chùi hiệu quả (Lon 5L)', 5, N'Lon', 1, 7),
('SON-KOVA-CT11A', N'Sơn chống thấm Kova CT-11A Plus (Thùng 20Kg)', 5, N'Thùng', 1, 7),
('SON-JOTUN-NGOAI', N'Sơn ngoại thất Jotun Jotashield (Thùng 15L)', 5, N'Thùng', 1, 7),
('BOT-TRET-JOTUN', N'Bột trét tường nội thất Jotun (Bao 40Kg)', 5, N'Bao', 1, 7),

('BC-INAX-C108', N'Bồn cầu 2 khối INAX C-108VAN', 6, N'Bộ', 1, 7),
('LAVABO-TOTO-LHT300', N'Chậu rửa mặt (Lavabo) TOTO LHT300CR', 6, N'Cái', 1, 7),
('VOI-SEN-INAX-1', N'Vòi sen tắm nóng lạnh INAX BFV-1403S-4C', 6, N'Bộ', 1, 7),
('GUONG-TOTO-1', N'Gương phòng tắm TOTO YM4560A', 6, N'Cái', 1, 7),

('GOL-VIGLA-60', N'Gạch lát nền Viglacera 60x60 ECO-622', 7, N'Hộp', 1, 7),
('GOL-PRIME-80', N'Gạch lát nền Prime 80x80 8221', 7, N'Hộp', 1, 7),
('GOT-TAICERA-3060', N'Gạch ốp tường Taicera 30x60 G63728', 7, N'Hộp', 1, 7),
('KEO-DANGACH', N'Keo dán gạch WeberTai Vis', 7, N'Bao', 1, 7),

('ONG-PVC-D21', N'Ống nhựa PVC Bình Minh D21', 8, N'Cây', 1, 7),
('ONG-PPR-D25', N'Ống nhựa chịu nhiệt PPR Vesbo D25', 8, N'Cây', 1, 7),
('DAYDIEN-CADIVI-2.5', N'Dây điện Cadivi CV 2.5 (Cuộn 100m)', 8, N'Cuộn', 1, 7),
('CB-PANA-1P20A', N'Aptomat (CB) Panasonic 1P 20A', 8, N'Cái', 1, 7);