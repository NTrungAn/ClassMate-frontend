import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/join_class_screen.dart';
import 'package:frontend/screens/class_schedule_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Phương thức getter thay vì biến final
  List<Map<String, dynamic>> get _notifications {
    return [
      {
        'id': '1',
        'title': 'Thông báo lịch thi',
        'content': 'Lịch thi cuối kỳ đã được cập nhật',
        'time': '2 giờ trước',
        'isRead': false,
      },
      {
        'id': '2',
        'title': 'Bài tập mới',
        'content': 'Bài tập lớn môn Lập trình di động',
        'time': '1 ngày trước',
        'isRead': true,
      },
      {
        'id': '3',
        'title': 'Điểm danh',
        'content': 'Đã điểm danh thành công môn Công nghệ phần mềm',
        'time': '2 ngày trước',
        'isRead': true,
      },
    ];
  }

  // Phương thức getter thay vì biến final
  List<Map<String, dynamic>> get _activities {
    return [
      {
        'id': '1',
        'title': 'Điểm danh thành công',
        'course': 'Lập trình di động',
        'time': 'Hôm nay, 08:30',
        'type': 'attendance',
      },
      {
        'id': '2',
        'title': 'Nộp bài tập',
        'course': 'Công nghệ phần mềm',
        'time': 'Hôm qua, 14:20',
        'type': 'assignment',
      },
      {
        'id': '3',
        'title': 'Vắng mặt có phép',
        'course': 'Toán cao cấp',
        'time': '2 ngày trước',
        'type': 'absence',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider>();

    return Obx(() {
      final user = authProvider.currentUser.value;

      if (user == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Trang chủ'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xin chào, ${user.fullName}!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${user.userName} • ${_getRoleText(user.role)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4 Button chính
              const Text(
                'Tính năng chính',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildFeatureButton(
                    icon: Icons.schedule,
                    label: 'Thời khóa biểu',
                    color: AppColors.primaryColor,
                    onTap: () {
                      // Mở màn hình thời khóa biểu
                      Get.to(() => const ClassScheduleScreen());
                    },
                  ),
                  _buildFeatureButton(
                    icon: Icons.assignment,
                    label: 'Bài tập',
                    color: Colors.green,
                    onTap: () {
                      Get.snackbar('Thông báo', 'Tính năng đang phát triển');
                    },
                  ),
                  _buildFeatureButton(
                    icon: Icons.group_add,
                    label: 'Tham gia lớp',
                    color: Colors.orange,
                    onTap: () {
                      // Mở màn hình tham gia lớp
                      Get.to(() => const JoinClassScreen());
                    },
                  ),
                  _buildFeatureButton(
                    icon: Icons.notifications,
                    label: 'Thông báo',
                    color: Colors.purple,
                    onTap: () {
                      Get.snackbar('Thông báo', 'Tính năng đang phát triển');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Hoạt động gần đây
              const Text(
                'Hoạt động gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ..._activities.map((activity) => _buildActivityItem(activity)).toList(),

              const SizedBox(height: 24),

              // Thông báo
              const Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ..._notifications.map((notification) => _buildNotificationItem(notification)).toList(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    IconData icon;
    Color color;

    switch (activity['type']) {
      case 'attendance':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'assignment':
        icon = Icons.assignment_turned_in;
        color = Colors.blue;
        break;
      case 'absence':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      default:
        icon = Icons.history;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(activity['title'] as String),
        subtitle: Text(activity['course'] as String),
        trailing: Text(
          activity['time'] as String,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Get.snackbar(
                'Đã đọc',
                'Đánh dấu đã đọc: ${notification['title']}',
              );
            },
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Đã đọc',
          ),
          SlidableAction(
            onPressed: (context) {
              Get.snackbar(
                'Đã xóa',
                'Xóa thông báo: ${notification['title']}',
              );
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Xóa',
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: notification['isRead'] ? Colors.grey[300]! : AppColors.primaryColor,
            width: notification['isRead'] ? 1 : 2,
          ),
        ),
        child: ListTile(
          leading: Icon(
            Icons.notifications,
            color: notification['isRead'] ? Colors.grey : AppColors.primaryColor,
          ),
          title: Text(
            notification['title'] as String,
            style: TextStyle(
              fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Text(notification['content'] as String),
          trailing: Text(
            notification['time'] as String,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'Student':
        return 'Sinh viên';
      case 'Teacher':
        return 'Giảng viên';
      case 'Admin':
        return 'Quản trị viên';
      default:
        return 'Người dùng';
    }
  }
}