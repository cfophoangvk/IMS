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
                        <p class="text-sm text-gray-500 mt-1">Kiểm tra và chốt sổ giao dịch trong kho của bạn</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <c:if test="${not empty param.success}">
                <div class="bg-green-50 border-l-4 border-green-500 p-4 mb-4 rounded-r-lg flex items-center justify-between shadow-sm">
                    <div class="flex items-center"><i class="fas fa-check-circle text-green-500 mr-3"></i><span class="text-green-700 font-medium">${param.success}</span></div>
                    <button onclick="this.parentElement.remove()" class="text-green-500 hover:text-green-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-4 rounded-r-lg flex items-center justify-between shadow-sm">
                    <div class="flex items-center"><i class="fas fa-exclamation-circle text-red-500 mr-3"></i><span class="text-red-700 font-medium">${param.error}</span></div>
                    <button onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>

            <!-- Step 1: Select date -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-6">
                <h2 class="text-lg font-semibold text-gray-800 mb-5 pb-3 border-b border-gray-100">
                    <i class="fas fa-calendar mr-2 text-blue-500"></i>Thông tin chốt sổ
                </h2>
                <form action="${pageContext.request.contextPath}/daily-closing/add" method="GET" class="space-y-5">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1.5">Kho đang làm việc</label>
                            <input type="text" value="${warehouseName}" readonly disabled
                                   class="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 text-gray-700 rounded-lg selection-none">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1.5">Ngày cần chốt <span class="text-red-500">*</span></label>
                            <div class="flex gap-3">
                                <input type="date" name="closingDate" value="${selectedDate}" required
                                       class="flex-1 px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                                <button type="submit" class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition font-medium shadow-sm flex items-center whitespace-nowrap">
                                    <i class="fas fa-search mr-2"></i>Xem dữ liệu
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Step 2: Show data and confirm -->
            <c:if test="${not empty selectedDate}">
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                    <h2 class="text-lg font-semibold text-gray-800 mb-1">
                        <i class="fas fa-clipboard-list mr-2 text-amber-500"></i>Dữ liệu ngày <fmt:parseDate value="${selectedDate}" pattern="yyyy-MM-dd" var="parsedDate"/><fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy"/>
                    </h2>
                    
                    <c:choose>
                        <c:when test="${isClosed}">
                            <div class="mt-4 p-6 bg-blue-50 rounded-xl border border-blue-100 text-center">
                                <div class="w-16 h-16 bg-blue-100 text-blue-500 rounded-full flex items-center justify-center mx-auto mb-4 text-2xl">
                                    <i class="fas fa-lock"></i>
                                </div>
                                <h3 class="text-lg font-semibold text-blue-800 mb-2">${closedMessage}</h3>
                                <p class="text-blue-600 text-sm max-w-md mx-auto">Kho đã được khóa cho ngày này. Bạn không thể chốt sổ lại trừ khi người quản trị mở lại ngày này.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-sm text-gray-500 mb-5">Danh sách phiếu giao dịch phát sinh trong ngày</p>
                            
                            <c:if test="${pendingCount > 0}">
                                <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-5 rounded-r-lg shadow-sm">
                                    <div class="flex">
                                        <i class="fas fa-exclamation-triangle text-red-500 mt-0.5 mr-3"></i>
                                        <div>
                                            <h3 class="text-red-800 font-medium">Không thể chốt sổ</h3>
                                            <p class="text-red-700 text-sm mt-1">Vẫn còn <strong>${pendingCount}</strong> phiếu chưa được duyệt. Vui lòng duyệt hoặc từ chối tất cả phiếu trong ngày trước khi chốt sổ.</p>
                                        </div>
                                    </div>
                                </div>
                            </c:if>

                            <div class="overflow-hidden border border-gray-200 rounded-lg mb-6">
                                <table class="w-full text-sm">
                                    <thead class="bg-gray-50 border-b border-gray-200">
                                        <tr>
                                            <th class="px-4 py-3 text-center text-xs font-semibold text-gray-600 w-12">STT</th>
                                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600">Mã phiếu</th>
                                            <th class="px-4 py-3 text-center text-xs font-semibold text-gray-600">Loại</th>
                                            <th class="px-4 py-3 text-center text-xs font-semibold text-gray-600">Trạng thái duyệt</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-200">
                                        <c:forEach var="t" items="${transactions}" varStatus="loop">
                                            <tr class="hover:bg-gray-50 transition">
                                                <td class="px-4 py-3 text-center text-gray-500">${loop.index + 1}</td>
                                                <td class="px-4 py-3 font-medium text-blue-600"><a href="${pageContext.request.contextPath}/transaction/details?id=${t.transactionId}" target="_blank" class="hover:underline">${t.transactionCode} <i class="fas fa-external-link-alt text-[10px] ml-1"></i></a></td>
                                                <td class="px-4 py-3 text-center">
                                                    <c:choose>
                                                        <c:when test="${t.transactionType == 1}"><span class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-medium">Nhập - NCC</span></c:when>
                                                        <c:when test="${t.transactionType == 2}"><span class="px-2 py-1 bg-orange-100 text-orange-700 rounded-full text-xs font-medium">Xuất - NCC</span></c:when>
                                                        <c:when test="${t.transactionType == 3}"><span class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium">Nhập - Nội bộ</span></c:when>
                                                        <c:when test="${t.transactionType == 4}"><span class="px-2 py-1 bg-purple-100 text-purple-700 rounded-full text-xs font-medium">Xuất - Nội bộ</span></c:when>
                                                    </c:choose>
                                                </td>
                                                <td class="px-4 py-3 text-center">
                                                    <c:choose>
                                                        <c:when test="${t.approvalStatus == 0}"><span class="px-2 py-1 bg-yellow-100 text-yellow-800 rounded-md text-xs font-medium">Chờ duyệt</span></c:when>
                                                        <c:when test="${t.approvalStatus == 1}"><span class="px-2 py-1 bg-green-100 text-green-800 rounded-md text-xs font-medium">Đã duyệt</span></c:when>
                                                        <c:when test="${t.approvalStatus == 2}"><span class="px-2 py-1 bg-red-100 text-red-800 rounded-md text-xs font-medium">Từ chối</span></c:when>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty transactions}">
                                            <tr>
                                                <td colspan="4" class="px-4 py-8 text-center text-gray-500">
                                                    <div class="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-3 text-gray-400">
                                                        <i class="fas fa-file-invoice"></i>
                                                    </div>
                                                    Không có giao dịch nào được tạo trong ngày này.
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>

                            <form action="${pageContext.request.contextPath}/daily-closing/add" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn chốt sổ và gửi email thông báo cho nhân viên?');">
                                <input type="hidden" name="closingDate" value="${selectedDate}">
                                <div class="bg-gray-50 p-4 rounded-xl border border-gray-200">
                                    <button type="submit" ${pendingCount > 0 ? 'disabled' : ''} 
                                            class="w-full px-6 py-3.5 ${pendingCount > 0 ? 'bg-gray-400 cursor-not-allowed' : 'bg-green-600 hover:bg-green-700 shadow-md hover:shadow-lg'} text-white rounded-lg transition-all font-medium text-lg flex items-center justify-center">
                                        <i class="fas fa-lock mr-2 text-xl"></i>
                                        Xác nhận chốt sổ ngày <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy"/>
                                    </button>
                                    <p class="text-center text-xs text-gray-500 mt-3"><i class="fas fa-envelope mr-1"></i>Hệ thống sẽ ngay lập tức gửi email thông báo đến toàn bộ nhân viên kho.</p>
                                </div>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>
    </div>
</layout:layout>
