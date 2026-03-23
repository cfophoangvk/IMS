package dal;

import model.DailyClosing;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.Validator;

public class DailyClosingDAO {

    private final Connection conn = DBContext.getConnection();

    private DailyClosing mapResultSet(ResultSet rs) throws Exception {
        DailyClosing dc = new DailyClosing();
        dc.setClosingId(rs.getInt("ClosingId"));
        dc.setWarehouseId(rs.getInt("WarehouseId"));
        dc.setClosingDate(rs.getDate("ClosingDate"));
        dc.setTotalProducts(rs.getInt("TotalProducts"));
        dc.setClosed(rs.getBoolean("IsClosed"));
        dc.setCreatedBy(rs.getInt("CreatedBy"));
        dc.setCreatedDate(rs.getTimestamp("CreatedDate"));
        if (Validator.hasColumn(rs, "WarehouseName")) {
            dc.setWarehouseName(rs.getNString("WarehouseName"));
        }
        if (Validator.hasColumn(rs, "CreatedByName")) {
            dc.setCreatedByName(rs.getNString("CreatedByName"));
        }
        return dc;
    }

    public List<DailyClosing> getAllClosings(Integer warehouseId, int page, int pageSize) {
        List<DailyClosing> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT dc.*, w.WarehouseName, u.FullName AS CreatedByName "
                + "FROM DailyClosings dc "
                + "JOIN Warehouses w ON dc.WarehouseId = w.WarehouseId "
                + "LEFT JOIN Users u ON dc.CreatedBy = u.UserId WHERE 1=1 ");
        if (warehouseId != null) {
            sql.append("AND dc.WarehouseId = ? ");
        }
        sql.append("ORDER BY dc.ClosingDate DESC, dc.ClosingId DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (warehouseId != null) {
                ps.setInt(idx++, warehouseId);
            }
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalClosings(Integer warehouseId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM DailyClosings dc WHERE 1=1 ");
        if (warehouseId != null) {
            sql.append("AND dc.WarehouseId = ? ");
        }
        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (warehouseId != null) {
                ps.setInt(1, warehouseId);
            }
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

    public List<DailyClosing> getClosingsByDate(int warehouseId, java.sql.Date date) {
        List<DailyClosing> list = new ArrayList<>();
        String sql = "SELECT dc.*, w.WarehouseName, u.FullName AS CreatedByName "
                + "FROM DailyClosings dc "
                + "JOIN Warehouses w ON dc.WarehouseId = w.WarehouseId "
                + "LEFT JOIN Users u ON dc.CreatedBy = u.UserId "
                + "WHERE dc.WarehouseId = ? AND dc.ClosingDate = ? ORDER BY dc.ClosingId DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean isDateClosed(int warehouseId, java.sql.Date date) {
        String sql = "SELECT COUNT(*) FROM DailyClosings WHERE WarehouseId = ? AND ClosingDate = ? AND IsClosed = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setDate(2, date);
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

    public boolean isDateClosedForTransaction(int fromWarehouseId, int toWarehouseId, java.sql.Date date) {
        if (fromWarehouseId > 0 && isDateClosed(fromWarehouseId, date)) {
            return true;
        }
        if (toWarehouseId > 0 && isDateClosed(toWarehouseId, date)) {
            return true;
        }
        return false;
    }

    public int createClosing(DailyClosing dc) {
        String sql = "INSERT INTO DailyClosings (WarehouseId, ClosingDate, TotalProducts, IsClosed, CreatedBy, CreatedDate) "
                + "VALUES (?, ?, ?, 1, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, dc.getWarehouseId());
            ps.setDate(2, new java.sql.Date(dc.getClosingDate().getTime()));
            ps.setInt(3, dc.getTotalProducts());
            ps.setInt(4, dc.getCreatedBy());
            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean toggleClosed(int closingId, int updatedBy) {
        String sql = "UPDATE DailyClosings SET IsClosed = CASE WHEN IsClosed=1 THEN 0 ELSE 1 END, "
                + "UpdatedBy=?, UpdatedDate=GETDATE() WHERE ClosingId=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, updatedBy);
            ps.setInt(2, closingId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countProductsInWarehouse(int warehouseId) {
        String sql = "SELECT COUNT(DISTINCT ProductId) FROM InventoryBalances WHERE WarehouseId = ? AND Quantity > 0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
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
}
