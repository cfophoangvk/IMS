package controller;

import dal.DashboardDAO;
import dal.WarehouseDAO;
import java.io.IOException;
import java.text.SimpleDateFormat;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import util.Constant;

@WebServlet(name = "DashboardServlet", urlPatterns = {
    "/dashboard/it-admin",
    "/dashboard/system-admin",
    "/dashboard/manager",
    "/dashboard/business-owner"
})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute(Constant.SESSION_ACCOUNT);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String path = request.getServletPath();
        DashboardDAO dao = new DashboardDAO();

        switch (path) {
            case "/dashboard/it-admin":
                if (user.getRoleId() != Constant.ROLE_IT_ADMIN) { response.sendRedirect(request.getContextPath() + "/dashboard/it-admin"); return; }
                handleITAdmin(request, response, dao);
                break;
            case "/dashboard/system-admin":
                if (user.getRoleId() != Constant.ROLE_SYSTEM_ADMIN) { response.sendRedirect(request.getContextPath() + "/dashboard/system-admin"); return; }
                handleSystemAdmin(request, response, dao);
                break;
            case "/dashboard/manager":
                if (user.getRoleId() != Constant.ROLE_MANAGER) { response.sendRedirect(request.getContextPath() + "/dashboard/manager"); return; }
                handleManager(request, response, dao, user);
                break;
            case "/dashboard/business-owner":
                if (user.getRoleId() != Constant.ROLE_BUSINESS_OWNER) { response.sendRedirect(request.getContextPath() + "/dashboard/business-owner"); return; }
                handleBusinessOwner(request, response, dao);
                break;
        }
    }

    private void handleITAdmin(HttpServletRequest req, HttpServletResponse res, DashboardDAO dao)
            throws ServletException, IOException {
        req.setAttribute("totalUsers", dao.getTotalUsers());
        req.setAttribute("activeUsers", dao.getActiveUsers());
        req.setAttribute("lockedUsers", dao.getLockedUsers());
        req.setAttribute("firstLoginUsers", dao.getFirstLoginUsers());
        req.setAttribute("unassignedUsers", dao.getUnassignedUsers());
        req.setAttribute("recentUsers", dao.getRecentUsers(10));
        req.getRequestDispatcher("/views/dashboard/it-admin-dashboard.jsp").forward(req, res);
    }

    private void handleSystemAdmin(HttpServletRequest req, HttpServletResponse res, DashboardDAO dao)
            throws ServletException, IOException {
        req.setAttribute("totalProducts", dao.getTotalProducts());
        req.setAttribute("totalCategories", dao.getTotalCategories());
        req.setAttribute("totalWarehouses", dao.getTotalWarehouses());
        req.setAttribute("productsByCategory", dao.getProductCountByCategory());
        req.setAttribute("recentProducts", dao.getRecentProducts(10));
        req.getRequestDispatcher("/views/dashboard/system-admin-dashboard.jsp").forward(req, res);
    }

    private void handleBusinessOwner(HttpServletRequest req, HttpServletResponse res, DashboardDAO dao)
            throws ServletException, IOException {
        req.setAttribute("totalStock", dao.getTotalStockQuantity());
        req.setAttribute("monthlyImport", dao.getMonthlyImportQuantity());
        req.setAttribute("monthlyExport", dao.getMonthlyExportQuantity());
        req.setAttribute("stockByWarehouse", dao.getStockByWarehouse());
        req.setAttribute("dailyTrend", dao.getDailyImportExport(30));
        req.setAttribute("topExported", dao.getTopExportedProducts(5));
        req.setAttribute("topStock", dao.getTopStockProducts(5));
        req.setAttribute("oldPendingCount", dao.getOldPendingTransactionCount());
        req.getRequestDispatcher("/views/dashboard/business-owner-dashboard.jsp").forward(req, res);
    }

    private void handleManager(HttpServletRequest req, HttpServletResponse res, DashboardDAO dao, User user)
            throws ServletException, IOException {
        int wId = user.getWarehouseId();
        String whName = new WarehouseDAO().getWarehouseNameById(wId);

        req.setAttribute("warehouseName", whName);
        req.setAttribute("warehouseStock", dao.getWarehouseStock(wId));
        req.setAttribute("pendingCount", dao.getPendingCountForWarehouse(wId));
        req.setAttribute("todayImport", dao.getTodayImportQuantity(wId));
        req.setAttribute("todayExport", dao.getTodayExportQuantity(wId));
        req.setAttribute("todayClosed", dao.isTodayClosed(wId));
        req.setAttribute("todayDate", new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()));
        req.setAttribute("lowStockProducts", dao.getLowStockProducts(wId, 10));
        req.setAttribute("outOfStockProducts", dao.getOutOfStockProducts(wId));
        req.setAttribute("pendingTransactions", dao.getPendingTransactions(wId));
        req.setAttribute("recentApproved", dao.getRecentApprovedTransactions(wId, 5));
        req.getRequestDispatcher("/views/dashboard/manager-dashboard.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
