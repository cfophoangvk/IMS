<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex justify-between items-center">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Chốt sổ ngày</h1>
                        <p class="text-sm text-gray-500 mt-1">Danh sách các ngày đã chốt sổ</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/daily-closing/add"
                       class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg shadow-sm transition">
                        <i class="fas fa-plus mr-2"></i> Chốt sổ mới
                    </a>
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

            <!-- Filter -->
            <div class="bg-white rounded-lg shadow-sm border p-4 mb-6">
                <form action="${pageContext.request.contextPath}/daily-closing/list" method="GET" class="flex flex-wrap gap-3">
                    <div class="w-64">
                        <select name="warehouseId" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition appearance-none bg-white">
                            <option value="">-- Tất cả kho --</option>
                            <c:forEach var="w" items="${warehouses}">
                                <option value="${w.warehouseId}" ${filterWarehouseId == w.warehouseId ? 'selected' : ''}>${w.warehouseCode} - ${w.warehouseName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition font-medium">
                        <i class="fas fa-filter mr-2"></i>Lọc
                    </button>
                </form>
            </div>

            <!-- Table -->
            <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50 border-b">
                            <tr>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">#</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Kho</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Ngày chốt</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Tổng SP</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Người chốt</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Trạng thái</th>
                                <th class="px-4 py-3 text-center text-xs font-semibold text-gray-600 uppercase">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <c:forEach var="dc" items="${closings}" varStatus="loop">
                                <tr class="hover:bg-gray-50 transition">
                                    <td class="px-4 py-3 text-sm text-gray-500">${(currentPage - 1) * 10 + loop.index + 1}</td>
                                    <td class="px-4 py-3 text-sm font-medium text-gray-700">${dc.warehouseName}</td>
                                    <td class="px-4 py-3 text-sm text-gray-700"><fmt:formatDate value="${dc.closingDate}" pattern="dd/MM/yyyy"/></td>
                                    <td class="px-4 py-3 text-sm text-gray-700">${dc.totalProducts}</td>
                                    <td class="px-4 py-3 text-sm text-gray-700">${dc.createdByName}</td>
                                    <td class="px-4 py-3 text-sm">
                                        <c:choose>
                                            <c:when test="${dc.closed}"><span class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-medium"><i class="fas fa-lock mr-1"></i>Đã đóng</span></c:when>
                                            <c:otherwise><span class="px-2 py-1 bg-yellow-100 text-yellow-700 rounded-full text-xs font-medium"><i class="fas fa-lock-open mr-1"></i>Đang mở</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-4 py-3 text-center">
                                        <form action="${pageContext.request.contextPath}/daily-closing/toggle" method="POST" class="inline">
                                            <input type="hidden" name="id" value="${dc.closingId}">
                                            <button type="submit" class="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg transition
                                                    ${dc.closed ? 'text-yellow-700 bg-yellow-50 hover:bg-yellow-100' : 'text-green-700 bg-green-50 hover:bg-green-100'}">
                                                <i class="fas ${dc.closed ? 'fa-lock-open' : 'fa-lock'} mr-1"></i>
                                                ${dc.closed ? 'Mở lại' : 'Đóng lại'}
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty closings}">
                                <tr>
                                    <td colspan="7" class="px-4 py-8 text-center text-gray-400">
                                        <div class="flex justify-center items-center gap-3">
                                            <i class="fas fa-inbox text-4xl mb-3 block"></i>
                                            <span>Chưa có dữ liệu chốt sổ</span>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <c:if test="${totalPages > 1}">
                <div class="flex justify-center mt-6 gap-1">
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <a href="${pageContext.request.contextPath}/daily-closing/list?page=${i}&warehouseId=${filterWarehouseId}"
                           class="px-3 py-2 text-sm rounded-lg ${i == currentPage ? 'bg-blue-600 text-white' : 'bg-white text-gray-700 border hover:bg-gray-50'} transition">
                            ${i}
                        </a>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </div>
</layout:layout>
