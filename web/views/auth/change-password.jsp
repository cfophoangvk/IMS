<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen flex items-center justify-center bg-gray-100">
        <div class="bg-white p-8 rounded-lg shadow-md w-full max-w-md border-t-4 border-yellow-500">
            <h2 class="text-xl font-bold text-center text-gray-800 mb-2">Cập Nhật Mật Khẩu</h2>
            <p class="text-sm text-gray-500 text-center mb-6">Bạn cần đổi mật khẩu trong lần đăng nhập đầu tiên để bảo vệ tài khoản.</p>
            
            <c:if test="${not empty error}">
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4 text-sm">
                    ${error}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/auth/change-password" method="POST">
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Email xác thực</label>
                    <input type="email" name="email" readonly placeholder="Nhập email của bạn..." value="${email}"
                           class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:ring-2 focus:ring-yellow-500">
                </div>
                
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Mật khẩu mới</label>
                    <input type="password" name="newPassword" required
                           class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:ring-2 focus:ring-yellow-500">
                </div>

                <div class="mb-6">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Xác nhận mật khẩu</label>
                    <input type="password" name="confirmPassword" required
                           class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:ring-2 focus:ring-yellow-500">
                </div>
                
                <div class="flex items-center space-x-2">
                    <button type="submit" class="flex-1 bg-yellow-500 hover:bg-yellow-600 text-white font-bold py-2 px-4 rounded focus:outline-none transition duration-200">
                        Xác Nhận & Cập Nhật
                    </button>
                    <a href="${pageContext.request.contextPath}/auth/logout" class="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded text-center">
                        Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>
</layout:layout>