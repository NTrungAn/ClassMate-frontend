class ApiConstants {
  // Base URL - Thay đổi theo địa chỉ API của bạn
  static const String baseUrl = 'http://192.168.1.249:5201/api';
  // static const String baseUrl = 'http://10.0.2.2:5000/api'; // Cho Android Emulator

  // Auth Endpoints
  static const String login = '$baseUrl/Auth/login';
  static const String getProfile = '$baseUrl/Auth/me';
  static const String myClasses = '$baseUrl/ClassSections/my';
  static const String classById = '$baseUrl/ClassSections';
  static const String enrollClass = '$baseUrl/Enrollments/join';

  static const String attendanceBase = '$baseUrl/Attendance';
  static const String validateCode = '$attendanceBase/validate';
  static const String checkIn = '$attendanceBase/check-in';
  static const String myAttendance = '$attendanceBase/my';
  static const String sessionRecords = '$attendanceBase/sessions';
  // Timeout
  static const int receiveTimeout = 15000;
  static const int connectTimeout = 15000;

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // JWT Key
  static const String jwtTokenKey = 'jwt_token';
  static const String userDataKey = 'user_data';
}
