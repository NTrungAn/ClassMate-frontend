import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/strings.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authProvider = Get.find<AuthProvider>();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final usernameOrEmail = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      await _authProvider.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FontAwesomeIcons.graduationCap,
                    size: 50,
                    color: AppColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  AppStrings.welcomeBack,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 8),

                // Text(
                //   AppStrings.loginDescription,
                //   style: const TextStyle(
                //     fontSize: 16,
                //     color: AppColors.textSecondary,
                //   ),
                //   textAlign: TextAlign.center,
                // ),

                const SizedBox(height: 48),

                // Username/Email Field
                CustomTextField(
                  controller: _usernameController,
                  labelText: AppStrings.usernameOrEmail,
                  prefixIcon: const Icon(
                    FontAwesomeIcons.user,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                  validator: Validators.validateUsernameOrEmail,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  labelText: AppStrings.password,
                  prefixIcon: const Icon(
                    FontAwesomeIcons.lock,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      size: 18,
                      color: AppColors.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                ),

                const SizedBox(height: 32),

                // Login Button
                Obx(() => _authProvider.isLoading.value
                    ? const LoadingIndicator()
                    : CustomButton(
                  onPressed: _login,
                  text: AppStrings.loginButton,
                ),
                ),

                const SizedBox(height: 40),

                // Role Info
                // Container(
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: AppColors.backgroundColor,
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(
                //       color: AppColors.borderColor,
                //     ),
                //   ),
                //   child: const Column(
                //     children: [
                //       Row(
                //         children: [
                //           Icon(
                //             FontAwesomeIcons.infoCircle,
                //             size: 16,
                //             color: AppColors.primaryColor,
                //           ),
                //           SizedBox(width: 8),
                //           Text(
                //             'Chỉ dành cho:',
                //             style: TextStyle(
                //               fontWeight: FontWeight.w600,
                //               color: AppColors.textColor,
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 8),
                //       Text(
                //         '• Sinh viên (Student)\n• Giảng viên (Teacher)',
                //         style: TextStyle(
                //           color: AppColors.textSecondary,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}