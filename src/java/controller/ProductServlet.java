package controller;

import dal.CategoryDAO;
import dal.ProductDAO;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.PrintWriter;
import model.Category;
import model.Product;
import model.User;
import util.Constant;
import util.Validator;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.usermodel.DataValidation;
import org.apache.poi.ss.usermodel.DataValidationConstraint;
import org.apache.poi.ss.usermodel.DataValidationHelper;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.util.CellRangeAddressList;

@WebServlet(name = "ProductServlet", urlPatterns = {
    "/product/list",
    "/product/details",
    "/product/add",
    "/product/edit",
    "/product/toggle-status",
    "/product/categories",
    "/product/import-excel",
    "/product/import-excel/template"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
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
        } else if (path.equals("/product/import-excel/template")) {
            handleDownloadTemplate(request, response);
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
            case "/product/import-excel":
                request.getRequestDispatcher("/views/product/import-excel.jsp").forward(request, response);
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
            case "/product/import-excel":
                handleImportExcel(request, response);
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

    private void handleDownloadTemplate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        CategoryDAO categoryDAO = new CategoryDAO();
        List<Category> categories = categoryDAO.getAllCategoriesForDropdown();

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Sản phẩm");

        CellStyle headerStyle = workbook.createCellStyle();
        Font headerFont = workbook.createFont();
        headerFont.setFontName("Arial");
        headerFont.setFontHeightInPoints((short) 11);
        headerFont.setBold(true);
        headerStyle.setFont(headerFont);

        Row headerRow = sheet.createRow(0);
        String[] headers = {"Mã sản phẩm", "Tên sản phẩm", "Danh mục", "Đơn vị tính"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        sheet.setColumnWidth(0, 5000);
        sheet.setColumnWidth(1, 8000);
        sheet.setColumnWidth(2, 6000);
        sheet.setColumnWidth(3, 4000);

        if (!categories.isEmpty()) {
            String[] categoryNames = new String[categories.size()];
            for (int i = 0; i < categories.size(); i++) {
                categoryNames[i] = categories.get(i).getCategoryName();
            }

            DataValidationHelper dvHelper = sheet.getDataValidationHelper();
            DataValidationConstraint dvConstraint = dvHelper.createExplicitListConstraint(categoryNames);
            CellRangeAddressList addressList = new CellRangeAddressList(1, 100, 2, 2);
            DataValidation validation = dvHelper.createValidation(dvConstraint, addressList);
            validation.setShowErrorBox(true);
            validation.setErrorStyle(DataValidation.ErrorStyle.STOP);
            validation.createErrorBox("Lỗi", "Vui lòng chọn danh mục từ danh sách.");
            sheet.addValidationData(validation);
        }

        Row sampleRow = sheet.createRow(1);
        sampleRow.createCell(0).setCellValue("SP-001");
        sampleRow.createCell(1).setCellValue("Tên sản phẩm mẫu");
        if (!categories.isEmpty()) {
            sampleRow.createCell(2).setCellValue(categories.get(0).getCategoryName());
        }
        sampleRow.createCell(3).setCellValue("Cái");

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=product-template.xlsx");

        try (OutputStream out = response.getOutputStream()) {
            workbook.write(out);
        } finally {
            workbook.close();
        }
    }

    private void handleImportExcel(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("error", "Vui lòng chọn một file Excel.");
            request.getRequestDispatcher("/views/product/import-excel.jsp").forward(request, response);
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        if (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls")) {
            request.setAttribute("error", "Định dạng file không hỗ trợ. Vui lòng tải lên file .xlsx hoặc .xls.");
            request.getRequestDispatcher("/views/product/import-excel.jsp").forward(request, response);
            return;
        }

        CategoryDAO categoryDAO = new CategoryDAO();
        List<Category> categories = categoryDAO.getAllCategoriesForDropdown();
        java.util.Map<String, Integer> categoryMap = new java.util.HashMap<>();
        for (Category cat : categories) {
            categoryMap.put(cat.getCategoryName().trim().toLowerCase(), cat.getCategoryId());
        }

        List<java.util.Map<String, String>> results = new ArrayList<>();
        int successCount = 0;
        int failCount = 0;
        ProductDAO productDAO = new ProductDAO();

        try (InputStream inp = filePart.getInputStream(); Workbook workbook = WorkbookFactory.create(inp)) {
            Sheet sheet = workbook.getSheetAt(0);
            boolean firstRow = true;

            for (Row row : sheet) {
                if (firstRow) {
                    firstRow = false;
                    continue;
                }

                if (row.getCell(0) == null || row.getCell(0).getCellType() == Cell.CELL_TYPE_BLANK) {
                    break;
                }

                String productCode = getCellValueAsString(row.getCell(0));
                String productName = getCellValueAsString(row.getCell(1));
                String categoryName = getCellValueAsString(row.getCell(2));
                String unit = getCellValueAsString(row.getCell(3));

                java.util.Map<String, String> result = new java.util.HashMap<>();
                result.put("productCode", productCode);
                result.put("productName", productName);
                result.put("categoryName", categoryName);
                result.put("unit", unit);

                Integer categoryId = categoryMap.get(categoryName.trim().toLowerCase());
                if (categoryId == null) {
                    result.put("status", "error");
                    result.put("message", "Danh mục \"" + categoryName + "\" không tồn tại hoặc đã bị ẩn.");
                    failCount++;
                    results.add(result);
                    continue;
                }

                List<String> errors = validateProduct(productCode, productName, String.valueOf(categoryId), 0);
                if (!errors.isEmpty()) {
                    result.put("status", "error");
                    result.put("message", String.join(", ", errors));
                    failCount++;
                } else {
                    Product p = new Product();
                    p.setProductCode(productCode.trim());
                    p.setProductName(productName.trim());
                    p.setCategoryId(categoryId);
                    p.setUnit(unit != null && !unit.trim().isEmpty() ? unit.trim() : null);
                    p.setCreatedBy(getLoggedUser(request).getUserId());

                    int newId = productDAO.createProduct(p);
                    if (newId > 0) {
                        result.put("status", "success");
                        result.put("message", "Tạo thành công");
                        successCount++;
                    } else {
                        result.put("status", "error");
                        result.put("message", "Lỗi khi lưu vào CSDL (có thể trùng mã sản phẩm)");
                        failCount++;
                    }
                }
                results.add(result);
            }

            request.setAttribute("results", results);
            request.setAttribute("successCount", successCount);
            request.setAttribute("failCount", failCount);
            request.getRequestDispatcher("/views/product/import-excel.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Không thể đọc file Excel. Vui lòng đảm bảo file đúng định dạng.");
            request.getRequestDispatcher("/views/product/import-excel.jsp").forward(request, response);
        }
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null) {
            return "";
        }
        switch (cell.getCellType()) {
            case Cell.CELL_TYPE_STRING:
                return cell.getStringCellValue().trim();
            case Cell.CELL_TYPE_NUMERIC:
                double num = cell.getNumericCellValue();
                if (num == Math.floor(num) && !Double.isInfinite(num)) {
                    return String.valueOf((long) num);
                }
                return String.valueOf(num).trim();
            case Cell.CELL_TYPE_BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            default:
                return "";
        }
    }
}
