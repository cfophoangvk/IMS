package controller;

import dal.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.DailyClosing;
import model.InventoryTransaction;
import model.User;
import util.Constant;
import util.EmailService;

@WebServlet(name = "DailyClosingServlet", urlPatterns = {
    "/daily-closing/list",
    "/daily-closing/add",
    "/daily-closing/toggle"
})
public class DailyClosingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedUser(request);
        if (user == null || user.getRoleId() != Constant.ROLE_MANAGER) {
            request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
            return;
        }

        String path = request.getServletPath();
        switch (path) {
            case "/daily-closing/list":
                handleList(request, response, user);
                break;
            case "/daily-closing/add":
                handleShowAdd(request, response, user);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getLoggedUser(request);
        if (user == null || user.getRoleId() != Constant.ROLE_MANAGER) {
            request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
            return;
        }

        String path = request.getServletPath();
        switch (path) {
            case "/daily-closing/add":
                handleAdd(request, response, user);
                break;
            case "/daily-closing/toggle":
                handleToggle(request, response, user);
                break;
        }
    }

    private User getLoggedUser(HttpServletRequest req) {
        return (User) req.getSession().getAttribute(Constant.SESSION_ACCOUNT);
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        int warehouseId = user.getWarehouseId();
        int page = parsePage(request);

        DailyClosingDAO dao = new DailyClosingDAO();
        int total = dao.getTotalClosings(warehouseId);
        List<DailyClosing> closings = dao.getAllClosings(warehouseId, page, Constant.PAGE_SIZE);

        // Get warehouse name for display
        String warehouseName = new WarehouseDAO().getWarehouseNameById(warehouseId);

        request.setAttribute("closings", closings);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) total / Constant.PAGE_SIZE));
        request.setAttribute("warehouseName", warehouseName);
        request.getRequestDispatcher("/views/daily-closing/list-daily-closing.jsp").forward(request, response);
    }

    private void handleShowAdd(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        int warehouseId = user.getWarehouseId();
        String warehouseName = new WarehouseDAO().getWarehouseNameById(warehouseId);
        request.setAttribute("warehouseName", warehouseName);
        request.setAttribute("userWarehouseId", warehouseId);

        String dateStr = request.getParameter("closingDate");

        if (dateStr != null && !dateStr.isEmpty()) {
            java.sql.Date date = java.sql.Date.valueOf(dateStr);
            DailyClosingDAO dcDao = new DailyClosingDAO();
            request.setAttribute("selectedDate", dateStr);

            // Check if already closed (IsClosed = 1)
            boolean isClosed = dcDao.isDateClosed(warehouseId, date);
            request.setAttribute("isClosed", isClosed);

            if (isClosed) {
                // Already closed - show message
                request.setAttribute("closedMessage", "Đã chốt sổ ngày " + new SimpleDateFormat("dd/MM/yyyy").format(date));
            } else {
                // Not closed - show transactions and check for pending
                InventoryTransactionDAO txDao = new InventoryTransactionDAO();
                List<InventoryTransaction> transactions = txDao.getTransactionsByWarehouseAndDate(warehouseId, date);
                int pendingCount = txDao.countPendingByWarehouseAndDate(warehouseId, date);

                request.setAttribute("transactions", transactions);
                request.setAttribute("pendingCount", pendingCount);
            }
        }

        request.getRequestDispatcher("/views/daily-closing/add-daily-closing.jsp").forward(request, response);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        int warehouseId = user.getWarehouseId();
        String dateStr = request.getParameter("closingDate");

        if (dateStr == null || dateStr.isEmpty()) {
            redirect(response, request, "/daily-closing/add", null, "Vui lòng chọn ngày.");
            return;
        }

        java.sql.Date date = java.sql.Date.valueOf(dateStr);
        DailyClosingDAO dcDao = new DailyClosingDAO();

        // Check if already closed
        if (dcDao.isDateClosed(warehouseId, date)) {
            redirect(response, request, "/daily-closing/add", null, "Ngày này đã được chốt sổ.");
            return;
        }

        // Check for pending transactions
        InventoryTransactionDAO txDao = new InventoryTransactionDAO();
        int pendingCount = txDao.countPendingByWarehouseAndDate(warehouseId, date);
        if (pendingCount > 0) {
            redirect(response, request, "/daily-closing/add?closingDate=" + dateStr, null,
                    "Vẫn còn " + pendingCount + " phiếu chưa duyệt. Vui lòng duyệt hết trước khi chốt sổ.");
            return;
        }

        // Count products in warehouse
        int totalProducts = dcDao.countProductsInWarehouse(warehouseId);

        DailyClosing dc = new DailyClosing();
        dc.setWarehouseId(warehouseId);
        dc.setClosingDate(date);
        dc.setTotalProducts(totalProducts);
        dc.setCreatedBy(user.getUserId());

        int id = dcDao.createClosing(dc);
        if (id > 0) {
            // Send email notification to all employees in this warehouse
            String warehouseName = new WarehouseDAO().getWarehouseNameById(warehouseId);
            List<InventoryTransaction> transactions = txDao.getTransactionsByWarehouseAndDate(warehouseId, date);
            List<String> emails = new UserDAO().getEmployeeEmailsByWarehouse(warehouseId);
            String formattedDate = new SimpleDateFormat("dd/MM/yyyy").format(date);
            EmailService.sendDailyClosingNotification(emails, warehouseName, formattedDate, transactions);

            redirect(response, request, "/daily-closing/list", "Chốt sổ thành công! Email thông báo đã được gửi.", null);
        } else {
            redirect(response, request, "/daily-closing/add", null, "Lỗi khi chốt sổ.");
        }
    }

    private void handleToggle(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        int closingId = Integer.parseInt(request.getParameter("id"));
        new DailyClosingDAO().toggleClosed(closingId, user.getUserId());
        redirect(response, request, "/daily-closing/list", "Cập nhật trạng thái thành công!", null);
    }

    private int parsePage(HttpServletRequest req) {
        try {
            int p = Integer.parseInt(req.getParameter("page"));
            return p < 1 ? 1 : p;
        } catch (Exception e) {
            return 1;
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
