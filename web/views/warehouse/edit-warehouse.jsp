<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/warehouse/list" class="text-gray-500 hover:text-gray-700 transition">
                        <i class="fas fa-arrow-left text-lg"></i>
                    </a>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Chỉnh sửa kho hàng</h1>
                        <p class="text-sm text-gray-500 mt-1">Cập nhật thông tin kho: <strong>${warehouse.warehouseCode}</strong></p>
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
                    <h2 class="text-lg font-semibold text-gray-800"><i class="fas fa-edit mr-2 text-blue-600"></i>Thông tin kho hàng</h2>
                </div>
                <form action="${pageContext.request.contextPath}/warehouse/edit" method="POST" class="p-6 space-y-5">
                    <input type="hidden" name="warehouseId" value="${warehouse.warehouseId}">

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Mã kho</label>
                        <input type="text" value="${warehouse.warehouseCode}" disabled
                               class="w-full px-4 py-2.5 border border-gray-200 rounded-lg bg-gray-100 text-gray-500 cursor-not-allowed">
                        <p class="mt-1 text-xs text-gray-400">Mã kho không thể thay đổi</p>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">
                            Tên kho <span class="text-red-500">*</span>
                        </label>
                        <input type="text" name="warehouseName" value="${warehouse.warehouseName}" required
                               class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition">
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Địa chỉ</label>
                        <input type="text" name="location" value="${warehouse.location}"
                               class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition">
                        <p class="mt-1 text-xs text-gray-400">Không bắt buộc</p>
                    </div>

                    <div class="flex items-center gap-3 pt-4 border-t">
                        <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg shadow-sm transition duration-200">
                            <i class="fas fa-save mr-2"></i> Lưu thay đổi
                        </button>
                        <a href="${pageContext.request.contextPath}/warehouse/list" class="px-6 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium rounded-lg transition">
                            Hủy bỏ
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</layout:layout>