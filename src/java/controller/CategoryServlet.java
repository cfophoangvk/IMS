package controller;

import dal.CategoryDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.User;
import util.Constant;
import util.Validator;

@WebServlet(name = "CategoryServlet", urlPatterns = {
    "/category/list",
    "/category/details",
    "/category/add",
    "/category/edit",
    "/category/toggle-status"
})
public class CategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String path = request.getServletPath();

        if (path.equals("/category/list") || path.equals("/category/details")) {
            if (!Validator.hasRole(user.getRoleId(), Constant.PRODUCT_VIEWER_ROLES)) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
            if (path.equals("/category/list")) {
                handleList(request, response);
            } else {
                handleDetails(request, response);
            }
            return;
        }

        if (!isSysAdmin(user)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        switch (path) {
            case "/category/add":
                request.getRequestDispatcher("/views/product/add-category.jsp").forward(request, response);
                break;
            case "/category/edit":
                handleShowEdit(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getLoggedUser(request);
        if (user == null || !isSysAdmin(user)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        switch (request.getServletPath()) {
            case "/category/add":
                handleAdd(request, response);
                break;
            case "/category/edit":
                handleEdit(request, response);
                break;
            case "/category/toggle-status":
                handleToggle(request, response);
                break;
        }
    }

    private User getLoggedUser(HttpServletRequest req) {
        return (User) req.getSession().getAttribute(Constant.SESSION_ACCOUNT);
    }

    private boolean isSysAdmin(User u) {
        return u != null && u.getRoleId() == Constant.ROLE_SYSTEM_ADMIN;
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        int page = parsePage(request);
        User user = getLoggedUser(request);
        boolean activeOnly = true;
        if (user != null && (user.getRoleId() == Constant.ROLE_SYSTEM_ADMIN || user.getRoleId() == Constant.ROLE_MANAGER)) {
            activeOnly = false;
        }
        CategoryDAO dao = new CategoryDAO();
        int total = dao.getTotalCategories(search, activeOnly);
        request.setAttribute("categories", dao.getAllCategories(search, activeOnly, page, Constant.PAGE_SIZE));
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) total / Constant.PAGE_SIZE));
        request.setAttribute("search", search);
        request.getRequestDispatcher("/views/product/list-category.jsp").forward(request, response);
    }

    private void handleDetails(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = parseId(request);
        CategoryDAO dao = new CategoryDAO();
        Category c = dao.getCategoryById(id);
        if (c == null) {
            redirect(response, request, "/category/list", null, "Không tìm thấy danh mục.");
            return;
        }
        User user = getLoggedUser(request);
        if (!c.isStatus() && user != null && (user.getRoleId() == Constant.ROLE_EMPLOYEE || user.getRoleId() == Constant.ROLE_BUSINESS_OWNER)) {
            redirect(response, request, "/category/list", null, "Danh mục này đã bị ẩn, bạn không có quyền xem.");
            return;
        }
        request.setAttribute("category", c);
        request.getRequestDispatcher("/views/product/view-category-details.jsp").forward(request, response);
    }

    private void handleShowEdit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = parseId(request);
        Category c = new CategoryDAO().getCategoryById(id);
        if (c == null) {
            redirect(response, request, "/category/list", null, "Không tìm thấy danh mục.");
            return;
        }
        if (!c.isStatus()) {
            redirect(response, request, "/category/list", null, "Không thể chỉnh sửa danh mục đã bị ẩn.");
            return;
        }
        request.setAttribute("category", c);
        request.getRequestDispatcher("/views/product/edit-category.jsp").forward(request, response);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("categoryName");
        List<String> errors = validateCategory(name, 0);
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("categoryName", name);
            request.getRequestDispatcher("/views/product/add-category.jsp").forward(request, response);
            return;
        }
        Category c = new Category();
        c.setCategoryName(name.trim());
        c.setCreatedBy(getLoggedUser(request).getUserId());
        int id = new CategoryDAO().createCategory(c);
        if (id > 0) {
            redirect(response, request, "/category/list", "Tạo danh mục thành công!", null);
        } else {
            request.setAttribute("errors", List.of("Lỗi khi tạo danh mục."));
            request.setAttribute("categoryName", name);
            request.getRequestDispatcher("/views/product/add-category.jsp").forward(request, response);
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("categoryId"));
        CategoryDAO dao = new CategoryDAO();
        Category existing = dao.getCategoryById(id);
        if (existing == null || !existing.isStatus()) {
            redirect(response, request, "/category/list", null, "Không thể chỉnh sửa danh mục đã bị ẩn.");
            return;
        }

        String name = request.getParameter("categoryName");
        List<String> errors = validateCategory(name, id);
        if (!errors.isEmpty()) {
            existing.setCategoryName(name);
            request.setAttribute("category", existing);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/views/product/edit-category.jsp").forward(request, response);
            return;
        }
        Category c = new Category();
        c.setCategoryId(id);
        c.setCategoryName(name.trim());
        c.setUpdatedBy(getLoggedUser(request).getUserId());
        if (dao.updateCategory(c)) {
            redirect(response, request, "/category/list", "Cập nhật danh mục thành công!", null);
        } else {
            request.setAttribute("errors", List.of("Lỗi khi cập nhật."));
            request.setAttribute("category", c);
            request.getRequestDispatcher("/views/product/edit-category.jsp").forward(request, response);
        }
    }

    private void handleToggle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        new CategoryDAO().toggleCategoryStatus(parseId(request), getLoggedUser(request).getUserId());
        redirect(response, request, "/category/list", "Cập nhật trạng thái thành công!", null);
    }

    private List<String> validateCategory(String name, int excludeId) {
        List<String> errors = new ArrayList<>();
        if (!Validator.isValidCategoryName(name)) {
            errors.add("Tên danh mục phải từ 2-100 ký tự.");
        } else if (new CategoryDAO().isCategoryNameExists(name.trim(), excludeId)) {
            errors.add("Tên danh mục đã tồn tại.");
        }
        return errors;
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
