<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/transaction/list" class="text-gray-500 hover:text-gray-700"><i class="fas fa-arrow-left"></i></a>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Chỉnh sửa phiếu: ${tx.transactionCode}</h1>
                        <p class="text-sm text-gray-500 mt-1">Cập nhật thông tin phiếu nhập/xuất/chuyển</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <c:if test="${not empty errors}">
                <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-4 rounded-r-lg">
                    <c:forEach var="err" items="${errors}"><p class="text-red-700 text-sm">${err}</p></c:forEach>
                    </div>
            </c:if>

            <div class="bg-blue-50 border-l-4 border-blue-400 p-4 mb-6 rounded-r-lg">
                <p class="text-blue-800 font-semibold text-sm mb-2"><i class="fas fa-info-circle mr-1"></i> Hướng dẫn</p>
                <ul class="text-blue-700 text-sm space-y-1">
                    <li><strong>Nhập ngoài:</strong> Kho đến = kho nhận hàng. Kho từ để trống.</li>
                    <li><strong>Xuất ngoài:</strong> Kho từ = kho xuất hàng. Kho đến để trống.</li>
                    <li><strong>Chuyển nội bộ:</strong> Cần cả Kho từ và Kho đến (phải khác nhau).</li>
                </ul>
            </div>

            <form action="${pageContext.request.contextPath}/transaction/edit" method="POST" id="txForm">
                <input type="hidden" name="transactionId" value="${tx.transactionId}">
                <div class="bg-white rounded-lg shadow-sm border p-6 mb-6">
                    <h2 class="text-lg font-semibold text-gray-800 mb-4">Thông tin phiếu</h2>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Mã phiếu</label>
                            <input type="text" value="${tx.transactionCode}" readonly
                                   class="w-full px-4 py-2.5 bg-gray-100 border border-gray-300 rounded-lg text-gray-500">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Loại phiếu <span class="text-red-500">*</span></label>
                            <select name="transactionType" id="transactionType" required
                                    class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                                <option value="1" ${tx.transactionType == 1 ? 'selected' : ''}>Nhập ngoài</option>
                                <option value="2" ${tx.transactionType == 2 ? 'selected' : ''}>Xuất ngoài</option>
                                <option value="3" ${tx.transactionType == 3 ? 'selected' : ''}>Chuyển nội bộ</option>
                            </select>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Ngày giao dịch <span class="text-red-500">*</span></label>
                            <input type="date" name="transactionDate" value="<fmt:formatDate value='${tx.transactionDate}' pattern='yyyy-MM-dd'/>" required
                                   class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                        </div>
                        <div id="fromWarehouseGroup">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Kho từ (xuất)</label>
                            <select name="fromWarehouseId" id="fromWarehouseId"
                                    class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                                <option value="">-- Chọn kho --</option>
                                <c:forEach var="w" items="${warehouses}">
                                    <option value="${w.warehouseId}" ${tx.fromWarehouseId == w.warehouseId ? 'selected' : ''}>${w.warehouseCode} - ${w.warehouseName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div id="toWarehouseGroup">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Kho đến (nhận)</label>
                            <select name="toWarehouseId" id="toWarehouseId"
                                    class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                                <option value="">-- Chọn kho --</option>
                                <c:forEach var="w" items="${warehouses}">
                                    <option value="${w.warehouseId}" ${tx.toWarehouseId == w.warehouseId ? 'selected' : ''}>${w.warehouseCode} - ${w.warehouseName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-span-full">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Đối tác</label>
                            <select name="partnerId" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                                <option value="">-- Chọn đối tác --</option>
                                <c:forEach var="entry" items="${partnerList}">
                                    <option value="${entry.key}" ${tx.partnerId == entry.key ? 'selected' : ''}>${entry.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <c:set var="u" value="${sessionScope.account}"/>
                        <c:if test="${u.roleId == 4}">
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 mb-1">Ghi chú (Notes)</label>
                                <textarea name="notes" rows="3" placeholder="Ghi chú cho nhân viên..."
                                          class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">${tx.notes}</textarea>
                            </div>
                        </c:if>
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow-sm border p-6 mb-6">
                    <h2 class="text-lg font-semibold text-gray-800">Chi tiết sản phẩm</h2>

                    <div class="mb-4 items-center gap-2">
                        <label class="block text-sm font-medium text-gray-700 mb-1">Chọn danh mục để lọc sản phẩm</label>
                        <select id="categoryFilter" onchange="loadProductsByCategory()" class="w-full md:w-1/2 px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                            <option value="">-- Chọn danh mục --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}">${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                        <button type="button" onclick="addProductRow()" class="ml-auto items-center px-3 py-2 bg-green-600 hover:bg-green-700 text-white text-sm font-medium rounded-lg transition">
                            <i class="fas fa-plus mr-1"></i> Thêm sản phẩm
                        </button>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full" id="detailsTable">
                            <thead class="bg-gray-50 border-b">
                                <tr>
                                    <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600 w-36">Danh mục</th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">Sản phẩm</th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600 w-32">Số lượng</th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600 w-36">Đơn giá</th>
                                    <th class="px-3 py-2 text-center text-xs font-semibold text-gray-600 w-16">Xóa</th>
                                </tr>
                            </thead>
                            <tbody id="detailsBody">
                                <c:forEach var="d" items="${details}">
                                    <tr class="border-b">
                                        <td class="px-3 py-2">${d.categoryName}</td>
                                        <td class="px-3 py-2">
                                            <select name="productId" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none">
                                                <option value="${d.productId}" selected>${d.productCode} - ${d.productName}</option>
                                            </select>
                                        </td>
                                        <td class="px-3 py-2"><input type="number" name="quantity" step="0.01" min="0.01" value="${d.quantity}" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"></td>
                                        <td class="px-3 py-2"><input type="number" name="price" step="0.01" min="0" value="${d.price}" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"></td>
                                        <td class="px-3 py-2 text-center"><button type="button" onclick="this.closest('tr').remove()" class="text-red-500 hover:text-red-700"><i class="fas fa-trash"></i></button></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="flex justify-end gap-3">
                    <a href="${pageContext.request.contextPath}/transaction/list" class="px-6 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition font-medium">Hủy</a>
                    <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition font-medium">
                        <i class="fas fa-save mr-2"></i>Cập nhật
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        var productsData = [];

        function loadProductsByCategory () {
            let catId = document.getElementById('categoryFilter').value;
            if (!catId) {
                productsData = [];
                return;
            }
            fetch('${pageContext.request.contextPath}/api/products-by-category?categoryId=' + catId)
                    .then(r => r.json())
                    .then(data => {
                        productsData = data;
                    })
                    .catch(e => console.error(e));
        }

        function addProductRow () {
            let categoryFilter = document.getElementById("categoryFilter");
            let tbody = document.getElementById('detailsBody');
            let row = document.createElement('tr');
            row.className = 'border-b';
            row.innerHTML =
                    '<td class="px-3 py-2 font-bold">' + categoryFilter.options[categoryFilter.selectedIndex].text + '</td>' +
                    '<td class="px-3 py-2"><select name="productId" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"><option value="">-- Chọn --</option>' +
                    productsData.map(p => '<option value="' + p.productId + '">' + p.productCode + ' - ' + p.productName + (p.unit ? ' (' + p.unit + ')' : '') + '</option>').join('') +
                    '</select></td>' +
                    '<td class="px-3 py-2"><input type="number" name="quantity" step="0.01" min="0.01" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"></td>' +
                    '<td class="px-3 py-2"><input type="number" name="price" step="0.01" min="0" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"></td>' +
                    '<td class="px-3 py-2 text-center"><button type="button" onclick="this.closest(\'tr\').remove()" class="text-red-500 hover:text-red-700"><i class="fas fa-trash"></i></button></td>';
            tbody.appendChild(row);
        }

        document.getElementById('transactionType').addEventListener('change', function () {
            let type = this.value;
            document.getElementById('fromWarehouseGroup').style.display = (type === '2' || type === '3') ? '' : 'none';
            document.getElementById('toWarehouseGroup').style.display = (type === '1' || type === '3') ? '' : 'none';
            if (type === '1')
                document.getElementById('fromWarehouseId').value = '';
            if (type === '2')
                document.getElementById('toWarehouseId').value = '';
        });
        document.getElementById('transactionType').dispatchEvent(new Event('change'));
    </script>
</layout:layout>
