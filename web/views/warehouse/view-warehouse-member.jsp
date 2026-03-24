<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex justify-between items-center">
                    <div class="flex items-center gap-4">
                        <a href="${pageContext.request.contextPath}/warehouse/details?id=${warehouse.warehouseId}" class="text-gray-500 hover:text-gray-700 transition">
                            <i class="fas fa-arrow-left text-lg"></i>
                        </a>
                        <div>
                            <h1 class="text-2xl font-bold text-gray-900">Nhân sự kho hàng</h1>
                            <p class="text-sm text-gray-500 mt-1">
                                Kho: <span class="font-medium text-gray-700">${warehouse.warehouseName}</span>
                                <span class="text-gray-300 mx-1">|</span>
                                <span class="font-mono text-blue-600">${warehouse.warehouseCode}</span>
                            </p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/warehouse/member/upsert?warehouseId=${warehouse.warehouseId}"
                       class="inline-flex items-center px-4 py-2 bg-teal-600 hover:bg-teal-700 text-white text-sm font-medium rounded-lg shadow-sm transition duration-200">
                        <i class="fas fa-user-plus mr-2"></i> Thêm nhân sự
                    </a>
                </div>
            </div>
        </div>

        <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <c:if test="${not empty param.success}">
                <div id="successAlert" class="bg-green-50 border-l-4 border-green-500 p-4 mb-4 rounded-r-lg flex items-center justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-check-circle text-green-500 mr-3"></i>
                        <span class="text-green-700">${param.success}</span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-green-500 hover:text-green-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div id="errorAlert" class="bg-red-50 border-l-4 border-red-500 p-4 mb-4 rounded-r-lg flex items-center justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle text-red-500 mr-3"></i>
                        <span class="text-red-700">${param.error}</span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>

            <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="bg-gray-50 border-b">
                                <th class="px-4 py-3 text-xs font-semibold text-gray-500 uppercase text-center">#</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-center">Tên đăng nhập</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-center">Họ tên</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-center">Email</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-center">Vai trò</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                        <c:forEach var="m" items="${members}" varStatus="loop">
                            <tr class="hover:bg-gray-50 transition">
                                <td class="px-4 py-4 text-sm text-gray-500 text-center">${loop.index + 1}</td>
                                <td class="px-6 py-4 text-center">
                                    <span class="text-sm font-medium text-gray-900">${m.username}</span>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-700 text-center">${m.fullName}</td>
                                <td class="px-6 py-4 text-sm text-gray-700 text-center">${m.email}</td>
                                <td class="px-6 py-4 text-center">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium
                                          ${m.roleId == 4 ? 'bg-yellow-100 text-yellow-800' : 'bg-green-100 text-green-800'}">
                                        ${m.roleName}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <form action="${pageContext.request.contextPath}/warehouse/member/remove" method="POST" class="inline"
                                          onsubmit="return confirm('Bạn có chắc muốn xóa ${m.fullName} khỏi kho này?')">
                                        <input type="hidden" name="userId" value="${m.userId}">
                                        <input type="hidden" name="warehouseId" value="${warehouse.warehouseId}">
                                        <button type="submit" class="inline-flex items-center px-3 py-2 text-sm bg-red-50 text-red-600 hover:bg-red-100 rounded-md transition" title="Xóa">
                                            <i class="fas fa-user-minus mr-1"></i> Xóa
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty members}">
                            <tr>
                                <td colspan="6" class="px-6 py-12 text-center text-gray-500">
                                    <i class="fas fa-users text-4xl text-gray-300 mb-3 block"></i>
                                    <p class="text-lg font-medium">Chưa có nhân sự nào trong kho này</p>
                                    <p class="text-sm mt-1">Bấm "Thêm nhân sự" để phân công nhân viên hoặc quản lý.</p>
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        setTimeout(() => {
            document.querySelectorAll('#successAlert, #errorAlert').forEach(el => {
                el.style.transition = 'opacity 0.5s';
                el.style.opacity = '0';
                setTimeout(() => el.remove(), 500);
            });
        }, 5000);
    </script>
</layout:layout>