package controller;

import dal.DailyClosingDAO;
import dal.WarehouseDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.DailyClosing;
import model.User;
import util.Constant;

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
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String path = request.getServletPath();
        switch (path) {
            case "/daily-closing/list":
                handleList(request, response);
                break;
            case "/daily-closing/add":
                handleShowAdd(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getLoggedUser(request);
        if (user == null || user.getRoleId() != Constant.ROLE_MANAGER) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
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

    private void handleList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer warehouseId = parseIntOrNull(request.getParameter("warehouseId"));
        int page = parsePage(request);

        DailyClosingDAO dao = new DailyClosingDAO();
        int total = dao.getTotalClosings(warehouseId);
        List<DailyClosing> closings = dao.getAllClosings(warehouseId, page, Constant.PAGE_SIZE);

        request.setAttribute("closings", closings);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) total / Constant.PAGE_SIZE));
        request.setAttribute("filterWarehouseId", warehouseId);
        request.setAttribute("warehouses", new WarehouseDAO().getAllActiveWarehouses());
        request.getRequestDispatcher("/views/daily-closing/list-daily-closing.jsp").forward(request, response);
    }

    private void handleShowAdd(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("warehouses", new WarehouseDAO().getAllActiveWarehouses());

        // If warehouse and date selected, load history
        String whStr = request.getParameter("warehouseId");
        String dateStr = request.getParameter("closingDate");

        if (whStr != null && !whStr.isEmpty() && dateStr != null && !dateStr.isEmpty()) {
            int warehouseId = Integer.parseInt(whStr);
            java.sql.Date date = java.sql.Date.valueOf(dateStr);
            DailyClosingDAO dao = new DailyClosingDAO();
            List<DailyClosing> history = dao.getClosingsByDate(warehouseId, date);
            request.setAttribute("history", history);
            request.setAttribute("historyCount", history.size());
            request.setAttribute("selectedWarehouseId", warehouseId);
            request.setAttribute("selectedDate", dateStr);
        }

        request.getRequestDispatcher("/views/daily-closing/add-daily-closing.jsp").forward(request, response);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String whStr = request.getParameter("warehouseId");
        String dateStr = request.getParameter("closingDate");

        if (whStr == null || whStr.isEmpty() || dateStr == null || dateStr.isEmpty()) {
            redirect(response, request, "/daily-closing/add", null, "Vui lòng chọn kho và ngày.");
            return;
        }

        int warehouseId = Integer.parseInt(whStr);
        java.sql.Date date = java.sql.Date.valueOf(dateStr);

        DailyClosingDAO dao = new DailyClosingDAO();

        // Count products in warehouse
        int totalProducts = dao.countProductsInWarehouse(warehouseId);

        DailyClosing dc = new DailyClosing();
        dc.setWarehouseId(warehouseId);
        dc.setClosingDate(date);
        dc.setTotalProducts(totalProducts);
        dc.setCreatedBy(user.getUserId());

        int id = dao.createClosing(dc);
        if (id > 0) {
            redirect(response, request, "/daily-closing/list", "Chốt sổ thành công!", null);
        } else {
            redirect(response, request, "/daily-closing/add", null, "Lỗi khi chốt sổ.");
        }
    }

    private void handleToggle(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        int closingId = Integer.parseInt(request.getParameter("id"));
        new DailyClosingDAO().toggleClosed(closingId, user.getUserId());
        redirect(response, request, "/daily-closing/list", "Cập nhật trạng thái thành công!", null);
    }

    private Integer parseIntOrNull(String s) {
        try {
            return s != null && !s.isEmpty() ? Integer.parseInt(s) : null;
        } catch (Exception e) {
            return null;
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

    private void redirect(HttpServletResponse res, HttpServletRequest req, String path, String success, String error) throws IOException {
        String base = req.getContextPath() + path + "?";
        try {
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
