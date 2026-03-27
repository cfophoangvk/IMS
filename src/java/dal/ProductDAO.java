package dal;

import model.Product;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import util.Validator;

public class ProductDAO {

    private final Connection conn = DBContext.getConnection();

    private Product mapResultSet(ResultSet rs) throws Exception {
        Product p = new Product();
        p.setProductId(rs.getInt("ProductId"));
        p.setProductCode(rs.getString("ProductCode"));
        p.setProductName(rs.getNString("ProductName"));
        p.setCategoryId(rs.getInt("CategoryId"));
        p.setUnit(rs.getNString("Unit"));
        p.setStatus(rs.getBoolean("Status"));
        if (Validator.hasColumn(rs, "CategoryName")) {
            p.setCategoryName(rs.getNString("CategoryName"));
        }
        return p;
    }

    public List<Product> getAllProducts(String search, Integer categoryId, boolean activeOnly, int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.CategoryName FROM Products p "
                + "LEFT JOIN Categories c ON p.CategoryId = c.CategoryId "
                + "WHERE (p.ProductCode LIKE ? OR p.ProductName LIKE ?) AND c.Status = 1 ";
        if (categoryId != null) {
            sql += "AND p.CategoryId = ? ";
        }
        if (activeOnly) {
            sql += "AND p.Status = 1 ";
        }
        sql += "ORDER BY p.ProductId DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String pat = "%" + (search != null ? search : "") + "%";
            ps.setString(1, pat);
            ps.setNString(2, pat);
            int idx = 3;
            if (categoryId != null) {
                ps.setInt(idx++, categoryId);
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

    public int getTotalProducts(String search, Integer categoryId, boolean activeOnly) {
        String sql = "SELECT COUNT(*) FROM Products p "
                + "LEFT JOIN Categories c ON p.CategoryId = c.CategoryId "
                + "WHERE (p.ProductCode LIKE ? OR p.ProductName LIKE ?) AND c.Status = 1 ";
        if (categoryId != null) {
            sql += "AND p.CategoryId = ? ";
        }
        if (activeOnly) {
            sql += "AND p.Status = 1 ";
        }
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String pat = "%" + (search != null ? search : "") + "%";
            ps.setString(1, pat);
            ps.setNString(2, pat);
            if (categoryId != null) {
                ps.setInt(3, categoryId);
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

    public Product getProductById(int id) {
        String sql = "SELECT p.*, c.CategoryName FROM Products p "
                + "LEFT JOIN Categories c ON p.CategoryId = c.CategoryId WHERE p.ProductId = ? AND c.Status = 1";
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

    public int createProduct(Product p) {
        String sql = "INSERT INTO Products (ProductCode, ProductName, CategoryId, Unit, Status, CreatedBy, CreatedDate) "
                + "VALUES (?, ?, ?, ?, 1, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getProductCode());
            ps.setNString(2, p.getProductName());
            ps.setInt(3, p.getCategoryId());
            ps.setNString(4, p.getUnit());
            ps.setInt(5, p.getCreatedBy());
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

    public boolean updateProduct(Product p) {
        String sql = "UPDATE Products SET ProductName=?, CategoryId=?, Unit=?, UpdatedBy=?, UpdatedDate=GETDATE() WHERE ProductId=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, p.getProductName());
            ps.setInt(2, p.getCategoryId());
            ps.setNString(3, p.getUnit());
            ps.setInt(4, p.getUpdatedBy());
            ps.setInt(5, p.getProductId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleProductStatus(int id, int updatedBy) {
        String sql = "UPDATE Products SET Status=CASE WHEN Status=1 THEN 0 ELSE 1 END, UpdatedBy=?, UpdatedDate=GETDATE() WHERE ProductId=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, updatedBy);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isProductCodeExists(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM Products WHERE ProductCode = ? AND ProductId != ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
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

    public List<Product> getProductsByCategoryForDropdown(int categoryId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.* FROM Products p "
                + "JOIN Categories c ON p.CategoryId = c.CategoryId "
                + "WHERE p.Status = 1 AND c.Status = 1 AND p.CategoryId = ? ORDER BY p.ProductName ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
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

    public String getProductCodeById(int productId) {
        String sql = "SELECT ProductCode FROM Products WHERE ProductId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("ProductCode");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }
}
