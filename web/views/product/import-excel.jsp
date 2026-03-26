<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50 pb-12">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
                <div class="flex items-center">
                    <a href="${pageContext.request.contextPath}/product/list" class="mr-4 text-gray-400 hover:text-gray-600 transition">
                        <i class="fas fa-arrow-left text-xl"></i>
                    </a>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Nhập sản phẩm bằng Excel</h1>
                        <p class="text-sm text-gray-500 mt-1">Tải lên file Excel (.xlsx, .xls) để tạo nhiều sản phẩm cùng lúc</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <c:if test="${not empty error}">
                <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded-r-lg flex items-center shadow-sm">
                    <i class="fas fa-exclamation-circle text-red-500 mr-3"></i>
                    <span class="text-red-700">${error}</span>
                </div>
            </c:if>

            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-8">
                <form action="${pageContext.request.contextPath}/product/import-excel" method="POST" enctype="multipart/form-data" class="space-y-6">
                    <div class="flex flex-col md:flex-row md:items-end gap-6">
                        <div class="flex-1">
                            <label class="block text-sm font-medium text-gray-700 mb-2">Chọn file Excel</label>
                            <label class="flex flex-col items-center justify-center w-full h-32 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-gray-50 hover:bg-gray-100 transition-colors group relative">
                                <div class="flex flex-col items-center justify-center pt-5 pb-6">
                                    <i class="fas fa-cloud-upload-alt text-3xl text-gray-400 group-hover:text-green-500 transition-colors mb-3"></i>
                                    <p class="mb-2 text-sm text-gray-500"><span class="font-bold">Nhấn để chọn file</span> hoặc kéo thả vào đây</p>
                                    <p class="text-xs text-gray-500">Hỗ trợ định dạng XLS, XLSX</p>
                                </div>
                                <input id="file" name="file" type="file" class="hidden" accept=".xlsx, .xls" required onchange="updateFileName(this)" />
                            </label>
                            <p id="fileNameDisplay" class="mt-2 text-sm text-green-600 font-medium hidden">
                                <i class="fas fa-file-excel mr-1"></i> <span id="fileNameText"></span>
                            </p>
                        </div>

                        <div class="flex flex-col items-center gap-3 pb-1">
                            <a class="bg-blue-500 text-white px-6 py-2.5 hover:bg-blue-600 text-sm font-medium rounded-lg font-medium transition" href="${pageContext.request.contextPath}/product/import-excel/template" download="product-template.xlsx"><i class="fas fa-download mr-1"></i>Tải xuống file mẫu</a>
                            <button id="btnSubmit" type="submit" class="w-full md:w-auto px-6 py-2.5 bg-green-600 hover:bg-green-700 text-white font-medium rounded-lg shadow-sm transition disabled:opacity-50 cursor-pointer" disabled="true">
                                <i class="fas fa-file-import mr-2"></i>Tiến hành Nhập
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <c:if test="${not empty results}">
                <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                    <div class="px-6 py-5 border-b border-gray-200 bg-gray-50/50 flex justify-between items-center">
                        <h2 class="text-lg font-semibold text-gray-800">
                            Kết quả xử lý file Excel
                        </h2>
                        <div class="flex gap-4">
                            <span class="inline-flex items-center px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-medium">
                                <i class="fas fa-check-circle mr-1.5"></i>Thành công: <strong>${successCount}</strong>
                            </span>
                            <span class="inline-flex items-center px-3 py-1 bg-red-100 text-red-800 rounded-full text-sm font-medium">
                                <i class="fas fa-times-circle mr-1.5"></i>Thất bại: <strong>${failCount}</strong>
                            </span>
                        </div>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-sm text-left">
                            <thead class="text-xs text-gray-500 uppercase bg-gray-50/50 border-b border-gray-200">
                                <tr>
                                    <th class="px-6 py-3 font-semibold text-center">STT</th>
                                    <th class="px-6 py-3 font-semibold">Mã SP</th>
                                    <th class="px-6 py-3 font-semibold">Tên sản phẩm</th>
                                    <th class="px-6 py-3 font-semibold">Danh mục</th>
                                    <th class="px-6 py-3 font-semibold">Đơn vị</th>
                                    <th class="px-6 py-3 font-semibold text-center">Trạng thái</th>
                                    <th class="px-6 py-3 font-semibold">Chi tiết lỗi / Thông báo</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <c:forEach var="item" items="${results}" varStatus="loop">
                                    <tr class="hover:bg-gray-50 transition-colors ${item.status == 'error' ? 'bg-red-50/20' : ''}">
                                        <td class="px-6 py-4 text-center text-gray-500">${loop.index + 1}</td>
                                        <td class="px-6 py-4">
                                            <span class="font-mono text-sm font-medium text-blue-700 bg-blue-50 px-2 py-1 rounded">${item.productCode}</span>
                                        </td>
                                        <td class="px-6 py-4 font-medium text-gray-900">${item.productName}</td>
                                        <td class="px-6 py-4 text-gray-700">
                                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">${item.categoryName}</span>
                                        </td>
                                        <td class="px-6 py-4 text-gray-600">${not empty item.unit ? item.unit : '—'}</td>
                                        <td class="px-6 py-4 text-center">
                                            <c:choose>
                                                <c:when test="${item.status == 'success'}">
                                                    <span class="inline-flex items-center justify-center p-1.5 bg-green-100 text-green-600 rounded-full" title="Thành công">
                                                        <i class="fas fa-check w-4 h-4 text-center leading-4"></i>
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="inline-flex items-center justify-center p-1.5 bg-red-100 text-red-600 rounded-full" title="Thất bại">
                                                        <i class="fas fa-times w-4 h-4 text-center leading-4"></i>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="px-6 py-4">
                                            <span class="${item.status == 'error' ? 'text-red-600 font-medium' : 'text-green-600'}">
                                                ${item.message}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>
        </div>
    </div>

    <script>
        function updateFileName (input) {
            const display = document.getElementById('fileNameDisplay');
            const text = document.getElementById('fileNameText');
            const btnSubmit = document.getElementById("btnSubmit");
            if (input.files && input.files[0]) {
                text.textContent = input.files[0].name;
                display.classList.remove('hidden');
                btnSubmit.disabled = false;
            } else {
                display.classList.add('hidden');
                btnSubmit.disabled = true;
            }
        }
    </script>
</layout:layout>
