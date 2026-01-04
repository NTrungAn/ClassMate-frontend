// lib/core/services/auth_service.dart

import 'package:get/get.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();

  Future<UserModel?> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final response = await ApiService.instance.post(
      ApiConstants.login,
      {
        'userNameOrEmail': usernameOrEmail,
        'password': password,
      },
    );

    if (response != null) {
      final user = UserModel.fromJson(response);
      await _saveUserData(user);
      return user;
    }

    return null;
  }

  Future<void> _saveUserData(UserModel user) async {
    await StorageService.instance.saveToken(user.token);
    await StorageService.instance.saveUser(user);
  }

  Future<bool> checkAuthStatus() async {
    final token = await StorageService.instance.getToken();
    final user = await StorageService.instance.getUser();

    if (token == null || token.isEmpty || user == null) {
      return false;
    }

    // Kiểm tra token còn hiệu lực không
    final expiration = DateTime.parse(user.expiration);
    if (expiration.isBefore(DateTime.now())) {
      await logout();
      return false;
    }

    return true;
  }

  Future<void> logout() async {
    await StorageService.instance.clearAll();
  }

  Future<UserModel?> getCurrentUser() async {
    return await StorageService.instance.getUser();
  }
}