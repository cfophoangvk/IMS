package dal;

import model.TransactionDetail;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TransactionDetailDAO {

    private final Connection conn = DBContext.getConnection();

    public List<TransactionDetail> getDetailsByTransactionId(int txId) {
        List<TransactionDetail> list = new ArrayList<>();
        String sql = "SELECT d.*, p.ProductCode, p.ProductName, p.Unit, c.CategoryName "
                + "FROM TransactionDetails d "
                + "JOIN Products p ON d.ProductId = p.ProductId "
                + "JOIN Categories c ON p.CategoryId = c.CategoryId "
                + "WHERE d.TransactionId = ? AND d.Status = 1 ORDER BY d.DetailId ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, txId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TransactionDetail d = new TransactionDetail();
                    d.setDetailId(rs.getInt("DetailId"));
                    d.setTransactionId(rs.getInt("TransactionId"));
                    d.setProductId(rs.getInt("ProductId"));
                    d.setQuantity(rs.getBigDecimal("Quantity"));
                    d.setPrice(rs.getBigDecimal("Price"));
                    d.setProductCode(rs.getString("ProductCode"));
                    d.setProductName(rs.getNString("ProductName"));
                    d.setUnit(rs.getNString("Unit"));
                    d.setCategoryName(rs.getNString("CategoryName"));
                    list.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insertDetail(TransactionDetail d) {
        String sql = "INSERT INTO TransactionDetails (TransactionId, ProductId, Quantity, Price, Status, CreatedBy, CreatedDate) "
                + "VALUES (?, ?, ?, ?, 1, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, d.getTransactionId());
            ps.setInt(2, d.getProductId());
            ps.setBigDecimal(3, d.getQuantity());
            if (d.getPrice() != null) {
                ps.setBigDecimal(4, d.getPrice());
            } else {
                ps.setNull(4, Types.DECIMAL);
            }
            ps.setInt(5, d.getCreatedBy());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteDetailsByTransactionId(int txId) {
        String sql = "DELETE FROM TransactionDetails WHERE TransactionId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, txId);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
