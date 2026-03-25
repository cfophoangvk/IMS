<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>
<layout:layout>
    <section class="relative pt-5 pb-7 lg:pt-16 lg:pb-10 overflow-hidden bg-[linear-gradient(#FFFFFFC0,#FFFFFFC0),url('${pageContext.request.contextPath}/assets/images/background.png')] bg-cover bg-center">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
            <div class="text-center max-w-3xl mx-auto">
                <h1 class="text-4xl md:text-5xl lg:text-6xl font-extrabold text-slate-900 leading-tight mb-6">
                    Quản lý kho hàng <br class="hidden md:block">
                    <span class="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-indigo-600">Toàn diện & Chính xác</span>
                </h1>
                <p class="text-lg md:text-xl text-slate-600 mb-10 leading-relaxed">
                    Hệ thống số hóa quy trình Nhập - Xuất - Tồn. Kiểm soát đa kho, phân quyền chặt chẽ và theo dõi dữ liệu chốt sổ theo thời gian thực dành riêng cho doanh nghiệp của bạn.
                </p>
                <div class="flex flex-col sm:flex-row gap-4 justify-center">
                    <a href="${pageContext.request.contextPath}/auth/login" class="px-8 py-3.5 text-base font-semibold text-white bg-blue-600 hover:bg-blue-700 rounded-xl shadow-lg hover:shadow-xl transition-all">
                        Đăng nhập ngay
                    </a>
                </div>
            </div>
        </div>
    </section>

    <section id="features" class="py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-16">
                <h2 class="text-3xl font-bold text-slate-900 mb-4">Giải quyết triệt để bài toán vận hành</h2>
                <p class="text-slate-600 max-w-2xl mx-auto text-lg">Hệ thống được thiết kế dựa trên các nghiệp vụ kho tiêu chuẩn, đáp ứng nhu cầu từ nhân viên đến chủ doanh nghiệp.</p>
            </div>

            <div class="grid md:grid-cols-3 gap-8">
                <div class="p-8 rounded-2xl bg-gray-50 border border-gray-100 hover:border-blue-200 hover:shadow-lg transition-all duration-300">
                    <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 002-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                    </div>
                    <h3 class="text-xl font-bold text-slate-900 mb-3">Quản lý Đa kho</h3>
                    <p class="text-slate-600 leading-relaxed">Điều phối và thuyên chuyển hàng hóa nội bộ dễ dàng. Gán quyền nhân sự theo từng kho cụ thể để bảo mật thông tin.</p>
                </div>

                <div class="p-8 rounded-2xl bg-gray-50 border border-gray-100 hover:border-blue-200 hover:shadow-lg transition-all duration-300">
                    <div class="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </div>
                    <h3 class="text-xl font-bold text-slate-900 mb-3">Chốt sổ & Phê duyệt</h3>
                    <p class="text-slate-600 leading-relaxed">Cơ chế duyệt phiếu Nhập/Xuất nghiêm ngặt. Tính năng "Chốt sổ ngày" khóa dữ liệu, ngăn chặn chỉnh sửa gian lận.</p>
                </div>

                <div class="p-8 rounded-2xl bg-gray-50 border border-gray-100 hover:border-blue-200 hover:shadow-lg transition-all duration-300">
                    <div class="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path></svg>
                    </div>
                    <h3 class="text-xl font-bold text-slate-900 mb-3">Báo cáo Dashboard</h3>
                    <p class="text-slate-600 leading-relaxed">Cung cấp cái nhìn tổng quan cho Chủ doanh nghiệp về số lượng hàng hóa ở các kho ngay trên một màn hình.</p>
                </div>
            </div>
        </div>
    </section>
</layout:layout>