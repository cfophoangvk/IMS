<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/transaction/list" class="text-gray-500 hover:text-gray-700"><i class="fas fa-arrow-left"></i></a>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Tạo phiếu mới</h1>
                        <p class="text-sm text-gray-500 mt-1">Nhập/Xuất kho</p>
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
                    <li><strong>Nhập - Nhà cung cấp:</strong> Nhập hàng từ nhà cung cấp vào kho của bạn.</li>
                    <li><strong>Xuất - Nhà cung cấp:</strong> Xuất hàng từ kho của bạn cho khách hàng/đối tác.</li>
                    <li><strong>Nhập - Nội bộ:</strong> Nhận hàng từ kho khác chuyển đến kho của bạn.</li>
                    <li><strong>Xuất - Nội bộ:</strong> Chuyển hàng từ kho của bạn sang kho khác.</li>
                </ul>
            </div>

            <form action="${pageContext.request.contextPath}/transaction/add" method="POST" id="txForm">
                <div class="bg-white rounded-lg shadow-sm border p-6 mb-6">
                    <h2 class="text-lg font-semibold text-gray-800 mb-4">Thông tin phiếu</h2>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Hướng giao dịch <span class="text-red-500">*</span></label>
                            <div class="flex gap-4">
                                <label class="flex items-center gap-2 cursor-pointer px-4 py-2.5 border rounded-lg transition ${direction == 'import' ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:bg-gray-50'}">
                                    <input type="radio" name="direction" value="import" ${direction == 'import' ? 'checked' : ''} class="text-blue-600" required>
                                    <span class="text-sm font-medium">Nhập</span>
                                </label>
                                <label class="flex items-center gap-2 cursor-pointer px-4 py-2.5 border rounded-lg transition ${direction == 'export' ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:bg-gray-50'}">
                                    <input type="radio" name="direction" value="export" ${direction == 'export' ? 'checked' : ''} class="text-blue-600" required>
                                    <span class="text-sm font-medium">Xuất</span>
                                </label>
                            </div>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Nguồn giao dịch <span class="text-red-500">*</span></label>
                            <div class="flex gap-4">
                                <label class="flex items-center gap-2 cursor-pointer px-4 py-2.5 border rounded-lg transition ${source == 'supplier' ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:bg-gray-50'}" id="supplierLabel">
                                    <input type="radio" name="source" value="supplier" ${source == 'supplier' ? 'checked' : ''} class="text-blue-600" required>
                                    <span class="text-sm font-medium">Nhà cung cấp</span>
                                </label>
                                <label class="flex items-center gap-2 cursor-pointer px-4 py-2.5 border rounded-lg transition ${source == 'internal' ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:bg-gray-50'}" id="internalLabel">
                                    <input type="radio" name="source" value="internal" ${source == 'internal' ? 'checked' : ''} class="text-blue-600" required>
                                    <span class="text-sm font-medium">Nội bộ</span>
                                </label>
                            </div>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Ngày giao dịch <span class="text-red-500">*</span></label>
                            <input type="date" name="transactionDate" value="${transactionDate}" required
                                   class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                        </div>

                        <div id="otherWarehouseGroup" style="display:none;">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Chọn kho <span class="text-red-500">*</span></label>
                            <select name="otherWarehouseId" id="otherWarehouseId" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                                <option value="">-- Chọn kho --</option>
                                <c:forEach var="w" items="${warehouses}">
                                    <c:if test="${w.warehouseId != userWarehouseId}">
                                        <option value="${w.warehouseId}" ${otherWarehouseId == w.warehouseId ? 'selected' : ''}>${w.warehouseCode} - ${w.warehouseName}</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </div>
                        <div id="partnerGroup">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Chọn đối tác <span class="text-red-500">*</span></label>
                            <select name="partnerId" id="partnerId" class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                                <option value="">-- Chọn đối tác --</option>
                                <c:forEach var="entry" items="${partnerList}">
                                    <option value="${entry.key}" ${partnerId == entry.key ? 'selected' : ''}>${entry.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow-sm border p-6 mb-6">
                    <h2 class="text-lg font-semibold text-gray-800">Chi tiết sản phẩm</h2>

                    <div class="mb-4 flex items-center gap-2">
                        <label class="block text-sm font-medium text-gray-700 mb-1" for="categoryFilter">Chọn danh mục để lọc sản phẩm:</label>
                        <select id="categoryFilter" onchange="loadProductsByCategory()" class="w-[200px] px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition">
                            <option value="">-- Chọn danh mục --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}">${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                        <button type="button" onclick="addProductRow()" id="btn-add-product" class="ml-auto items-center px-3 py-2 bg-green-600 hover:bg-green-700 text-white text-sm font-medium rounded-lg transition disabled:opacity-50" disabled="true">
                            <i class="fas fa-plus mr-1"></i> Thêm sản phẩm
                        </button>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full" id="detailsTable">
                            <thead class="bg-gray-50 border-b">
                                <tr>
                                    <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600 w-36">Danh mục</th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">Sản phẩm <span class="text-red-500">*</span></th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600 w-32">Số lượng <span class="text-red-500">*</span></th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold text-gray-600 w-36">Đơn giá</th>
                                    <th class="px-3 py-2 text-center text-xs font-semibold text-gray-600 w-16">Xóa</th>
                                </tr>
                            </thead>
                            <tbody id="detailsBody">
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="flex justify-end gap-3">
                    <a href="${pageContext.request.contextPath}/transaction/list" class="px-6 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg transition font-medium">Hủy</a>
                    <button type="submit" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition font-medium">
                        <i class="fas fa-save mr-2"></i>Lưu phiếu
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
                document.getElementById("btn-add-product").disabled = true;
                productsData = [];
                return;
            }
            fetch('${pageContext.request.contextPath}/product/categories?categoryId=' + catId)
                    .then(r => r.json())
                    .then(data => {
                        productsData = data;
                    })
                    .catch(e => console.error(e));
            document.getElementById("btn-add-product").disabled = false;
        }

        function addProductRow () {
            let categoryFilter = document.getElementById("categoryFilter");
            let tbody = document.getElementById('detailsBody');
            let row = document.createElement('tr');
            row.className = 'border-b';
            row.innerHTML =
                    '<td class="px-3 py-2 font-bold">' + categoryFilter.options[categoryFilter.selectedIndex].text + '</td>' +
                    '<td class="px-3 py-2"><select name="productId" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"><option value="">-- Chọn sản phẩm --</option>' +
                    productsData.map(p => '<option value="' + p.productId + '">' + p.productCode + ' - ' + p.productName + (p.unit ? ' (' + p.unit + ')' : '') + '</option>').join('') +
                    '</select></td>' +
                    '<td class="px-3 py-2"><input type="number" name="quantity" step="0.01" min="0.01" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"></td>' +
                    '<td class="px-3 py-2"><input type="number" name="price" step="0.01" min="0" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"></td>' +
                    '<td class="px-3 py-2 text-center"><button type="button" onclick="this.closest(\'tr\').remove()" class="text-red-500 hover:text-red-700"><i class="fas fa-trash"></i></button></td>';
            tbody.appendChild(row);
        }

        function updateSourceVisibility () {
            let source = document.querySelector('input[name="source"]:checked');
            let otherWhGroup = document.getElementById('otherWarehouseGroup');
            let partnerGroup = document.getElementById('partnerGroup');
            if (source && source.value === 'internal') {
                otherWhGroup.style.display = '';
                if (partnerGroup) {
                    partnerGroup.style.display = 'none';
                    document.getElementById('partnerId').value = '';
                }
            } else {
                otherWhGroup.style.display = 'none';
                document.getElementById('otherWarehouseId').value = '';
                if (partnerGroup) partnerGroup.style.display = '';
            }
        }

        function updateRadioStyles (name) {
            document.querySelectorAll('input[name="' + name + '"]').forEach(function (radio) {
                let label = radio.closest('label');
                if (radio.checked) {
                    label.classList.add('border-blue-500', 'bg-blue-50');
                    label.classList.remove('border-gray-300');
                } else {
                    label.classList.remove('border-blue-500', 'bg-blue-50');
                    label.classList.add('border-gray-300');
                }
            });
        }

        document.querySelectorAll('input[name="source"]').forEach(function (radio) {
            radio.addEventListener('change', function () {
                updateSourceVisibility();
                updateRadioStyles('source');
            });
        });

        document.querySelectorAll('input[name="direction"]').forEach(function (radio) {
            radio.addEventListener('change', function () {
                updateRadioStyles('direction');
            });
        });

        updateSourceVisibility();
    </script>
</layout:layout>
