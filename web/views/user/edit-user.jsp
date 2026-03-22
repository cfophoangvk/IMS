<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/user/list" class="text-gray-500 hover:text-gray-700 transition">
                        <i class="fas fa-arrow-left text-lg"></i>
                    </a>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Chỉnh sửa tài khoản</h1>
                        <p class="text-sm text-gray-500 mt-1">Cập nhật thông tin người dùng: <strong>${editUser.username}</strong></p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <c:if test="${not empty errors}">
                <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded-r-lg">
                    <div class="flex items-start">
                        <i class="fas fa-exclamation-triangle text-red-500 mt-0.5 mr-3"></i>
                        <div>
                            <p class="text-red-800 font-medium">Vui lòng sửa các lỗi sau:</p>
                            <ul class="mt-2 text-sm text-red-700 list-disc list-inside">
                                <c:forEach var="error" items="${errors}">
                                    <li>${error}</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </div>
                </div>
            </c:if>

            <div class="bg-white rounded-lg shadow-sm border">
                <div class="p-6 border-b bg-gray-50 rounded-t-lg">
                    <h2 class="text-lg font-semibold text-gray-800"><i class="fas fa-user-edit mr-2 text-blue-600"></i>Thông tin tài khoản</h2>
                </div>
                <form action="${pageContext.request.contextPath}/user/edit" method="POST" class="p-6 space-y-5">
                    <input type="hidden" name="userId" value="${editUser.userId}">

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Tên đăng nhập</label>
                        <input type="text" value="${editUser.username}" disabled
                               class="w-full px-4 py-2.5 border border-gray-200 rounded-lg bg-gray-100 text-gray-500 cursor-not-allowed">
                        <p class="mt-1 text-xs text-gray-400">Tên đăng nhập không thể thay đổi</p>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">
                            Họ và tên <span class="text-red-500">*</span>
                        </label>
                        <input type="text" name="fullName" value="${editUser.fullName}" required
                               class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition">
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">
                            Email <span class="text-red-500">*</span>
                        </label>
                        <input type="email" name="email" value="${editUser.email}" required
                               class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition">
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">
                            Vai trò <span class="text-red-500">*</span>
                        </label>
                        <select name="roleId" required
                                class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition bg-white">
                            <option value="">-- Chọn vai trò --</option>
                            <c:forEach var="role" items="${roles}">
                                <option value="${role.roleId}" ${editUser.roleId == role.roleId ? 'selected' : ''}>${role.roleName} - ${role.description}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="flex items-center gap-3 pt-4 border-t">
                        <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg shadow-sm transition duration-200">
                            <i class="fas fa-save mr-2"></i> Lưu thay đổi
                        </button>
                        <a href="${pageContext.request.contextPath}/user/list" class="px-6 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium rounded-lg transition">
                            Hủy bỏ
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</layout:layout>