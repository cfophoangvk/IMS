<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <div class="min-h-screen bg-slate-50 pb-12">
        <div class="bg-white border-b border-gray-200 shadow-sm top-16 z-30">
            <div class="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8 py-5">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900 tracking-tight">Business Owner Dashboard</h1>
                        <p class="text-sm text-gray-500 mt-1">Báo cáo tổng hợp số liệu kinh doanh và luân chuyển hàng hóa</p>
                    </div>
                    <div class="flex items-center gap-3">
                        <span class="inline-flex items-center px-3 py-1.5 rounded-md text-sm font-medium bg-blue-50 text-blue-700 border border-blue-100">
                            <i class="fas fa-calendar-alt mr-2"></i>Tháng <fmt:formatDate value="<%=new java.util.Date()%>" pattern="MM/yyyy" />
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8 mt-8">
            <c:if test="${oldPendingCount > 0}">
                <div class="bg-red-50 border-l-4 border-red-500 rounded-r-lg p-4 mb-6 flex items-start shadow-sm">
                    <div class="flex-shrink-0 mt-0.5">
                        <i class="fas fa-exclamation-triangle text-red-500 text-lg"></i>
                    </div>
                    <div class="ml-3">
                        <h3 class="text-sm font-semibold text-red-800">Cảnh báo tồn đọng giao dịch</h3>
                        <p class="mt-1 text-sm text-red-700">Hệ thống ghi nhận có <strong>${oldPendingCount}</strong> phiếu Nhập/Xuất/Chuyển đang treo (Chờ duyệt) quá 3 ngày. Vui lòng đôn đốc các Quản lý kho xử lý để tránh sai sót số liệu tồn kho thực tế.</p>
                    </div>
                </div>
            </c:if>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div class="bg-gradient-to-br from-blue-600 to-indigo-700 rounded-2xl shadow-lg p-6 flex flex-col relative overflow-hidden text-white">
                    <i class="fas fa-boxes absolute right-0 top-0 text-9xl text-white opacity-10 -mr-6 -mt-6"></i>
                    <div class="relative z-10 flex justify-between items-start">
                        <div>
                            <p class="text-blue-100 font-medium mb-1 drop-shadow-sm">Tổng Tồn Kho Hệ Thống</p>
                            <h3 class="text-4xl font-bold tracking-tight"><fmt:formatNumber value="${totalStock}" pattern="#,##0.##"/></h3>
                        </div>
                        <div class="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center text-xl">
                            <i class="fas fa-cubes"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-gradient-to-br from-emerald-500 to-teal-600 rounded-2xl shadow-lg p-6 flex flex-col relative overflow-hidden text-white">
                    <i class="fas fa-arrow-down absolute right-0 top-0 text-9xl text-white opacity-10 -mr-6 -mt-6"></i>
                    <div class="relative z-10 flex justify-between items-start">
                        <div>
                            <p class="text-emerald-50 font-medium mb-1 drop-shadow-sm">Tổng Nhập (Tháng này)</p>
                            <h3 class="text-4xl font-bold tracking-tight"><fmt:formatNumber value="${monthlyImport}" pattern="#,##0.##"/></h3>
                        </div>
                        <div class="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center text-xl">
                            <i class="fas fa-arrow-circle-down"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-gradient-to-br from-orange-500 to-red-600 rounded-2xl shadow-lg p-6 flex flex-col relative overflow-hidden text-white">
                    <i class="fas fa-arrow-up absolute right-0 top-0 text-9xl text-white opacity-10 -mr-6 -mt-6"></i>
                    <div class="relative z-10 flex justify-between items-start">
                        <div>
                            <p class="text-orange-50 font-medium mb-1 drop-shadow-sm">Tổng Xuất (Tháng này)</p>
                            <h3 class="text-4xl font-bold tracking-tight"><fmt:formatNumber value="${monthlyExport}" pattern="#,##0.##"/></h3>
                        </div>
                        <div class="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center text-xl">
                            <i class="fas fa-arrow-circle-up"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
                <div class="bg-white rounded-2xl shadow-[0_2px_15px_-3px_rgba(6,81,237,0.08)] border border-gray-100 overflow-hidden">
                    <div class="px-6 py-5 border-b border-gray-100 flex justify-between items-center bg-gray-50/30">
                        <h2 class="text-lg font-semibold text-gray-800">
                            <i class="fas fa-chart-line text-blue-500 mr-2"></i>Xu hướng Nhập - Xuất 30 ngày
                        </h2>
                    </div>
                    <div class="p-6 relative" style="height: 380px;">
                        <canvas id="trendChart"></canvas>
                    </div>
                </div>

                <div class="bg-white rounded-2xl shadow-[0_2px_15px_-3px_rgba(6,81,237,0.08)] border border-gray-100 overflow-hidden">
                    <div class="px-6 py-5 border-b border-gray-100 flex justify-between items-center bg-gray-50/30">
                        <h2 class="text-lg font-semibold text-gray-800">
                            <i class="fas fa-chart-bar text-indigo-500 mr-2"></i>Số lượng tồn kho nhiều nhất
                        </h2>
                    </div>
                    <div class="p-6 relative" style="height: 380px;">
                        <canvas id="warehouseChart"></canvas>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div class="bg-white rounded-2xl shadow-[0_2px_15px_-3px_rgba(6,81,237,0.08)] border border-gray-100 overflow-hidden">
                    <div class="px-6 py-5 border-b border-gray-100 bg-orange-50/50">
                        <h2 class="text-lg font-semibold text-gray-800">
                            <i class="fas fa-fire text-orange-500 mr-2"></i>Top Sản phẩm Xuất Kho (Tháng)
                        </h2>
                    </div>
                    <table class="w-full text-sm">
                        <thead class="bg-gray-50/50 text-gray-500 border-b border-gray-100">
                            <tr>
                                <th class="px-6 py-3 font-medium text-left">Sản phẩm</th>
                                <th class="px-6 py-3 font-medium text-right">Tổng xuất</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-50">
                            <c:forEach var="item" items="${topExported}">
                                <tr class="hover:bg-gray-50 transition-colors">
                                    <td class="px-6 py-4 font-medium text-gray-900">${item.productName}</td>
                                    <td class="px-6 py-4 text-right">
                                        <span class="inline-flex font-semibold text-orange-600 bg-orange-50 px-2 py-1 rounded">
                                            <fmt:formatNumber value="${item.totalExported}" pattern="#,##0.##"/>&nbsp;${item.unit}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty topExported}">
                                <tr><td colspan="2" class="px-6 py-8 text-center text-gray-500">Chưa có dữ liệu xuất trong tháng</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="bg-white rounded-2xl shadow-[0_2px_15px_-3px_rgba(6,81,237,0.08)] border border-gray-100 overflow-hidden">
                    <div class="px-6 py-5 border-b border-gray-100 bg-blue-50/50">
                        <h2 class="text-lg font-semibold text-gray-800">
                            <i class="fas fa-layer-group text-blue-500 mr-2"></i>Top Sản phẩm Tồn Kho Cao
                        </h2>
                    </div>
                    <table class="w-full text-sm">
                        <thead class="bg-gray-50/50 text-gray-500 border-b border-gray-100">
                            <tr>
                                <th class="px-6 py-3 font-medium text-left">Sản phẩm</th>
                                <th class="px-6 py-3 font-medium text-left">Vị trí kho</th>
                                <th class="px-6 py-3 font-medium text-right">Số lượng</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-50">
                            <c:forEach var="item" items="${topStock}">
                                <tr class="hover:bg-gray-50 transition-colors">
                                    <td class="px-6 py-3 font-medium text-gray-900">${item.productName}</td>
                                    <td class="px-6 py-3 text-gray-600 text-xs">${item.warehouseName}</td>
                                    <td class="px-6 py-3 text-right">
                                        <span class="inline-flex font-semibold text-blue-700 bg-blue-50 px-2 py-1 rounded">
                                            <fmt:formatNumber value="${item.quantity}" pattern="#,##0.##"/>&nbsp;${item.unit}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty topStock}">
                                <tr><td colspan="3" class="px-6 py-8 text-center text-gray-500">Chưa có dữ liệu tồn kho</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function () {

        <c:if test="${not empty dailyTrend}">
            const trendCtx = document.getElementById('trendChart').getContext('2d');
            const trendLabels = [];
            const importData = [];
            const exportData = [];

            <c:forEach var="d" items="${dailyTrend}">
            var pDate = new Date("${d.txDate}");
            trendLabels.push(pDate.getDate() + '/' + (pDate.getMonth() + 1));
            importData.push(${d.importQty});
            exportData.push(${d.exportQty});
            </c:forEach>

            new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: trendLabels,
                    datasets: [
                        {
                            label: 'Nhập kho',
                            data: importData,
                            borderColor: 'rgba(16, 185, 129, 1)', // emerald-500
                            backgroundColor: 'rgba(16, 185, 129, 0.1)',
                            borderWidth: 2,
                            pointBackgroundColor: '#fff',
                            pointBorderColor: 'rgba(16, 185, 129, 1)',
                            pointBorderWidth: 2,
                            pointRadius: 3,
                            pointHoverRadius: 5,
                            fill: true,
                            tension: 0.4
                        },
                        {
                            label: 'Xuất kho',
                            data: exportData,
                            borderColor: 'rgba(249, 115, 22, 1)',
                            backgroundColor: 'rgba(249, 115, 22, 0.05)',
                            borderWidth: 2,
                            pointBackgroundColor: '#fff',
                            pointBorderColor: 'rgba(249, 115, 22, 1)',
                            pointBorderWidth: 2,
                            pointRadius: 3,
                            pointHoverRadius: 5,
                            fill: true,
                            tension: 0.4
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false,
                    },
                    scales: {
                        x: {
                            grid: {display: false, drawBorder: false},
                            ticks: {font: {family: "'Inter', sans-serif"}}
                        },
                        y: {
                            grid: {color: 'rgba(243, 244, 246, 1)', drawBorder: false},
                            ticks: {font: {family: "'Inter', sans-serif"}},
                            beginAtZero: true
                        }
                    },
                    plugins: {
                        legend: {
                            position: 'top',
                            labels: {usePointStyle: true, font: {family: "'Inter', sans-serif"}}
                        },
                        tooltip: {
                            backgroundColor: 'rgba(17, 24, 39, 0.9)',
                            titleFont: {family: "'Inter', sans-serif", size: 13},
                            bodyFont: {family: "'Inter', sans-serif", size: 13},
                            padding: 12,
                            cornerRadius: 8
                        }
                    }
                }
            });
        </c:if>

        <c:if test="${not empty stockByWarehouse}">
            const whCtx = document.getElementById('warehouseChart').getContext('2d');
            const whLabels = [];
            const whData = [];

            <c:forEach var="w" items="${stockByWarehouse}">
            whLabels.push("${w.warehouseName}");
            whData.push(${w.totalStock});
            </c:forEach>

            new Chart(whCtx, {
                type: 'bar',
                data: {
                    labels: whLabels,
                    datasets: [{
                            label: 'Tồn kho',
                            data: whData,
                            backgroundColor: 'rgba(59, 130, 246, 0.85)', // blue-500
                            hoverBackgroundColor: 'rgba(37, 99, 235, 1)', // blue-600
                            borderRadius: 6,
                            barPercentage: 0.6
                        }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        x: {
                            grid: {display: false, drawBorder: false},
                            ticks: {
                                font: {family: "'Inter', sans-serif", size: 11},
                                maxRotation: 45,
                                minRotation: 45
                            }
                        },
                        y: {
                            grid: {color: 'rgba(243, 244, 246, 1)', drawBorder: false},
                            ticks: {font: {family: "'Inter', sans-serif"}},
                            beginAtZero: true
                        }
                    },
                    plugins: {
                        legend: {display: false},
                        tooltip: {
                            backgroundColor: 'rgba(17, 24, 39, 0.9)',
                            titleFont: {family: "'Inter', sans-serif", size: 13},
                            bodyFont: {family: "'Inter', sans-serif", size: 13},
                            padding: 12,
                            cornerRadius: 8
                        }
                    }
                }
            });
        </c:if>
        });
    </script>
</layout:layout>