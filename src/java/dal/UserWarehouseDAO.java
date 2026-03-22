package dal;

import model.User;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserWarehouseDAO {

    private final Connection conn = DBContext.getConnection();

    public List<User> getMembersByWarehouse(int warehouseId) {
        List<User> members = new ArrayList<>();
        String sql = "SELECT u.UserId, u.Username, u.FullName, u.Email, u.RoleId, r.RoleName, "
                + "uw.UserWarehouseId, uw.Status "
                + "FROM UserWarehouses uw "
                + "JOIN Users u ON uw.UserId = u.UserId "
                + "JOIN Roles r ON u.RoleId = r.RoleId "
                + "WHERE uw.WarehouseId = ? AND uw.Status = 1 AND u.Status = 1 "
                + "ORDER BY u.RoleId ASC, u.FullName ASC";
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
                    u.setCreatedBy(rs.getInt("UserWarehouseId"));
                    members.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return members;
    }

    public List<User> getAvailableUsers(int warehouseId) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.UserId, u.Username, u.FullName, u.Email, u.RoleId, r.RoleName "
                + "FROM Users u "
                + "JOIN Roles r ON u.RoleId = r.RoleId "
                + "WHERE u.Status = 1 AND u.RoleId IN (3, 4) "
                + "AND u.UserId NOT IN ("
                + "    SELECT UserId FROM UserWarehouses WHERE WarehouseId = ? AND Status = 1"
                + ") "
                + "ORDER BY r.RoleName ASC, u.FullName ASC";
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
                    users.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    public boolean addMember(int warehouseId, int userId, int createdBy) {
        String sql = "INSERT INTO UserWarehouses (UserId, WarehouseId, Status, CreatedBy, CreatedDate) "
                + "VALUES (?, ?, 1, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, warehouseId);
            ps.setInt(3, createdBy);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeMember(int userWarehouseId, int updatedBy) {
        String sql = "UPDATE UserWarehouses SET Status = 0, UpdatedBy = ?, UpdatedDate = GETDATE() WHERE UserWarehouseId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, updatedBy);
            ps.setInt(2, userWarehouseId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isMemberExists(int warehouseId, int userId) {
        String sql = "SELECT COUNT(*) FROM UserWarehouses WHERE WarehouseId = ? AND UserId = ? AND Status = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
