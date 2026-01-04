import 'package:get/get.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/models/attendance_model.dart';

class AttendanceService extends GetxService {
  static AttendanceService get instance => Get.find<AttendanceService>();

  // Validate attendance code - FIXED
  Future<Map<String, dynamic>?> validateCode(String code) async {
    final response = await ApiService.instance
        .get('${ApiConstants.baseUrl}/Attendance/sessions/validate?code=$code');
    return response as Map<String, dynamic>?;
  }

  // Check-in attendance - FIXED
  Future<CheckInResponse?> checkIn({
    required String code,
    required String studentLocation,
  }) async {
    final response = await ApiService.instance.post(
      '${ApiConstants.baseUrl}/Attendance/check-in',
      {
        'code': code,
        'studentLocation': studentLocation,
      },
    );

    if (response != null && response is Map<String, dynamic>) {
      return CheckInResponse.fromJson(response);
    }

    return null;
  }

  // Get my attendance history
  Future<List<AttendanceRecord>> getMyAttendance() async {
    final response = await ApiService.instance
        .get('${ApiConstants.baseUrl}/Attendance/my');

    if (response != null && response is List) {
      return response
          .map<AttendanceRecord>((item) => AttendanceRecord.fromJson(item))
          .toList();
    }

    return [];
  }

  // Get sessions by class (for teacher)
  Future<List<AttendanceSession>> getSessionsByClass(int classSectionId) async {
    final response = await ApiService.instance
        .get('${ApiConstants.baseUrl}/Attendance/sessions/class/$classSectionId');

    if (response != null && response is List) {
      return response
          .map<AttendanceSession>((item) => AttendanceSession.fromJson(item))
          .toList();
    }

    return [];
  }

  // Get attendance records for a session
  Future<Map<String, dynamic>?> getSessionRecords(int sessionId) async {
    final response = await ApiService.instance
        .get('${ApiConstants.baseUrl}/Attendance/sessions/$sessionId/records');
    return response as Map<String, dynamic>?;
  }
}