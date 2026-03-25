<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Phiếu chờ duyệt</h1>
                    <p class="text-sm text-gray-500 mt-1">Danh sách các phiếu nhập/xuất/chuyển đang chờ phê duyệt</p>
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
                <form action="${pageContext.request.contextPath}/transaction/approval-list" method="GET" class="flex flex-wrap gap-3">
                    <div class="flex-1 min-w-[200px] relative">
                        <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                        <input type="text" name="search" value="${search}" placeholder="Tìm theo mã phiếu..."
                               class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                    </div>
                    <div class="w-48">
                        <select name="type" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition bg-white">
                            <option value="">-- Loại phiếu --</option>
                            <option value="1" ${filterType == 1 ? 'selected' : ''}>Nhập - Nhà cung cấp</option>
                            <option value="2" ${filterType == 2 ? 'selected' : ''}>Xuất - Nhà cung cấp</option>
                            <option value="3" ${filterType == 3 ? 'selected' : ''}>Nhập - Nội bộ</option>
                            <option value="4" ${filterType == 4 ? 'selected' : ''}>Xuất - Nội bộ</option>
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
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Mã phiếu</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Loại</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Ngày GD</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Từ kho</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Đến kho</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Người tạo</th>
                                <th class="px-4 py-3 text-center text-xs font-semibold text-gray-600 uppercase">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <c:forEach var="t" items="${transactions}" varStatus="loop">
                                <tr class="hover:bg-gray-50 transition" id="row-${t.transactionId}">
                                    <td class="px-4 py-3 text-sm text-gray-500">${(currentPage - 1) * 10 + loop.index + 1}</td>
                                    <td class="px-4 py-3"><span class="text-sm font-medium text-blue-600">${t.transactionCode}</span></td>
                                    <td class="px-4 py-3 text-sm">
                                        <c:choose>
                                            <c:when test="${t.transactionType == 1}"><span class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-medium">Nhập - NCC</span></c:when>
                                            <c:when test="${t.transactionType == 2}"><span class="px-2 py-1 bg-orange-100 text-orange-700 rounded-full text-xs font-medium">Xuất - NCC</span></c:when>
                                            <c:when test="${t.transactionType == 3}"><span class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium">Nhập - Nội bộ</span></c:when>
                                            <c:when test="${t.transactionType == 4}"><span class="px-2 py-1 bg-purple-100 text-purple-700 rounded-full text-xs font-medium">Xuất - Nội bộ</span></c:when>
                                        </c:choose>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-gray-700"><fmt:formatDate value="${t.transactionDate}" pattern="dd/MM/yyyy"/></td>
                                    <td class="px-4 py-3 text-sm text-gray-700">${not empty t.fromWarehouseName ? t.fromWarehouseName : '—'}</td>
                                    <td class="px-4 py-3 text-sm text-gray-700">${not empty t.toWarehouseName ? t.toWarehouseName : '—'}</td>
                                    <td class="px-4 py-3 text-sm text-gray-700">${t.createdByName}</td>
                                    <td class="px-4 py-3 text-center" id="action-${t.transactionId}">
                                        <a href="${pageContext.request.contextPath}/transaction/details?id=${t.transactionId}"
                                           class="inline-flex items-center px-2.5 py-1.5 text-xs font-medium text-blue-700 bg-blue-50 hover:bg-blue-100 rounded-lg transition">
                                            <i class="fas fa-eye mr-1"></i> Chi tiết
                                        </a>
                                        <form action="${pageContext.request.contextPath}/transaction/approve" method="POST" class="inline"
                                              onsubmit="return confirm('Hành động này không thể hoàn tác. Bạn có chắc chắn muốn duyệt?')">
                                            <input type="hidden" name="id" value="${t.transactionId}">
                                            <button type="submit" class="inline-flex items-center px-2.5 py-1.5 text-xs font-medium text-green-700 bg-green-50 hover:bg-green-100 rounded-lg transition ml-1">
                                                <i class="fas fa-check mr-1"></i> Duyệt
                                            </button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/transaction/reject" method="POST" class="inline"
                                              onsubmit="return confirm('Hành động này không thể hoàn tác. Bạn có chắc chắn muốn từ chối?')">
                                            <input type="hidden" name="id" value="${t.transactionId}">
                                            <button type="submit" class="inline-flex items-center px-2.5 py-1.5 text-xs font-medium text-red-700 bg-red-50 hover:bg-red-100 rounded-lg transition ml-1">
                                                <i class="fas fa-times mr-1"></i> Từ chối
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty transactions}">
                                <tr>
                                    <td colspan="8" class="px-4 py-8 text-center text-gray-400">
                                        <div class="flex justify-center items-center gap-3">
                                            <i class="fas fa-inbox text-4xl mb-3 block"></i>
                                            <span>Không có phiếu nào chờ duyệt</span>
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
                        <a href="${pageContext.request.contextPath}/transaction/approval-list?page=${i}&search=${search}&type=${filterType}"
                           class="px-3 py-2 text-sm rounded-lg ${i == currentPage ? 'bg-blue-600 text-white' : 'bg-white text-gray-700 border hover:bg-gray-50'} transition">
                            ${i}
                        </a>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </div>
</layout:layout>
