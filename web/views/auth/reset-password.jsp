<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen flex items-center justify-center bg-gray-100">
        <div class="bg-white p-8 rounded-lg shadow-md w-full max-w-md border-t-4 border-red-500">
            <h2 class="text-2xl font-bold text-center text-gray-800 mb-2">Khôi Phục Mật Khẩu</h2>
            <p class="text-sm text-gray-500 text-center mb-6">Nhập Tên đăng nhập và Email khớp với tài khoản để hệ thống reset mật khẩu.</p>
            
            <c:if test="${not empty error}">
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4 text-sm">
                    ${error}
                </div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4 text-sm font-bold">
                    ${success}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/auth/reset-password" method="POST">
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Tên đăng nhập hoặc email</label>
                    <input type="text" name="usernameEmail" required
                           class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                </div>
                
                <div class="mb-6">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Mật khẩu</label>
                    <input type="password" name="password" required
                           class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                
                <div class="mb-6">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Xác nhận mật khẩu</label>
                    <input type="password" name="confirmPassword" required
                           class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                
                <div class="flex flex-col space-y-3">
                    <button type="submit" class="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-4 rounded focus:outline-none transition duration-200">
                        Khôi phục mật khẩu
                    </button>
                    <a href="${pageContext.request.contextPath}/auth/login" class="text-center text-sm text-blue-500 hover:underline">
                        Quay lại Đăng nhập
                    </a>
                </div>
            </form>
        </div>
    </div>
</layout:layout>