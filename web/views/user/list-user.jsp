<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex justify-between items-center">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Quản lý người dùng</h1>
                        <p class="text-sm text-gray-500 mt-1">Danh sách tất cả tài khoản trong hệ thống</p>
                    </div>
                    <div class="flex gap-3">
                        <form id="batchEmailForm" action="${pageContext.request.contextPath}/user/send-email" method="POST" onsubmit="return validateBatchEmail()"></form>
                        <button id="btnSelectBatchEmail" class="items-center px-4 py-2 bg-yellow-400 hover:bg-yellow-500 text-white text-sm font-medium rounded-lg shadow-sm transition duration-200" onclick="toggleSelection(true)" title="Gửi email cho người dùng để nhận tài khoản.">
                            <i class="fas fa-envelope mr-2"></i> Gửi email hàng loạt
                        </button>
                        <button type="submit" form="batchEmailForm" id="btnSendBatchEmail" class="items-center px-4 py-2 bg-yellow-600 hover:bg-yellow-700 text-white text-sm font-medium rounded-lg shadow-sm transition duration-200 hidden">
                            <i class="fas fa-mail-forward mr-2"></i> Gửi
                        </button>
                        <button id="btnCancelBatchEmail" class="items-center px-4 py-2 bg-red-600 hover:bg-red-700 text-white text-sm font-medium rounded-lg shadow-sm transition duration-200 hidden" onclick="toggleSelection(false)">
                            <i class="fas fa-x mr-2"></i> Hủy
                        </button>
                        <a href="${pageContext.request.contextPath}/user/create"
                           class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg shadow-sm transition duration-200">
                            <i class="fas fa-user-plus mr-2"></i> Tạo tài khoản
                        </a>
                        <a href="${pageContext.request.contextPath}/user/create-batch"
                           class="inline-flex items-center px-4 py-2 bg-green-600 hover:bg-green-700 text-white text-sm font-medium rounded-lg shadow-sm transition duration-200">
                            <i class="fas fa-users mr-2"></i> Tạo hàng loạt
                        </a>
                        <a href="${pageContext.request.contextPath}/user/create-excel"
                           class="inline-flex items-center px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium rounded-lg shadow-sm transition duration-200">
                            <i class="fas fa-file-excel mr-2"></i> Nhập Excel
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <c:if test="${not empty param.success}">
                <div id="successAlert" class="bg-green-50 border-l-4 border-green-500 p-4 mb-4 rounded-r-lg flex items-center justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-check-circle text-green-500 mr-3"></i>
                        <span class="text-green-700">${param.success}</span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-green-500 hover:text-green-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div id="errorAlert" class="bg-red-50 border-l-4 border-red-500 p-4 mb-4 rounded-r-lg flex items-center justify-between">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle text-red-500 mr-3"></i>
                        <span class="text-red-700">${param.error}</span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-700"><i class="fas fa-times"></i></button>
                </div>
            </c:if>

            <div class="bg-white rounded-lg shadow-sm border p-4 mb-6">
                <form action="${pageContext.request.contextPath}/user/list" method="GET" class="flex flex-wrap gap-3">
                    <div class="flex-1 min-w-[300px] relative">
                        <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                        <input type="text" name="search" value="${search}" placeholder="Tìm kiếm theo tên đăng nhập, họ tên, email..."
                               class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition">
                    </div>

                    <div class="w-48 relative">
                        <select name="roleId" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition appearance-none bg-white">
                            <option value="">-- Tất cả vai trò --</option>
                            <c:forEach var="r" items="${roles}">
                                <option value="${r.roleId}" ${filterRoleId == r.roleId ? 'selected' : ''}>${r.roleName}</option>
                            </c:forEach>
                        </select>
                        <i class="fas fa-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none text-sm"></i>
                    </div>

                    <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition">
                        <i class="fas fa-filter mr-1"></i> Lọc
                    </button>
                    <c:if test="${not empty search or not empty filterRoleId}">
                        <a href="${pageContext.request.contextPath}/user/list" class="px-4 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg font-medium transition whitespace-nowrap">
                            <i class="fas fa-times mr-1"></i> Xóa bộ lọc
                        </a>
                    </c:if>
                </form>
            </div>

            <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="bg-gray-50 border-b">
                                <th class="px-4 py-3 text-center w-12 hidden" id="th-select">
                                    <input type="checkbox" id="selectAll" class="accent-blue-500 size-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500 cursor-pointer" onclick="toggleAll(this)">
                                </th>
                                <th class="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-center">#</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-center">Tên đăng nhập</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-center">Họ tên</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-center">Email</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-center">Vai trò</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-center">Trạng thái</th>
                                <th class="px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <c:forEach var="user" items="${users}" varStatus="loop">
                                <tr class="hover:bg-gray-50 transition">
                                    <td class="px-4 py-4 text-center td-select hidden">
                                        <c:if test="${user.isFirstLogin()}">
                                            <input type="checkbox" name="userIds" value="${user.userId}" form="batchEmailForm" class="accent-blue-500 size-4 user-checkbox rounded border-gray-300 text-blue-600 focus:ring-blue-500 cursor-pointer">
                                        </c:if>
                                    </td>
                                    <td class="px-4 py-4 text-sm text-gray-500 text-center">${(currentPage - 1) * 10 + loop.index + 1}</td>
                                    <td class="px-6 py-4 text-center">
                                        <span class="text-sm font-medium text-gray-900">${user.username}</span>
                                    </td>
                                    <td class="px-6 py-4 text-sm text-gray-700 text-center">${user.fullName}</td>
                                    <td class="px-6 py-4 text-sm text-gray-700 text-center">${user.email}</td>
                                    <td class="px-6 py-4 text-center">
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-center text-xs font-medium
                                              <c:choose>
                                                  <c:when test="${user.roleId == 1}">bg-purple-100 text-purple-800</c:when>
                                                  <c:when test="${user.roleId == 2}">bg-blue-100 text-blue-800</c:when>
                                                  <c:when test="${user.roleId == 3}">bg-green-100 text-green-800</c:when>
                                                  <c:when test="${user.roleId == 4}">bg-yellow-100 text-yellow-800</c:when>
                                                  <c:when test="${user.roleId == 5}">bg-red-100 text-red-800</c:when>
                                                  <c:otherwise>bg-gray-100 text-gray-800</c:otherwise>
                                              </c:choose>
                                              ">${user.roleName}</span>
                                    </td>
                                    <td class="px-6 py-4 text-center">
                                        <c:choose>
                                            <c:when test="${user.status}">
                                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                                    <i class="fas fa-circle text-green-500 mr-1" style="font-size: 6px;"></i> Hoạt động
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                                    <i class="fas fa-circle text-red-500 mr-1" style="font-size: 6px;"></i> Đã ẩn
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-6 py-4 text-center">
                                        <div class="flex items-center justify-center gap-2">
                                            <a href="${pageContext.request.contextPath}/user/edit?id=${user.userId}"  title="Sửa"
                                               class="inline-flex items-center px-3 py-3 text-sm bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-md transition" title="Sửa">
                                                <i class="fas fa-edit mr-1"></i>
                                            </a>

                                            <c:if test="${account.username ne user.username}">
                                                <form action="${pageContext.request.contextPath}/user/toggle-status" method="POST" class="inline"
                                                      onsubmit="return confirm('Bạn có chắc muốn thay đổi trạng thái tài khoản này?')">
                                                    <input type="hidden" name="id" value="${user.userId}">
                                                    <button type="submit" title="${user.status ? 'Ẩn' : 'Kích hoạt'}"
                                                            class="inline-flex items-center px-3 py-3 text-sm rounded-md transition bg-gray-50 text-gray-600 hover:bg-gray-100">
                                                        <i class="fas ${user.status ? 'fa-ban' : 'fa-unlock'} mr-1"></i>
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty users}">
                                <tr>
                                    <td colspan="8" class="px-6 py-12 text-center text-gray-500">
                                        <i class="fas fa-users text-4xl text-gray-300 mb-3 block"></i>
                                        <p class="text-lg font-medium">Không tìm thấy người dùng</p>
                                        <p class="text-sm mt-1">Thử tìm kiếm với từ khóa khác hoặc tạo tài khoản mới.</p>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <c:if test="${totalPages > 1}">
                    <div class="bg-white px-4 py-3 flex items-center justify-between border-t sm:px-6">
                        <div class="flex-1 flex justify-between sm:hidden">
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/user/list?page=${currentPage - 1}&search=${search}&roleId=${filterRoleId}" 
                                   class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">Trước</a>
                            </c:if>
                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/user/list?page=${currentPage + 1}&search=${search}&roleId=${filterRoleId}" 
                                   class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">Sau</a>
                            </c:if>
                        </div>
                        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-center">
                            <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px">
                                <c:if test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/user/list?page=${currentPage - 1}&search=${search}&roleId=${filterRoleId}"
                                       class="relative inline-flex items-center px-3 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                                        <i class="fas fa-chevron-left"></i>
                                    </a>
                                </c:if>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <a href="${pageContext.request.contextPath}/user/list?page=${i}&search=${search}&roleId=${filterRoleId}"
                                       class="relative inline-flex items-center px-4 py-2 border text-sm font-medium
                                       ${i == currentPage ? 'z-10 bg-blue-50 border-blue-500 text-blue-600' : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'}">
                                        ${i}
                                    </a>
                                </c:forEach>
                                <c:if test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/user/list?page=${currentPage + 1}&search=${search}&roleId=${filterRoleId}"
                                       class="relative inline-flex items-center px-3 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                                        <i class="fas fa-chevron-right"></i>
                                    </a>
                                </c:if>
                            </nav>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <script>
        setTimeout(() => {
            const alerts = document.querySelectorAll('#successAlert, #errorAlert');
            alerts.forEach(alert => {
                alert.style.transition = 'opacity 0.5s';
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 500);
            });
        }, 5000);
        
        function toggleSelection(show) {
            const thSelect = document.getElementById("th-select");
            const tdSelects = document.getElementsByClassName("td-select");
            const btnSelect = document.getElementById("btnSelectBatchEmail");
            const btnCancel = document.getElementById("btnCancelBatchEmail");
            const btnSend = document.getElementById("btnSendBatchEmail");
            
            if (show) {
                thSelect.classList.remove("hidden");
                Array.from(tdSelects).forEach(el => el.classList.remove("hidden"));
                btnSelect.classList.add("hidden");
                btnCancel.classList.remove("hidden");
                btnSend.classList.remove("hidden");
            } else {
                thSelect.classList.add("hidden");
                Array.from(tdSelects).forEach(el => el.classList.add("hidden"));
                btnSelect.classList.remove("hidden");
                btnCancel.classList.add("hidden");
                btnSend.classList.add("hidden");
            }
        }

        function toggleAll (source) {
            const checkboxes = document.querySelectorAll('.user-checkbox');
            checkboxes.forEach(checkbox => {
                checkbox.checked = source.checked;
            });
        }

        function validateBatchEmail () {
            const checkboxes = document.querySelectorAll('.user-checkbox:checked');
            if (checkboxes.length === 0) {
                alert('Vui lòng chọn ít nhất một tài khoản để gửi email!');
                return false;
            }
            return confirm('Bạn có chắc muốn gửi email cho ' + checkboxes.length + ' tài khoản đã chọn?');
        }
    </script>
</layout:layout>