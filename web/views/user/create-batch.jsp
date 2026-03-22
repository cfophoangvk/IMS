<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/user/list" class="text-gray-500 hover:text-gray-700 transition">
                        <i class="fas fa-arrow-left text-lg"></i>
                    </a>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Tạo tài khoản hàng loạt</h1>
                        <p class="text-sm text-gray-500 mt-1">Tạo nhiều tài khoản cùng lúc. Mật khẩu sẽ được tạo tự động.</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <c:if test="${not empty error}">
                <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded-r-lg">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle text-red-500 mr-3"></i>
                        <span class="text-red-700">${error}</span>
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty results}">
                <div class="bg-white rounded-lg shadow-sm border mb-6">
                    <div class="p-4 border-b bg-gray-50 rounded-t-lg flex items-center justify-between">
                        <div>
                            <h2 class="text-lg font-semibold text-gray-800"><i class="fas fa-clipboard-check mr-2 text-green-600"></i>Kết quả tạo tài khoản</h2>
                            <p class="text-sm text-gray-500 mt-1">
                                Thành công: <span class="font-medium text-green-600">${successCount}</span> | 
                                Thất bại: <span class="font-medium text-red-600">${failCount}</span>
                            </p>
                        </div>
                        <a href="${pageContext.request.contextPath}/user/list" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition">
                            <i class="fas fa-list mr-1"></i> Xem danh sách
                        </a>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full">
                            <thead>
                                <tr class="bg-gray-50 border-b">
                                    <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">#</th>
                                    <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Tên đăng nhập</th>
                                    <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Họ tên</th>
                                    <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Email</th>
                                    <th class="px-4 py-3 text-center text-xs font-semibold text-gray-500 uppercase">Kết quả</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200">
                                <c:forEach var="result" items="${results}" varStatus="loop">
                                    <tr class="hover:bg-gray-50">
                                        <td class="px-4 py-3 text-sm text-gray-500">${loop.index + 1}</td>
                                        <td class="px-4 py-3 text-sm font-medium text-gray-900">${result.username}</td>
                                        <td class="px-4 py-3 text-sm text-gray-700">${result.fullName}</td>
                                        <td class="px-4 py-3 text-sm text-gray-700">${result.email}</td>
                                        <td class="px-4 py-3 text-center">
                                            <c:choose>
                                                <c:when test="${result.status == 'success'}">
                                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                                        <i class="fas fa-check mr-1"></i> ${result.message}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                                        <i class="fas fa-times mr-1"></i> ${result.message}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty results}">
                <div class="bg-white rounded-lg shadow-sm border">
                    <div class="p-4 border-b bg-gray-50 rounded-t-lg flex items-center justify-between">
                        <div>
                            <h2 class="text-lg font-semibold text-gray-800"><i class="fas fa-users mr-2 text-green-600"></i>Danh sách tài khoản mới</h2>
                            <p class="text-sm text-gray-500 mt-1">Thêm thông tin cho từng tài khoản cần tạo</p>
                        </div>
                        <button type="button" id="addRowBtn" class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white text-sm font-medium rounded-lg transition">
                            <i class="fas fa-plus mr-1"></i> Thêm dòng
                        </button>
                    </div>
                    <form action="${pageContext.request.contextPath}/user/create-batch" method="POST" id="batchForm">
                        <div class="overflow-x-auto">
                            <table class="w-full" id="batchTable">
                                <thead>
                                    <tr class="bg-gray-50 border-b">
                                        <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase w-8">#</th>
                                        <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Tên đăng nhập <span class="text-red-500">*</span></th>
                                        <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Họ tên <span class="text-red-500">*</span></th>
                                        <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Email <span class="text-red-500">*</span></th>
                                        <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Vai trò <span class="text-red-500">*</span></th>
                                        <th class="px-4 py-3 text-center text-xs font-semibold text-gray-500 uppercase w-16">Xóa</th>
                                    </tr>
                                </thead>
                                <tbody id="batchBody">
                                    <tr class="border-b batch-row">
                                        <td class="px-4 py-3 text-sm text-gray-500 row-number">1</td>
                                        <td class="px-4 py-2">
                                            <input type="text" name="usernames" required placeholder="nguyenvana" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none">
                                        </td>
                                        <td class="px-4 py-2">
                                            <input type="text" name="fullNames" required placeholder="Nguyễn Văn A" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none">
                                        </td>
                                        <td class="px-4 py-2">
                                            <input type="email" name="emails" required placeholder="nguyenvana@company.com" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none">
                                        </td>
                                        <td class="px-4 py-2">
                                            <select name="roleIds" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none bg-white">
                                                <option value="">-- Chọn --</option>
                                                <c:forEach var="role" items="${roles}">
                                                    <option value="${role.roleId}">${role.roleName}</option>
                                                </c:forEach>
                                            </select>
                                        </td>
                                        <td class="px-4 py-2 text-center">
                                            <button type="button" onclick="removeRow(this)" class="text-red-500 hover:text-red-700 transition" title="Xóa dòng">
                                                <i class="fas fa-trash-alt"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="p-4 border-t flex items-center gap-3">
                            <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg shadow-sm transition duration-200">
                                <i class="fas fa-save mr-2"></i> Tạo tất cả
                            </button>
                            <a href="${pageContext.request.contextPath}/user/list" class="px-6 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium rounded-lg transition">
                                Hủy bỏ
                            </a>
                        </div>
                    </form>
                </div>
            </c:if>
        </div>
    </div>

    <script>
        const roleOptions = document.querySelector('select[name="roleIds"]') ? document.querySelector('select[name="roleIds"]').innerHTML : '';

        document.getElementById('addRowBtn')?.addEventListener('click', function () {
            const tbody = document.getElementById('batchBody');
            const rowCount = tbody.querySelectorAll('.batch-row').length + 1;
            const tr = document.createElement('tr');
            tr.className = 'border-b batch-row';
            tr.innerHTML =
                    '<td class="px-4 py-3 text-sm text-gray-500 row-number">' + rowCount + '</td>' +
                    '<td class="px-4 py-2"><input type="text" name="usernames" required placeholder="nguyenvana" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"></td>' +
                    '<td class="px-4 py-2"><input type="text" name="fullNames" required placeholder="Nguyễn Văn A" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"></td>' +
                    '<td class="px-4 py-2"><input type="email" name="emails" required placeholder="nguyenvana@company.com" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"></td>' +
                    '<td class="px-4 py-2"><select name="roleIds" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none bg-white">' + roleOptions + '</select></td>' +
                    '<td class="px-4 py-2 text-center"><button type="button" onclick="removeRow(this)" class="text-red-500 hover:text-red-700 transition" title="Xóa dòng"><i class="fas fa-trash-alt"></i></button></td>';
            tbody.appendChild(tr);
            updateRowNumbers();
        });

        function removeRow (btn) {
            const tbody = document.getElementById('batchBody');
            if (tbody.querySelectorAll('.batch-row').length <= 1) {
                alert('Phải có ít nhất một dòng.');
                return;
            }
            btn.closest('tr').remove();
            updateRowNumbers();
        }

        function updateRowNumbers () {
            const rows = document.querySelectorAll('#batchBody .batch-row');
            rows.forEach((row, index) => {
                row.querySelector('.row-number').textContent = index + 1;
            });
        }
    </script>
</layout:layout>