package dal;

import util.DBContext;
import java.sql.*;
import java.util.*;

public class DashboardDAO {

    private final Connection conn = DBContext.getConnection();

    public int getTotalUsers() {
        return countQuery("SELECT COUNT(*) FROM Users");
    }

    public int getActiveUsers() {
        return countQuery("SELECT COUNT(*) FROM Users WHERE Status = 1");
    }

    public int getLockedUsers() {
        return countQuery("SELECT COUNT(*) FROM Users WHERE Status = 0");
    }

    public int getFirstLoginUsers() {
        return countQuery("SELECT COUNT(*) FROM Users WHERE IsFirstLogin = 1");
    }

    public List<Map<String, Object>> getUnassignedUsers() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.UserId, u.FullName, u.Username, u.Email, r.RoleName "
                + "FROM Users u JOIN Roles r ON u.RoleId = r.RoleId "
                + "WHERE u.WarehouseId IS NULL AND u.RoleId IN (3, 4) AND u.Status = 1 "
                + "ORDER BY u.FullName";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("userId", rs.getInt("UserId"));
                m.put("fullName", rs.getNString("FullName"));
                m.put("username", rs.getString("Username"));
                m.put("email", rs.getString("Email"));
                m.put("roleName", rs.getString("RoleName"));
                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getRecentUsers(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) u.UserId, u.FullName, u.Username, u.Email, u.Status, r.RoleName, "
                + "u.CreatedDate, u.UpdatedDate "
                + "FROM Users u JOIN Roles r ON u.RoleId = r.RoleId "
                + "ORDER BY COALESCE(u.UpdatedDate, u.CreatedDate) DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("userId", rs.getInt("UserId"));
                    m.put("fullName", rs.getNString("FullName"));
                    m.put("username", rs.getString("Username"));
                    m.put("email", rs.getString("Email"));
                    m.put("status", rs.getBoolean("Status"));
                    m.put("roleName", rs.getString("RoleName"));
                    m.put("createdDate", rs.getTimestamp("CreatedDate"));
                    m.put("updatedDate", rs.getTimestamp("UpdatedDate"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalProducts() {
        return countQuery("SELECT COUNT(*) FROM Products WHERE Status = 1");
    }

    public int getTotalCategories() {
        return countQuery("SELECT COUNT(*) FROM Categories WHERE Status = 1");
    }

    public int getTotalWarehouses() {
        return countQuery("SELECT COUNT(*) FROM Warehouses WHERE Status = 1");
    }

    public List<Map<String, Object>> getProductCountByCategory() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.CategoryName, COUNT(p.ProductId) AS ProductCount "
                + "FROM Categories c LEFT JOIN Products p ON c.CategoryId = p.CategoryId AND p.Status = 1 "
                + "WHERE c.Status = 1 GROUP BY c.CategoryName ORDER BY ProductCount DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("categoryName", rs.getNString("CategoryName"));
                m.put("productCount", rs.getInt("ProductCount"));
                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getRecentProducts(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.ProductId, p.ProductCode, p.ProductName, c.CategoryName, p.Unit, p.CreatedDate "
                + "FROM Products p LEFT JOIN Categories c ON p.CategoryId = c.CategoryId "
                + "WHERE p.Status = 1 ORDER BY p.CreatedDate DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("productId", rs.getInt("ProductId"));
                    m.put("productCode", rs.getString("ProductCode"));
                    m.put("productName", rs.getNString("ProductName"));
                    m.put("categoryName", rs.getNString("CategoryName"));
                    m.put("unit", rs.getNString("Unit"));
                    m.put("createdDate", rs.getTimestamp("CreatedDate"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public double getTotalStockQuantity() {
        String sql = "SELECT COALESCE(SUM(Quantity), 0) FROM InventoryBalances";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getMonthlyImportQuantity() {
        String sql = "SELECT COALESCE(SUM(td.Quantity), 0) FROM TransactionDetails td "
                + "JOIN InventoryTransactions t ON td.TransactionId = t.TransactionId "
                + "WHERE t.TransactionType IN (1, 3) AND t.ApprovalStatus = 1 AND t.Status = 1 "
                + "AND MONTH(t.TransactionDate) = MONTH(GETDATE()) AND YEAR(t.TransactionDate) = YEAR(GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getMonthlyExportQuantity() {
        String sql = "SELECT COALESCE(SUM(td.Quantity), 0) FROM TransactionDetails td "
                + "JOIN InventoryTransactions t ON td.TransactionId = t.TransactionId "
                + "WHERE t.TransactionType IN (2, 4) AND t.ApprovalStatus = 1 AND t.Status = 1 "
                + "AND MONTH(t.TransactionDate) = MONTH(GETDATE()) AND YEAR(t.TransactionDate) = YEAR(GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, Object>> getStockByWarehouse() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP 10 w.WarehouseName, COALESCE(SUM(ib.Quantity), 0) AS TotalStock "
                + "FROM Warehouses w LEFT JOIN InventoryBalances ib ON w.WarehouseId = ib.WarehouseId "
                + "WHERE w.Status = 1 GROUP BY w.WarehouseName ORDER BY TotalStock DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("warehouseName", rs.getNString("WarehouseName"));
                m.put("totalStock", rs.getDouble("TotalStock"));
                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getDailyImportExport(int days) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "WITH DateRange AS ( "
                + "SELECT CAST(DATEADD(DAY, -number, CAST(GETDATE() AS DATE)) AS DATE) AS d "
                + "FROM master..spt_values WHERE type='P' AND number BETWEEN 0 AND ? "
                + ") "
                + "SELECT dr.d AS txDate, "
                + "COALESCE(SUM(CASE WHEN t.TransactionType IN (1,3) THEN td.Quantity ELSE 0 END), 0) AS importQty, "
                + "COALESCE(SUM(CASE WHEN t.TransactionType IN (2,4) THEN td.Quantity ELSE 0 END), 0) AS exportQty "
                + "FROM DateRange dr "
                + "LEFT JOIN InventoryTransactions t ON CAST(t.TransactionDate AS DATE) = dr.d AND t.ApprovalStatus = 1 AND t.Status = 1 "
                + "LEFT JOIN TransactionDetails td ON t.TransactionId = td.TransactionId "
                + "GROUP BY dr.d ORDER BY dr.d ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days - 1);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("txDate", rs.getDate("txDate"));
                    m.put("importQty", rs.getDouble("importQty"));
                    m.put("exportQty", rs.getDouble("exportQty"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getTopExportedProducts(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.ProductName, p.Unit, SUM(td.Quantity) AS TotalExported "
                + "FROM TransactionDetails td "
                + "JOIN InventoryTransactions t ON td.TransactionId = t.TransactionId "
                + "JOIN Products p ON td.ProductId = p.ProductId "
                + "WHERE t.TransactionType IN (2, 4) AND t.ApprovalStatus = 1 AND t.Status = 1 "
                + "AND MONTH(t.TransactionDate) = MONTH(GETDATE()) AND YEAR(t.TransactionDate) = YEAR(GETDATE()) "
                + "GROUP BY p.ProductName, p.Unit ORDER BY TotalExported DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("productName", rs.getNString("ProductName"));
                    m.put("unit", rs.getNString("Unit"));
                    m.put("totalExported", rs.getDouble("TotalExported"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getTopStockProducts(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.ProductName, p.Unit, w.WarehouseName, ib.Quantity "
                + "FROM InventoryBalances ib "
                + "JOIN Products p ON ib.ProductId = p.ProductId "
                + "JOIN Warehouses w ON ib.WarehouseId = w.WarehouseId "
                + "WHERE ib.Quantity > 0 ORDER BY ib.Quantity DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("productName", rs.getNString("ProductName"));
                    m.put("unit", rs.getNString("Unit"));
                    m.put("warehouseName", rs.getNString("WarehouseName"));
                    m.put("quantity", rs.getDouble("Quantity"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getOldPendingTransactionCount() {
        return countQuery("SELECT COUNT(*) FROM InventoryTransactions "
                + "WHERE ApprovalStatus = 0 AND Status = 1 AND DATEDIFF(DAY, CreatedDate, GETDATE()) > 3");
    }

    public double getWarehouseStock(int warehouseId) {
        String sql = "SELECT COALESCE(SUM(Quantity), 0) FROM InventoryBalances WHERE WarehouseId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getPendingCountForWarehouse(int warehouseId) {
        String sql = "SELECT COUNT(*) FROM InventoryTransactions "
                + "WHERE ApprovalStatus = 0 AND Status = 1 "
                + "AND (FromWarehouseId = ? OR ToWarehouseId = ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setInt(2, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getTodayImportQuantity(int warehouseId) {
        String sql = "SELECT COALESCE(SUM(td.Quantity), 0) FROM TransactionDetails td "
                + "JOIN InventoryTransactions t ON td.TransactionId = t.TransactionId "
                + "WHERE t.ApprovalStatus = 1 AND t.Status = 1 "
                + "AND t.TransactionType IN (1, 3) AND t.ToWarehouseId = ? "
                + "AND CAST(t.TransactionDate AS DATE) = CAST(GETDATE() AS DATE)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getTodayExportQuantity(int warehouseId) {
        String sql = "SELECT COALESCE(SUM(td.Quantity), 0) FROM TransactionDetails td "
                + "JOIN InventoryTransactions t ON td.TransactionId = t.TransactionId "
                + "WHERE t.ApprovalStatus = 1 AND t.Status = 1 "
                + "AND t.TransactionType IN (2, 4) AND t.FromWarehouseId = ? "
                + "AND CAST(t.TransactionDate AS DATE) = CAST(GETDATE() AS DATE)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean isTodayClosed(int warehouseId) {
        String sql = "SELECT COUNT(*) FROM DailyClosings WHERE WarehouseId = ? "
                + "AND ClosingDate = CAST(GETDATE() AS DATE) AND IsClosed = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Map<String, Object>> getLowStockProducts(int warehouseId, int threshold) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.ProductName, p.Unit, ib.Quantity "
                + "FROM InventoryBalances ib JOIN Products p ON ib.ProductId = p.ProductId "
                + "WHERE ib.WarehouseId = ? AND ib.Quantity > 0 AND ib.Quantity < ? "
                + "ORDER BY ib.Quantity ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setInt(2, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("productName", rs.getNString("ProductName"));
                    m.put("unit", rs.getNString("Unit"));
                    m.put("quantity", rs.getDouble("Quantity"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getOutOfStockProducts(int warehouseId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.ProductName, p.Unit "
                + "FROM InventoryBalances ib JOIN Products p ON ib.ProductId = p.ProductId "
                + "WHERE ib.WarehouseId = ? AND ib.Quantity = 0 ORDER BY p.ProductName";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("productName", rs.getNString("ProductName"));
                    m.put("unit", rs.getNString("Unit"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getPendingTransactions(int warehouseId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT t.TransactionId, t.TransactionCode, t.TransactionType, t.TransactionDate, "
                + "t.FromWarehouseId, t.ToWarehouseId, uc.FullName AS CreatedByName, t.CreatedDate "
                + "FROM InventoryTransactions t "
                + "LEFT JOIN Users uc ON t.CreatedBy = uc.UserId "
                + "WHERE t.ApprovalStatus = 0 AND t.Status = 1 "
                + "AND (t.FromWarehouseId = ? OR t.ToWarehouseId = ?) "
                + "ORDER BY t.CreatedDate ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setInt(2, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("transactionId", rs.getInt("TransactionId"));
                    m.put("transactionCode", rs.getString("TransactionCode"));
                    m.put("transactionType", rs.getInt("TransactionType"));
                    m.put("transactionDate", rs.getTimestamp("TransactionDate"));
                    m.put("fromWarehouseId", rs.getInt("FromWarehouseId"));
                    m.put("toWarehouseId", rs.getInt("ToWarehouseId"));
                    m.put("createdByName", rs.getNString("CreatedByName"));
                    m.put("createdDate", rs.getTimestamp("CreatedDate"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getRecentApprovedTransactions(int warehouseId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) t.TransactionId, t.TransactionCode, t.TransactionType, t.TransactionDate, "
                + "t.FromWarehouseId, t.ToWarehouseId, ua.FullName AS ApprovedByName, t.ApprovedDate "
                + "FROM InventoryTransactions t "
                + "LEFT JOIN Users ua ON t.ApprovedBy = ua.UserId "
                + "WHERE t.ApprovalStatus = 1 AND t.Status = 1 "
                + "AND (t.FromWarehouseId = ? OR t.ToWarehouseId = ?) "
                + "ORDER BY t.ApprovedDate DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, warehouseId);
            ps.setInt(3, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("transactionId", rs.getInt("TransactionId"));
                    m.put("transactionCode", rs.getString("TransactionCode"));
                    m.put("transactionType", rs.getInt("TransactionType"));
                    m.put("transactionDate", rs.getTimestamp("TransactionDate"));
                    m.put("fromWarehouseId", rs.getInt("FromWarehouseId"));
                    m.put("toWarehouseId", rs.getInt("ToWarehouseId"));
                    m.put("approvedByName", rs.getNString("ApprovedByName"));
                    m.put("approvedDate", rs.getTimestamp("ApprovedDate"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private int countQuery(String sql) {
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
