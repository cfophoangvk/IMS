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
    Price DECIMAL(18,2) NULL,
    Status BIT DEFAULT 1,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedBy INT,
    UpdatedDate DATETIME
);

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

SET IDENTITY_INSERT [dbo].[Warehouses] ON
GO
INSERT INTO Warehouses (WarehouseId, WarehouseCode, WarehouseName, Location, Status, CreatedBy)
VALUES 
(1,'KHO-HN-001', N'Kho Tổng Hà Nội', N'KCN Thăng Long, Đông Anh, Hà Nội', 1, 2),
(2,'KHO-DN-001', N'Kho Đà Nẵng', N'KCN Hòa Khánh, Liên Chiểu, Đà Nẵng', 1, 2),
(3,'KHO-HCM-001', N'Kho Trung tâm TP.HCM', N'KCN Tân Bình, Quận Tân Bình, TP. Hồ Chí Minh', 1, 2),
(4,'KHO-HCM-002', N'Kho Linh Trung', N'KCN Linh Trung, Thủ Đức, TP. Hồ Chí Minh', 1, 2),
(5,'KHO-CT-001', N'Kho Cần Thơ', N'KCN Trà Nóc, Bình Thủy, Cần Thơ', 1, 2),
(6,'KHO-HP-001', N'Kho Hải Phòng', N'KCN Đình Vũ, Hải An, Hải Phòng', 0, 2),
(7,'KHO-L-BD01', N'Kho Lạnh Bình Dương', N'KCN VSIP 1, Thuận An, Bình Dương', 1, 3),
(8,'KHO-NVL-BN01', N'Kho Nguyên Vật Liệu Bắc Ninh', N'KCN Tiên Sơn, Từ Sơn, Bắc Ninh', 1, 3),
(9,'KHO-TP-HCM03', N'Kho Thành Phẩm Quận 7', N'KCN Tân Thuận, Quận 7, TP.HCM', 1, 3),
(10,'KHO-KG-DL01', N'Kho Ký Gửi Đà Lạt', N'Phường 11, TP. Đà Lạt, Lâm Đồng', 1, 3),
(11,'KHO-TD-HN02', N'Kho Trung Chuyển Mỹ Đình', N'Đường Phạm Hùng, Nam Từ Liêm, Hà Nội', 1, 3),
(12,'KHO-TMP-DN02', N'Kho Tạm Thời Đà Nẵng', N'KCN Liên Chiểu, Đà Nẵng', 1, 3),
(13,'KHO-DL-HP02', N'Kho Hàng Lỗi Hải Phòng', N'Quận Hải An, Hải Phòng', 1, 3),
(14,'KHO-VP-VT01', N'Kho Vật Phẩm Vũng Tàu', N'KCN Phú Mỹ, Bà Rịa - Vũng Tàu', 1, 3);
SET IDENTITY_INSERT [dbo].[Warehouses] OFF
GO

SET IDENTITY_INSERT [dbo].[Categories] ON
GO
INSERT INTO Categories (CategoryId, CategoryName, Status, CreatedBy)
VALUES 
(1, N'Điện tử - Điện lạnh', 1, 1),
(2, N'Đồ gia dụng', 1, 1),
(3, N'Văn phòng phẩm', 1, 1),
(4, N'Thực phẩm đóng gói', 1, 1),
(5, N'Vật liệu xây dựng', 1, 1),
(6, N'Hóa chất công nghiệp', 1, 1),
(7, N'Thời trang - May mặc', 1, 1),
(8, N'Mẹ và Bé', 1, 1),
(9, N'Sức khỏe - Sắc đẹp', 1, 1),
(10, N'Đồ uống - Giải khát', 1, 1),
(11, N'Phụ tùng - Linh kiện', 1, 1),
(12, N'Thiết bị bảo hộ lao động', 1, 1),
(13, N'Hàng thanh lý', 0, 1);
SET IDENTITY_INSERT [dbo].[Categories] OFF
GO

