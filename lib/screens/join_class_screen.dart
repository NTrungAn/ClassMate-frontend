// lib/screens/join_class_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/services/class_service.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final TextEditingController _codeController = TextEditingController();
  final ClassService _classService = ClassService.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinClass() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập mã lớp',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (code.length != 6) {
      Get.snackbar(
        'Lỗi',
        'Mã lớp phải có 6 ký tự',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _classService.joinClass(code);

      if (success) {
        Get.snackbar(
          'Thành công',
          'Đã tham gia lớp học thành công',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _codeController.clear();
        // Quay lại sau 2 giây
        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể tham gia lớp học. Kiểm tra lại mã lớp',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra: $e',
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
        title: const Text('Tham gia lớp học'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hướng dẫn
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: AppColors.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Hướng dẫn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Nhận mã lớp từ giảng viên\n'
                        '2. Nhập mã 6 ký tự vào ô bên dưới\n'
                        '3. Nhấn "Tham gia lớp học"',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Input field
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Mã lớp học (6 ký tự)',
                hintText: 'VD: ABC123',
                prefixIcon: const Icon(Icons.class_),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) {
                return Text(
                  '$currentLength/$maxLength',
                  style: TextStyle(
                    color: currentLength == maxLength
                        ? Colors.green
                        : Colors.grey,
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Join button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'THAM GIA LỚP HỌC',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Thông tin thêm
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lưu ý',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Mỗi mã lớp chỉ sử dụng được một lần\n'
                        '• Mã lớp có thời hạn sử dụng\n'
                        '• Nếu gặp lỗi, hãy liên hệ giảng viên',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}