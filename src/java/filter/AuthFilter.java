package filter;

import model.User;
import util.Constant;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession();
        
        String path = req.getServletPath();
        if (path.startsWith("/assets/") || path.startsWith("/auth/") || path.equals("/index.jsp") || path.startsWith("/views/error/") || path.isEmpty()) {
            chain.doFilter(request, response);
            return;
        }

        User user = (User) session.getAttribute(Constant.SESSION_ACCOUNT);
        
        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        // Bắt buộc đổi mật khẩu lần đầu
        if (user.isFirstLogin() && !path.equals("/auth/change-password")) {
            res.sendRedirect(req.getContextPath() + "/auth/change-password");
            return;
        }

        chain.doFilter(request, response);
    }
}