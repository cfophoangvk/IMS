package dal;

import model.InventoryTransaction;
import util.Constant;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.Validator;

public class InventoryTransactionDAO {

    private final Connection conn = DBContext.getConnection();

    private InventoryTransaction mapResultSet(ResultSet rs) throws Exception {
        InventoryTransaction t = new InventoryTransaction();
        t.setTransactionId(rs.getInt("TransactionId"));
        t.setTransactionCode(rs.getString("TransactionCode"));
        t.setTransactionType(rs.getInt("TransactionType"));
        t.setTransactionDate(rs.getTimestamp("TransactionDate"));
        t.setFromWarehouseId(rs.getInt("FromWarehouseId"));
        t.setToWarehouseId(rs.getInt("ToWarehouseId"));
        t.setPartnerId(rs.getInt("PartnerId"));
        t.setNotes(rs.getNString("Notes"));
        t.setApprovalStatus(rs.getInt("ApprovalStatus"));
        t.setApprovedBy(rs.getInt("ApprovedBy"));
        t.setApprovedDate(rs.getTimestamp("ApprovedDate"));
        t.setStatus(rs.getBoolean("Status"));
        t.setCreatedBy(rs.getInt("CreatedBy"));
        t.setCreatedDate(rs.getTimestamp("CreatedDate"));
        if (Validator.hasColumn(rs, "FromWarehouseName")) {
            t.setFromWarehouseName(rs.getNString("FromWarehouseName"));
        }
        if (Validator.hasColumn(rs, "ToWarehouseName")) {
            t.setToWarehouseName(rs.getNString("ToWarehouseName"));
        }
        if (Validator.hasColumn(rs, "CreatedByName")) {
            t.setCreatedByName(rs.getNString("CreatedByName"));
        }
        if (Validator.hasColumn(rs, "ApprovedByName")) {
            t.setApprovedByName(rs.getNString("ApprovedByName"));
        }
        return t;
    }

    private String buildJoinSql() {
        return "SELECT t.*, "
                + "fw.WarehouseName AS FromWarehouseName, "
                + "tw.WarehouseName AS ToWarehouseName, "
                + "uc.FullName AS CreatedByName, "
                + "ua.FullName AS ApprovedByName "
                + "FROM InventoryTransactions t "
                + "LEFT JOIN Warehouses fw ON t.FromWarehouseId = fw.WarehouseId "
                + "LEFT JOIN Warehouses tw ON t.ToWarehouseId = tw.WarehouseId "
                + "LEFT JOIN Users uc ON t.CreatedBy = uc.UserId "
                + "LEFT JOIN Users ua ON t.ApprovedBy = ua.UserId ";
    }

    public List<InventoryTransaction> getAllTransactions(String search, Integer type, Integer approvalStatus, int page, int pageSize) {
        List<InventoryTransaction> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(buildJoinSql());
        sql.append("WHERE t.Status = 1 AND t.TransactionCode LIKE ? ");
        List<Object> params = new ArrayList<>();
        params.add("%" + (search != null ? search : "") + "%");

        if (type != null) {
            sql.append("AND t.TransactionType = ? ");
            params.add(type);
        }
        if (approvalStatus != null) {
            sql.append("AND t.ApprovalStatus = ? ");
            params.add(approvalStatus);
        }

        sql.append("ORDER BY t.TransactionId DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                } else {
                    ps.setString(i + 1, (String) p);
                }
            }
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

    public int getTotalTransactions(String search, Integer type, Integer approvalStatus) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM InventoryTransactions t WHERE t.Status = 1 AND t.TransactionCode LIKE ? ");
        List<Object> params = new ArrayList<>();
        params.add("%" + (search != null ? search : "") + "%");

        if (type != null) {
            sql.append("AND t.TransactionType = ? ");
            params.add(type);
        }
        if (approvalStatus != null) {
            sql.append("AND t.ApprovalStatus = ? ");
            params.add(approvalStatus);
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                } else {
                    ps.setString(i + 1, (String) p);
                }
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

