import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart'; // 1. Đã đổi sang Hive
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../views/login_screen.dart';
import '../views/dashboard_screen.dart';
import 'package:flutter/foundation.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  // 2. Khởi tạo Box của Hive (Thay vì GetStorage)
  // Lưu ý: Phải đảm bảo bạn đã mở box này ở main.dart
  final Box box = Hive.box('myBox');

  // URL API (Android Emulator dùng 10.0.2.2)
  final String baseUrl = "http://192.168.1.249:5201/api/auth";

  var selectedImage = Rx<XFile?>(null);
  var selectedImageBytes = Rx<Uint8List?>(null);
  var currentUser = Rx<UserResponse?>(null);

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage.value = pickedFile;
      selectedImageBytes.value = await pickedFile.readAsBytes();
    }
  }

  // --- 1. LOGIN ---
  Future<void> login(String userOrEmail, String password) async {
    try {
      isLoading.value = true;
      var response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userNameOrEmail": userOrEmail,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        UserResponse user = UserResponse.fromJson(data);

        //  box.put
        box.put('token', user.token);
        Get.snackbar(
          "Thành công",
          "Chào mừng ${user.fullName}",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        await getMe();

        // Chuyển sang HomeScreen (Menu dưới đáy)
        Get.offAll(() => DashboardScreen());
      } else {
        var msg = jsonDecode(response.body)['message'] ?? "Lỗi đăng nhập";
        Get.snackbar(
          "Thất bại",
          msg,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Lỗi mạng", "Server không phản hồi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 2. REGISTER ---
  Future<void> register({
    required String userName,
    required String email,
    required String fullName,
    required String password,
    XFile? avatarFile,
  }) async {
    try {
      isLoading.value = true;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register'),
      );

      request.fields['UserName'] = userName;
      request.fields['Email'] = email;
      request.fields['FullName'] = fullName;
      request.fields['Password'] = password;

      if (avatarFile != null) {
        var bytes = await avatarFile.readAsBytes();
        var pic = http.MultipartFile.fromBytes(
          "Avatar",
          bytes,
          filename: avatarFile.name,
        );
        request.files.add(pic);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 3. Thay box.write thành box.put
        box.put('token', data['token']);

        Get.defaultDialog(
          title: "Đăng ký thành công ✅",
          middleText: "Tài khoản $userName đã được tạo.",
          textConfirm: "Đăng nhập ngay",
          confirmTextColor: Colors.white,
          buttonColor: Colors.blue,
          onConfirm: () {
            Get.back();
            Get.offAll(() => LoginScreen());
          },
        );
      } else {
        var errorData = jsonDecode(response.body);
        Get.snackbar(
          "Lỗi",
          errorData['message'] ?? "Đăng ký thất bại",
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      Get.snackbar("Lỗi hệ thống", e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // --- 3. GET ME ---
  Future<void> getMe() async {
    try {
      String? token = box.get('token');

      if (token == null) return;

      var response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // pull role out of various possible shapes
        String? parsedRole;
        if (data['role'] != null) {
          parsedRole = data['role'].toString();
        } else if (data['roles'] != null) {
          final r = data['roles'];
          if (r is String) {
            parsedRole = r;
          } else if (r is Iterable && r.isNotEmpty) {
            final first = r.first;
            if (first is String) {
              parsedRole = first;
            } else if (first is Map) {
              parsedRole =
                  (first['normalizedName'] ?? first['name'] ?? first['role'])
                      ?.toString();
            }
          }
        } else if (data['normalizedRole'] != null) {
          parsedRole = data['normalizedRole'].toString();
        }

        // Nếu chưa có role từ /me thì thử decode token để lấy claim role
        if (parsedRole == null || parsedRole.isEmpty) {
          try {
            final parts = token.split('.');
            if (parts.length >= 2) {
              String payload = parts[1];
              // base64Url normalize
              payload = payload.replaceAll('-', '+').replaceAll('_', '/');
              while (payload.length % 4 != 0) {
                payload += '=';
              }
              final decoded = utf8.decode(base64Url.decode(payload));
              final Map<String, dynamic> claims = jsonDecode(decoded);

              if (claims['role'] != null) {
                parsedRole = claims['role'].toString();
              } else if (claims['roles'] != null)
                parsedRole = claims['roles'].toString();
              else if (claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] !=
                  null)
                parsedRole =
                    claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
                        .toString();
              else if (claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role'] !=
                  null)
                parsedRole =
                    claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role']
                        .toString();
              if (parsedRole == null && claims['roles'] is Iterable) {
                final r = claims['roles'];
                if (r.isNotEmpty) parsedRole = r.first.toString();
              }
            }
          } catch (e) {
            // silent on decode failure in production
          }
        }

        // normalize/trimm role
        parsedRole = parsedRole?.toString().trim();

        // Build UserResponse with token from storage to keep token available
        currentUser.value = UserResponse(
          token: token,
          userName: data['userName']?.toString(),
          fullName: data['fullName']?.toString(),
          avatarUrl: data['avatarUrl']?.toString(),
          role: parsedRole,
        );
      } else {
        logout();
      }
    } catch (e) {
      // keep minimal error log
    }
  }

  // --- 4. UPDATE PROFILE ---
  Future<void> updateProfile({String? fullName, XFile? newAvatar}) async {
    try {
      isLoading.value = true;
      // 3. Thay box.read thành box.get
      String? token = box.get('token');

      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/profile'));
      request.headers['Authorization'] = "Bearer $token";

      if (fullName != null) request.fields['FullName'] = fullName;

      if (newAvatar != null) {
        var bytes = await newAvatar.readAsBytes();
        var pic = http.MultipartFile.fromBytes(
          "Avatar",
          bytes,
          filename: newAvatar.name,
        );
        request.files.add(pic);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await getMe();
        Get.snackbar(
          "Thành công",
          "Đã cập nhật hồ sơ!",
          backgroundColor: Colors.green,
        );
      } else {
        Get.snackbar(
          "Lỗi",
          "Không thể cập nhật",
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- 5. LOGOUT ---
  void logout() {
    // 3. Thay box.remove thành box.delete
    box.delete('token');

    currentUser.value = null;
    Get.offAll(() => LoginScreen());
    Get.snackbar("Đăng xuất", "Hẹn gặp lại!", backgroundColor: Colors.grey);
  }
}
