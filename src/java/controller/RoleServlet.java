package controller;

import dal.RoleDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Role;
import model.User;
import util.Constant;

@WebServlet(name = "RoleServlet", urlPatterns = {"/role/list"})
public class RoleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute(Constant.SESSION_ACCOUNT);
        if (user == null || user.getRoleId() != Constant.ROLE_IT_ADMIN) {
            request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
            return;
        }

        RoleDAO roleDAO = new RoleDAO();
        List<Role> roles = roleDAO.getAllRoles();
        request.setAttribute("roles", roles);

        request.getRequestDispatcher("/views/role/list-role.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute(Constant.SESSION_ACCOUNT);
        if (user == null || user.getRoleId() != Constant.ROLE_IT_ADMIN) {
            request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
            return;
        }

        String roleName = request.getParameter("roleName");
        String description = request.getParameter("description");

        if (roleName == null || roleName.trim().isEmpty()) {
            redirect(response, request, "/role/list", null, "Tên vai trò không được để trống.");
            return;
        }

        RoleDAO roleDAO = new RoleDAO();
        if (roleDAO.isRoleExists(roleName)) {
            redirect(response, request, "/role/list", null, "Vai trò này đã tồn tại.");
            return;
        }

        Role role = new Role();
        role.setRoleName(roleName.trim());
        role.setDescription(description != null ? description.trim() : "");

        boolean success = roleDAO.createRole(role);
        if (success) {
            redirect(response, request, "/role/list", "Tạo vai trò thành công!", null);
        } else {
            redirect(response, request, "/role/list", null, "Đã có lỗi xảy ra. Hãy thử lại!");
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
