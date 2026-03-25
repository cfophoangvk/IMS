package controller;

import dal.CategoryDAO;
import dal.ProductDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import model.Product;
import model.User;
import util.Constant;
import util.Validator;

@WebServlet(name = "ProductServlet", urlPatterns = {
    "/product/list",
    "/product/details",
    "/product/add",
    "/product/edit",
    "/product/toggle-status",
    "/product/categories"
})
public class ProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String path = request.getServletPath();

        if (path.equals("/product/list") || path.equals("/product/details")) {
            if (!Validator.hasRole(user.getRoleId(), Constant.PRODUCT_VIEWER_ROLES)) {
                request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
                return;
            }
            if (path.equals("/product/list")) {
                handleList(request, response);
            } else {
                handleDetails(request, response);
            }
            return;
        } else if (path.equals("/product/categories")) {
            handleProductsByCategory(request, response);
            return;
        }

        if (!Validator.hasRole(user.getRoleId(), Constant.PRODUCT_EDITOR_ROLES)) {
            request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
            return;
        }
        switch (path) {
            case "/product/add":
                request.setAttribute("categories", new CategoryDAO().getAllCategoriesForDropdown());
                request.getRequestDispatcher("/views/product/add-product.jsp").forward(request, response);
                break;
            case "/product/edit":
                handleShowEdit(request, response);
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

        if (path.equals("/product/toggle-status")) {
            if (user.getRoleId() != Constant.ROLE_SYSTEM_ADMIN) {
                request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
                return;
            }
            handleToggle(request, response);
            return;
        }

        if (!Validator.hasRole(user.getRoleId(), Constant.PRODUCT_EDITOR_ROLES)) {
            request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
            return;
        }
        switch (path) {
            case "/product/add":
                handleAdd(request, response);
                break;
            case "/product/edit":
                handleEdit(request, response);
                break;
        }
    }

    private User getLoggedUser(HttpServletRequest req) {
        return (User) req.getSession().getAttribute(Constant.SESSION_ACCOUNT);
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        String catIdStr = request.getParameter("categoryId");
        Integer filterCategoryId = null;
        try {
            if (catIdStr != null && !catIdStr.isEmpty()) {
                filterCategoryId = Integer.parseInt(catIdStr);
            }
        } catch (Exception ignored) {
        }

        int page = parsePage(request);
        User user = getLoggedUser(request);
        boolean activeOnly = true;
        if (user != null && (user.getRoleId() == Constant.ROLE_SYSTEM_ADMIN || user.getRoleId() == Constant.ROLE_MANAGER)) {
            activeOnly = false;
        }

        ProductDAO dao = new ProductDAO();
        int total = dao.getTotalProducts(search, filterCategoryId, activeOnly);

        request.setAttribute("products", dao.getAllProducts(search, filterCategoryId, activeOnly, page, Constant.PAGE_SIZE));
        request.setAttribute("categories", new CategoryDAO().getAllCategoriesForDropdown());
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) total / Constant.PAGE_SIZE));
        request.setAttribute("search", search);
        request.setAttribute("filterCategoryId", filterCategoryId);
        request.getRequestDispatcher("/views/product/list-product.jsp").forward(request, response);
    }

    private void handleDetails(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = parseId(request);
        Product p = new ProductDAO().getProductById(id);
        if (p == null) {
            redirect(response, request, "/product/list", null, "Không tìm thấy sản phẩm.");
            return;
        }
        User user = getLoggedUser(request);
        if (!p.isStatus() && user != null && (user.getRoleId() == Constant.ROLE_EMPLOYEE || user.getRoleId() == Constant.ROLE_BUSINESS_OWNER)) {
            redirect(response, request, "/product/list", null, "Sản phẩm này đã bị ẩn, bạn không có quyền xem.");
            return;
        }
        request.setAttribute("product", p);
        request.getRequestDispatcher("/views/product/view-product-details.jsp").forward(request, response);
    }

    private void handleShowEdit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = parseId(request);
        Product p = new ProductDAO().getProductById(id);
        if (p == null) {
            redirect(response, request, "/product/list", null, "Không tìm thấy sản phẩm.");
            return;
        }
        if (!p.isStatus()) {
            redirect(response, request, "/product/list", null, "Không thể chỉnh sửa sản phẩm đã bị ẩn.");
            return;
        }
        request.setAttribute("product", p);
        request.setAttribute("categories", new CategoryDAO().getAllCategoriesForDropdown());
        request.getRequestDispatcher("/views/product/edit-product.jsp").forward(request, response);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("productCode");
        String name = request.getParameter("productName");
        String catIdStr = request.getParameter("categoryId");
        String unit = request.getParameter("unit");

        List<String> errors = validateProduct(code, name, catIdStr, 0);
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("productCode", code);
            request.setAttribute("productName", name);
            request.setAttribute("categoryId", catIdStr);
            request.setAttribute("unit", unit);
            request.setAttribute("categories", new CategoryDAO().getAllCategoriesForDropdown());
            request.getRequestDispatcher("/views/product/add-product.jsp").forward(request, response);
            return;
        }

        Product p = new Product();
        p.setProductCode(code.trim());
        p.setProductName(name.trim());
        p.setCategoryId(Integer.parseInt(catIdStr));
        p.setUnit(unit != null && !unit.trim().isEmpty() ? unit.trim() : null);
        p.setCreatedBy(getLoggedUser(request).getUserId());

        if (new ProductDAO().createProduct(p) > 0) {
            redirect(response, request, "/product/list", "Tạo sản phẩm thành công!", null);
        } else {
            request.setAttribute("errors", List.of("Lỗi khi tạo sản phẩm."));
            request.setAttribute("categories", new CategoryDAO().getAllCategoriesForDropdown());
            request.setAttribute("productCode", code);
            request.setAttribute("productName", name);
            request.setAttribute("categoryId", catIdStr);
            request.setAttribute("unit", unit);
            request.getRequestDispatcher("/views/product/add-product.jsp").forward(request, response);
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("productId"));
        ProductDAO dao = new ProductDAO();
        Product existing = dao.getProductById(id);
        if (existing == null || !existing.isStatus()) {
            redirect(response, request, "/product/list", null, "Không thể chỉnh sửa sản phẩm đã bị ẩn.");
            return;
        }

        String name = request.getParameter("productName");
        String catIdStr = request.getParameter("categoryId");
        String unit = request.getParameter("unit");

        List<String> errors = new ArrayList<>();
        if (!Validator.isValidProductName(name)) {
            errors.add("Tên sản phẩm phải từ 2-200 ký tự.");
        }
        if (catIdStr == null || catIdStr.isEmpty()) {
            errors.add("Vui lòng chọn danh mục.");
        }

        if (!errors.isEmpty()) {
            existing.setProductName(name);
            existing.setCategoryId(catIdStr != null && !catIdStr.isEmpty() ? Integer.parseInt(catIdStr) : 0);
            existing.setUnit(unit);
            request.setAttribute("product", existing);
            request.setAttribute("errors", errors);
            request.setAttribute("categories", new CategoryDAO().getAllCategoriesForDropdown());
            request.getRequestDispatcher("/views/product/edit-product.jsp").forward(request, response);
            return;
        }

        Product p = new Product();
        p.setProductId(id);
        p.setProductName(name.trim());
        p.setCategoryId(Integer.parseInt(catIdStr));
        p.setUnit(unit != null && !unit.trim().isEmpty() ? unit.trim() : null);
        p.setUpdatedBy(getLoggedUser(request).getUserId());

        if (dao.updateProduct(p)) {
            redirect(response, request, "/product/list", "Cập nhật sản phẩm thành công!", null);
        } else {
            request.setAttribute("errors", List.of("Lỗi khi cập nhật."));
            request.setAttribute("product", p);
            request.setAttribute("categories", new CategoryDAO().getAllCategoriesForDropdown());
            request.getRequestDispatcher("/views/product/edit-product.jsp").forward(request, response);
        }
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

    private void handleToggle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        new ProductDAO().toggleProductStatus(parseId(request), getLoggedUser(request).getUserId());
        redirect(response, request, "/product/list", "Cập nhật trạng thái thành công!", null);
    }

    private List<String> validateProduct(String code, String name, String catIdStr, int excludeId) {
        List<String> errors = new ArrayList<>();
        if (!Validator.isValidProductCode(code)) {
            errors.add("Mã sản phẩm phải 1-50 ký tự, chỉ chứa chữ cái, số và dấu gạch ngang.");
        } else if (new ProductDAO().isProductCodeExists(code.trim(), excludeId)) {
            errors.add("Mã sản phẩm đã tồn tại.");
        }
        if (!Validator.isValidProductName(name)) {
            errors.add("Tên sản phẩm phải từ 2-200 ký tự.");
        }
        if (catIdStr == null || catIdStr.isEmpty()) {
            errors.add("Vui lòng chọn danh mục.");
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

    private String escapeJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
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
