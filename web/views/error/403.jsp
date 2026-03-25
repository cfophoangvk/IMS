<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>403 - Forbidden | IMS</title>
        <script src="${pageContext.request.contextPath}/assets/js/tailwindcss.js"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            body { font-family: 'Inter', sans-serif; }
        </style>
    </head>
    <body class="bg-gray-50 flex items-center justify-center min-h-screen p-4">
        <div class="max-w-md w-full text-center">
            <!-- Icon -->
            <div class="w-32 h-32 bg-red-100 text-red-500 rounded-full flex items-center justify-center mx-auto mb-8 shadow-inner">
                <i class="fas fa-lock text-6xl"></i>
            </div>
            
            <!-- Content -->
            <h1 class="text-6xl font-bold text-gray-900 mb-4 tracking-tight">403</h1>
            <h2 class="text-2xl font-semibold text-gray-800 mb-3">Truy cập bị từ chối</h2>
            <p class="text-gray-500 mb-8">Bạn không có quyền truy cập vào trang này. Vui lòng liên hệ với quản trị viên nếu bạn cho rằng đây là một sự nhầm lẫn.</p>
            
            <!-- Determine Dashboard URL -->
            <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/auth/login" />
            <c:set var="buttonText" value="Đăng nhập lại" />
            
            <c:if test="${not empty sessionScope.account}">
                <c:set var="roleId" value="${sessionScope.account.roleId}" />
                <c:choose>
                    <c:when test="${roleId == 1}">
                        <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/dashboard/it-admin" />
                        <c:set var="buttonText" value="Về Dashboard IT" />
                    </c:when>
                    <c:when test="${roleId == 2}">
                        <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/dashboard/system-admin" />
                        <c:set var="buttonText" value="Về Dashboard Hệ thống" />
                    </c:when>
                    <c:when test="${roleId == 3}">
                        <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/transaction/list" />
                        <c:set var="buttonText" value="Về trang Giao dịch" />
                    </c:when>
                    <c:when test="${roleId == 4}">
                        <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/dashboard/manager" />
                        <c:set var="buttonText" value="Về Dashboard Quản lý" />
                    </c:when>
                    <c:when test="${roleId == 5}">
                        <c:set var="dashboardUrl" value="${pageContext.request.contextPath}/dashboard/business-owner" />
                        <c:set var="buttonText" value="Về Dashboard Lãnh đạo" />
                    </c:when>
                </c:choose>
            </c:if>

            <!-- Actions -->
            <div class="flex flex-col sm:flex-row justify-center gap-4">
                <a href="${dashboardUrl}" class="inline-flex items-center justify-center px-6 py-3 text-base font-medium text-white bg-blue-600 rounded-lg shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors">
                    <i class="fas fa-home mr-2"></i>${buttonText}
                </a>
                <button onclick="window.history.back()" class="inline-flex items-center justify-center px-6 py-3 text-base font-medium text-gray-700 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors">
                    <i class="fas fa-arrow-left mr-2"></i>Quay lại
                </button>
            </div>
            
            <div class="mt-12 text-sm text-gray-400">
                <p>&copy; ${java.time.Year.now().getValue()} IMS System. All rights reserved.</p>
            </div>
        </div>
    </body>
</html>
