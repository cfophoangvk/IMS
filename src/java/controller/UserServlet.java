package controller;

import dal.RoleDAO;
import dal.UserDAO;
import dal.WarehouseDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Role;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import util.Constant;
import util.EmailService;
import util.Validator;

@WebServlet(name = "UserServlet", urlPatterns = {
    "/user/list",
    "/user/create",
    "/user/create-batch",
    "/user/edit",
    "/user/toggle-status",
    "/user/send-email",
    "/user/profile"
})
public class UserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/user/profile":
                handleViewProfile(request, response);
                break;
            default:
                if (!checkITAdmin(request, response)) {
                    return;
                }
                switch (path) {
                    case "/user/list":
                        handleListUsers(request, response);
                        break;
                    case "/user/create":
                        handleShowCreateForm(request, response);
                        break;
                    case "/user/create-batch":
                        handleShowCreateBatchForm(request, response);
                        break;
                    case "/user/edit":
                        handleShowEditForm(request, response);
                        break;
                }
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if (!checkITAdmin(request, response)) {
            return;
        }

        switch (path) {
            case "/user/create":
                handleCreateUser(request, response);
                break;
            case "/user/create-batch":
                handleCreateBatch(request, response);
                break;
            case "/user/edit":
                handleEditUser(request, response);
                break;
            case "/user/toggle-status":
                handleToggleStatus(request, response);
                break;
            case "/user/send-email":
                handleSendEmail(request, response);
                break;
        }
    }

    private boolean checkITAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute(Constant.SESSION_ACCOUNT);
        if (loggedUser == null || loggedUser.getRoleId() != Constant.ROLE_IT_ADMIN) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    private User getLoggedUser(HttpServletRequest request) {
        return (User) request.getSession().getAttribute(Constant.SESSION_ACCOUNT);
    }

    private void handleListUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        String roleIdStr = request.getParameter("roleId");
        Integer roleId = null;
        if (roleIdStr != null && !roleIdStr.trim().isEmpty()) {
            try {
                roleId = Integer.parseInt(roleIdStr);
            } catch (Exception e) {
            }
        }

        String pageStr = request.getParameter("page");
        int page = 1;
        try {
            page = Integer.parseInt(pageStr);
        } catch (Exception e) {
        }
        if (page < 1) {
            page = 1;
        }

        UserDAO userDAO = new UserDAO();
        RoleDAO roleDAO = new RoleDAO();
        List<User> users = userDAO.getAllUsers(search, roleId, page, Constant.PAGE_SIZE);
        int totalUsers = userDAO.getTotalUsers(search, roleId);
        int totalPages = (int) Math.ceil((double) totalUsers / Constant.PAGE_SIZE);

        request.setAttribute("users", users);
        request.setAttribute("roles", roleDAO.getAllRoles());
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("search", search);
        request.setAttribute("filterRoleId", roleId);

        request.getRequestDispatcher("/views/user/list-user.jsp").forward(request, response);
    }

    private void handleShowCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        RoleDAO roleDAO = new RoleDAO();
        request.setAttribute("roles", roleDAO.getAllRoles());
        request.getRequestDispatcher("/views/user/create-single.jsp").forward(request, response);
    }

    private void handleCreateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username").trim();
        String fullName = request.getParameter("fullName").trim();
        String email = request.getParameter("email").trim();
        String roleIdStr = request.getParameter("roleId").trim();

        RoleDAO roleDAO = new RoleDAO();
        List<Role> roles = roleDAO.getAllRoles();
        request.setAttribute("roles", roles);

        // Validation
        List<String> errors = validateUserInput(username, fullName, email, roleIdStr, 0);
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("username", username);
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("roleId", roleIdStr);
            request.getRequestDispatcher("/views/user/create-single.jsp").forward(request, response);
            return;
        }

        String hash = BCrypt.hashpw(Constant.DEFAULT_PASSWORD, BCrypt.gensalt());

        User user = new User();
        user.setUsername(username.trim());
        user.setFullName(fullName.trim());
        user.setEmail(email.trim());
        user.setRoleId(Integer.parseInt(roleIdStr));
        user.setPasswordHash(hash);
        user.setCreatedBy(getLoggedUser(request).getUserId());

        UserDAO userDAO = new UserDAO();
        int newUserId = userDAO.createUser(user);
        if (newUserId > 0) {
            response.sendRedirect(request.getContextPath() + "/user/list?success=" + java.net.URLEncoder.encode("Tạo tài khoản thành công! Bấm nút gửi email để gửi thông tin đăng nhập.", "UTF-8"));
        } else {
            request.setAttribute("errors", List.of("Đã xảy ra lỗi khi tạo tài khoản."));
            request.setAttribute("username", username);
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("roleId", roleIdStr);
            request.getRequestDispatcher("/views/user/create-single.jsp").forward(request, response);
        }
    }

    private void handleShowCreateBatchForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        RoleDAO roleDAO = new RoleDAO();
        request.setAttribute("roles", roleDAO.getAllRoles());
        request.getRequestDispatcher("/views/user/create-batch.jsp").forward(request, response);
    }

    private void handleCreateBatch(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String[] usernames = request.getParameterValues("usernames");
        String[] fullNames = request.getParameterValues("fullNames");
        String[] emails = request.getParameterValues("emails");
        String[] roleIds = request.getParameterValues("roleIds");

        RoleDAO roleDAO = new RoleDAO();
        List<Role> roles = roleDAO.getAllRoles();
        request.setAttribute("roles", roles);

        if (usernames == null || usernames.length == 0) {
            request.setAttribute("error", "Vui lòng thêm ít nhất một tài khoản.");
            request.getRequestDispatcher("/views/user/create-batch.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        List<java.util.Map<String, String>> results = new ArrayList<>();

        int successCount = 0;
        int failCount = 0;

        for (int i = 0; i < usernames.length; i++) {
            java.util.Map<String, String> result = new java.util.HashMap<>();
            String username = usernames[i];
            String fullName = fullNames[i];
            String email = emails[i];
            String roleId = roleIds[i];

            result.put("username", username);
            result.put("fullName", fullName);
            result.put("email", email);
            result.put("roleId", roleId);

            List<String> errors = validateUserInput(username, fullName, email, roleId, 0);
            if (!errors.isEmpty()) {
                result.put("status", "error");
                result.put("message", String.join(", ", errors));
                failCount++;
            } else {
                String hash = BCrypt.hashpw(Constant.DEFAULT_PASSWORD, BCrypt.gensalt());

                User user = new User();
                user.setUsername(username.trim());
                user.setFullName(fullName.trim());
                user.setEmail(email.trim());
                user.setRoleId(Integer.parseInt(roleId));
                user.setPasswordHash(hash);
                user.setCreatedBy(getLoggedUser(request).getUserId());

                int newUserId = userDAO.createUser(user);
                if (newUserId > 0) {
                    result.put("status", "success");
                    result.put("message", "Tạo thành công");
                    result.put("userId", String.valueOf(newUserId));
                    successCount++;
                } else {
                    result.put("status", "error");
                    result.put("message", "Lỗi khi tạo tài khoản (có thể trùng username)");
                    failCount++;
                }
            }
            results.add(result);
        }

        request.setAttribute("results", results);
        request.setAttribute("successCount", successCount);
        request.setAttribute("failCount", failCount);
        request.getRequestDispatcher("/views/user/create-batch.jsp").forward(request, response);
    }

    private void handleShowEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userIdStr = request.getParameter("id").trim();
        if (userIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/user/list");
            return;
        }
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserById(Integer.parseInt(userIdStr));
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/list?error=" + java.net.URLEncoder.encode("Không tìm thấy người dùng.", "UTF-8"));
            return;
        }
        RoleDAO roleDAO = new RoleDAO();
        request.setAttribute("editUser", user);
        request.setAttribute("roles", roleDAO.getAllRoles());
        request.getRequestDispatcher("/views/user/edit-user.jsp").forward(request, response);
    }

    private void handleEditUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userIdStr = request.getParameter("userId").trim();
        String fullName = request.getParameter("fullName").trim();
        String email = request.getParameter("email").trim();
        String roleIdStr = request.getParameter("roleId").trim();

        int userId = Integer.parseInt(userIdStr);

        RoleDAO roleDAO = new RoleDAO();
        request.setAttribute("roles", roleDAO.getAllRoles());

        List<String> errors = new ArrayList<>();
        if (!Validator.isValidFullName(fullName)) {
            errors.add("Họ tên phải từ 2-100 ký tự.");
        }
        if (!Validator.isValidEmail(email)) {
            errors.add("Email không hợp lệ.");
        } else {
            UserDAO userDAO = new UserDAO();
            if (userDAO.isEmailExists(email.trim(), userId)) {
                errors.add("Email đã tồn tại trong hệ thống.");
            }
        }
        if (roleIdStr == null || roleIdStr.isEmpty()) {
            errors.add("Vui lòng chọn vai trò.");
        }

        if (!errors.isEmpty()) {
            UserDAO userDAO = new UserDAO();
            User editUser = userDAO.getUserById(userId);
            editUser.setFullName(fullName);
            editUser.setEmail(email);
            if (roleIdStr != null && !roleIdStr.isEmpty()) {
                editUser.setRoleId(Integer.parseInt(roleIdStr));
            }
            request.setAttribute("editUser", editUser);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/views/user/edit-user.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setUserId(userId);
        user.setFullName(fullName.trim());
        user.setEmail(email.trim());
        user.setRoleId(Integer.parseInt(roleIdStr));
        user.setUpdatedBy(getLoggedUser(request).getUserId());

        UserDAO userDAO = new UserDAO();
        if (userDAO.updateUser(user)) {
            response.sendRedirect(request.getContextPath() + "/user/list?success=" + java.net.URLEncoder.encode("Cập nhật tài khoản thành công!", "UTF-8"));
        } else {
            request.setAttribute("errors", List.of("Đã xảy ra lỗi khi cập nhật."));
            request.setAttribute("editUser", user);
            request.getRequestDispatcher("/views/user/edit-user.jsp").forward(request, response);
        }
    }

    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userIdStr = request.getParameter("id").trim();
        UserDAO userDAO = new UserDAO();
        userDAO.toggleUserStatus(Integer.parseInt(userIdStr), getLoggedUser(request).getUserId());
        response.sendRedirect(request.getContextPath() + "/user/list?success=" + java.net.URLEncoder.encode("Cập nhật trạng thái thành công!", "UTF-8"));
    }

    private void handleSendEmail(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String[] userIdsStr = request.getParameterValues("userIds");
        
        if (userIdsStr == null || userIdsStr.length == 0) {
            response.sendRedirect(request.getContextPath() + "/user/list?error=" + java.net.URLEncoder.encode("Vui lòng chọn ít nhất một người dùng.", "UTF-8"));
            return;
        }

        UserDAO userDAO = new UserDAO();
        int successCount = 0;
        int failCount = 0;

        for (String idStr : userIdsStr) {
            try {
                int userId = Integer.parseInt(idStr);
                User user = userDAO.getUserById(userId);
                if (user != null && user.isFirstLogin()) {
                    boolean sent = EmailService.sendAccountCredentials(user.getEmail(), user.getUsername(), Constant.DEFAULT_PASSWORD);
                    if (sent) {
                        successCount++;
                    } else {
                        failCount++;
                    }
                }
            } catch (Exception e) {
                failCount++;
            }
        }

        if (successCount > 0 && failCount == 0) {
            response.sendRedirect(request.getContextPath() + "/user/list?success=" + java.net.URLEncoder.encode("Đã gửi email thông tin đăng nhập thành công cho " + successCount + " tài khoản!", "UTF-8"));
        } else if (successCount > 0 && failCount > 0) {
            response.sendRedirect(request.getContextPath() + "/user/list?success=" + java.net.URLEncoder.encode("Đã gửi email cho " + successCount + " tài khoản. Thất bại " + failCount + " tài khoản.", "UTF-8"));
        } else {
            response.sendRedirect(request.getContextPath() + "/user/list?error=" + java.net.URLEncoder.encode("Gửi email thất bại. Vui lòng kiểm tra lại cấu hình email.", "UTF-8"));
        }
    }

    private void handleViewProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loggedUser = getLoggedUser(request);
        UserDAO userDAO = new UserDAO();
        WarehouseDAO wdao = new WarehouseDAO();
        User fullUser = userDAO.getUserById(loggedUser.getUserId());
        String warehouseName = wdao.getWarehouseNameById(fullUser.getWarehouseId());
        
        request.setAttribute("profileUser", fullUser);
        request.setAttribute("warehouseName", warehouseName);
        request.getRequestDispatcher("/views/user/view-profile.jsp").forward(request, response);
    }

    private List<String> validateUserInput(String username, String fullName, String email, String roleIdStr, int excludeUserId) {
        List<String> errors = new ArrayList<>();
        UserDAO userDAO = new UserDAO();

        if (!Validator.isValidUsername(username)) {
            errors.add("Tên đăng nhập phải từ 3-50 ký tự, chỉ chứa chữ cái, số và gạch dưới.");
        } else if (excludeUserId == 0 && userDAO.isUsernameExists(username.trim())) {
            errors.add("Tên đăng nhập đã tồn tại.");
        }

        if (!Validator.isValidFullName(fullName)) {
            errors.add("Họ tên phải từ 2-100 ký tự.");
        }

        if (!Validator.isValidEmail(email)) {
            errors.add("Email không hợp lệ.");
        } else if (userDAO.isEmailExists(email.trim(), excludeUserId)) {
            errors.add("Email đã tồn tại trong hệ thống.");
        }

        if (roleIdStr == null || roleIdStr.isEmpty()) {
            errors.add("Vui lòng chọn vai trò.");
        } else {
            try {
                Integer.valueOf(roleIdStr);
            } catch (NumberFormatException e) {
                errors.add("Vai trò không hợp lệ.");
            }
        }

        return errors;
    }
}
