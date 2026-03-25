package controller;

import dal.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import util.Constant;
import util.Validator;

@WebServlet(name = "AuthServlet", urlPatterns = {
    "/auth/login",
    "/auth/change-password",
    "/auth/reset-password",
    "/auth/logout"
})
public class AuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getServletPath();

        switch (pathInfo) {
            case "/auth/login":
                handleShowLoginForm(request, response);
                break;
            case "/auth/change-password":
                handleShowChangePasswordForm(request, response);
                break;
            case "/auth/reset-password":
                handleShowResetPasswordForm(request, response);
                break;
            case "/auth/logout":
                handleLogout(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getServletPath();
        switch (pathInfo) {
            case "/auth/login":
                handleLogin(request, response);
                break;
            case "/auth/change-password":
                handleChangePassword(request, response);
                break;
            case "/auth/reset-password":
                handleResetPassword(request, response);
                break;
        }
    }

    private void handleShowLoginForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    private void handleShowChangePasswordForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");

        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        request.setAttribute("email", email.trim());
        request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
    }

    private void handleShowResetPasswordForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username").trim();
        String password = request.getParameter("password").trim();

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByUsername(username);

        if (user != null && BCrypt.checkpw(password, user.getPasswordHash())) {
            if (!user.isStatus()) {
                request.setAttribute("error", "Tài khoản của bạn đã bị khóa. Liên hệ với IT để được hỗ trợ.");
                request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute(Constant.SESSION_ACCOUNT, user);

            if (user.isFirstLogin()) {
                response.sendRedirect(request.getContextPath() + "/auth/change-password?email=" + user.getEmail());
            } else {
                switch (user.getRoleId()) {
                    case Constant.ROLE_IT_ADMIN:
                        response.sendRedirect(request.getContextPath() + "/dashboard/it-admin");
                        break;
                    case Constant.ROLE_SYSTEM_ADMIN:
                        response.sendRedirect(request.getContextPath() + "/dashboard/system-admin");
                        break;
                    case Constant.ROLE_EMPLOYEE:
                        response.sendRedirect(request.getContextPath() + "/transaction/list");
                        break;
                    case Constant.ROLE_MANAGER:
                        response.sendRedirect(request.getContextPath() + "/dashboard/manager");
                        break;
                    case Constant.ROLE_BUSINESS_OWNER:
                        response.sendRedirect(request.getContextPath() + "/dashboard/business-owner");
                        break;
                    default:
                        response.sendRedirect(request.getContextPath() + "/auth/login");
                        break;
                }
            }
        } else {
            request.setAttribute("error", "Tài khoản hoặc mật khẩu không chính xác!");
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
        }
    }

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute(Constant.SESSION_ACCOUNT);

        if (loggedUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String email = request.getParameter("email").trim();
        String newPassword = request.getParameter("newPassword").trim();
        String confirmPassword = request.getParameter("confirmPassword").trim();

        request.setAttribute("email", email); // Nếu có lỗi thì vẫn giữ nguyên email.

        if (!email.equals(loggedUser.getEmail())) {
            request.setAttribute("error", "Email không khớp với tài khoản hiện tại.");
            request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
            return;
        }

        if (!Validator.isValidPassword(newPassword)) {
            request.setAttribute("error", "Mật khẩu phải dài ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt (@#$%^&+=!*).");
            request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
            return;
        }

        String hash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        UserDAO dao = new UserDAO();

        if (dao.changePassword(email, hash)) {
            loggedUser.setFirstLogin(false);
            loggedUser.setPasswordHash(hash);
            session.setAttribute(Constant.SESSION_ACCOUNT, loggedUser);
            response.sendRedirect(request.getContextPath() + "/auth/login");
        } else {
            request.setAttribute("error", "Đã xảy ra lỗi khi đổi mật khẩu.");
            request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
        }
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getSession().removeAttribute(Constant.SESSION_ACCOUNT);
        request.getSession().invalidate();
        response.sendRedirect(request.getContextPath() + "/auth/login");
    }

    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String usernameEmail = request.getParameter("usernameEmail").trim();
        String password = request.getParameter("password").trim();
        String confirmPassword = request.getParameter("confirmPassword").trim();

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
        }

        UserDAO dao = new UserDAO();
        User user = dao.getUserByUsernameOrEmail(usernameEmail);
        if (user == null) {
            request.setAttribute("error", "Không tìm thấy tên đăng nhập hoặc email!");
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        String hash = BCrypt.hashpw(password, BCrypt.gensalt());

        if (dao.changePassword(user.getEmail(), hash)) {
            user.setPasswordHash(hash);
            session.setAttribute(Constant.SESSION_ACCOUNT, user);
            response.sendRedirect(request.getContextPath() + "/auth/login");
        } else {
            request.setAttribute("error", "Đã xảy ra lỗi khi đổi mật khẩu.");
            request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
        }
        request.setAttribute("success", "Mật khẩu đã được khôi phục. Vui lòng đăng nhập lại!");

        request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
    }
}
