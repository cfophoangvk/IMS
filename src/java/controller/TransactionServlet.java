package controller;

import dal.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.InventoryTransaction;
import model.TransactionDetail;
import model.User;
import util.Constant;
import util.Validator;

@WebServlet(name = "TransactionServlet", urlPatterns = {
    "/transaction/list",
    "/transaction/details",
    "/transaction/add",
    "/transaction/edit",
    "/transaction/approve",
    "/transaction/reject",
    "/transaction/approval-list",
    "/api/products-by-category"
})
public class TransactionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String path = request.getServletPath();

        switch (path) {
            case "/transaction/list":
                if (!Validator.hasRole(user.getRoleId(), Constant.TX_VIEW_ROLES)) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleList(request, response, user);
                break;
            case "/transaction/details":
                if (!Validator.hasRole(user.getRoleId(), Constant.TX_VIEW_ROLES)) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleDetails(request, response, user);
                break;
            case "/transaction/add":
                if (!Validator.hasRole(user.getRoleId(), Constant.TX_CREATE_ROLES)) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                prepareFormData(request);
                request.getRequestDispatcher("/views/transaction/add-transaction.jsp").forward(request, response);
                break;
            case "/transaction/edit":
                if (!Validator.hasRole(user.getRoleId(), Constant.TX_CREATE_ROLES)) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleShowEdit(request, response, user);
                break;
            case "/transaction/approval-list":
                if (user.getRoleId() != Constant.ROLE_MANAGER) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleApprovalList(request, response);
                break;
            case "/api/products-by-category":
                handleProductsByCategory(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getLoggedUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String path = request.getServletPath();

        switch (path) {
            case "/transaction/add":
                if (!Validator.hasRole(user.getRoleId(), Constant.TX_CREATE_ROLES)) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleAdd(request, response, user);
                break;
            case "/transaction/edit":
                if (!Validator.hasRole(user.getRoleId(), Constant.TX_CREATE_ROLES)) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleEdit(request, response, user);
                break;
            case "/transaction/approve":
                if (user.getRoleId() != Constant.ROLE_MANAGER) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleApprove(request, response, user);
                break;
            case "/transaction/reject":
                if (user.getRoleId() != Constant.ROLE_MANAGER) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleReject(request, response, user);
                break;
        }
    }

    private User getLoggedUser(HttpServletRequest req) {
        return (User) req.getSession().getAttribute(Constant.SESSION_ACCOUNT);
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        String search = request.getParameter("search");
        Integer type = parseIntOrNull(request.getParameter("type"));
        Integer approvalStatus = null;

        // Business Owner: only see approved
        if (user.getRoleId() == Constant.ROLE_BUSINESS_OWNER) {
            approvalStatus = Constant.APPROVAL_APPROVED;
        } else {
            approvalStatus = parseIntOrNull(request.getParameter("approvalStatus"));
        }

        int page = parsePage(request);
        InventoryTransactionDAO dao = new InventoryTransactionDAO();
        int total = dao.getTotalTransactions(search, type, approvalStatus);
        List<InventoryTransaction> list = dao.getAllTransactions(search, type, approvalStatus, page, Constant.PAGE_SIZE);

        // Set partner names
        for (InventoryTransaction t : list) {
            if (t.getPartnerId() > 0) {
                t.setPartnerName(Constant.PARTNER_LIST.getOrDefault(t.getPartnerId(), ""));
            }
        }

        request.setAttribute("transactions", list);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) total / Constant.PAGE_SIZE));
        request.setAttribute("search", search);
        request.setAttribute("filterType", type);
        request.setAttribute("filterApprovalStatus", approvalStatus);
        request.getRequestDispatcher("/views/transaction/list-transaction.jsp").forward(request, response);
    }

    private void handleApprovalList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        Integer type = parseIntOrNull(request.getParameter("type"));
        int page = parsePage(request);

        InventoryTransactionDAO dao = new InventoryTransactionDAO();
        int total = dao.getTotalTransactions(search, type, Constant.APPROVAL_PENDING);
        List<InventoryTransaction> list = dao.getAllTransactions(search, type, Constant.APPROVAL_PENDING, page, Constant.PAGE_SIZE);

        for (InventoryTransaction t : list) {
            if (t.getPartnerId() > 0) {
                t.setPartnerName(Constant.PARTNER_LIST.getOrDefault(t.getPartnerId(), ""));
            }
        }

        request.setAttribute("transactions", list);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) total / Constant.PAGE_SIZE));
        request.setAttribute("search", search);
        request.setAttribute("filterType", type);
        request.getRequestDispatcher("/views/transaction/list-approval.jsp").forward(request, response);
    }

    private void handleDetails(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        int id = parseId(request);
        InventoryTransactionDAO txDao = new InventoryTransactionDAO();
        InventoryTransaction tx = txDao.getTransactionById(id);
        if (tx == null) {
            redirect(response, request, "/transaction/list", null, "Không tìm thấy phiếu.");
            return;
        }

        TransactionDetailDAO detailDao = new TransactionDetailDAO();
        List<TransactionDetail> details = detailDao.getDetailsByTransactionId(id);

        // Check if date is closed (for approve/reject button visibility)
        boolean dateClosed = false;
        if (tx.getTransactionDate() != null) {
            java.sql.Date txDate = new java.sql.Date(tx.getTransactionDate().getTime());
            DailyClosingDAO dcDao = new DailyClosingDAO();
            dateClosed = dcDao.isDateClosedForTransaction(tx.getFromWarehouseId(), tx.getToWarehouseId(), txDate);
        }

        request.setAttribute("tx", tx);
        request.setAttribute("details", details);
        request.setAttribute("dateClosed", dateClosed);
        request.getRequestDispatcher("/views/transaction/view-transaction-details.jsp").forward(request, response);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        int typeInt = Integer.parseInt(request.getParameter("transactionType"));
        String dateStr = request.getParameter("transactionDate");
        String fromWhStr = request.getParameter("fromWarehouseId");
        String toWhStr = request.getParameter("toWarehouseId");
        String partnerIdStr = request.getParameter("partnerId");

        List<String> errors = new ArrayList<>();
        if (typeInt < 1 || typeInt > 3) {
            errors.add("Loại phiếu không hợp lệ.");
        }
        if (dateStr == null || dateStr.isEmpty()) {
            errors.add("Vui lòng chọn ngày giao dịch.");
        }

        int fromWh = parseIntSafe(fromWhStr);
        int toWh = parseIntSafe(toWhStr);
        int partnerId = parseIntSafe(partnerIdStr);

        // Validate warehouse based on type
        if (typeInt == Constant.TX_TYPE_IMPORT && toWh <= 0) {
            errors.add("Phiếu nhập cần chọn kho đến.");
        }
        if (typeInt == Constant.TX_TYPE_EXPORT && fromWh <= 0) {
            errors.add("Phiếu xuất cần chọn kho từ.");
        }
        if (typeInt == Constant.TX_TYPE_TRANSFER) {
            if (fromWh <= 0 || toWh <= 0) {
                errors.add("Phiếu chuyển cần chọn cả kho từ và kho đến.");
            }
            if (fromWh > 0 && fromWh == toWh) {
                errors.add("Kho từ và kho đến phải khác nhau.");
            }
        }

        // Parse details
        String[] productIds = request.getParameterValues("productId");
        String[] quantities = request.getParameterValues("quantity");
        String[] prices = request.getParameterValues("price");

        List<TransactionDetail> details = new ArrayList<>();
        if (productIds == null || productIds.length == 0) {
            errors.add("Vui lòng thêm ít nhất một sản phẩm.");
        } else {
            for (int i = 0; i < productIds.length; i++) {
                TransactionDetail d = new TransactionDetail();
                try {
                    d.setProductId(Integer.parseInt(productIds[i]));
                    d.setQuantity(new BigDecimal(quantities[i]));
                    if (d.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                        errors.add("Số lượng phải lớn hơn 0.");
                        break;
                    }
                    if (prices != null && i < prices.length && prices[i] != null && !prices[i].isEmpty()) {
                        d.setPrice(new BigDecimal(prices[i]));
                    }
                    details.add(d);
                } catch (Exception e) {
                    errors.add("Dữ liệu sản phẩm dòng " + (i + 1) + " không hợp lệ.");
                    break;
                }
            }
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("transactionType", typeInt);
            request.setAttribute("transactionDate", dateStr);
            request.setAttribute("fromWarehouseId", fromWhStr);
            request.setAttribute("toWarehouseId", toWhStr);
            request.setAttribute("partnerId", partnerIdStr);
            prepareFormData(request);
            request.getRequestDispatcher("/views/transaction/add-transaction.jsp").forward(request, response);
            return;
        }

        // Create transaction
        InventoryTransactionDAO txDao = new InventoryTransactionDAO();
        InventoryTransaction tx = new InventoryTransaction();
        tx.setTransactionCode(txDao.generateTransactionCode(typeInt));
        tx.setTransactionType(typeInt);
        tx.setTransactionDate(Timestamp.valueOf(dateStr + " 00:00:00"));
        tx.setFromWarehouseId(fromWh);
        tx.setToWarehouseId(toWh);
        tx.setPartnerId(partnerId);
        tx.setCreatedBy(user.getUserId());

        int txId = txDao.createTransaction(tx);
        if (txId > 0) {
            TransactionDetailDAO detailDao = new TransactionDetailDAO();
            for (TransactionDetail d : details) {
                d.setTransactionId(txId);
                d.setCreatedBy(user.getUserId());
                detailDao.insertDetail(d);
            }
            redirect(response, request, "/transaction/list", "Tạo phiếu thành công!", null);
        } else {
            request.setAttribute("errors", List.of("Lỗi khi tạo phiếu."));
            prepareFormData(request);
            request.getRequestDispatcher("/views/transaction/add-transaction.jsp").forward(request, response);
        }
    }

    private void handleShowEdit(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        int id = parseId(request);
        InventoryTransactionDAO txDao = new InventoryTransactionDAO();
        InventoryTransaction tx = txDao.getTransactionById(id);
        if (tx == null) {
            redirect(response, request, "/transaction/list", null, "Không tìm thấy phiếu.");
            return;
        }
        if (tx.getApprovalStatus() != Constant.APPROVAL_PENDING) {
            redirect(response, request, "/transaction/list", null, "Không thể chỉnh sửa phiếu đã được duyệt/từ chối.");
            return;
        }

        TransactionDetailDAO detailDao = new TransactionDetailDAO();
        List<TransactionDetail> details = detailDao.getDetailsByTransactionId(id);

        request.setAttribute("tx", tx);
        request.setAttribute("details", details);
        prepareFormData(request);
        request.getRequestDispatcher("/views/transaction/edit-transaction.jsp").forward(request, response);
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        int txId = Integer.parseInt(request.getParameter("transactionId"));
        InventoryTransactionDAO txDao = new InventoryTransactionDAO();
        InventoryTransaction existing = txDao.getTransactionById(txId);

        if (existing == null || existing.getApprovalStatus() != Constant.APPROVAL_PENDING) {
            redirect(response, request, "/transaction/list", null, "Không thể chỉnh sửa phiếu đã được duyệt/từ chối.");
            return;
        }

        int typeInt = Integer.parseInt(request.getParameter("transactionType"));
        String dateStr = request.getParameter("transactionDate");
        String fromWhStr = request.getParameter("fromWarehouseId");
        String toWhStr = request.getParameter("toWarehouseId");
        String partnerIdStr = request.getParameter("partnerId");
        String notes = request.getParameter("notes");

        List<String> errors = new ArrayList<>();
        if (typeInt < 1 || typeInt > 3) {
            errors.add("Loại phiếu không hợp lệ.");
        }
        if (dateStr == null || dateStr.isEmpty()) {
            errors.add("Vui lòng chọn ngày giao dịch.");
        }

        int fromWh = parseIntSafe(fromWhStr);
        int toWh = parseIntSafe(toWhStr);
        int partnerId = parseIntSafe(partnerIdStr);

        if (typeInt == Constant.TX_TYPE_IMPORT && toWh <= 0) {
            errors.add("Phiếu nhập cần chọn kho đến.");
        }
        if (typeInt == Constant.TX_TYPE_EXPORT && fromWh <= 0) {
            errors.add("Phiếu xuất cần chọn kho từ.");
        }
        if (typeInt == Constant.TX_TYPE_TRANSFER) {
            if (fromWh <= 0 || toWh <= 0) {
                errors.add("Phiếu chuyển cần chọn cả kho từ và kho đến.");
            }
            if (fromWh > 0 && fromWh == toWh) {
                errors.add("Kho từ và kho đến phải khác nhau.");
            }
        }

        String[] productIds = request.getParameterValues("productId");
        String[] quantities = request.getParameterValues("quantity");
        String[] prices = request.getParameterValues("price");

        List<TransactionDetail> details = new ArrayList<>();
        if (productIds == null || productIds.length == 0) {
            errors.add("Vui lòng thêm ít nhất một sản phẩm.");
        } else {
            for (int i = 0; i < productIds.length; i++) {
                TransactionDetail d = new TransactionDetail();
                try {
                    d.setProductId(Integer.parseInt(productIds[i]));
                    d.setQuantity(new BigDecimal(quantities[i]));
                    if (d.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                        errors.add("Số lượng phải lớn hơn 0.");
                        break;
                    }
                    if (prices != null && i < prices.length && prices[i] != null && !prices[i].isEmpty()) {
                        d.setPrice(new BigDecimal(prices[i]));
                    }
                    details.add(d);
                } catch (Exception e) {
                    errors.add("Dữ liệu sản phẩm dòng " + (i + 1) + " không hợp lệ.");
                    break;
                }
            }
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            existing.setTransactionType(typeInt);
            existing.setFromWarehouseId(fromWh);
            existing.setToWarehouseId(toWh);
            existing.setPartnerId(partnerId);
            existing.setNotes(notes);
            request.setAttribute("tx", existing);
            request.setAttribute("details", details);
            prepareFormData(request);
            request.getRequestDispatcher("/views/transaction/edit-transaction.jsp").forward(request, response);
            return;
        }

        InventoryTransaction tx = new InventoryTransaction();
        tx.setTransactionId(txId);
        tx.setTransactionType(typeInt);
        tx.setTransactionDate(Timestamp.valueOf(dateStr + " 00:00:00"));
        tx.setFromWarehouseId(fromWh);
        tx.setToWarehouseId(toWh);
        tx.setPartnerId(partnerId);
        tx.setNotes(notes != null && !notes.trim().isEmpty() ? notes.trim() : null);
        tx.setUpdatedBy(user.getUserId());

        if (txDao.updateTransaction(tx)) {
            // Delete old details and re-insert
            TransactionDetailDAO detailDao = new TransactionDetailDAO();
            detailDao.deleteDetailsByTransactionId(txId);
            for (TransactionDetail d : details) {
                d.setTransactionId(txId);
                d.setCreatedBy(user.getUserId());
                detailDao.insertDetail(d);
            }
            redirect(response, request, "/transaction/list", "Cập nhật phiếu thành công!", null);
        } else {
            request.setAttribute("errors", List.of("Lỗi khi cập nhật."));
            request.setAttribute("tx", existing);
            prepareFormData(request);
            request.getRequestDispatcher("/views/transaction/edit-transaction.jsp").forward(request, response);
        }
    }

    private void handleApprove(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        int txId = parseId(request);
        InventoryTransactionDAO txDao = new InventoryTransactionDAO();
        InventoryTransaction tx = txDao.getTransactionById(txId);

        if (tx == null || tx.getApprovalStatus() != Constant.APPROVAL_PENDING) {
            redirect(response, request, "/transaction/approval-list", null, "Phiếu không ở trạng thái chờ duyệt.");
            return;
        }

        // Check daily closing
        java.sql.Date txDate = new java.sql.Date(tx.getTransactionDate().getTime());
        DailyClosingDAO dcDao = new DailyClosingDAO();
        if (dcDao.isDateClosedForTransaction(tx.getFromWarehouseId(), tx.getToWarehouseId(), txDate)) {
            redirect(response, request, "/transaction/details?id=" + txId, null,
                    "Ngày giao dịch đã được chốt sổ. Không thể duyệt phiếu.");
            return;
        }

        // Apply inventory balance update
        TransactionDetailDAO detailDao = new TransactionDetailDAO();
        List<TransactionDetail> details = detailDao.getDetailsByTransactionId(txId);
        InventoryBalanceDAO balanceDao = new InventoryBalanceDAO();
        String balanceError = null;

        switch (tx.getTransactionType()) {
            case Constant.TX_TYPE_IMPORT:
                balanceError = balanceDao.applyImport(tx.getToWarehouseId(), details, user.getUserId());
                break;
            case Constant.TX_TYPE_EXPORT:
                balanceError = balanceDao.applyExport(tx.getFromWarehouseId(), details, user.getUserId());
                break;
            case Constant.TX_TYPE_TRANSFER:
                balanceError = balanceDao.applyTransfer(tx.getFromWarehouseId(), tx.getToWarehouseId(), details, user.getUserId());
                break;
        }

        if (balanceError != null) {
            redirect(response, request, "/transaction/details?id=" + txId, null, balanceError);
            return;
        }

        txDao.approveTransaction(txId, user.getUserId());
        redirect(response, request, "/transaction/details?id=" + txId, "Đã duyệt phiếu thành công!", null);
    }

    private void handleReject(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        int txId = parseId(request);
        InventoryTransactionDAO txDao = new InventoryTransactionDAO();
        InventoryTransaction tx = txDao.getTransactionById(txId);

        if (tx == null || tx.getApprovalStatus() != Constant.APPROVAL_PENDING) {
            redirect(response, request, "/transaction/approval-list", null, "Phiếu không ở trạng thái chờ duyệt.");
            return;
        }

        // Check daily closing
        java.sql.Date txDate = new java.sql.Date(tx.getTransactionDate().getTime());
        DailyClosingDAO dcDao = new DailyClosingDAO();
        if (dcDao.isDateClosedForTransaction(tx.getFromWarehouseId(), tx.getToWarehouseId(), txDate)) {
            redirect(response, request, "/transaction/details?id=" + txId, null,
                    "Ngày giao dịch đã được chốt sổ. Không thể từ chối phiếu.");
            return;
        }

        txDao.rejectTransaction(txId, user.getUserId());
        redirect(response, request, "/transaction/details?id=" + txId, "Đã từ chối phiếu.", null);
    }

    private void handleProductsByCategory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String catIdStr = request.getParameter("categoryId");
        StringBuilder json = new StringBuilder("[");
        if (catIdStr != null && !catIdStr.isEmpty()) {
            ProductDAO dao = new ProductDAO();
            var products = dao.getProductsByCategoryForDropdown(Integer.parseInt(catIdStr));
            for (int i = 0; i < products.size(); i++) {
                var p = products.get(i);
                if (i > 0) {
                    json.append(",");
                }
                json.append("{\"productId\":").append(p.getProductId())
                        .append(",\"productCode\":\"").append(escapeJson(p.getProductCode())).append("\"")
                        .append(",\"productName\":\"").append(escapeJson(p.getProductName())).append("\"")
                        .append(",\"unit\":\"").append(escapeJson(p.getUnit() != null ? p.getUnit() : "")).append("\"")
                        .append("}");
            }
        }
        json.append("]");
        try (PrintWriter pw = response.getWriter()) {
            pw.print(json.toString());
        }
    }

    private void prepareFormData(HttpServletRequest request) {
        request.setAttribute("warehouses", new WarehouseDAO().getAllActiveWarehouses());
        request.setAttribute("categories", new CategoryDAO().getAllCategoriesForDropdown());
        request.setAttribute("partnerList", Constant.PARTNER_LIST);
    }

    private int parseId(HttpServletRequest req) {
        try {
            return Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            return 0;
        }
    }

    private int parsePage(HttpServletRequest req) {
        try {
            int p = Integer.parseInt(req.getParameter("page"));
            return p < 1 ? 1 : p;
        } catch (Exception e) {
            return 1;
        }
    }

    private Integer parseIntOrNull(String s) {
        try {
            return s != null && !s.isEmpty() ? Integer.parseInt(s) : null;
        } catch (Exception e) {
            return null;
        }
    }

    private int parseIntSafe(String s) {
        try {
            return s != null && !s.isEmpty() ? Integer.parseInt(s) : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    private String escapeJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }

    private void redirect(HttpServletResponse res, HttpServletRequest req, String path, String success, String error) throws IOException {
        String base = req.getContextPath() + path;
        try {
            if (path.contains("?")) {
                base += "&";
            } else {
                base += "?";
            }
            if (success != null) {
                res.sendRedirect(base + "success=" + URLEncoder.encode(success, "UTF-8"));
            } else {
                res.sendRedirect(base + "error=" + URLEncoder.encode(error, "UTF-8"));
            }
        } catch (Exception e) {
            res.sendRedirect(req.getContextPath() + path);
        }
    }
}
