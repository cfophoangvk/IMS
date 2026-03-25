package controller;

import dal.*;
import java.io.IOException;
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
    "/transaction/approval-list"
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
                prepareFormData(request, user);
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

        if (user.getRoleId() == Constant.ROLE_BUSINESS_OWNER) {
            approvalStatus = Constant.APPROVAL_APPROVED;
        } else {
            approvalStatus = parseIntOrNull(request.getParameter("approvalStatus"));
        }

        int page = parsePage(request);
        InventoryTransactionDAO dao = new InventoryTransactionDAO();
        int total = dao.getTotalTransactions(search, type, approvalStatus);
        List<InventoryTransaction> list = dao.getAllTransactions(search, type, approvalStatus, page, Constant.PAGE_SIZE);

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
        String direction = request.getParameter("direction"); // "import", "export"
        String source = request.getParameter("source");       // "supplier", "internal"
        String dateStr = request.getParameter("transactionDate");
        String otherWhStr = request.getParameter("otherWarehouseId");
        String partnerIdStr = request.getParameter("partnerId");

        List<String> errors = new ArrayList<>();

        boolean isImport = "import".equals(direction);
        boolean isInternal = "internal".equals(source);

        if (direction == null || (!direction.equals("import") && !direction.equals("export"))) {
            errors.add("Vui lòng chọn hướng giao dịch (Nhập/Xuất).");
        }
        if (source == null || (!source.equals("supplier") && !source.equals("internal"))) {
            errors.add("Vui lòng chọn nguồn giao dịch (Nhà cung cấp/Nội bộ).");
        }
        if (dateStr == null || dateStr.isEmpty()) {
            errors.add("Vui lòng chọn ngày giao dịch.");
        }

        int userWarehouseId = user.getWarehouseId();
        int otherWh = parseIntSafe(otherWhStr);
        int partnerId = parseIntSafe(partnerIdStr);

        if (userWarehouseId <= 0) {
            errors.add("Tài khoản chưa được gán kho. Vui lòng liên hệ quản trị viên.");
        }
        if (isInternal && otherWh <= 0) {
            errors.add("Vui lòng chọn kho để chuyển.");
        }
        if (isInternal && otherWh > 0 && otherWh == userWarehouseId) {
            errors.add("Kho chuyển phải khác kho hiện tại.");
        }

        int typeInt;
        int fromWh, toWh;
        if (isImport && !isInternal) {
            typeInt = Constant.TX_IMPORT_SUPPLIER;
            fromWh = 0;
            toWh = userWarehouseId;
        } else if (!isImport && !isInternal) {
            typeInt = Constant.TX_EXPORT_SUPPLIER;
            fromWh = userWarehouseId;
            toWh = 0;
        } else if (isImport && isInternal) {
            typeInt = Constant.TX_IMPORT_INTERNAL;
            fromWh = otherWh;
            toWh = userWarehouseId;
        } else {
            typeInt = Constant.TX_EXPORT_INTERNAL;
            fromWh = userWarehouseId;
            toWh = otherWh;
        }

        if (errors.isEmpty()) {
            DailyClosingDAO dcDao = new DailyClosingDAO();
            java.sql.Date sqlDate = java.sql.Date.valueOf(dateStr);
            if (dcDao.isDateClosedForTransaction(fromWh, toWh, sqlDate)) {
                errors.add("Không thể thêm phiếu: Ngày giao dịch đã chốt sổ ở kho tương ứng.");
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

        if (errors.isEmpty() && !details.isEmpty()) {
            InventoryBalanceDAO balanceDao = new InventoryBalanceDAO();
            String stockError = null;
            if (!isImport && !isInternal) {
                // Xuất - Nhà cung cấp: check kho hiện tại
                stockError = balanceDao.checkStockForDetails(userWarehouseId, details);
            } else if (isImport && isInternal) {
                // Nhập - Nội bộ: check kho bên kia
                stockError = balanceDao.checkStockForDetails(otherWh, details);
            } else if (!isImport && isInternal) {
                // Xuất - Nội bộ: check kho hiện tại
                stockError = balanceDao.checkStockForDetails(userWarehouseId, details);
            }
            if (stockError != null) {
                errors.add(stockError);
            }
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("direction", direction);
            request.setAttribute("source", source);
            request.setAttribute("transactionDate", dateStr);
            request.setAttribute("otherWarehouseId", otherWhStr);
            request.setAttribute("partnerId", partnerIdStr);
            prepareFormData(request, user);
            request.getRequestDispatcher("/views/transaction/add-transaction.jsp").forward(request, response);
            return;
        }

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
            prepareFormData(request, user);
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
        prepareFormData(request, user);
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

        String direction = request.getParameter("direction");
        String source = request.getParameter("source");
        String dateStr = request.getParameter("transactionDate");
        String otherWhStr = request.getParameter("otherWarehouseId");
        String partnerIdStr = request.getParameter("partnerId");
        String notes = request.getParameter("notes");

        List<String> errors = new ArrayList<>();

        boolean isImport = "import".equals(direction);
        boolean isInternal = "internal".equals(source);

        if (direction == null || (!direction.equals("import") && !direction.equals("export"))) {
            errors.add("Vui lòng chọn hướng giao dịch (Nhập/Xuất).");
        }
        if (source == null || (!source.equals("supplier") && !source.equals("internal"))) {
            errors.add("Vui lòng chọn nguồn giao dịch (Nhà cung cấp/Nội bộ).");
        }
        if (dateStr == null || dateStr.isEmpty()) {
            errors.add("Vui lòng chọn ngày giao dịch.");
        }

        int userWarehouseId = user.getWarehouseId();
        int otherWh = parseIntSafe(otherWhStr);
        int partnerId = parseIntSafe(partnerIdStr);

        if (userWarehouseId <= 0) {
            errors.add("Tài khoản chưa được gán kho. Vui lòng liên hệ quản trị viên.");
        }
        if (isInternal && otherWh <= 0) {
            errors.add("Vui lòng chọn kho để chuyển.");
        }
        if (isInternal && otherWh > 0 && otherWh == userWarehouseId) {
            errors.add("Kho chuyển phải khác kho hiện tại.");
        }

        int typeInt;
        int fromWh, toWh;
        if (isImport && !isInternal) {
            typeInt = Constant.TX_IMPORT_SUPPLIER;
            fromWh = 0;
            toWh = userWarehouseId;
        } else if (!isImport && !isInternal) {
            typeInt = Constant.TX_EXPORT_SUPPLIER;
            fromWh = userWarehouseId;
            toWh = 0;
        } else if (isImport && isInternal) {
            typeInt = Constant.TX_IMPORT_INTERNAL;
            fromWh = otherWh;
            toWh = userWarehouseId;
        } else {
            typeInt = Constant.TX_EXPORT_INTERNAL;
            fromWh = userWarehouseId;
            toWh = otherWh;
        }

        if (errors.isEmpty()) {
            DailyClosingDAO dcDao = new DailyClosingDAO();
            java.sql.Date sqlDate = java.sql.Date.valueOf(dateStr);
            if (dcDao.isDateClosedForTransaction(fromWh, toWh, sqlDate)) {
                errors.add("Không thể lưu: Ngày giao dịch đã chốt sổ ở kho tương ứng.");
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

        if (errors.isEmpty() && !details.isEmpty()) {
            InventoryBalanceDAO balanceDao = new InventoryBalanceDAO();
            String stockError = null;
            if (!isImport && !isInternal) {
                stockError = balanceDao.checkStockForDetails(userWarehouseId, details);
            } else if (isImport && isInternal) {
                stockError = balanceDao.checkStockForDetails(otherWh, details);
            } else if (!isImport && isInternal) {
                stockError = balanceDao.checkStockForDetails(userWarehouseId, details);
            }
            if (stockError != null) {
                errors.add(stockError);
            }
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("direction", direction);
            request.setAttribute("source", source);
            request.setAttribute("otherWarehouseId", otherWhStr);
            existing.setPartnerId(partnerId);
            existing.setNotes(notes);
            request.setAttribute("tx", existing);
            request.setAttribute("details", details);
            prepareFormData(request, user);
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
            prepareFormData(request, user);
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

        java.sql.Date txDate = new java.sql.Date(tx.getTransactionDate().getTime());
        DailyClosingDAO dcDao = new DailyClosingDAO();
        if (dcDao.isDateClosedForTransaction(tx.getFromWarehouseId(), tx.getToWarehouseId(), txDate)) {
            redirect(response, request, "/transaction/details?id=" + txId, null,
                    "Ngày giao dịch đã được chốt sổ. Không thể duyệt phiếu.");
            return;
        }

        TransactionDetailDAO detailDao = new TransactionDetailDAO();
        List<TransactionDetail> details = detailDao.getDetailsByTransactionId(txId);
        InventoryBalanceDAO balanceDao = new InventoryBalanceDAO();
        String balanceError = null;

        switch (tx.getTransactionType()) {
            case Constant.TX_IMPORT_SUPPLIER:
                balanceError = balanceDao.applyImport(tx.getToWarehouseId(), details, user.getUserId());
                break;
            case Constant.TX_EXPORT_SUPPLIER:
                balanceError = balanceDao.applyExport(tx.getFromWarehouseId(), details, user.getUserId());
                break;
            case Constant.TX_IMPORT_INTERNAL:
                balanceError = balanceDao.applyTransfer(tx.getToWarehouseId(), tx.getFromWarehouseId(), details, user.getUserId());
                break;
            case Constant.TX_EXPORT_INTERNAL:
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

    private void prepareFormData(HttpServletRequest request, User user) {
        request.setAttribute("warehouses", new WarehouseDAO().getAllActiveWarehouses());
        request.setAttribute("categories", new CategoryDAO().getAllCategoriesForDropdown());
        request.setAttribute("partnerList", Constant.PARTNER_LIST);
        request.setAttribute("userWarehouseId", user.getWarehouseId());
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
