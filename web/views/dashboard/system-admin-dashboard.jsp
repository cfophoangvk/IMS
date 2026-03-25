<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <div class="min-h-screen bg-gray-50/50 pb-12">
        <div class="bg-white border-b border-gray-200">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900 tracking-tight">System Admin Dashboard</h1>
                        <p class="text-sm text-gray-500 mt-1">Quản lý danh mục, hàng hóa và hệ thống kho bãi</p>
                    </div>
                    <div class="flex flex-wrap items-center gap-3">
                        <a href="${pageContext.request.contextPath}/product/add" 
                           class="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-lg hover:bg-blue-700 shadow-sm transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                            <i class="fas fa-plus mr-2"></i>Thêm sản phẩm
                        </a>
                        <a href="${pageContext.request.contextPath}/warehouse/list" 
                           class="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 shadow-sm transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                            <i class="fas fa-user-tag mr-2 text-blue-500"></i>Phân quyền Kho
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-indigo-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Tổng sản phẩm</p>
                            <h3 class="text-3xl font-bold text-gray-900">${totalProducts}</h3>
                        </div>
                        <div class="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-boxes"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-teal-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Tổng danh mục</p>
                            <h3 class="text-3xl font-bold text-gray-900">${totalCategories}</h3>
                        </div>
                        <div class="w-12 h-12 bg-teal-100 text-teal-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-tags"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-[0_2px_10px_-3px_rgba(6,81,237,0.1)] border border-gray-100 p-6 flex flex-col relative overflow-hidden group">
                    <div class="absolute right-0 top-0 w-24 h-24 bg-orange-50 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                    <div class="flex justify-between items-start relative z-10">
                        <div>
                            <p class="text-sm font-medium text-gray-500 mb-1">Hệ thống kho bãi</p>
                            <h3 class="text-3xl font-bold text-gray-900">${totalWarehouses} <span class="text-base font-normal text-gray-500">cơ sở</span></h3>
                        </div>
                        <div class="w-12 h-12 bg-orange-100 text-orange-600 rounded-lg flex items-center justify-center text-xl shadow-inner">
                            <i class="fas fa-warehouse"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 xl:grid-cols-3 gap-8">
                <div class="xl:col-span-2">
                    <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden h-full">
                        <div class="px-6 py-5 border-b border-gray-200 bg-gray-50/50 flex justify-between items-center">
                            <h2 class="text-lg font-semibold text-gray-800">
                                <i class="fas fa-cubes text-blue-500 mr-2"></i>Sản phẩm mới cập nhật
                            </h2>
                            <a href="${pageContext.request.contextPath}/product/list" class="text-sm text-blue-600 hover:text-blue-700 font-medium">Xem tất cả &rarr;</a>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm text-left">
                                <thead class="text-xs text-gray-500 uppercase bg-gray-50/50 border-b border-gray-200">
                                    <tr>
                                        <th class="px-6 py-4 font-semibold">Mã SP</th>
                                        <th class="px-6 py-4 font-semibold">Tên sản phẩm</th>
                                        <th class="px-6 py-4 font-semibold">Danh mục</th>
                                        <th class="px-6 py-4 font-semibold text-right">Ngày tạo</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100">
                                    <c:forEach var="p" items="${recentProducts}">
                                        <tr class="hover:bg-gray-50/50 transition-colors">
                                            <td class="px-6 py-4">
                                                <a href="${pageContext.request.contextPath}/product/details?id=${p.productId}" class="font-medium text-blue-600 hover:text-blue-800">
                                                    ${p.productCode}
                                                </a>
                                            </td>
                                            <td class="px-6 py-4 text-gray-900 font-medium">${p.productName}</td>
                                            <td class="px-6 py-4">
                                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                                                    ${p.categoryName}
                                                </span>
                                            </td>
                                            <td class="px-6 py-4 text-right text-gray-500 text-xs whitespace-nowrap">
                                                <fmt:formatDate value="${p.createdDate}" pattern="dd/MM/yy" />
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty recentProducts}">
                                        <tr>
                                            <td colspan="4" class="px-6 py-8 text-center text-gray-500">Chưa có dữ liệu</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="xl:col-span-1">
                    <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden h-full flex flex-col">
                        <div class="px-5 py-4 border-b border-gray-200 bg-gray-50/50">
                            <h2 class="text-base font-semibold text-gray-800">
                                <i class="fas fa-chart-pie text-purple-500 mr-2"></i>Tỷ lệ Sản phẩm theo Danh mục
                            </h2>
                        </div>
                        <div class="p-6 flex-1 flex items-center justify-center">
                            <c:if test="${empty productsByCategory}">
                                <div class="text-center py-10">
                                    <div class="w-16 h-16 bg-gray-50 text-gray-300 rounded-full flex items-center justify-center mx-auto mb-3 text-2xl">
                                        <i class="fas fa-chart-pie"></i>
                                    </div>
                                    <p class="text-gray-500">Chưa có dữ liệu biểu đồ</p>
                                </div>
                            </c:if>
                            <c:if test="${not empty productsByCategory}">
                                <div class="w-full relative" style="height: 300px;">
                                    <canvas id="categoryChart"></canvas>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <c:if test="${not empty productsByCategory}">
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const ctx = document.getElementById('categoryChart').getContext('2d');

                const labels = [];
                const data = [];
            <c:forEach var="item" items="${productsByCategory}">
                labels.push("${item.categoryName}");
                data.push(${item.productCount});
            </c:forEach>

                const colors = [
                    'rgba(59, 130, 246, 0.85)', // Blue
                    'rgba(16, 185, 129, 0.85)', // Emerald
                    'rgba(245, 158, 11, 0.85)', // Amber
                    'rgba(139, 92, 246, 0.85)', // Violet
                    'rgba(236, 72, 153, 0.85)', // Pink
                    'rgba(14, 165, 233, 0.85)', // Sky
                    'rgba(244, 63, 94, 0.85)', // Rose
                    'rgba(20, 184, 166, 0.85)', // Teal
                    'rgba(249, 115, 22, 0.85)', // Orange
                    'rgba(100, 116, 139, 0.85)' // Slate
                ];

                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: labels,
                        datasets: [{
                                data: data,
                                backgroundColor: colors,
                                borderWidth: 0,
                                hoverOffset: 4
                            }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '65%',
                        plugins: {
                            legend: {
                                position: 'right',
                                labels: {
                                    usePointStyle: true,
                                    padding: 20,
                                    font: {
                                        family: "'Inter', sans-serif",
                                        size: 12
                                    }
                                }
                            },
                            tooltip: {
                                backgroundColor: 'rgba(17, 24, 39, 0.9)',
                                titleFont: {family: "'Inter', sans-serif", size: 13},
                                bodyFont: {family: "'Inter', sans-serif", size: 13},
                                padding: 12,
                                cornerRadius: 8,
                                displayColors: true
                            }
                        }
                    }
                });
            });
        </script>
    </c:if>
</layout:layout>