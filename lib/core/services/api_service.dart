import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/utils/snackbar_helper.dart';
import 'package:frontend/core/services/storage_service.dart';

import '../../providers/auth_provider.dart';
import '../constants/strings.dart';

class ApiService extends GetxService {
  static ApiService get instance => Get.find<ApiService>();

  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);

    final token = await StorageService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// ================= GET =================
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
        Uri.parse(endpoint),
        headers: await _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      SnackbarHelper.showError(AppStrings.networkError);
      return null;
    } catch (e) {
      SnackbarHelper.showError(AppStrings.serverError);
      return null;
    }
  }

  /// ================= POST =================
  Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    try {
      final response = await http
          .post(
        Uri.parse(endpoint),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      SnackbarHelper.showError(AppStrings.networkError);
      return null;
    } catch (e) {
      SnackbarHelper.showError(AppStrings.serverError);
      return null;
    }
  }

  /// ================= HANDLE RESPONSE =================
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final decodedBody = utf8.decode(response.bodyBytes);
    final data = decodedBody.isNotEmpty ? jsonDecode(decodedBody) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return data; // 🔥 có thể là Map hoặc List
    }

    if (statusCode == 401) {
      Get.find<AuthProvider>().logout();
      SnackbarHelper.showError('Phiên đăng nhập đã hết hạn');
      return null;
    }

    final errorMessage =
    data is Map<String, dynamic> ? data['message'] : 'Có lỗi xảy ra';

    SnackbarHelper.showError(errorMessage);
    return null;
  }
}
