<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

<layout:layout>
    <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow-sm border-b">
            <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <h1 class="text-2xl font-bold text-gray-900">Thông tin cá nhân</h1>
                <p class="text-sm text-gray-500 mt-1">Xem thông tin tài khoản của bạn</p>
            </div>
        </div>

        <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div class="bg-white rounded-lg shadow-sm border overflow-hidden">
                <div class="bg-gradient-to-r from-blue-600 to-indigo-700 px-6 py-8">
                    <div class="flex items-center gap-5">
                        <div class="w-20 h-20 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white text-3xl font-bold border-2 border-white/30">
                            ${profileUser.fullName.substring(0, 1)}
                        </div>
                        <div class="text-white">
                            <h2 class="text-2xl font-bold">${profileUser.fullName}</h2>
                            <p class="mt-1 text-blue-100 flex items-center gap-2">
                                <i class="fas fa-shield-alt"></i> ${profileUser.roleName}
                            </p>
                        </div>
                    </div>
                </div>

                <div class="p-6">
                    <div class="grid gap-5">
                        <div class="flex items-center p-4 bg-gray-50 rounded-lg">
                            <div class="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center mr-4">
                                <i class="fas fa-user text-blue-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-400 uppercase tracking-wider font-medium">Tên đăng nhập</p>
                                <p class="text-gray-900 font-medium mt-0.5">${profileUser.username}</p>
                            </div>
                        </div>

                        <div class="flex items-center p-4 bg-gray-50 rounded-lg">
                            <div class="w-10 h-10 rounded-lg bg-green-100 flex items-center justify-center mr-4">
                                <i class="fas fa-id-card text-green-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-400 uppercase tracking-wider font-medium">Họ và tên</p>
                                <p class="text-gray-900 font-medium mt-0.5">${profileUser.fullName}</p>
                            </div>
                        </div>

                        <div class="flex items-center p-4 bg-gray-50 rounded-lg">
                            <div class="w-10 h-10 rounded-lg bg-purple-100 flex items-center justify-center mr-4">
                                <i class="fas fa-envelope text-purple-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-400 uppercase tracking-wider font-medium">Email</p>
                                <p class="text-gray-900 font-medium mt-0.5">${profileUser.email}</p>
                            </div>
                        </div>

                        <div class="flex items-center p-4 bg-gray-50 rounded-lg">
                            <div class="w-10 h-10 rounded-lg bg-yellow-100 flex items-center justify-center mr-4">
                                <i class="fas fa-user-tag text-yellow-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-400 uppercase tracking-wider font-medium">Vai trò</p>
                                <p class="text-gray-900 font-medium mt-0.5">${profileUser.roleName}</p>
                            </div>
                        </div>

                        <div class="flex items-center p-4 bg-gray-50 rounded-lg">
                            <div class="w-10 h-10 rounded-lg bg-indigo-100 flex items-center justify-center mr-4">
                                <i class="fas fa-circle-check text-indigo-600"></i>
                            </div>
                            <div>
                                <p class="text-xs text-gray-400 uppercase tracking-wider font-medium">Trạng thái</p>
                                <c:choose>
                                    <c:when test="${profileUser.status}">
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800 mt-0.5">
                                            <i class="fas fa-circle text-green-500 mr-1" style="font-size: 6px;"></i> Đang hoạt động
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800 mt-0.5">
                                            <i class="fas fa-circle text-red-500 mr-1" style="font-size: 6px;"></i> Vô hiệu
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</layout:layout>