SET IDENTITY_INSERT [dbo].[Products] ON
GO
INSERT INTO Products (ProductId, ProductCode, ProductName, CategoryId, Unit, Status, CreatedBy)
VALUES 
(1,'DT-IP15-01', N'Điện thoại iPhone 15 Pro', 1, N'Cái', 1, 2),
(2,'DT-SS-TVS65', N'Smart Tivi Samsung 65 inch', 1, N'Cái', 1, 3),
(3,'DT-LG-MT01', N'Máy giặt LG 9kg', 1, N'Cái', 1, 2),
(4,'GD-BL-SH01', N'Máy xay sinh tố Sunhouse', 2, N'Bộ', 1, 3),
(5,'GD-NC-KSH02', N'Nồi cơm điện Kangaroo', 2, N'Cái', 1, 2),
(6,'VPP-GIAY-A4', N'Giấy in A4 Double A', 3, N'Ram', 1, 3),
(7,'VPP-BUT-BI01', N'Bút bi Thiên Long TL08', 3, N'Hộp', 1, 2),
(8,'TP-MI-HAO01', N'Mì tôm Hảo Hảo', 4, N'Thùng', 1, 2),
(9,'TP-GAO-ST25', N'Gạo ST25', 4, N'Túi', 1, 3),
(10,'VLXD-XM-HOA', N'Xi măng Hoàng Thạch', 5, N'Bao', 1, 3),
(11,'VLXD-THEP-V', N'Thép phi 16', 5, N'Cây', 1, 2),
(12,'HC-DUNG-MOI', N'Dung môi công nghiệp A', 6, N'Thùng phuy', 1, 2),
(13,'HC-CHAT-TAY', N'Chất tẩy rửa chuyên dụng', 6, N'Can', 1, 3),
(14,'DT-LT-DELL01', N'Laptop Dell Vostro 3510', 1, N'Cái', 1, 7),
(15,'DT-TL-PANA01', N'Tủ lạnh Panasonic Inverter', 1, N'Cái', 1, 7),
(16,'DT-IP13-OLD', N'Điện thoại iPhone 13 Pro', 1, N'Cái', 0, 7),
(17,'GD-QUAT-SENKO', N'Quạt cây Senko', 2, N'Cái', 1, 7),
(18,'GD-LVS-SHARP', N'Lò vi sóng Sharp R-205VN-S', 2, N'Cái', 1, 7),
(19,'VPP-GHIM-KW', N'Dập ghim KWTrio', 3, N'Cái', 1, 7),
(20,'VPP-BIA-CONG', N'Bìa còng Plus A4', 3, N'Cái', 1, 7),
(21,'TP-SUA-TH', N'Sữa tươi tiệt trùng TH True Milk', 4, N'Thùng', 1, 7),
(22,'TT-AO-SOMI-ANP', N'Áo sơ mi nam An Phước', 7, N'Cái', 1, 7),
(23,'TT-QUAN-JEAN-LV', N'Quần Jean Levis 501', 7, N'Cái', 1, 7),
(24,'TT-GIAY-BITIS', N'Giày thể thao Bitis Hunter X', 7, N'Đôi', 1, 7),
(25,'MB-BIM-BOBBY', N'Bỉm tã quần Bobby size L', 8, N'Bịch', 1, 7),
(26,'MB-SUA-VNM', N'Sữa bột Vinamilk Dielac Alpha', 8, N'Lon', 1, 7),
(27,'MB-BINH-COMO', N'Bình sữa Comotomo 250ml', 8, N'Cái', 1, 7),
(28,'SK-SRM-CETA', N'Sữa rửa mặt Cetaphil', 9, N'Chai', 1, 7),
(29,'SK-KCN-BIORE', N'Kem chống nắng Biore UV', 9, N'Tuýp', 1, 7),
(30,'SK-DAUGOI-SUN', N'Dầu gội Sunsilk mềm mượt diệu kỳ', 9, N'Chai', 1, 7),
(31,'DU-COCA-ZERO', N'Coca Cola Zero Sugar', 10, N'Thùng', 1, 7),
(32,'DU-CAFE-G7', N'Cà phê hòa tan G7 Trung Nguyên', 10, N'Hộp', 1, 7),
(33,'DU-NUOC-AQ', N'Nước tinh khiết Aquafina 500ml', 10, N'Thùng', 1, 7),
(34,'PT-BUG-NGK', N'Bugi NGK Iridium', 11, N'Cái', 1, 7),
(35,'PT-LOC-NHOT', N'Lọc nhớt xe máy', 11, N'Cái', 1, 7),
(36,'PT-ACQUY-GS', N'Bình ắc quy GS 12V', 11, N'Cái', 1, 7),
(37,'BH-NON-3M', N'Nón bảo hộ 3M', 12, N'Cái', 1, 7),
(38,'BH-GANG-TAY', N'Găng tay bảo hộ chống cắt', 12, N'Đôi', 1, 7),
(39,'BH-KINH-CHONG', N'Kính chống bụi Sperian', 12, N'Cái', 1, 7);
SET IDENTITY_INSERT [dbo].[Products] OFF
GO