package dal;

import model.Category;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    private final Connection conn = DBContext.getConnection();

    private Category mapResultSet(ResultSet rs) throws Exception {
        Category c = new Category();
        c.setCategoryId(rs.getInt("CategoryId"));
        c.setCategoryName(rs.getNString("CategoryName"));
        c.setStatus(rs.getBoolean("Status"));
        return c;
    }

    public List<Category> getAllCategories(String search, boolean activeOnly, int page, int pageSize) {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Categories WHERE CategoryName LIKE ? ";
        if (activeOnly) {
            sql += "AND Status = 1 ";
        }
        sql += "ORDER BY CategoryId DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, "%" + (search != null ? search : "") + "%");
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
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

    public int getTotalCategories(String search, boolean activeOnly) {
        String sql = "SELECT COUNT(*) FROM Categories WHERE CategoryName LIKE ? ";
        if (activeOnly) {
            sql += "AND Status = 1 ";
        }
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, "%" + (search != null ? search : "") + "%");
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

    public Category getCategoryById(int id) {
        String sql = "SELECT * FROM Categories WHERE CategoryId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Category> getAllCategoriesForDropdown() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Categories WHERE Status = 1 ORDER BY CategoryName ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public int createCategory(Category c) {
        String sql = "INSERT INTO Categories (CategoryName, Status, CreatedBy, CreatedDate) VALUES (?, 1, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setNString(1, c.getCategoryName());
            ps.setInt(2, c.getCreatedBy());
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

    public boolean updateCategory(Category c) {
        String sql = "UPDATE Categories SET CategoryName = ?, UpdatedBy = ?, UpdatedDate = GETDATE() WHERE CategoryId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, c.getCategoryName());
            ps.setInt(2, c.getUpdatedBy());
            ps.setInt(3, c.getCategoryId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleCategoryStatus(int id, int updatedBy) {
        String sql = "UPDATE Categories SET Status = CASE WHEN Status=1 THEN 0 ELSE 1 END, UpdatedBy=?, UpdatedDate=GETDATE() WHERE CategoryId=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, updatedBy);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isCategoryNameExists(String name, int excludeId) {
        String sql = "SELECT COUNT(*) FROM Categories WHERE CategoryName = ? AND CategoryId != ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, name.trim());
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
}
