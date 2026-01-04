// lib/screens/class_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/services/class_service.dart';
import 'package:frontend/models/class_model.dart';

class ClassScheduleScreen extends StatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  State<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends State<ClassScheduleScreen> {
  final ClassService _classService = ClassService.instance;
  late Future<List<ClassSection>> _classesFuture;
  List<ClassSection> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final classes = await _classService.getMyClasses();
      setState(() {
        _classes = classes;
      });
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách lớp học: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thời khóa biểu'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: _loadClasses,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có lớp học nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy tham gia lớp học để xem thời khóa biểu',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadClasses,
        color: AppColors.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _classes.length,
          itemBuilder: (context, index) {
            final classItem = _classes[index];
            return _buildClassCard(classItem);
          },
        ),
      ),
    );
  }

  Widget _buildClassCard(ClassSection classItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: classItem.isActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    classItem.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: classItem.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: classItem.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Text(
                    classItem.isActive ? 'Đang học' : 'Đã kết thúc',
                    style: TextStyle(
                      fontSize: 12,
                      color: classItem.isActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Course info
            Text(
              classItem.courseName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            // Schedule info
            _buildInfoRow(
              icon: Icons.schedule,
              text: '${_getDayNames(classItem.studyDays)}, ${classItem.startTime.format(context)} - ${classItem.endTime.format(context)}',
            ),

            _buildInfoRow(
              icon: Icons.calendar_today,
              text: '${_formatDate(classItem.startDate)} - ${_formatDate(classItem.endDate)}',
            ),

            _buildInfoRow(
              icon: Icons.location_on,
              text: classItem.room ?? 'Chưa có phòng học',
            ),

            _buildInfoRow(
              icon: Icons.person,
              text: 'GV: ${classItem.teacherName}',
            ),

            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.group, size: 14, color: AppColors.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '${classItem.studentCount} SV',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.code, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        classItem.joinCode,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayNames(List<int> studyDays) {
    final days = ['Chủ Nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
    final dayNames = studyDays.map((day) => days[day]).toList();
    return dayNames.join(', ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}