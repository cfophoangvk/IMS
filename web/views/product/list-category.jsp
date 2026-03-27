<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex justify-between items-center">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Danh mục sản phẩm</h1>
                        <p class="text-sm text-gray-500 mt-1">Quản lý các danh mục trong hệ thống</p>
                    </div>
                    <c:set var="loggedUser" value="${sessionScope.account}"/>
                    <c:if test="${loggedUser.roleId == 2}">
                        <a href="${pageContext.request.contextPath}/category/add"
                           class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg shadow-sm transition">
                            <i class="fas fa-plus mr-2"></i> Thêm danh mục
                        </a>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <c:if test="${not empty param.success}">
                <div id="successAlert" class="bg-green-50 border-l-4 border-green-500 p-4 mb-4 rounded-r-lg flex items-center justify-between">
                    <div class="flex items-center"><i class="fas fa-check-circle text-green-500 mr-3"></i><span class="text-green-700">${param.success}</span></div>
                    <button onclick="this.parentElement.remove()" class="text-green-500 hover:text-green-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div id="errorAlert" class="bg-red-50 border-l-4 border-red-500 p-4 mb-4 rounded-r-lg flex items-center justify-between">
                    <div class="flex items-center"><i class="fas fa-exclamation-circle text-red-500 mr-3"></i><span class="text-red-700">${param.error}</span></div>
                    <button onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>

            <div class="bg-white rounded-lg shadow-sm border p-4 mb-6">
                <form action="${pageContext.request.contextPath}/category/list" method="GET" class="flex gap-3">
                    <div class="flex-1 relative">
                        <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                        <input type="text" name="search" value="${search}" placeholder="Tìm kiếm theo tên danh mục..."
                               class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                    </div>
                    <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition">
                        <i class="fas fa-search mr-1"></i> Tìm
                    </button>
                    <c:if test="${not empty search}">
                        <a href="${pageContext.request.contextPath}/category/list" class="px-4 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg font-medium transition">
                            <i class="fas fa-times mr-1"></i> Xóa
                        </a>
                    </c:if>
                </form>
            </div>

            <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                <table class="w-full">
                    <thead>
                        <tr class="bg-gray-50 border-b">
                            <th class="px-4 py-3 text-xs font-semibold text-gray-500 uppercase text-center">#</th>
                            <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-left">Tên danh mục</th>
                            <c:if test="${loggedUser.roleId == 2}"><th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-center">Trạng thái</th></c:if>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                        <c:forEach var="cat" items="${categories}" varStatus="loop">
                            <tr class="hover:bg-gray-50 transition">
                                <td class="px-4 py-4 text-sm text-gray-500 text-center">${(currentPage-1)*10 + loop.index+1}</td>
                                <td class="px-6 py-4 text-sm font-medium text-gray-900"><span class="line-clamp-1" title="${cat.categoryName}">${cat.categoryName}</span></td>
                                <c:if test="${loggedUser.roleId == 2}">
                                    <td class="px-6 py-4 text-center"> 
                                        <c:choose>
                                            <c:when test="${cat.status}">
                                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                                    <i class="fas fa-circle text-green-500 mr-1" style="font-size:6px"></i> Hoạt động
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                                    <i class="fas fa-circle text-red-500 mr-1" style="font-size:6px"></i> Đã ẩn
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </c:if>
                                <td class="px-6 py-4 text-center">
                                    <div class="flex items-center justify-center gap-2">
                                        <a href="${pageContext.request.contextPath}/category/details?id=${cat.categoryId}"
                                           class="inline-flex items-center px-3 py-2 text-sm bg-indigo-50 text-indigo-600 hover:bg-indigo-100 rounded-md transition" title="Chi tiết">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <c:if test="${loggedUser.roleId == 2}">
                                            <a href="${pageContext.request.contextPath}/category/edit?id=${cat.categoryId}"
                                               class="inline-flex items-center px-3 py-2 text-sm bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-md transition" title="Sửa">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <form action="${pageContext.request.contextPath}/category/toggle-status" method="POST" class="inline"
                                                  onsubmit="return confirm('Thay đổi trạng thái danh mục này?')">
                                                <input type="hidden" name="id" value="${cat.categoryId}">
                                                <button type="submit" class="inline-flex items-center px-3 py-2 text-sm bg-gray-50 text-gray-600 hover:bg-gray-100 rounded-md transition"
                                                        title="${cat.status ? 'Ẩn' : 'Kích hoạt'}">
                                                    <i class="fas ${cat.status ? 'fa-ban' : 'fa-unlock'}"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty categories}">
                            <tr><td colspan="4" class="px-6 py-12 text-center text-gray-500">
                                    <i class="fas fa-tags text-4xl text-gray-300 mb-3 block"></i>
                                    <p class="text-lg font-medium">Không tìm thấy danh mục</p>
                                </td></tr>
                            </c:if>
                    </tbody>
                </table>
                <c:if test="${totalPages > 1}">
                    <div class="bg-white px-4 py-3 flex items-center justify-center border-t">
                        <nav class="inline-flex rounded-md shadow-sm -space-x-px">
                            <c:if test="${currentPage > 1}">
                                <a href="?page=${currentPage-1}&search=${search}" class="px-3 py-2 rounded-l-md border border-gray-300 bg-white text-sm text-gray-500 hover:bg-gray-50"><i class="fas fa-chevron-left"></i></a>
                                </c:if>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                <a href="?page=${i}&search=${search}" class="px-4 py-2 border text-sm font-medium ${i==currentPage ? 'z-10 bg-blue-50 border-blue-500 text-blue-600' : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'}">${i}</a>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}">
                                <a href="?page=${currentPage+1}&search=${search}" class="px-3 py-2 rounded-r-md border border-gray-300 bg-white text-sm text-gray-500 hover:bg-gray-50"><i class="fas fa-chevron-right"></i></a>
                                </c:if>
                        </nav>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
    <script>
        setTimeout(() => {
            document.querySelectorAll('#successAlert,#errorAlert').forEach(e => {
                e.style.transition = 'opacity .5s';
                e.style.opacity = '0';
                setTimeout(() => e.remove(), 500);
            });
        }, 5000);
    </script>
</layout:layout>