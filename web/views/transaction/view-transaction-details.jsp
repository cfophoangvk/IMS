<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/transaction/list" class="text-gray-500 hover:text-gray-700"><i class="fas fa-arrow-left"></i></a>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Chi tiết phiếu: ${tx.transactionCode}</h1>
                        <p class="text-sm text-gray-500 mt-1">Xem thông tin chi tiết giao dịch</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
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

            <!-- Transaction Info -->
            <div class="bg-white rounded-lg shadow-sm border p-6 mb-6">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="text-lg font-semibold text-gray-800">Thông tin phiếu</h2>
                    <c:choose>
                        <c:when test="${tx.approvalStatus == 0}"><span class="px-3 py-1.5 bg-yellow-100 text-yellow-700 rounded-full text-sm font-medium"><i class="fas fa-clock mr-1"></i>Chờ duyệt</span></c:when>
                        <c:when test="${tx.approvalStatus == 1}"><span class="px-3 py-1.5 bg-green-100 text-green-700 rounded-full text-sm font-medium"><i class="fas fa-check-circle mr-1"></i>Đã duyệt</span></c:when>
                        <c:when test="${tx.approvalStatus == 2}"><span class="px-3 py-1.5 bg-red-100 text-red-700 rounded-full text-sm font-medium"><i class="fas fa-times-circle mr-1"></i>Đã từ chối</span></c:when>
                    </c:choose>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                    <div><span class="text-gray-500">Mã phiếu:</span> <span class="font-medium text-gray-800 ml-2">${tx.transactionCode}</span></div>
                    <div><span class="text-gray-500">Loại phiếu:</span>
                        <c:choose>
                            <c:when test="${tx.transactionType == 1}"><span class="ml-2 px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-medium">Nhập - Nhà cung cấp</span></c:when>
                            <c:when test="${tx.transactionType == 2}"><span class="ml-2 px-2 py-1 bg-orange-100 text-orange-700 rounded-full text-xs font-medium">Xuất - Nhà cung cấp</span></c:when>
                            <c:when test="${tx.transactionType == 3}"><span class="ml-2 px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium">Nhập - Nội bộ</span></c:when>
                            <c:when test="${tx.transactionType == 4}"><span class="ml-2 px-2 py-1 bg-purple-100 text-purple-700 rounded-full text-xs font-medium">Xuất - Nội bộ</span></c:when>
                        </c:choose>
                    </div>
                    <div><span class="text-gray-500">Ngày giao dịch:</span> <span class="font-medium text-gray-800 ml-2"><fmt:formatDate value="${tx.transactionDate}" pattern="dd/MM/yyyy"/></span></div>
                    <div><span class="text-gray-500">Người tạo:</span> <span class="font-medium text-gray-800 ml-2">${tx.createdByName}</span></div>
                        <c:if test="${tx.fromWarehouseId > 0}">
                        <div><span class="text-gray-500">Kho từ:</span> <span class="font-medium text-gray-800 ml-2">${tx.fromWarehouseName}</span></div>
                        </c:if>
                        <c:if test="${tx.toWarehouseId > 0}">
                        <div><span class="text-gray-500">Kho đến:</span> <span class="font-medium text-gray-800 ml-2">${tx.toWarehouseName}</span></div>
                        </c:if>
                        <c:if test="${tx.partnerId > 0}">
                        <div><span class="text-gray-500">Đối tác:</span> <span class="font-medium text-gray-800 ml-2">${tx.partnerName}</span></div>
                        </c:if>
                        <c:if test="${not empty tx.notes}">
                        <div class="md:col-span-2"><span class="text-gray-500">Ghi chú:</span> <span class="font-medium text-gray-800 ml-2">${tx.notes}</span></div>
                        </c:if>
                        <c:if test="${tx.approvalStatus != 0}">
                        <div><span class="text-gray-500">Người duyệt:</span> <span class="font-medium text-gray-800 ml-2">${tx.approvedByName}</span></div>
                        <div><span class="text-gray-500">Ngày duyệt:</span> <span class="font-medium text-gray-800 ml-2"><fmt:formatDate value="${tx.approvedDate}" pattern="dd/MM/yyyy HH:mm"/></span></div>
                        </c:if>
                </div>
            </div>

            <!-- Product Details Table -->
            <div class="bg-white rounded-lg shadow-sm border p-6 mb-6">
                <h2 class="text-lg font-semibold text-gray-800 mb-4">Chi tiết sản phẩm</h2>
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50 border-b">
                            <tr>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600">#</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600">Mã SP</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600">Tên sản phẩm</th>
                                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600">ĐVT</th>
                                <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600">Số lượng</th>
                                <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600">Đơn giá</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <c:forEach var="d" items="${details}" varStatus="loop">
                                <tr class="hover:bg-gray-50">
                                    <td class="px-4 py-3 text-sm text-gray-500">${loop.index + 1}</td>
                                    <td class="px-4 py-3 text-sm font-medium text-blue-600">${d.productCode}</td>
                                    <td class="px-4 py-3 text-sm text-gray-700">${d.productName}</td>
                                    <td class="px-4 py-3 text-sm text-gray-500">${d.unit}</td>
                                    <td class="px-4 py-3 text-sm text-gray-700 text-right"><fmt:formatNumber value="${d.quantity}" maxFractionDigits="2"/></td>
                                    <td class="px-4 py-3 text-sm text-gray-700 text-right">
                                        <c:if test="${d.price != null}"><fmt:formatNumber value="${d.price}" maxFractionDigits="2"/></c:if>
                                        <c:if test="${d.price == null}">—</c:if>
                                        </td>
                                    </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Approve/Reject Buttons for Manager -->
            <c:set var="u" value="${sessionScope.account}"/>
            <c:if test="${u.roleId == 4 and tx.approvalStatus == 0}">
                <div class="bg-white rounded-lg shadow-sm border p-6">
                    <h2 class="text-lg font-semibold text-gray-800 mb-4">Phê duyệt</h2>
                    <c:if test="${dateClosed}">
                        <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-4 rounded-r-lg">
                            <p class="text-yellow-700 text-sm"><i class="fas fa-exclamation-triangle mr-1"></i> Ngày giao dịch đã được chốt sổ. Không thể duyệt hoặc từ chối phiếu này.</p>
                        </div>
                    </c:if>
                    <c:if test="${!dateClosed}">
                        <div class="flex gap-3">
                            <form action="${pageContext.request.contextPath}/transaction/approve" method="POST" onsubmit="return confirm('Hành động này không thể hoàn tác. Bạn có chắc chắn muốn duyệt phiếu này?')">
                                <input type="hidden" name="id" value="${tx.transactionId}">
                                <button type="submit" class="inline-flex items-center px-5 py-2.5 bg-green-600 hover:bg-green-700 text-white font-medium rounded-lg transition">
                                    <i class="fas fa-check mr-2"></i> Duyệt phiếu
                                </button>
                            </form>
                            <form action="${pageContext.request.contextPath}/transaction/reject" method="POST" onsubmit="return confirm('Hành động này không thể hoàn tác. Bạn có chắc chắn muốn từ chối phiếu này?')">
                                <input type="hidden" name="id" value="${tx.transactionId}">
                                <button type="submit" class="inline-flex items-center px-5 py-2.5 bg-red-600 hover:bg-red-700 text-white font-medium rounded-lg transition">
                                    <i class="fas fa-times mr-2"></i> Từ chối
                                </button>
                            </form>
                        </div>
                    </c:if>
                </div>
            </c:if>

            <!-- Already processed badge -->
            <c:if test="${u.roleId == 4 and tx.approvalStatus == 1}">
                <div class="bg-green-50 border-l-4 border-green-500 p-4 rounded-r-lg">
                    <p class="text-green-700 font-medium"><i class="fas fa-check-circle mr-2"></i>Đã duyệt bởi ${tx.approvedByName} lúc <fmt:formatDate value="${tx.approvedDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                </div>
            </c:if>
            <c:if test="${u.roleId == 4 and tx.approvalStatus == 2}">
                <div class="bg-red-50 border-l-4 border-red-500 p-4 rounded-r-lg">
                    <p class="text-red-700 font-medium"><i class="fas fa-times-circle mr-2"></i>Đã từ chối bởi ${tx.approvedByName} lúc <fmt:formatDate value="${tx.approvedDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                </div>
            </c:if>
        </div>
    </div>
</layout:layout>
