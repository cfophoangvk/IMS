package dal;

import model.Role;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO {

    private final Connection conn = DBContext.getConnection();

    public List<Role> getAllRoles() {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT * FROM Roles";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getInt("RoleId"));
                role.setRoleName(rs.getString("RoleName"));
                role.setDescription(rs.getString("Description"));
                roles.add(role);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return roles;
    }

    public Role getRoleById(int roleId) {
        String sql = "SELECT * FROM Roles WHERE RoleId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role role = new Role();
                    role.setRoleId(rs.getInt("RoleId"));
                    role.setRoleName(rs.getString("RoleName"));
                    role.setDescription(rs.getString("Description"));
                    return role;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
