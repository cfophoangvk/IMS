package dal;

import model.TransactionDetail;
import util.DBContext;
import java.math.BigDecimal;
import java.sql.*;
import java.util.List;

public class InventoryBalanceDAO {

    private final Connection conn = DBContext.getConnection();

    public BigDecimal getBalance(int warehouseId, int productId) {
        String sql = "SELECT Quantity FROM InventoryBalances WHERE WarehouseId = ? AND ProductId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("Quantity");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private boolean upsertBalance(int warehouseId, int productId, BigDecimal delta, int updatedBy) throws SQLException {
        BigDecimal current = getBalance(warehouseId, productId);
        if (current == null) {
            String sql = "INSERT INTO InventoryBalances (WarehouseId, ProductId, Quantity, UpdatedBy, UpdatedDate) VALUES (?, ?, ?, ?, GETDATE())";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, warehouseId);
                ps.setInt(2, productId);
                ps.setBigDecimal(3, delta);
                ps.setInt(4, updatedBy);
                return ps.executeUpdate() > 0;
            }
        } else {
            String sql = "UPDATE InventoryBalances SET Quantity = Quantity + ?, UpdatedBy = ?, UpdatedDate = GETDATE() WHERE WarehouseId = ? AND ProductId = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setBigDecimal(1, delta);
                ps.setInt(2, updatedBy);
                ps.setInt(3, warehouseId);
                ps.setInt(4, productId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    public String applyImport(int toWarehouseId, List<TransactionDetail> details, int updatedBy) {
        try {
            conn.setAutoCommit(false);
            for (TransactionDetail d : details) {
                upsertBalance(toWarehouseId, d.getProductId(), d.getQuantity(), updatedBy);
            }
            conn.commit();
            return null;
        } catch (Exception e) {
            try {
                conn.rollback();
            } catch (Exception ignored) {
            }
            e.printStackTrace();
            return "Lỗi khi cập nhật tồn kho: " + e.getMessage();
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (Exception ignored) {
            }
        }
    }

    public String applyExport(int fromWarehouseId, List<TransactionDetail> details, int updatedBy) {
        try {
            conn.setAutoCommit(false);
            for (TransactionDetail d : details) {
                BigDecimal current = getBalance(fromWarehouseId, d.getProductId());
                if (current == null || current.compareTo(d.getQuantity()) < 0) {
                    conn.rollback();
                    return "Số lượng tồn kho không đủ cho sản phẩm " + d.getProductCode()
                            + " (Tồn: " + (current != null ? current : "0")
                            + ", Cần xuất: " + d.getQuantity() + ")";
                }
                upsertBalance(fromWarehouseId, d.getProductId(), d.getQuantity().negate(), updatedBy);
            }
            conn.commit();
            return null;
        } catch (Exception e) {
            try {
                conn.rollback();
            } catch (Exception ignored) {
            }
            e.printStackTrace();
            return "Lỗi khi cập nhật tồn kho: " + e.getMessage();
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (Exception ignored) {
            }
        }
    }

    public String applyTransfer(int fromWarehouseId, int toWarehouseId, List<TransactionDetail> details, int updatedBy) {
        try {
            conn.setAutoCommit(false);
            for (TransactionDetail d : details) {
                BigDecimal current = getBalance(fromWarehouseId, d.getProductId());
                if (current == null || current.compareTo(d.getQuantity()) < 0) {
                    conn.rollback();
                    return "Số lượng tồn kho không đủ tại kho nguồn cho sản phẩm " + d.getProductCode()
                            + " (Tồn: " + (current != null ? current : "0")
                            + ", Cần chuyển: " + d.getQuantity() + ")";
                }
                upsertBalance(fromWarehouseId, d.getProductId(), d.getQuantity().negate(), updatedBy);
                upsertBalance(toWarehouseId, d.getProductId(), d.getQuantity(), updatedBy);
            }
            conn.commit();
            return null;
        } catch (Exception e) {
            try {
                conn.rollback();
            } catch (Exception ignored) {
            }
            e.printStackTrace();
            return "Lỗi khi cập nhật tồn kho: " + e.getMessage();
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (Exception ignored) {
            }
        }
    }

    public String checkStockForDetails(int warehouseId, java.util.List<TransactionDetail> details) {
        for (TransactionDetail d : details) {
            BigDecimal current = getBalance(warehouseId, d.getProductId());
            if (current == null || current.compareTo(d.getQuantity()) < 0) {
                ProductDAO pdao = new ProductDAO();
                String productCode = pdao.getProductCodeById(d.getProductId());
                return "Tồn kho không đủ cho sản phẩm (Code: " + productCode
                        + "). Tồn: " + (current != null ? current.stripTrailingZeros().toPlainString() : "0")
                        + ", Cần: " + d.getQuantity();
            }
        }
        return null;
    }
}