    public InventoryTransaction getTransactionById(int id) {
        String sql = buildJoinSql() + "WHERE t.TransactionId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    InventoryTransaction t = mapResultSet(rs);
                    // set partner name from Constant
                    if (t.getPartnerId() > 0) {
                        t.setPartnerName(Constant.PARTNER_LIST.getOrDefault(t.getPartnerId(), ""));
                    }
                    return t;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int createTransaction(InventoryTransaction t) {
        String sql = "INSERT INTO InventoryTransactions (TransactionCode, TransactionType, TransactionDate, "
                + "FromWarehouseId, ToWarehouseId, PartnerId, Notes, ApprovalStatus, Status, CreatedBy, CreatedDate) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, 0, 1, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, t.getTransactionCode());
            ps.setInt(2, t.getTransactionType());
            ps.setTimestamp(3, t.getTransactionDate());
            if (t.getFromWarehouseId() > 0) {
                ps.setInt(4, t.getFromWarehouseId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            if (t.getToWarehouseId() > 0) {
                ps.setInt(5, t.getToWarehouseId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            if (t.getPartnerId() > 0) {
                ps.setInt(6, t.getPartnerId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            if (t.getNotes() != null && !t.getNotes().isEmpty()) {
                ps.setNString(7, t.getNotes());
            } else {
                ps.setNull(7, Types.NVARCHAR);
            }
            ps.setInt(8, t.getCreatedBy());
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

    public boolean updateTransaction(InventoryTransaction t) {
        String sql = "UPDATE InventoryTransactions SET TransactionType=?, TransactionDate=?, "
                + "FromWarehouseId=?, ToWarehouseId=?, PartnerId=?, Notes=?, "
                + "UpdatedBy=?, UpdatedDate=GETDATE() WHERE TransactionId=? AND ApprovalStatus=0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getTransactionType());
            ps.setTimestamp(2, t.getTransactionDate());
            if (t.getFromWarehouseId() > 0) {
                ps.setInt(3, t.getFromWarehouseId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            if (t.getToWarehouseId() > 0) {
                ps.setInt(4, t.getToWarehouseId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            if (t.getPartnerId() > 0) {
                ps.setInt(5, t.getPartnerId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            if (t.getNotes() != null && !t.getNotes().isEmpty()) {
                ps.setNString(6, t.getNotes());
            } else {
                ps.setNull(6, Types.NVARCHAR);
            }
            ps.setInt(7, t.getUpdatedBy());
            ps.setInt(8, t.getTransactionId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean approveTransaction(int txId, int approvedBy) {
        String sql = "UPDATE InventoryTransactions SET ApprovalStatus=1, ApprovedBy=?, ApprovedDate=GETDATE(), "
                + "UpdatedBy=?, UpdatedDate=GETDATE() WHERE TransactionId=? AND ApprovalStatus=0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, approvedBy);
            ps.setInt(2, approvedBy);
            ps.setInt(3, txId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean rejectTransaction(int txId, int rejectedBy) {
        String sql = "UPDATE InventoryTransactions SET ApprovalStatus=2, ApprovedBy=?, ApprovedDate=GETDATE(), "
                + "UpdatedBy=?, UpdatedDate=GETDATE() WHERE TransactionId=? AND ApprovalStatus=0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rejectedBy);
            ps.setInt(2, rejectedBy);
            ps.setInt(3, txId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isTransactionCodeExists(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM InventoryTransactions WHERE TransactionCode = ? AND TransactionId != ?";
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

    public String generateTransactionCode(int type) {
        String prefix;
        switch (type) {
            case Constant.TX_IMPORT_SUPPLIER:
                prefix = "NH-NCC";
                break;
            case Constant.TX_EXPORT_SUPPLIER:
                prefix = "XH-NCC";
                break;
            case Constant.TX_IMPORT_INTERNAL:
                prefix = "NH-NB";
                break;
            default:
                prefix = "XH-NB";
                break;
        }
        String code = prefix + "-" + new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date());
        return code;
    }
}
