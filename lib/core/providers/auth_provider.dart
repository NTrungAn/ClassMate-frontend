// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/strings.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/core/services/api_service.dart'; // Thêm import này
import 'package:frontend/core/utils/snackbar_helper.dart';
import 'package:frontend/models/user_model.dart';

class AuthProvider extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() async {
    super.onInit();
    await _initializeServices();
    await checkAuthStatus();
  }

  Future<void> _initializeServices() async {
    // Khởi tạo tất cả services theo thứ tự
    await Get.putAsync(() => StorageService().init());
    Get.put(ApiService()); // Thêm dòng này
    Get.put(AuthService());
  }

  Future<void> checkAuthStatus() async {
    isLoading.value = true;
    try {
      final isAuthenticated = await AuthService.instance.checkAuthStatus();
      isLoggedIn.value = isAuthenticated;

      if (isAuthenticated) {
        currentUser.value = await AuthService.instance.getCurrentUser();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    isLoading.value = true;

    try {
      final user = await AuthService.instance.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      if (user != null) {
        // Kiểm tra role - chỉ cho phép Student và Teacher login
        if (user.role != AppStrings.roleStudent &&
            user.role != AppStrings.roleTeacher) {
          await AuthService.instance.logout();
          SnackbarHelper.showError(
              'Chỉ sinh viên và giảng viên được đăng nhập vào ứng dụng này'
          );
          return;
        }

        currentUser.value = user;
        isLoggedIn.value = true;
        SnackbarHelper.showSuccess(AppStrings.loginSuccess);
      }
    } catch (e) {
      SnackbarHelper.showError('Đăng nhập thất bại: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    isLoggedIn.value = false;
    currentUser.value = null;
    SnackbarHelper.showInfo('Đã đăng xuất');
  }

  Future<void> updateProfile(UserModel user) async {
    await StorageService.instance.saveUser(user);
    currentUser.value = user;
  }
}