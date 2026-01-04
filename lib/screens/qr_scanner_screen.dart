import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/services/attendance_service.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/core/utils/snackbar_helper.dart';
import 'package:frontend/providers/auth_provider.dart';

import '../models/attendance_model.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isScanning = true;
  bool _isTorchOn = false;
  bool _isProcessing = false;
  String? _lastScannedCode;
  Timer? _debounceTimer;
  String _currentLocation = 'Đang lấy vị trí...';

  @override
  void initState() {
    super.initState();
    _startScanner();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    cameraController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _startScanner() {
    setState(() {
      _isScanning = true;
    });
  }

  void _stopScanner() {
    setState(() {
      _isScanning = false;
    });
  }

  void _toggleScanner() {
    if (_isScanning) {
      _stopScanner();
    } else {
      _startScanner();
    }
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    cameraController.toggleTorch();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationService = Get.find<LocationService>();
      final location = await locationService.getCurrentLocationName();
      setState(() {
        _currentLocation = location;
      });
    } catch (e) {
      setState(() {
        _currentLocation = "Không thể lấy vị trí";
      });
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty && !_isProcessing) {
      final String code = barcodes.first.rawValue ?? '';

      // Debounce: chỉ xử lý mỗi 3 giây
      if (_debounceTimer?.isActive ?? false) {
        return;
      }

      _processQrCode(code);

      // Set debounce timer
      _debounceTimer = Timer(const Duration(seconds: 3), () {
        _debounceTimer = null;
      });
    }
  }

  Future<void> _processQrCode(String rawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _lastScannedCode = rawValue;
    });

    try {
      String code = rawValue;

      // 🔥 FIX QUAN TRỌNG
      if (rawValue.trim().startsWith('{')) {
        final decoded = jsonDecode(rawValue);
        code = decoded['code'];
      }

      print('✅ QR CODE PARSED: $code');

      final attendanceService = Get.find<AttendanceService>();
      final validation = await attendanceService.validateCode(code);

      if (validation == null) {
        _showInvalidCode('Không nhận được phản hồi từ server');
        return;
      }

      if (!validation['valid']) {
        _showInvalidCode(validation['message'] ?? 'Mã QR không hợp lệ');
        return;
      }

      await _showConfirmationDialog(
        code,
        validation,
        validation['expectedStatus'],
      );
    } catch (e) {
      SnackbarHelper.showError('QR không hợp lệ');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }


  Future<void> _showConfirmationDialog(
      String code,
      Map<String, dynamic> sessionInfo,
      String expectedStatus
      ) async {
    final authProvider = Get.find<AuthProvider>();
    final user = authProvider.currentUser.value;

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              expectedStatus == "LATE"
                  ? FontAwesomeIcons.clock
                  : FontAwesomeIcons.checkCircle,
              color: expectedStatus == "LATE"
                  ? AppColors.warningColor
                  : AppColors.successColor,
            ),
            const SizedBox(width: 12),
            Text(
              expectedStatus == "LATE"
                  ? 'Điểm danh trễ'
                  : 'Xác nhận điểm danh',
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chào ${user?.fullName ?? 'bạn'}!'),
              const SizedBox(height: 12),

              // Thông tin lớp học
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sessionInfo['ClassSection']?['CourseName'] ?? 'Không rõ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lớp: ${sessionInfo['ClassSection']?['Name'] ?? 'Không rõ'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Phòng: ${sessionInfo['ClassSection']?['Room'] ?? 'Không rõ'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Giảng viên: ${sessionInfo['ClassSection']?['TeacherName'] ?? 'Không rõ'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Thông tin điểm danh
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin điểm danh:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Bắt đầu: '),
                      Text(_formatTime(sessionInfo['StartTime'])),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Kết thúc: '),
                      Text(_formatTime(sessionInfo['EndTime'])),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Trạng thái: '),
                      Text(
                        expectedStatus == "LATE" ? 'Trễ' : 'Đúng giờ',
                        style: TextStyle(
                          color: expectedStatus == "LATE"
                              ? AppColors.warningColor
                              : AppColors.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vị trí của bạn:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _currentLocation,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Mã QR
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mã: ${code.length > 20 ? '${code.substring(0, 20)}...' : code}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: expectedStatus == "LATE"
                  ? AppColors.warningColor
                  : AppColors.successColor,
            ),
            child: Text(expectedStatus == "LATE" ? 'ĐIỂM DANH TRỄ' : 'ĐIỂM DANH'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _performCheckIn(code);
    }
  }

  String _formatTime(dynamic time) {
    if (time is String) {
      final dateTime = DateTime.parse(time);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return '--:--';
  }

  Future<void> _performCheckIn(String code) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final attendanceService = Get.find<AttendanceService>();

      // Thực hiện check-in
      final result = await attendanceService.checkIn(
        code: code,
        studentLocation: _currentLocation,
      );

      if (result != null) {
        _showCheckInSuccess(result);
      } else {
        SnackbarHelper.showError('Điểm danh thất bại');
      }
    } catch (e) {
      SnackbarHelper.showError('Lỗi điểm danh: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showCheckInSuccess(CheckInResponse result) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              result.status == "LATE"
                  ? FontAwesomeIcons.clock
                  : FontAwesomeIcons.checkCircle,
              color: result.status == "LATE"
                  ? AppColors.warningColor
                  : AppColors.successColor,
            ),
            const SizedBox(width: 12),
            Text(result.status == "LATE" ? 'Điểm danh trễ' : 'Thành công'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Trạng thái: '),
                      Text(
                        result.status == "LATE" ? 'Trễ' : 'Đúng giờ',
                        style: TextStyle(
                          color: result.status == "LATE"
                              ? AppColors.warningColor
                              : AppColors.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Thời gian: '),
                      Text('${result.checkInTime.hour}:${result.checkInTime.minute} ${result.checkInTime.day}/${result.checkInTime.month}/${result.checkInTime.year}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Vị trí: '),
                      Expanded(
                        child: Text(
                          result.location ?? 'Không xác định',
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'Điểm danh thành công! Bạn có thể đóng màn hình này.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // Quay về màn hình trước
            },
            child: const Text('HOÀN TẤT'),
          ),
        ],
      ),
    );
  }

  void _showInvalidCode(String message) {
    Get.snackbar(
      'Mã QR không hợp lệ',
      message,
      backgroundColor: AppColors.warningColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR điểm danh'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.xmark),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn
                ? FontAwesomeIcons.bolt
                : FontAwesomeIcons.bolt),
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Scan Frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isScanning ? AppColors.primaryColor : Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Corner Borders
                  _buildCorner(
                    Alignment.topLeft,
                    const BorderDirectional(
                      top: BorderSide(color: AppColors.primaryColor, width: 4),
                      start: BorderSide(color: AppColors.primaryColor, width: 4),
                    ),
                  ),
                  _buildCorner(
                    Alignment.topRight,
                    const BorderDirectional(
                      top: BorderSide(color: AppColors.primaryColor, width: 4),
                      end: BorderSide(color: AppColors.primaryColor, width: 4),
                    ),
                  ),
                  _buildCorner(
                    Alignment.bottomLeft,
                    const BorderDirectional(
                      bottom: BorderSide(color: AppColors.primaryColor, width: 4),
                      start: BorderSide(color: AppColors.primaryColor, width: 4),
                    ),
                  ),
                  _buildCorner(
                    Alignment.bottomRight,
                    const BorderDirectional(
                      bottom: BorderSide(color: AppColors.primaryColor, width: 4),
                      end: BorderSide(color: AppColors.primaryColor, width: 4),
                    ),
                  ),

                  // Processing indicator
                  if (_isProcessing)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Đang xử lý...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  _isScanning && !_isProcessing
                      ? 'Đang quét mã QR...'
                      : _isProcessing
                      ? 'Đang xử lý...'
                      : 'Quét đã dừng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Đưa mã QR vào khung hình để điểm danh',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _currentLocation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),

          // Last Scanned Code
          if (_lastScannedCode != null && !_isProcessing)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      FontAwesomeIcons.qrcode,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Đã quét mã',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _lastScannedCode!.length > 30
                          ? '${_lastScannedCode!.substring(0, 30)}...'
                          : _lastScannedCode!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // Control Buttons
          if (!_isProcessing)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Switch Camera Button
                  _buildControlButton(
                    icon: FontAwesomeIcons.cameraRotate,
                    onPressed: () {
                      cameraController.switchCamera();
                    },
                  ),

                  const SizedBox(width: 32),

                  // Main Scan Button
                  GestureDetector(
                    onTap: _toggleScanner,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _isScanning
                            ? AppColors.errorColor
                            : AppColors.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isScanning
                                ? AppColors.errorColor
                                : AppColors.primaryColor).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isScanning
                            ? FontAwesomeIcons.stop
                            : FontAwesomeIcons.play,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 32),

                  // Refresh Location Button
                  _buildControlButton(
                    icon: FontAwesomeIcons.locationArrow,
                    onPressed: () async {
                      await _getCurrentLocation();
                      SnackbarHelper.showInfo('Đã cập nhật vị trí');
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, BorderDirectional border) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: border,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}