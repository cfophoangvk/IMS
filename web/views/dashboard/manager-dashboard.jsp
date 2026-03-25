<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50/50 pb-12">
        <div class="bg-white border-b border-gray-200">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-4">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900 tracking-tight">Quản lý <span class="text-blue-600">${warehouseName}</span></h1>
                        <p class="text-sm text-gray-500 mt-1">Tổng quan hoạt động và giao dịch cần xử lý hôm nay</p>
                    </div>
                    <div class="flex flex-wrap items-center gap-3">
                        <a href="${pageContext.request.contextPath}/transaction/add" 
                           class="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-lg hover:bg-blue-700 shadow-sm transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                            <i class="fas fa-plus mr-2"></i>Lập phiếu mới
                        </a>
                        <c:choose>
                            <c:when test="${todayClosed}">
                                <span class="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-400 bg-gray-100 border border-gray-200 rounded-lg cursor-not-allowed">
                                    <i class="fas fa-lock mr-2"></i>Đã chốt sổ
                                </span>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/daily-closing/add?closingDate=<fmt:formatDate value="<%=new java.util.Date()%>" pattern="yyyy-MM-dd" />" 
                                   class="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-white bg-green-600 border border-transparent rounded-lg hover:bg-green-700 shadow-sm transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500">
                                    <i class="fas fa-calendar-check mr-2"></i>Chốt sổ hôm nay
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${todayClosed}">
                        <div class="bg-blue-50 border border-blue-200 text-blue-800 rounded-lg px-4 py-3 text-sm flex items-center shadow-sm">
                            <i class="fas fa-info-circle text-blue-500 mr-2 text-lg"></i>
                            <div>Trạng thái chốt sổ hôm nay (${todayDate}): <strong class="text-blue-700">Đã chốt</strong>. Các giao dịch mới thực hiện trong hôm nay sẽ bị khóa lại.</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="bg-amber-50 border border-amber-200 text-amber-800 rounded-lg px-4 py-3 text-sm flex items-center shadow-sm">
                            <i class="fas fa-exclamation-circle text-amber-500 mr-2 text-lg"></i>
                            <div>Trạng thái chốt sổ hôm nay (${todayDate}): <strong class="text-amber-700">Chưa chốt</strong>. Vui lòng hoàn tất duyệt phiếu và chốt sổ cuối ngày làm việc.</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-blue-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Tổng tồn hiện tại</p>
                            <h3 class="text-3xl font-bold text-gray-900"><fmt:formatNumber value="${warehouseStock}" pattern="#,##0.##"/></h3>
                        </div>
                        <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-boxes"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border ${pendingCount > 0 ? 'border-red-300 ring-1 ring-red-300' : 'border-gray-100'} p-6 flex flex-col relative overflow-hidden group transition-all">
                    <div class="absolute right-0 top-0 w-24 h-24 ${pendingCount > 0 ? 'bg-red-50' : 'bg-green-50'} rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium ${pendingCount > 0 ? 'text-red-600' : 'text-gray-500'} mb-1">Phiếu chờ duyệt</p>
                            <h3 class="text-3xl font-bold ${pendingCount > 0 ? 'text-red-700' : 'text-gray-900'}">${pendingCount}</h3>
                        </div>
                        <div class="w-12 h-12 ${pendingCount > 0 ? 'bg-red-100 text-red-600' : 'bg-green-100 text-green-600'} rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-bell"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-emerald-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Nhập hôm nay</p>
                            <h3 class="text-3xl font-bold text-gray-900"><fmt:formatNumber value="${todayImport}" pattern="#,##0.##"/></h3>
                        </div>
                        <div class="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-arrow-down"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-orange-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Xuất hôm nay</p>
                            <h3 class="text-3xl font-bold text-gray-900"><fmt:formatNumber value="${todayExport}" pattern="#,##0.##"/></h3>
                        </div>
                        <div class="w-12 h-12 bg-orange-100 text-orange-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-arrow-up"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                <div class="bg-white rounded-xl shadow-sm border border-red-200 overflow-hidden">
                    <div class="px-5 py-4 bg-red-50/50 border-b border-red-100">
                        <h2 class="text-base font-semibold text-red-800 flex items-center">
                            <i class="fas fa-times-circle text-red-500 mr-2"></i>Đã hết hàng (${outOfStockProducts.size()})
                        </h2>
                    </div>
                    <div class="p-4 ${outOfStockProducts.size() > 0 ? 'max-h-[240px] overflow-y-auto' : ''}">
                        <c:if test="${empty outOfStockProducts}">
                            <p class="text-sm text-gray-500 text-center py-4">Không có sản phẩm nào hết hàng.</p>
                        </c:if>
                        <c:if test="${not empty outOfStockProducts}">
                            <ul class="space-y-2">
                                <c:forEach var="p" items="${outOfStockProducts}">
                                    <li class="flex items-center text-sm py-2 px-3 bg-red-50/30 rounded-md border border-red-50">
                                        <i class="fas fa-minus text-red-400 mr-2 text-xs"></i>
                                        <span class="font-medium text-gray-800">${p.productName}</span>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:if>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-sm border border-amber-200 overflow-hidden">
                    <div class="px-5 py-4 bg-amber-50/50 border-b border-amber-100">
                        <h2 class="text-base font-semibold text-amber-800 flex items-center">
                            <i class="fas fa-exclamation-triangle text-amber-500 mr-2"></i>Sắp hết hàng (${lowStockProducts.size()}) <span class="text-xs font-normal text-amber-600 ml-2">(Tồn &lt; 10)</span>
                        </h2>
                    </div>
                    <div class="p-4 ${lowStockProducts.size() > 0 ? 'max-h-[240px] overflow-y-auto' : ''}">
                        <c:if test="${empty lowStockProducts}">
                            <p class="text-sm text-gray-500 text-center py-4">Tất cả sản phẩm đều có số dư an toàn.</p>
                        </c:if>
                        <c:if test="${not empty lowStockProducts}">
                            <ul class="space-y-2">
                                <c:forEach var="p" items="${lowStockProducts}">
                                    <li class="flex justify-between items-center text-sm py-2 px-3 bg-amber-50/30 rounded-md border border-amber-50">
                                        <span class="font-medium text-gray-800">${p.productName}</span>
                                        <span class="font-bold text-amber-600 bg-amber-100 px-2 py-0.5 rounded text-xs"><fmt:formatNumber value="${p.quantity}" pattern="#,##0.##"/> ${p.unit}</span>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:if>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
                <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden h-full">
                    <div class="px-6 py-5 border-b border-gray-200 bg-gray-50/50 flex justify-between items-center">
                        <h2 class="text-lg font-semibold text-gray-800">
                            <i class="fas fa-clipboard-list text-rose-500 mr-2"></i>Chờ Duyệt & Xử Lý (${pendingTransactions.size()})
                        </h2>
                        <a href="${pageContext.request.contextPath}/transaction/approval-list" class="text-sm text-blue-600 hover:text-blue-700 font-medium">Đến trang Duyệt &rarr;</a>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm text-left">
                            <thead class="text-xs text-gray-500 uppercase bg-gray-100/50 border-b border-gray-200">
                                <tr>
                                    <th class="px-5 py-3 font-semibold">Mã GD</th>
                                    <th class="px-5 py-3 font-semibold">Loại</th>
                                    <th class="px-5 py-3 font-semibold text-center hidden sm:table-cell">Ngày tạo</th>
                                    <th class="px-5 py-3 font-semibold text-right"></th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <c:forEach var="t" items="${pendingTransactions}">
                                    <tr class="hover:bg-rose-50/30 transition-colors">
                                        <td class="px-5 py-3 font-medium text-blue-600">${t.transactionCode}</td>
                                        <td class="px-5 py-3">
                                            <c:choose>
                                                <c:when test="${t.transactionType == 1}"><span class="px-2 py-1 bg-green-100 text-green-700 rounded text-xs font-medium">Nhập (NCC)</span></c:when>
                                                <c:when test="${t.transactionType == 2}"><span class="px-2 py-1 bg-orange-100 text-orange-700 rounded text-xs font-medium">Xuất (NCC)</span></c:when>
                                                <c:when test="${t.transactionType == 3}">
                                                    <c:choose>
                                                        <c:when test="${t.toWarehouseId == sessionScope.account.warehouseId}"><span class="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs font-medium">Nhập (Nội bộ)</span></c:when>
                                                        <c:otherwise><span class="px-2 py-1 bg-purple-100 text-purple-700 rounded text-xs font-medium">Xuất (Nội bộ)</span></c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td class="px-5 py-3 text-center text-gray-500 hidden sm:table-cell">
                                            <fmt:formatDate value="${t.createdDate}" pattern="dd/MM HH:mm" />
                                        </td>
                                        <td class="px-5 py-3 text-right">
                                            <a href="${pageContext.request.contextPath}/transaction/details?id=${t.transactionId}" 
                                               class="inline-flex items-center text-xs font-medium text-blue-600 hover:text-white border border-blue-600 hover:bg-blue-600 px-2.5 py-1 rounded transition-colors focus:ring-2 focus:outline-none focus:ring-blue-300">
                                                Duyệt <i class="fas fa-chevron-right ml-1 text-[10px]"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty pendingTransactions}">
                                    <tr>
                                        <td colspan="4" class="px-5 py-10 text-center text-gray-500">
                                            <div class="w-12 h-12 bg-green-50 text-green-500 rounded-full flex items-center justify-center mx-auto mb-3 text-xl">
                                                <i class="fas fa-check-double"></i>
                                            </div>
                                            Tuyệt vời! Không còn phiếu nào chờ duyệt.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden h-full">
                    <div class="px-6 py-5 border-b border-gray-200 bg-gray-50/50 flex justify-between items-center">
                        <h2 class="text-lg font-semibold text-gray-800">
                            <i class="fas fa-check-circle text-emerald-500 mr-2"></i>Lịch sử kiểm duyệt gần đây
                        </h2>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm text-left">
                            <thead class="text-xs text-gray-500 uppercase bg-gray-100/50 border-b border-gray-200">
                                <tr>
                                    <th class="px-5 py-3 font-semibold">Mã GD</th>
                                    <th class="px-5 py-3 font-semibold">Loại</th>
                                    <th class="px-5 py-3 font-semibold hidden sm:table-cell">Người duyệt</th>
                                    <th class="px-5 py-3 font-semibold text-right">Lúc</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <c:forEach var="t" items="${recentApproved}">
                                    <tr class="hover:bg-gray-50/50 transition-colors">
                                        <td class="px-5 py-3 font-medium text-gray-700">
                                            <a href="${pageContext.request.contextPath}/transaction/details?id=${t.transactionId}" class="hover:text-blue-600 hover:underline">
                                                ${t.transactionCode}
                                            </a>
                                        </td>
                                        <td class="px-5 py-3">
                                            <c:choose>
                                                <c:when test="${t.transactionType == 1}"><span class="px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs font-medium border">Nhập (NCC)</span></c:when>
                                                <c:when test="${t.transactionType == 2}"><span class="px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs font-medium border">Xuất (NCC)</span></c:when>
                                                <c:when test="${t.transactionType == 3}">
                                                    <c:choose>
                                                        <c:when test="${t.toWarehouseId == sessionScope.account.warehouseId}"><span class="px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs font-medium border">Nhập (Nội bộ)</span></c:when>
                                                        <c:otherwise><span class="px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs font-medium border">Xuất (Nội bộ)</span></c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td class="px-5 py-3 text-gray-600 text-xs hidden sm:table-cell">${t.approvedByName}</td>
                                        <td class="px-5 py-3 text-right text-gray-500 text-xs whitespace-nowrap">
                                            <fmt:formatDate value="${t.approvedDate}" pattern="dd/MM/yy HH:mm" />
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recentApproved}">
                                    <tr>
                                        <td colspan="4" class="px-5 py-8 text-center text-gray-500">Chưa có lịch sử.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</layout:layout>