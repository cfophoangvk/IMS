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
                        <h1 class="text-2xl font-bold text-gray-900">Chi tiết kho hàng</h1>
                        <p class="text-sm text-gray-500 mt-1">Thông tin chi tiết kho: <strong>${warehouse.warehouseCode}</strong></p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                <div class="bg-gradient-to-r from-teal-600 to-cyan-700 px-6 py-8">
                    <div class="flex items-center gap-5">
                        <div class="w-16 h-16 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white text-2xl border-2 border-white/30">
                            <i class="fas fa-warehouse"></i>
                        </div>
                        <div class="text-white">
                            <h2 class="text-2xl font-bold">${warehouse.warehouseName}</h2>
                            <p class="mt-1 text-teal-100 flex items-center gap-2">
                                <i class="fas fa-barcode"></i> ${warehouse.warehouseCode}
                            </p>
                        </div>
                    </div>
                </div>

                <div class="p-6">
                    <div class="grid gap-5">
                        <div class="flex items-center p-4 bg-gray-50 rounded-lg">
                            <div class="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center mr-4">
                                <i class="fas fa-barcode text-blue-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-400 uppercase tracking-wider font-medium">Mã kho</p>
                                <p class="text-gray-900 font-medium mt-0.5">${warehouse.warehouseCode}</p>
                            </div>
                        </div>

                        <div class="flex items-center p-4 bg-gray-50 rounded-lg">
                            <div class="w-10 h-10 rounded-lg bg-green-100 flex items-center justify-center mr-4">
                                <i class="fas fa-warehouse text-green-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-400 uppercase tracking-wider font-medium">Tên kho</p>
                                <p class="text-gray-900 font-medium mt-0.5">${warehouse.warehouseName}</p>
                            </div>
                        </div>

                        <div class="flex items-center p-4 bg-gray-50 rounded-lg">
                            <div class="w-10 h-10 rounded-lg bg-purple-100 flex items-center justify-center mr-4">
                                <i class="fas fa-map-marker-alt text-purple-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-400 uppercase tracking-wider font-medium">Địa chỉ</p>
                                <p class="text-gray-900 font-medium mt-0.5">${warehouse.location != null ? warehouse.location : '— Chưa cập nhật'}</p>
                            </div>
                        </div>

                        <div class="flex items-center p-4 bg-gray-50 rounded-lg">
                            <div class="w-10 h-10 rounded-lg bg-indigo-100 flex items-center justify-center mr-4">
                                <i class="fas fa-circle-check text-indigo-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-400 uppercase tracking-wider font-medium">Trạng thái</p>
                                <c:choose>
                                    <c:when test="${warehouse.status}">
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800 mt-0.5">
                                            <i class="fas fa-circle text-green-500 mr-1" style="font-size: 6px;"></i> Đang hoạt động
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800 mt-0.5">
                                            <i class="fas fa-circle text-red-500 mr-1" style="font-size: 6px;"></i> Vô hiệu
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="flex gap-3 mt-6 pt-4 border-t">
                        <a href="${pageContext.request.contextPath}/warehouse/edit?id=${warehouse.warehouseId}"
                           class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg shadow-sm transition">
                            <i class="fas fa-edit mr-2"></i> Chỉnh sửa
                        </a>
                        <a href="${pageContext.request.contextPath}/warehouse/members?id=${warehouse.warehouseId}"
                           class="px-5 py-2.5 bg-teal-600 hover:bg-teal-700 text-white font-medium rounded-lg shadow-sm transition">
                            <i class="fas fa-users mr-2"></i> Quản lý nhân sự
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</layout:layout>