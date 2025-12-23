import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- 1. IMPORT CÁC MÀN HÌNH CON (Kiểm tra kỹ đường dẫn này) ---
import '../controllers/auth_controller.dart'; // Controller để lấy thông tin User

class DashboardScreen extends StatelessWidget {
  // Biến quản lý tab hiện tại (0: Khóa học, 1: Lớp học phần, 2: Cá nhân)
  final RxInt tabIndex = 0.obs;

  // Lấy AuthController để hiển thị Avatar và Tên
  final AuthController authController = Get.find<AuthController>();

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild scaffold when user/role changes
    return Obx(() {
      final String role = _getRole();
      final destinations = _buildDestinations(role);

      // ensure tabIndex is valid for current role
      if (tabIndex.value >= destinations.length) {
        tabIndex.value = 0;
      }

      return Scaffold(
        appBar: null,
        // body: giữ trạng thái các màn hình thông qua IndexedStack
        // IMPORTANT: Disable Hero animations for the inner pages to prevent
        // "multiple heroes with same tag" errors when multiple pages contain
        // FloatingActionButton (which uses the same default hero tag).
        // Alternatively: give each FAB a unique heroTag across pages.

        // bottom nav thay đổi theo role
        bottomNavigationBar: NavigationBar(
          selectedIndex: tabIndex.value,
          onDestinationSelected: (index) => tabIndex.value = index,
          destinations: destinations,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      );
    });
  }

  // Lấy role từ currentUser (chuẩn hoá và kiểm tra từ khóa để tránh mismatch)
  String _getRole() {
    final user = authController.currentUser.value;
    if (user == null) return 'student';
    final String rawRole = (user.role ?? 'student')
        .toString()
        .trim()
        .toLowerCase();

    if (rawRole.contains('admin')) return 'admin';
    if (rawRole.contains('teach') ||
        rawRole.contains('giang') ||
        rawRole.contains('lecturer'))
      return 'teacher';
    if (rawRole.contains('student') ||
        rawRole.contains('sv') ||
        rawRole.contains('user'))
      return 'student';

    // fallback an toàn
    return 'student';
  }

  // Tạo các destination dựa trên role
  List<NavigationDestination> _buildDestinations(String role) {
    switch (role) {
      case 'admin':
        return [
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Quản trị',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Khóa học',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_),
            label: 'Lớp học phần',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ];
      case 'teacher':
        return [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Khóa học',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_),
            label: 'Lớp học phần',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Quản lý SV',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ];
      default: // student / fallback
        return [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Khóa học',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_),
            label: 'Lớp học phần',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ];
    }
  }

  // Tạo các trang tương ứng với destination

  // --- GIAO DIỆN TAB PROFILE (Tab cuối) ---
  // --- GIAO DIỆN TAB PROFILE (NÂNG CẤP) ---
  Widget _buildProfileView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 1. HEADER: AVATAR & INFO
          Obx(() {
            var user = authController.currentUser.value;
            String? avatarUrl = user?.avatarUrl;
            // Xử lý URL ảnh (cắt bỏ phần thừa nếu có)
            String domain = authController.baseUrl.replaceAll("/api/auth", "");

            return Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? NetworkImage("$domain$avatarUrl")
                            : null,
                        child: (avatarUrl == null || avatarUrl.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showEditProfileDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  user?.fullName ?? "Người dùng",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.userName ?? "username",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                // Badge Role
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRole() == 'teacher'
                        ? Colors.orange.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getRole() == 'teacher'
                        ? "Giảng viên"
                        : (_getRole() == 'admin'
                              ? "Quản trị viên"
                              : "Sinh viên"),
                    style: TextStyle(
                      color: _getRole() == 'teacher'
                          ? Colors.deepOrange
                          : Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 30),

          // 2. THỐNG KÊ (STATS) - Demo giao diện
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                "Khóa học",
                "5",
                Icons.book,
              ), // Có thể thay số 5 bằng list.length
              _buildVerticalDivider(),
              _buildStatItem("Bài tập", "12", Icons.assignment),
              _buildVerticalDivider(),
              _buildStatItem("Điểm danh", "98%", Icons.check_circle),
            ],
          ),

          const SizedBox(height: 30),

          // 3. MENU CÀI ĐẶT (SETTINGS LIST)
          _buildSettingsGroup(
            title: "Tài khoản",
            children: [
              _buildSettingItem(
                icon: Icons.edit,
                title: "Chỉnh sửa hồ sơ",
                onTap: () => _showEditProfileDialog(context),
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: "Đổi mật khẩu",
                onTap: () {
                  Get.snackbar("Thông báo", "Tính năng đang phát triển");
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildSettingsGroup(
            title: "Ứng dụng",
            children: [
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: "Giao diện tối",
                trailing: Switch(
                  value: false,
                  onChanged: (v) {},
                ), // Demo switch
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: "Về ứng dụng ClassMate",
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 4. LOGOUT BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => authController.logout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Đăng xuất",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Version 1.0.0",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- DIALOG CHỈNH SỬA HỒ SƠ ---
  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(
      text: authController.currentUser.value?.fullName,
    );

    // Reset ảnh cũ trong controller để tránh hiện ảnh lần trước
    authController.selectedImage.value = null;

    Get.defaultDialog(
      title: "Cập nhật hồ sơ",
      content: Column(
        children: [
          // Chọn ảnh
          GestureDetector(
            onTap: () => authController.pickImage(),
            child: Obx(() {
              // Ưu tiên hiển thị ảnh vừa chọn từ máy
              if (authController.selectedImageBytes.value != null) {
                return CircleAvatar(
                  radius: 40,
                  backgroundImage: MemoryImage(
                    authController.selectedImageBytes.value!,
                  ),
                );
              }
              // Nếu không thì hiện ảnh avatar hiện tại
              String? currentUrl = authController.currentUser.value?.avatarUrl;
              String domain = authController.baseUrl.replaceAll(
                "/api/auth",
                "",
              );

              return CircleAvatar(
                radius: 40,
                backgroundImage: (currentUrl != null)
                    ? NetworkImage("$domain$currentUrl")
                    : null,
                child: (currentUrl == null)
                    ? const Icon(Icons.camera_alt)
                    : null,
              );
            }),
          ),
          const SizedBox(height: 10),
          const Text(
            "Chạm để đổi ảnh",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Nhập tên
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: "Họ và tên",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
        ],
      ),
      textConfirm: "Lưu thay đổi",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        // Gọi hàm update trong AuthController
        await authController.updateProfile(
          fullName: nameCtrl.text,
          newAvatar: authController.selectedImage.value,
        );
        Get.back(); // Đóng dialog sau khi update xong (hoặc updateProfile tự đóng)
      },
    );
  }
  // --- CÁC WIDGET CON HỖ TRỢ ---

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // --- Admin panel placeholder (inline, không tạo file mới) ---
  Widget _adminPanelView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.admin_panel_settings, size: 72, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              "Bảng điều khiển quản trị",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Quản lý người dùng, thiết lập hệ thống và báo cáo.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- Manage students placeholder for teacher role ---
  Widget _manageStudentsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.group, size: 64, color: Colors.green),
            SizedBox(height: 12),
            Text(
              "Quản lý sinh viên",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Xem danh sách sinh viên, điểm và tương tác lớp.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
