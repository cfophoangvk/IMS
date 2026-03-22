<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/warehouse/members?id=${warehouse.warehouseId}" class="text-gray-500 hover:text-gray-700 transition">
                        <i class="fas fa-arrow-left text-lg"></i>
                    </a>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Thêm nhân sự</h1>
                        <p class="text-sm text-gray-500 mt-1">
                            Phân công nhân sự vào kho: <span class="font-medium text-gray-700">${warehouse.warehouseName}</span>
                            <span class="text-gray-300 mx-1">|</span>
                            <span class="font-mono text-blue-600">${warehouse.warehouseCode}</span>
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <!-- Error -->
            <c:if test="${not empty param.error}">
                <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded-r-lg">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle text-red-500 mr-3"></i>
                        <span class="text-red-700">${param.error}</span>
                    </div>
                </div>
            </c:if>

            <div class="bg-white rounded-lg shadow-sm border">
                <div class="p-6 border-b bg-gray-50 rounded-t-lg">
                    <h2 class="text-lg font-semibold text-gray-800"><i class="fas fa-user-plus mr-2 text-teal-600"></i>Chọn nhân sự</h2>
                    <p class="text-sm text-gray-500 mt-1">Chỉ hiển thị nhân viên kho và quản lý kho chưa được phân công vào kho này.</p>
                </div>

                <c:choose>
                    <c:when test="${not empty availableUsers}">
                        <form action="${pageContext.request.contextPath}/warehouse/member/upsert" method="POST" class="p-6 space-y-5">
                            <input type="hidden" name="warehouseId" value="${warehouse.warehouseId}">

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">
                                    Nhân viên <span class="text-red-500">*</span>
                                </label>
                                <select name="userId" required
                                        class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition bg-white">
                                    <option value="">-- Chọn nhân viên --</option>
                                    <c:forEach var="u" items="${availableUsers}">
                                        <option value="${u.userId}">${u.fullName} (${u.username}) — ${u.roleName}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="flex items-center gap-3 pt-4 border-t">
                                <button type="submit" class="px-6 py-2.5 bg-teal-600 hover:bg-teal-700 text-white font-medium rounded-lg shadow-sm transition duration-200">
                                    <i class="fas fa-plus mr-2"></i> Thêm nhân sự
                                </button>
                                <a href="${pageContext.request.contextPath}/warehouse/members?id=${warehouse.warehouseId}"
                                   class="px-6 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium rounded-lg transition">
                                    Hủy bỏ
                                </a>
                            </div>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <div class="p-12 text-center text-gray-500">
                            <i class="fas fa-user-check text-4xl text-gray-300 mb-3 block"></i>
                            <p class="text-lg font-medium">Không còn nhân sự khả dụng</p>
                            <p class="text-sm mt-1">Tất cả nhân viên kho và quản lý kho đã được phân công vào kho này.</p>
                            <a href="${pageContext.request.contextPath}/warehouse/members?id=${warehouse.warehouseId}"
                               class="inline-flex items-center mt-4 px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 text-sm font-medium rounded-lg transition">
                                <i class="fas fa-arrow-left mr-2"></i> Quay lại
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</layout:layout>