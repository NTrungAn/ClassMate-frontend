import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/strings.dart';
import 'package:frontend/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider>();

    return Obx(() {
      final user = authProvider.currentUser.value;

      if (user == null) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Cá nhân'),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 3,
                            ),
                          ),
                          child: user.avatarUrl != null
                              ? ClipOval(
                            child: Image.network(
                              user.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                FontAwesomeIcons.userGraduate,
                                size: 40,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          )
                              : const Icon(
                            FontAwesomeIcons.userGraduate,
                            size: 40,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.camera,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // User Name
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Username
                    Text(
                      '@${user.userName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role == AppStrings.roleStudent
                            ? 'Sinh viên'
                            : user.role == AppStrings.roleTeacher
                            ? 'Giảng viên'
                            : 'Quản trị viên',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Personal Information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin cá nhân',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildInfoItem(
                      icon: FontAwesomeIcons.envelope,
                      label: 'Email',
                      value: user.email,
                    ),

                    const Divider(height: 24),

                    _buildInfoItem(
                      icon: FontAwesomeIcons.idCard,
                      label: 'Mã số',
                      value: user.id,
                    ),

                    const Divider(height: 24),

                    _buildInfoItem(
                      icon: FontAwesomeIcons.calendar,
                      label: 'Ngày tạo',
                      value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    ),

                    const Divider(height: 24),

                    _buildInfoItem(
                      icon: FontAwesomeIcons.userTie,
                      label: 'Vai trò',
                      value: user.role == AppStrings.roleStudent
                          ? 'Sinh viên'
                          : user.role == AppStrings.roleTeacher
                          ? 'Giảng viên'
                          : 'Quản trị viên',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tài khoản',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildActionItem(
                      icon: FontAwesomeIcons.userEdit,
                      title: 'Chỉnh sửa hồ sơ',
                      onTap: () {
                        Get.snackbar(
                          'Thông báo',
                          'Tính năng đang phát triển',
                        );
                      },
                    ),

                    const Divider(height: 16),

                    _buildActionItem(
                      icon: FontAwesomeIcons.lock,
                      title: 'Đổi mật khẩu',
                      onTap: () {
                        Get.snackbar(
                          'Thông báo',
                          'Tính năng đang phát triển',
                        );
                      },
                    ),

                    const Divider(height: 16),

                    _buildActionItem(
                      icon: FontAwesomeIcons.bell,
                      title: 'Thông báo',
                      onTap: () {
                        Get.snackbar(
                          'Thông báo',
                          'Tính năng đang phát triển',
                        );
                      },
                    ),

                    const Divider(height: 16),

                    _buildActionItem(
                      icon: FontAwesomeIcons.rightFromBracket,
                      title: 'Đăng xuất',
                      color: AppColors.errorColor,
                      onTap: () {
                        _showLogoutDialog(context, authProvider);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primaryColor,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    Color color = AppColors.textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Icon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return AppColors.errorColor;
      case 'Teacher':
        return AppColors.warningColor;
      case 'Student':
      default:
        return AppColors.successColor;
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    Get.dialog(
      AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authProvider.logout();
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}