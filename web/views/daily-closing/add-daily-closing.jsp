<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/daily-closing/list" class="text-gray-500 hover:text-gray-700"><i class="fas fa-arrow-left"></i></a>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Chốt sổ ngày</h1>
                        <p class="text-sm text-gray-500 mt-1">Chọn kho và ngày để chốt sổ</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
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

            <!-- Step 1: Select warehouse and date -->
            <div class="bg-white rounded-lg shadow-sm border p-6 mb-6">
                <h2 class="text-lg font-semibold text-gray-800 mb-4"><i class="fas fa-calendar-check mr-2 text-blue-500"></i>Chọn kho và ngày chốt sổ</h2>
                <form action="${pageContext.request.contextPath}/daily-closing/add" method="GET" class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Kho hàng <span class="text-red-500">*</span></label>
                        <select name="warehouseId" required
                                class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                            <option value="">-- Chọn kho --</option>
                            <c:forEach var="w" items="${warehouses}">
                                <option value="${w.warehouseId}" ${selectedWarehouseId == w.warehouseId ? 'selected' : ''}>${w.warehouseCode} - ${w.warehouseName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Ngày chốt sổ <span class="text-red-500">*</span></label>
                        <input type="date" name="closingDate" value="${selectedDate}" required
                               class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                    </div>
                    <button type="submit" class="w-full px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition font-medium">
                        <i class="fas fa-search mr-2"></i>Kiểm tra
                    </button>
                </form>
            </div>

            <!-- Step 2: Show history and confirm -->
            <c:if test="${selectedWarehouseId != null and not empty selectedDate}">
                <div class="bg-white rounded-lg shadow-sm border p-6 mb-6">
                    <h2 class="text-lg font-semibold text-gray-800 mb-4"><i class="fas fa-history mr-2 text-amber-500"></i>Lịch sử chốt sổ</h2>

                    <c:choose>
                        <c:when test="${historyCount > 0}">
                            <div class="bg-amber-50 border-l-4 border-amber-400 p-4 mb-4 rounded-r-lg">
                                <p class="text-amber-700 font-medium text-sm">
                                    <i class="fas fa-info-circle mr-1"></i>
                                    Ngày <fmt:parseDate value="${selectedDate}" pattern="yyyy-MM-dd" var="parsedDate"/>
                                    <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy"/> đã có ${historyCount} lần chốt sổ.
                                </p>
                            </div>
                            <div class="overflow-x-auto mb-4">
                                <table class="w-full text-sm">
                                    <thead class="bg-gray-50 border-b">
                                        <tr>
                                            <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">#</th>
                                            <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">Tổng SP</th>
                                            <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">Trạng thái</th>
                                            <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">Người chốt</th>
                                            <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">Thời gian</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y">
                                        <c:forEach var="h" items="${history}" varStatus="loop">
                                            <tr>
                                                <td class="px-3 py-2">${loop.index + 1}</td>
                                                <td class="px-3 py-2">${h.totalProducts}</td>
                                                <td class="px-3 py-2">
                                                    <c:choose>
                                                        <c:when test="${h.closed}"><span class="text-green-600 font-medium">Đã đóng</span></c:when>
                                                        <c:otherwise><span class="text-yellow-600 font-medium">Đang mở</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="px-3 py-2">${h.createdByName}</td>
                                                <td class="px-3 py-2"><fmt:formatDate value="${h.createdDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="bg-blue-50 border-l-4 border-blue-400 p-4 mb-4 rounded-r-lg">
                                <p class="text-blue-700 text-sm"><i class="fas fa-info-circle mr-1"></i> Chưa có lần chốt sổ nào cho ngày này.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <form action="${pageContext.request.contextPath}/daily-closing/add" method="POST">
                        <input type="hidden" name="warehouseId" value="${selectedWarehouseId}">
                        <input type="hidden" name="closingDate" value="${selectedDate}">
                        <button type="submit" class="w-full px-6 py-3 bg-green-600 hover:bg-green-700 text-white rounded-lg transition font-medium text-lg">
                            <i class="fas fa-lock mr-2"></i>
                            Chốt sổ ngày
                            <fmt:parseDate value="${selectedDate}" pattern="yyyy-MM-dd" var="parsedDate"/>
                            <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy"/>
                        </button>
                    </form>
                </div>
            </c:if>
        </div>
    </div>
</layout:layout>
