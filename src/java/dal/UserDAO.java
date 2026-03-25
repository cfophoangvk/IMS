package dal;

import model.User;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import util.Validator;

public class UserDAO {

    private final Connection conn = DBContext.getConnection();

    private User mapResultSetToUser(ResultSet rs) throws Exception {
        User user = new User();
        user.setUserId(rs.getInt("UserId"));
        user.setRoleId(rs.getInt("RoleId"));
        user.setUsername(rs.getString("Username"));
        user.setPasswordHash(rs.getString("PasswordHash"));
        user.setFullName(rs.getNString("FullName"));
        user.setEmail(rs.getString("Email"));
        user.setFirstLogin(rs.getBoolean("IsFirstLogin"));
        user.setStatus(rs.getBoolean("Status"));
        user.setWarehouseId(rs.getInt("WarehouseId"));
        if (Validator.hasColumn(rs, "RoleName")) {
            user.setRoleName(rs.getString("RoleName"));
        }
        return user;
    }

    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM Users WHERE Username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getUserById(int userId) {
        String sql = "SELECT u.*, r.RoleName FROM Users u JOIN Roles r ON u.RoleId = r.RoleId WHERE u.UserId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<User> getAllUsers(String search, Integer roleId, int page, int pageSize) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.RoleName FROM Users u "
                + "JOIN Roles r ON u.RoleId = r.RoleId "
                + "WHERE (u.Username LIKE ? OR u.FullName LIKE ? OR u.Email LIKE ?) ";
        
        if (roleId != null) {
            sql += "AND u.RoleId = ? ";
        }
        
        sql += "ORDER BY u.UserId DESC "
             + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
             
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String searchPattern = "%" + (search != null ? search.trim() : "") + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            
            int paramIndex = 4;
            if (roleId != null) {
                ps.setInt(paramIndex++, roleId);
            }
            
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex, pageSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    public int getTotalUsers(String search, Integer roleId) {
        String sql = "SELECT COUNT(*) FROM Users u "
                + "WHERE (u.Username LIKE ? OR u.FullName LIKE ? OR u.Email LIKE ?) ";
                
        if (roleId != null) {
            sql += "AND u.RoleId = ? ";
        }
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String searchPattern = "%" + (search != null ? search.trim() : "") + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            
            if (roleId != null) {
                ps.setInt(4, roleId);
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

    public int createUser(User user) {
        String sql = "INSERT INTO Users (RoleId, Username, PasswordHash, FullName, Email, IsFirstLogin, Status, CreatedBy, CreatedDate) "
                + "VALUES (?, ?, ?, ?, ?, 1, 1, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, user.getRoleId());
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getEmail());
            ps.setInt(6, user.getCreatedBy());
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

    public boolean updateUser(User user) {
        String sql = "UPDATE Users SET FullName = ?, Email = ?, RoleId = ?, UpdatedBy = ?, UpdatedDate = GETDATE() WHERE UserId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setInt(3, user.getRoleId());
            ps.setInt(4, user.getUpdatedBy());
            ps.setInt(5, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleUserStatus(int userId, int updatedBy) {
        String sql = "UPDATE Users SET Status = CASE WHEN Status = 1 THEN 0 ELSE 1 END, UpdatedBy = ?, UpdatedDate = GETDATE() WHERE UserId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, updatedBy);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
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

    public boolean isEmailExists(String email, int excludeUserId) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Email = ? AND UserId != ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, excludeUserId);
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

    public boolean changePassword(String email, String newPasswordHash) {
        String sql = "UPDATE Users SET PasswordHash = ?, IsFirstLogin = 0 WHERE Email = ? AND Status = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public User getUserByUsernameOrEmail(String usernameEmail) {
        String sql = "SELECT * FROM Users WHERE IsFirstLogin = 0 AND Status = 1 AND (Username = ? OR Email = ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, usernameEmail);
            ps.setString(2, usernameEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<String> getEmployeeEmailsByWarehouse(int warehouseId) {
        List<String> emails = new ArrayList<>();
        String sql = "SELECT Email FROM Users WHERE WarehouseId = ? AND Status = 1 AND Email IS NOT NULL AND Email != ''";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    emails.add(rs.getString("Email"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return emails;
    }
}
