import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/colors.dart';

class SnackbarHelper {
  static void showSuccess(String message) {
    Get.snackbar(
      'Thành công',
      message,
      backgroundColor: AppColors.successColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Lỗi',
      message,
      backgroundColor: AppColors.errorColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      'Cảnh báo',
      message,
      backgroundColor: AppColors.warningColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  static void showInfo(String message) {
    Get.snackbar(
      'Thông tin',
      message,
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}