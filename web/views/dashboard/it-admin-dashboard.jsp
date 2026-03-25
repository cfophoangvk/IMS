<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50/50 pb-12">
        <div class="bg-white border-b border-gray-200">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900 tracking-tight">IT Admin Dashboard</h1>
                        <p class="text-sm text-gray-500 mt-1">Tổng quan hoạt động và quản trị tài khoản hệ thống</p>
                    </div>
                    <div class="flex items-center gap-3">
                        <a href="${pageContext.request.contextPath}/user/add" 
                           class="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-lg hover:bg-blue-700 shadow-sm transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                            <i class="fas fa-plus mr-2"></i>Tạo tài khoản mới
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-blue-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Tổng số tài khoản</p>
                            <h3 class="text-3xl font-bold text-gray-900">${totalUsers}</h3>
                        </div>
                        <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-users"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-emerald-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Đang hoạt động</p>
                            <h3 class="text-3xl font-bold text-gray-900">${activeUsers}</h3>
                        </div>
                        <div class="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-user-check"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-rose-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Đã khóa</p>
                            <h3 class="text-3xl font-bold text-gray-900">${lockedUsers}</h3>
                        </div>
                        <div class="w-12 h-12 bg-rose-100 text-rose-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-user-lock"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-amber-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Chưa đổi mật khẩu</p>
                            <h3 class="text-3xl font-bold text-gray-900">${firstLoginUsers}</h3>
                        </div>
                        <div class="w-12 h-12 bg-amber-100 text-amber-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-key"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div class="lg:col-span-2">
                    <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                        <div class="px-6 py-5 border-b border-gray-200 bg-gray-50/50 flex justify-between items-center">
                            <h2 class="text-lg font-semibold text-gray-800">
                                <i class="fas fa-clock text-blue-500 mr-2"></i>Hoạt động gần đây
                            </h2>
                            <a href="${pageContext.request.contextPath}/user/list" class="text-sm text-blue-600 hover:text-blue-700 font-medium">Xem tất cả &rarr;</a>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm text-left">
                                <thead class="text-xs text-gray-500 uppercase bg-gray-50/50 border-b border-gray-200">
                                    <tr>
                                        <th class="px-6 py-4 font-semibold">Tài khoản</th>
                                        <th class="px-6 py-4 font-semibold">Vai trò</th>
                                        <th class="px-6 py-4 font-semibold">Trạng thái</th>
                                        <th class="px-6 py-4 font-semibold text-right">Cập nhật</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100">
                                    <c:forEach var="u" items="${recentUsers}">
                                        <tr class="hover:bg-gray-50/50 transition-colors">
                                            <td class="px-6 py-4">
                                                <div class="flex items-center">
                                                    <div class="h-8 w-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold text-xs uppercase shadow-sm border border-blue-200 mr-3">
                                                        ${u.fullName.substring(0, 1)}
                                                    </div>
                                                    <div>
                                                        <div class="font-medium text-gray-900">${u.fullName}</div>
                                                        <div class="text-gray-500 text-xs">${u.username}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4">
                                                <span class="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-medium bg-gray-100 text-gray-800 border border-gray-200">
                                                    ${u.roleName}
                                                </span>
                                            </td>
                                            <td class="px-6 py-4">
                                                <c:choose>
                                                    <c:when test="${u.status}">
                                                        <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                            <span class="w-1.5 h-1.5 bg-emerald-500 rounded-full mr-1.5"></span>Kích hoạt
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-rose-50 text-rose-700 border border-rose-200">
                                                            <span class="w-1.5 h-1.5 bg-rose-500 rounded-full mr-1.5"></span>Đã khóa
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="px-6 py-4 text-right text-gray-500 text-xs whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${not empty u.updatedDate}">
                                                        <fmt:formatDate value="${u.updatedDate}" pattern="dd/MM/yy HH:mm" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <fmt:formatDate value="${u.createdDate}" pattern="dd/MM/yy HH:mm" />
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty recentUsers}">
                                        <tr>
                                            <td colspan="4" class="px-6 py-8 text-center text-gray-500">Chưa có dữ liệu</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-1">
                    <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                        <div class="px-5 py-4 border-b border-gray-200 bg-amber-50/50">
                            <h2 class="text-base font-semibold text-amber-900 flex items-center">
                                <i class="fas fa-exclamation-triangle text-amber-500 mr-2"></i>
                                Chú ý: Chưa phân kho (${unassignedUsers.size()})
                            </h2>
                        </div>
                        <div class="p-4 ${unassignedUsers.size() > 0 ? 'max-h-[400px] overflow-y-auto' : ''}">
                            <c:if test="${empty unassignedUsers}">
                                <div class="text-center py-6">
                                    <div class="w-12 h-12 bg-green-50 text-green-500 rounded-full flex items-center justify-center mx-auto mb-3">
                                        <i class="fas fa-check"></i>
                                    </div>
                                    <p class="text-sm text-gray-500">Tất cả nhân viên đã được phân kho.</p>
                                </div>
                            </c:if>

                            <c:if test="${not empty unassignedUsers}">
                                <p class="text-xs text-gray-500 mb-4">Các nhân viên/quản lý sau <strong>chưa được phân công</strong> vào bất kỳ kho nào. Họ sẽ không thể thao tác nghiệp vụ.</p>
                                <ul class="space-y-3">
                                    <c:forEach var="u" items="${unassignedUsers}">
                                        <li class="bg-gray-50 border border-gray-100 rounded-lg p-3 hover:border-blue-300 transition-colors">
                                            <div class="flex justify-between items-start">
                                                <div>
                                                    <div class="text-sm font-medium text-gray-900">${u.fullName}</div>
                                                    <div class="text-xs text-gray-500 mb-1">${u.username} • ${u.roleName}</div>
                                                </div>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/user/edit?id=${u.userId}" class="text-xs text-blue-600 hover:text-blue-800 font-medium inline-flex items-center mt-1">
                                                Cập nhật ngay <i class="fas fa-arrow-right ml-1 text-[10px]"></i>
                                            </a>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</layout:layout>