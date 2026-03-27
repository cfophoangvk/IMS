package dal;

import model.Warehouse;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.User;

public class WarehouseDAO {

    private final Connection conn = DBContext.getConnection();

    private Warehouse mapResultSetToWarehouse(ResultSet rs) throws Exception {
        Warehouse w = new Warehouse();
        w.setWarehouseId(rs.getInt("WarehouseId"));
        w.setWarehouseCode(rs.getString("WarehouseCode"));
        w.setWarehouseName(rs.getNString("WarehouseName"));
        w.setLocation(rs.getNString("Location"));
        w.setStatus(rs.getBoolean("Status"));
        return w;
    }

    public List<Warehouse> getAllWarehouses(String search, int page, int pageSize) {
        List<Warehouse> list = new ArrayList<>();
        String sql = "SELECT * FROM Warehouses "
                + "WHERE (WarehouseCode LIKE ? OR WarehouseName LIKE ? OR Location LIKE ?) "
                + "ORDER BY WarehouseId DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + (search != null ? search.trim() : "") + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            ps.setInt(4, (page - 1) * pageSize);
            ps.setInt(5, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToWarehouse(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalWarehouses(String search) {
        String sql = "SELECT COUNT(*) FROM Warehouses "
                + "WHERE (WarehouseCode LIKE ? OR WarehouseName LIKE ? OR Location LIKE ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + (search != null ? search.trim() : "") + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
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

    public Warehouse getWarehouseById(int id) {
        String sql = "SELECT * FROM Warehouses WHERE WarehouseId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToWarehouse(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public String getWarehouseNameById(int id) {
        String sql = "SELECT WarehouseName FROM Warehouses WHERE WarehouseId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getNString("WarehouseName");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int createWarehouse(Warehouse w) {
        String sql = "INSERT INTO Warehouses (WarehouseCode, WarehouseName, Location, Status, CreatedBy, CreatedDate) "
                + "VALUES (?, ?, ?, 1, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, w.getWarehouseCode());
            ps.setNString(2, w.getWarehouseName());
            ps.setNString(3, w.getLocation());
            ps.setInt(4, w.getCreatedBy());
            int affected = ps.executeUpdate();
            if (affected > 0) {
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

    public boolean updateWarehouse(Warehouse w) {
        String sql = "UPDATE Warehouses SET WarehouseName = ?, Location = ?, UpdatedBy = ?, UpdatedDate = GETDATE() WHERE WarehouseId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, w.getWarehouseName());
            ps.setNString(2, w.getLocation());
            ps.setInt(3, w.getUpdatedBy());
            ps.setInt(4, w.getWarehouseId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleWarehouseStatus(int id, int updatedBy) {
        String sql = "UPDATE Warehouses SET Status = CASE WHEN Status = 1 THEN 0 ELSE 1 END, UpdatedBy = ?, UpdatedDate = GETDATE() WHERE WarehouseId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, updatedBy);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isWarehouseCodeExists(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM Warehouses WHERE WarehouseCode = ? AND WarehouseId != ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            ps.setInt(2, excludeId);
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

    public List<Warehouse> getAllActiveWarehouses() {
        List<Warehouse> list = new ArrayList<>();
        String sql = "SELECT * FROM Warehouses WHERE Status = 1 ORDER BY WarehouseName ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToWarehouse(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getMembersByWarehouse(int warehouseId) {
        List<User> members = new ArrayList<>();
        String sql = "SELECT u.*, r.RoleName FROM Users u JOIN Roles r ON u.RoleId = r.RoleId WHERE u.WarehouseId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("UserId"));
                    u.setUsername(rs.getString("Username"));
                    u.setFullName(rs.getNString("FullName"));
                    u.setEmail(rs.getString("Email"));
                    u.setRoleId(rs.getInt("RoleId"));
                    u.setRoleName(rs.getString("RoleName"));
                    members.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return members;
    }

    public boolean isManagerInWarehouse(int warehouseId) {
        String sql = "SELECT 1 FROM Users WHERE WarehouseId = ? AND RoleId = 4";
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

    public List<User> getUsersNotInWarehouse(boolean includeManager) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*,r.RoleName FROM Users u JOIN Roles r ON u.RoleId = r.RoleId WHERE u.WarehouseId IS NULL AND u.RoleId IN (3" + (includeManager ? ", 4)" : ")");
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("UserId"));
                    u.setUsername(rs.getString("Username"));
                    u.setFullName(rs.getNString("FullName"));
                    u.setEmail(rs.getString("Email"));
                    u.setRoleId(rs.getInt("RoleId"));
                    u.setRoleName(rs.getString("RoleName"));
                    users.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    public boolean updateUserWarehouse(Integer warehouseId, int userId) {
        String sql = "UPDATE Users SET WarehouseId = ? WHERE UserId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (warehouseId == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, warehouseId);
            }
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isWarehouseMemberExists(int warehouseId, int userId) {
        String sql = "SELECT 1 FROM Users u JOIN Warehouses w ON u.WarehouseId = w.WarehouseId WHERE u.WarehouseId = ? AND u.UserId = ? AND w.Status = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setInt(2, userId);
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
}
