import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  // SỬA: Dùng Get.find
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  // thêm reactive để ẩn/hiện mật khẩu
  final RxBool isPasswordHidden = true.obs;

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF90CAF9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Đăng ký ClassMate",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Avatar picker
                        GestureDetector(
                          onTap: () => authController.pickImage(),
                          child: Obx(
                            () => CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  authController.selectedImageBytes.value !=
                                      null
                                  ? MemoryImage(
                                      authController.selectedImageBytes.value!,
                                    )
                                  : null,
                              child:
                                  authController.selectedImageBytes.value ==
                                      null
                                  ? const Icon(
                                      Icons.camera_alt,
                                      size: 36,
                                      color: Colors.black45,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Username
                        TextField(
                          controller: userController,
                          decoration: InputDecoration(
                            hintText: "Username",
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Full name
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Họ và tên",
                            prefixIcon: const Icon(Icons.badge),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Email
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email",
                            prefixIcon: const Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Password with toggle
                        Obx(
                          () => TextField(
                            controller: passController,
                            obscureText: isPasswordHidden.value,
                            decoration: InputDecoration(
                              hintText: "Mật khẩu",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordHidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => isPasswordHidden.value =
                                    !isPasswordHidden.value,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Register button / loading
                        Obx(
                          () => authController.isLoading.value
                              ? const SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      authController.register(
                                        userName: userController.text,
                                        email: emailController.text,
                                        fullName: nameController.text,
                                        password: passController.text,
                                        avatarFile:
                                            authController.selectedImage.value,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Đăng Ký",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Đã có tài khoản? Đăng nhập"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
