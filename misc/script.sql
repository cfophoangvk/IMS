CREATE DATABASE IMS;
GO
USE IMS;
GO

-- =========================================
-- 1. BẢNG PHÂN QUYỀN & TÀI KHOẢN
-- =========================================

CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL, -- IT Admin, System Admin, Nhân viên kho, Quản lý kho, Chủ DN
    Description NVARCHAR(255)
);
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    RoleId INT FOREIGN KEY REFERENCES Roles(RoleId),
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    IsFirstLogin BIT NOT NULL DEFAULT 1,
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

-- =========================================
-- 2. QUẢN LÝ DANH MỤC KHO & PHÂN QUYỀN KHO
-- =========================================

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

CREATE TABLE UserWarehouses (
    UserWarehouseId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT FOREIGN KEY REFERENCES Users(UserId),
    WarehouseId INT FOREIGN KEY REFERENCES Warehouses(WarehouseId),
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

-- =========================================
-- 3. QUẢN LÝ SẢN PHẨM & ĐỐI TÁC
-- =========================================

CREATE TABLE Partners (
    PartnerId INT IDENTITY(1,1) PRIMARY KEY,
    PartnerType TINYINT, -- 1: Supplier (Nhà cung cấp), 2: Customer (Khách hàng)
    PartnerName NVARCHAR(150) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

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

-- =========================================
-- 4. NHẬP XUẤT HÀNG & PHÊ DUYỆT
-- =========================================

CREATE TABLE InventoryTransactions (
    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
    TransactionCode VARCHAR(50) UNIQUE NOT NULL,
    TransactionType TINYINT NOT NULL, -- 1: Nhập ngoài, 2: Xuất ngoài, 3: Chuyển nội bộ
    TransactionDate DATETIME NOT NULL,
    -- Nếu Nhập: ToWarehouseId có data. Nếu Xuất: FromWarehouseId có data. Nếu Chuyển: Cả 2 có data.
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
    Price DECIMAL(18,2) NULL, -- Giá nhập/xuất
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

-- =========================================
-- 5. QUẢN LÝ TỒN KHO & CHỐT SỔ
-- =========================================

-- Bảng lưu Tồn kho hiện tại (Dùng để View Dashboard và Quản lý hàng tồn kho nhanh chóng)
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
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (1, 1, N'admin', N'$2a$10$odQnplXlA.njrqB9jKevSuXz10GaA163IGS23Xl6UyrX0w/vM.9sq', N'Quản trị viên IT', N'admin@ims.com', 1, NULL, CAST(N'2026-03-22T09:05:32.850' AS DateTime), NULL, NULL, 0)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (2, 2, N'hoangvk3', N'$2a$10$mah4xjLdvvFKhq5AoGQDtOzGZmh4euZqCGR3fwHmTfgd7c3joPcl6', N'Vũ Khánh Hoàng', N'hieuthien20042004@gmail.com', 1, 1, CAST(N'2026-03-22T12:24:57.553' AS DateTime), 1, CAST(N'2026-03-22T13:32:52.460' AS DateTime), 0)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (3, 4, N'hoangvk2', N'$2a$10$mToJ3j7e4Kpnm6EIdiNqMuFk/w81vEbA.3P4FG9f9AEAXsv5CPmdm', N'Vũ Khánh Hoàn', N'hoangvkhe180563@fpt.edu.vn', 1, 1, CAST(N'2026-03-22T12:29:43.943' AS DateTime), 1, CAST(N'2026-03-22T13:02:03.017' AS DateTime), 1)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (4, 5, N'hainv', N'$2a$10$L/aUuDl61TPlW0LUWllB9.3xccf0SicyGeW.5bAo5dxuuuBxGhvRq', N'Nguyễn Văn Hải', N'hainvhe172343@fpt.edu.vn', 1, 1, CAST(N'2026-03-22T12:36:51.873' AS DateTime), 1, CAST(N'2026-03-22T12:48:11.207' AS DateTime), 1)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (5, 3, N'nghianv', N'$2a$10$eTZwVd2VMVvdaTE4qI9E8O7YDNW7IVtEWzYd1b7aCeLncigpHquRW', N'Nguyễn Văn Nghĩa', N'nghianv@example.com', 1, 1, CAST(N'2026-03-22T13:03:24.633' AS DateTime), NULL, NULL, 1)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (6, 3, N'nghiadt', N'$2a$10$ME9bIDAJxVld1MalLSnm8u0ybIekrXy..QoApnQ6eildw4wM4T.b6', N'Đàm Trung Nghĩa', N'nghiadt@example.com', 1, 1, CAST(N'2026-03-22T13:03:24.773' AS DateTime), NULL, NULL, 1)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (7, 2, N'anhtd64', N'$2a$10$qTkbapXln1BdGjGjU9jLfOeaZb.GRxNc4QKOiWjMJ0qtnLlMqScM.', N'Trần Duy Anh', N'anhtd64@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.170' AS DateTime), NULL, NULL, 1)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (8, 3, N'anlt36', N'$2a$10$znlqrcZYqmLBggCapgswtOyb1ICYZQWfGdT19e5XReuw1JDqj7aUa', N'Lê Thanh An', N'anlt36@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.270' AS DateTime), NULL, NULL, 1)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (9, 3, N'thangnd76', N'$2a$10$txHL7AyahmrzK0vWclj95.a31NOb7Ps.YPcoWMM8RHrqh5KX6HmMK', N'Nguyễn Đức Thắng', N'thangnd76@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.367' AS DateTime), NULL, NULL, 1)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (10, 3, N'giangch2', N'$2a$10$WAmB.rga1SlsIgp4/F/tp.2I6F3.juRJobA81L8SR.4iTUwMyvzIq', N'Chu Hoàng Giang', N'giangch2@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.467' AS DateTime), NULL, NULL, 1)
GO
INSERT [dbo].[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Status], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate], [IsFirstLogin]) VALUES (11, 5, N'linhvk', N'$2a$10$PgJsaRwle3L7PwtAQnyvTeW2AWFTtjYm3Ver1duM1ILl18aRRhU7i', N'Vũ Khánh Linh', N'linhvk@example.com', 1, 1, CAST(N'2026-03-22T13:11:37.550' AS DateTime), NULL, NULL, 1)
GO
SET IDENTITY_INSERT [dbo].[Users] OFF
GO

/*
ALTER TABLE InventoryTransactions DROP CONSTRAINT FK__Inventory__Partn__5AEE82B9;
alter table InventoryTransactions drop column PartnerId;
alter table InventoryTransactions add PartnerId int null;
*/