<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>
<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center gap-4">
                <a href="${pageContext.request.contextPath}/product/list" class="text-gray-500 hover:text-gray-700"><i class="fas fa-arrow-left text-lg"></i></a>
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Thêm sản phẩm</h1>
                    <p class="text-sm text-gray-500 mt-1">Tạo sản phẩm mới trong hệ thống</p>
                </div>
            </div>
        </div>
        <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <c:if test="${not empty errors}">
                <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded-r-lg">
                    <p class="text-red-800 font-medium"><i class="fas fa-exclamation-triangle mr-2"></i>Vui lòng sửa các lỗi:</p>
                    <ul class="mt-2 text-sm text-red-700 list-disc list-inside">
                        <c:forEach var="e" items="${errors}">
                            <li>${e}</li>
                            </c:forEach>
                    </ul>
                </div>
            </c:if>
            <div class="bg-white rounded-lg shadow-sm border">
                <div class="p-6 border-b bg-gray-50 rounded-t-lg">
                    <h2 class="text-lg font-semibold text-gray-800"><i class="fas fa-box mr-2 text-blue-600"></i>Thông tin sản phẩm</h2>
                </div>
                <form action="${pageContext.request.contextPath}/product/add" method="POST" class="p-6 space-y-5">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Mã sản phẩm <span class="text-red-500">*</span></label>
                        <input type="text" name="productCode" value="${productCode}" required placeholder="VD: SP-001"
                               class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                        <p class="mt-1 text-xs text-gray-400">1-50 ký tự, chỉ chứa chữ cái, số và dấu gạch ngang (-)</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Tên sản phẩm <span class="text-red-500">*</span></label>
                        <input type="text" name="productName" value="${productName}" required placeholder="VD: Gạo ST25 túi 5kg"
                               class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Danh mục <span class="text-red-500">*</span></label>
                        <select name="categoryId" required class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition bg-white">
                            <option value="">-- Chọn danh mục --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}" ${categoryId == cat.categoryId ? 'selected' : ''}>${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Đơn vị tính</label>
                        <input type="text" name="unit" value="${unit}" placeholder="VD: Cái, Hộp, Kg, Thùng..."
                               class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                        <p class="mt-1 text-xs text-gray-400">Không bắt buộc</p>
                    </div>
                    <div class="flex gap-3 pt-4 border-t">
                        <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg shadow-sm transition">
                            <i class="fas fa-plus mr-2"></i> Tạo sản phẩm
                        </button>
                        <a href="${pageContext.request.contextPath}/product/list" class="px-6 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium rounded-lg transition">Hủy bỏ</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</layout:layout>
