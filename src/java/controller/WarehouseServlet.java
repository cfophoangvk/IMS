package controller;

import dal.WarehouseDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import model.Warehouse;
import util.Constant;
import util.Validator;

@WebServlet(name = "WarehouseServlet", urlPatterns = {
    "/warehouse/list",
    "/warehouse/add",
    "/warehouse/edit",
    "/warehouse/toggle-status",
    "/warehouse/details",
    "/warehouse/members",
    "/warehouse/member/upsert",
    "/warehouse/member/remove"
})
public class WarehouseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkSystemAdmin(request, response)) {
            return;
        }
        String path = request.getServletPath();

        switch (path) {
            case "/warehouse/list":
                handleListWarehouses(request, response);
                break;
            case "/warehouse/add":
                request.getRequestDispatcher("/views/warehouse/add-warehouse.jsp").forward(request, response);
                break;
            case "/warehouse/edit":
                handleShowEditForm(request, response);
                break;
            case "/warehouse/details":
                handleViewDetails(request, response);
                break;
            case "/warehouse/members":
                handleViewMembers(request, response);
                break;
            case "/warehouse/member/upsert":
                handleShowUpsertMember(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!checkSystemAdmin(request, response)) {
            return;
        }
        String path = request.getServletPath();

        switch (path) {
            case "/warehouse/add":
                handleAddWarehouse(request, response);
                break;
            case "/warehouse/edit":
                handleEditWarehouse(request, response);
                break;
            case "/warehouse/toggle-status":
                handleToggleStatus(request, response);
                break;
            case "/warehouse/member/upsert":
                handleUpsertMember(request, response);
                break;
            case "/warehouse/member/remove":
                handleRemoveMember(request, response);
                break;
        }
    }

    private boolean checkSystemAdmin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = getLoggedUser(request);
        if (user == null || user.getRoleId() != Constant.ROLE_SYSTEM_ADMIN) {
            request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
            return false;
        }
        return true;
    }

    private User getLoggedUser(HttpServletRequest request) {
        return (User) request.getSession().getAttribute(Constant.SESSION_ACCOUNT);
    }

    private void handleListWarehouses(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception e) {
        }
        if (page < 1) {
            page = 1;
        }

        WarehouseDAO dao = new WarehouseDAO();
        List<Warehouse> warehouses = dao.getAllWarehouses(search, page, Constant.PAGE_SIZE);
        int total = dao.getTotalWarehouses(search);
        int totalPages = (int) Math.ceil((double) total / Constant.PAGE_SIZE);

        request.setAttribute("warehouses", warehouses);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("search", search);

        request.getRequestDispatcher("/views/warehouse/list-warehouse.jsp").forward(request, response);
    }

    private void handleAddWarehouse(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("warehouseCode").trim();
        String name = request.getParameter("warehouseName").trim();
        String location = request.getParameter("location").trim();

        if (location.isBlank()) {
            location = null;
        }

        List<String> errors = validateWarehouse(code, name, 0);

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("warehouseCode", code);
            request.setAttribute("warehouseName", name);
            request.setAttribute("location", location);
            request.getRequestDispatcher("/views/warehouse/add-warehouse.jsp").forward(request, response);
            return;
        }

        Warehouse w = new Warehouse();
        w.setWarehouseCode(code.trim());
        w.setWarehouseName(name.trim());
        w.setLocation(location != null ? location.trim() : null);
        w.setCreatedBy(getLoggedUser(request).getUserId());

        WarehouseDAO dao = new WarehouseDAO();
        int id = dao.createWarehouse(w);
        if (id > 0) {
            response.sendRedirect(request.getContextPath() + "/warehouse/list?success=" + URLEncoder.encode("Tạo kho hàng thành công!", "UTF-8"));
        } else {
            request.setAttribute("errors", List.of("Đã xảy ra lỗi khi tạo kho hàng."));
            request.setAttribute("warehouseCode", code);
            request.setAttribute("warehouseName", name);
            request.setAttribute("location", location);
            request.getRequestDispatcher("/views/warehouse/add-warehouse.jsp").forward(request, response);
        }
    }

    private void handleShowEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        WarehouseDAO dao = new WarehouseDAO();
        Warehouse w = dao.getWarehouseById(id);
        if (w == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/list?error=" + URLEncoder.encode("Không tìm thấy kho hàng.", "UTF-8"));
            return;
        }
        request.setAttribute("warehouse", w);
        request.getRequestDispatcher("/views/warehouse/edit-warehouse.jsp").forward(request, response);
    }

    private void handleEditWarehouse(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("warehouseId").trim());
        String name = request.getParameter("warehouseName").trim();
        String location = request.getParameter("location").trim();

        if (location.isBlank()) {
            location = null;
        }

        List<String> errors = new ArrayList<>();
        if (!Validator.isValidWarehouseName(name)) {
            errors.add("Tên kho hàng phải từ 2-100 ký tự.");
        }

        if (!errors.isEmpty()) {
            WarehouseDAO dao = new WarehouseDAO();
            Warehouse w = dao.getWarehouseById(id);
            w.setWarehouseName(name);
            w.setLocation(location);
            request.setAttribute("warehouse", w);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/views/warehouse/edit-warehouse.jsp").forward(request, response);
            return;
        }

        Warehouse w = new Warehouse();
        w.setWarehouseId(id);
        w.setWarehouseName(name.trim());
        w.setLocation(location != null ? location.trim() : null);
        w.setUpdatedBy(getLoggedUser(request).getUserId());

        WarehouseDAO dao = new WarehouseDAO();
        if (dao.updateWarehouse(w)) {
            response.sendRedirect(request.getContextPath() + "/warehouse/list?success=" + URLEncoder.encode("Cập nhật kho hàng thành công!", "UTF-8"));
        } else {
            request.setAttribute("errors", List.of("Đã xảy ra lỗi khi cập nhật."));
            request.setAttribute("warehouse", w);
            request.getRequestDispatcher("/views/warehouse/edit-warehouse.jsp").forward(request, response);
        }
    }

    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id").trim());
        WarehouseDAO dao = new WarehouseDAO();
        dao.toggleWarehouseStatus(id, getLoggedUser(request).getUserId());
        response.sendRedirect(request.getContextPath() + "/warehouse/list?success=" + URLEncoder.encode("Cập nhật trạng thái thành công!", "UTF-8"));
    }

    private void handleViewDetails(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id").trim());
        WarehouseDAO dao = new WarehouseDAO();
        Warehouse w = dao.getWarehouseById(id);
        if (w == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/list?error=" + URLEncoder.encode("Không tìm thấy kho hàng.", "UTF-8"));
            return;
        }
        request.setAttribute("warehouse", w);
        request.getRequestDispatcher("/views/warehouse/view-warehouse-details.jsp").forward(request, response);
    }

    private void handleViewMembers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int warehouseId = Integer.parseInt(request.getParameter("id").trim());
        WarehouseDAO wDao = new WarehouseDAO();
        Warehouse w = wDao.getWarehouseById(warehouseId);
        if (w == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/list?error=" + URLEncoder.encode("Không tìm thấy kho hàng.", "UTF-8"));
            return;
        }

        WarehouseDAO wdao = new WarehouseDAO();
        List<User> members = wdao.getMembersByWarehouse(warehouseId);

        request.setAttribute("warehouse", w);
        request.setAttribute("members", members);
        request.getRequestDispatcher("/views/warehouse/view-warehouse-member.jsp").forward(request, response);
    }

    private void handleShowUpsertMember(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int warehouseId = Integer.parseInt(request.getParameter("warehouseId").trim());
        WarehouseDAO wDao = new WarehouseDAO();
        Warehouse w = wDao.getWarehouseById(warehouseId);
        if (w == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse/list");
            return;
        }

        WarehouseDAO wdao = new WarehouseDAO();
        boolean includeManager = !wdao.isManagerInWarehouse(warehouseId);

        List<User> availableUsers = wdao.getUsersNotInWarehouse(includeManager);

        request.setAttribute("warehouse", w);
        request.setAttribute("availableUsers", availableUsers);
        request.getRequestDispatcher("/views/warehouse/upsert-warehouse-member.jsp").forward(request, response);
    }

    private void handleUpsertMember(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int warehouseId = Integer.parseInt(request.getParameter("warehouseId").trim());
        String userIdStr = request.getParameter("userId");

        if (userIdStr == null || userIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/warehouse/member/upsert?warehouseId=" + warehouseId + "&error=" + URLEncoder.encode("Vui lòng chọn nhân viên.", "UTF-8"));
            return;
        }

        int userId = Integer.parseInt(userIdStr);
        WarehouseDAO wdao = new WarehouseDAO();

        if (wdao.isWarehouseMemberExists(warehouseId, userId)) {
            response.sendRedirect(request.getContextPath() + "/warehouse/member/upsert?warehouseId=" + warehouseId + "&error=" + URLEncoder.encode("Nhân viên đã được phân công vào kho này.", "UTF-8"));
            return;
        }

        if (wdao.updateUserWarehouse(warehouseId, userId)) {
            response.sendRedirect(request.getContextPath() + "/warehouse/members?id=" + warehouseId + "&success=" + URLEncoder.encode("Thêm nhân sự thành công!", "UTF-8"));
        } else {
            response.sendRedirect(request.getContextPath() + "/warehouse/member/upsert?warehouseId=" + warehouseId + "&error=" + URLEncoder.encode("Đã xảy ra lỗi.", "UTF-8"));
        }
    }

    private void handleRemoveMember(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId").trim());
        int warehouseId = Integer.parseInt(request.getParameter("warehouseId").trim());

        WarehouseDAO wdao = new WarehouseDAO();
        wdao.updateUserWarehouse(null, userId);
        response.sendRedirect(request.getContextPath() + "/warehouse/members?id=" + warehouseId + "&success=" + URLEncoder.encode("Đã xóa nhân sự khỏi kho.", "UTF-8"));
    }

    private List<String> validateWarehouse(String code, String name, int excludeId) {
        List<String> errors = new ArrayList<>();
        if (!Validator.isValidWarehouseCode(code)) {
            errors.add("Mã kho phải từ 1-20 ký tự, chỉ chứa chữ cái, số, dấu gạch ngang (-) hoặc dấu gạch dưới (_).");
        } else {
            WarehouseDAO dao = new WarehouseDAO();
            if (dao.isWarehouseCodeExists(code.trim(), excludeId)) {
                errors.add("Mã kho đã tồn tại.");
            }
        }
        if (!Validator.isValidWarehouseName(name)) {
            errors.add("Tên kho hàng phải từ 2-100 ký tự.");
        }
        return errors;
    }
}
