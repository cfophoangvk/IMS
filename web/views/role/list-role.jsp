<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex justify-between items-center">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Quản lý Vai trò</h1>
                        <p class="text-sm text-gray-500 mt-1">Danh sách các vai trò hệ thống và thêm mới</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <c:if test="${not empty param.success}">
                <div class="bg-green-50 border-l-4 border-green-500 p-4 mb-4 rounded-r-lg flex items-center justify-between">
                    <div class="flex items-center"><i class="fas fa-check-circle text-green-500 mr-3"></i><span class="text-green-700">${param.success}</span></div>
                    <button onclick="this.parentElement.remove()" class="text-green-500 hover:text-green-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-4 rounded-r-lg flex items-center justify-between">
                    <div class="flex items-center"><i class="fas fa-exclamation-circle text-red-500 mr-3"></i><span class="text-red-700">${param.error}</span></div>
                    <button onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
                <div class="lg:col-span-2">
                    <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                        <div class="px-6 py-4 border-b bg-gray-50 flex items-center justify-between">
                            <h2 class="text-lg font-semibold text-gray-800"><i class="fas fa-users-cog mr-2 text-blue-500"></i> Vai trò hiện có</h2>
                            <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-xs font-medium border border-blue-200">${roles.size()} vai trò</span>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full">
                                <thead class="bg-gray-50 border-b">
                                    <tr>
                                        <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Trọng số</th>
                                        <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Tên vai trò</th>
                                        <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Mô tả</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-200">
                                    <c:forEach var="r" items="${roles}">
                                        <tr class="hover:bg-gray-50 transition">
                                            <td class="px-4 py-3 text-sm font-medium text-gray-500 text-center w-16">
                                                <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded-lg">${r.roleId}</span>
                                            </td>
                                            <td class="px-4 py-3">
                                                <span class="text-sm font-semibold text-gray-800">${r.roleName}</span>
                                            </td>
                                            <td class="px-4 py-3 text-sm text-gray-600">${r.description}</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty roles}">
                                        <tr><td colspan="3" class="px-4 py-8 text-center text-gray-400"><i class="fas fa-inbox text-4xl mb-3 block"></i>Không có dữ liệu</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-1">
                    <div class="bg-white rounded-lg shadow-sm border sticky top-6 overflow-hidden">
                        <div class="px-6 py-4 border-b bg-gray-50 text-center sm:text-left">
                            <h2 class="text-lg font-semibold text-gray-800"><i class="fas fa-plus-circle mr-2 text-green-500"></i> Thêm vai trò mới</h2>
                        </div>
                        <div class="p-6">
                            <form action="${pageContext.request.contextPath}/role/list" method="POST" class="space-y-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Tên vai trò <span class="text-red-500">*</span></label>
                                    <input type="text" name="roleName" required placeholder="Ví dụ: Kế toán"
                                           class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition text-sm">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Mô tả (Không bắt buộc)</label>
                                    <textarea name="description" rows="4" placeholder="Nhập mô tả chi tiết cho vai trò..."
                                              class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition resize-none text-sm"></textarea>
                                </div>
                                <div class="pt-2">
                                    <button type="submit" class="w-full px-4 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition font-medium flex justify-center items-center shadow-sm">
                                        <i class="fas fa-save mr-2"></i>Lưu vai trò
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</layout:layout>