<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@tag description="Main Layout" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>IMS - Hệ thống quản lý kho</title>
        <script src="${pageContext.request.contextPath}/assets/js/tailwindcss.js"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="icon" href="${pageContext.request.contextPath}/assets/icons/favicon.ico">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
        </style>
    </head>
    <body>
        <c:if test="${empty sessionScope.account}">
            <header class="bg-white shadow-sm sticky top-0 z-50">
                <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div class="flex justify-between items-center h-16">
                        <div class="flex-shrink-0 flex items-center gap-2 cursor-pointer" onclick="location.href = '${pageContext.request.contextPath}/'">
                            <div class="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
                                <jsp:include page="/assets/icons/box.jsp"/>
                            </div>
                            <span class="font-bold text-xl text-slate-900 tracking-tight" title="Inventory Management System">IMS</span>
                        </div>

                        <div class="flex items-center gap-4">
                            <a href="${pageContext.request.contextPath}/auth/login" class="inline-flex items-center justify-center px-5 py-2.5 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-lg shadow-sm transition-all focus:ring-4 focus:ring-blue-100">
                                Đăng nhập hệ thống
                                <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                            </a>
                        </div>
                    </div>
                </div>
            </header>
        </c:if>

        <c:set var="user" value="${sessionScope.account}" />
        <c:if test="${not empty user}">
            <nav class="bg-blue-600 shadow-md">
                <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div class="flex justify-between h-16">
                        <div class="flex items-center space-x-2">
                            <c:choose>
                                <c:when test="${user.roleId == 1}">
                                    <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/dashboard/it-admin" />
                                </c:when>
                                <c:when test="${user.roleId == 2}">
                                    <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/dashboard/system-admin" />
                                </c:when>
                                <c:when test="${user.roleId == 3}">
                                    <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/transaction/list" />
                                </c:when>
                                <c:when test="${user.roleId == 4}">
                                    <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/dashboard/manager" />
                                </c:when>
                                <c:when test="${user.roleId == 5}">
                                    <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/dashboard/business-owner" />
                                </c:when>
                            </c:choose>

                            <a href="${dashboardUrl}" class="text-white font-bold text-xl mr-4 flex items-center">
                                <jsp:include page="/assets/icons/box.jsp"/>IMS
                            </a>

                            <c:if test="${user.roleId == 1}">
                                <a href="${pageContext.request.contextPath}/user/list" class="px-3 py-2 rounded-md text-sm font-medium text-white hover:bg-blue-700 transition" title="Quản lý người dùng"><i class="fas fa-users mr-1"></i>Người dùng</a>
                                <a href="${pageContext.request.contextPath}/role/list" class="px-3 py-2 rounded-md text-sm font-medium text-white hover:bg-blue-700 transition" title="Quản lý vai trò"><i class="fas fa-user-tag mr-1"></i>Vai trò</a>
                            </c:if>

                            <!-- System Admin (2) -->
                            <c:if test="${user.roleId == 2}">
                                <a href="${pageContext.request.contextPath}/warehouse/list" class="px-3 py-2 rounded-md text-sm font-medium text-white hover:bg-blue-700 transition"><i class="fas fa-warehouse mr-1"></i>Kho bãi</a>
                            </c:if>

                            <!-- Goods Management (2, 3, 4, 5) -->
                            <c:if test="${user.roleId >= 2}">
                                <div class="relative group">
                                    <button class="flex items-center px-3 py-2 rounded-md text-sm font-medium text-white hover:bg-blue-700 transition outline-none">
                                        <i class="fas fa-box-open mr-1"></i>Hàng hóa <i class="fas fa-chevron-down ml-1 text-xs"></i>
                                    </button>
                                    <div class="absolute left-0 w-48 mt-1 lg:-mt-1 lg:top-full bg-white rounded-md shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition duration-200 z-50 overflow-hidden text-sm pt-2 lg:pt-0 border border-gray-100">
                                        <a href="${pageContext.request.contextPath}/product/list" class="block px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-700"><i class="fas fa-cubes w-5 text-center mr-1"></i> Sản phẩm</a>
                                        <a href="${pageContext.request.contextPath}/category/list" class="block px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-700 border-t border-gray-50"><i class="fas fa-tags w-5 text-center mr-1"></i> Danh mục</a>
                                    </div>
                                </div>
                            </c:if>

                            <!-- Transactions (3, 4, 5) -->
                            <c:if test="${user.roleId >= 3}">
                                <div class="relative group">
                                    <button class="flex items-center px-3 py-2 rounded-md text-sm font-medium text-white hover:bg-blue-700 transition outline-none">
                                        <i class="fas fa-exchange-alt mr-1"></i>Giao dịch <i class="fas fa-chevron-down ml-1 text-xs"></i>
                                    </button>
                                    <div class="absolute left-0 w-52 mt-1 lg:-mt-1 lg:top-full bg-white rounded-md shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition duration-200 z-50 overflow-hidden text-sm border border-gray-100">
                                        <a href="${pageContext.request.contextPath}/transaction/list" class="block px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-700"><i class="fas fa-file-invoice w-5 text-center mr-1"></i> Nhập/Xuất/Chuyển</a>
                                        <c:if test="${user.roleId == 4}">
                                            <a href="${pageContext.request.contextPath}/transaction/approval-list" class="block px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-700 border-t border-gray-50"><i class="fas fa-clipboard-check w-5 text-center mr-1"></i> Phê duyệt phiếu</a>
                                        </c:if>
                                    </div>
                                </div>
                            </c:if>

                            <!-- Daily Closing (4) -->
                            <c:if test="${user.roleId == 4}">
                                <a href="${pageContext.request.contextPath}/daily-closing/list" class="px-3 py-2 rounded-md text-sm font-medium text-white hover:bg-blue-700 transition"><i class="fas fa-calendar-check mr-1"></i>Chốt sổ</a>
                            </c:if>
                        </div>

                        <!-- Right Side (User Profile & Logout) -->
                        <div class="flex items-center">
                            <div class="relative group">
                                <button class="flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium text-white hover:bg-blue-700 transition outline-none">
                                    <div class="w-7 h-7 bg-white text-blue-600 rounded-full flex items-center justify-center font-bold text-xs uppercase shadow-sm">
                                        ${user.fullName.substring(0, 1)}
                                    </div>
                                    <span class="hidden sm:inline-block">${user.fullName}</span>
                                    <i class="fas fa-chevron-down text-xs"></i>
                                </button>
                                <div class="absolute right-0 w-48 mt-1 lg:-mt-1 lg:top-full bg-white rounded-md shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition duration-200 z-50 overflow-hidden text-sm border border-gray-100">
                                    <a href="${pageContext.request.contextPath}/user/profile" class="block px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-700"><i class="fas fa-id-card w-5 text-center mr-1"></i> Hồ sơ cá nhân</a>
                                    <a href="${pageContext.request.contextPath}/auth/logout" class="block px-4 py-3 text-red-600 hover:bg-red-50 border-t border-gray-50"><i class="fas fa-sign-out-alt w-5 text-center mr-1"></i> Đăng xuất</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </nav>
        </c:if>

        <jsp:doBody />

        <footer class="bg-white border-t border-gray-200 py-10">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row justify-between items-center gap-4">
                <div class="flex items-center gap-2">
                    <div class="w-8 h-8 bg-blue-600 rounded flex items-center justify-center">
                        <jsp:include page="/assets/icons/box.jsp"/>
                    </div>
                    <span class="font-bold text-slate-800">IMS</span>
                </div>
                <p class="text-sm text-slate-500">© ${java.time.Year.now().getValue()} Copyright by cfop_hoangvk. All rights reserved.</p>
            </div>
        </footer>
    </body>
</html>