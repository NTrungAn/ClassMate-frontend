class AttendanceSession {
  final int id;
  final String code;
  final DateTime startTime;
  final DateTime endTime;
  final String teacherLocation;
  final int classSectionId;
  final String className;
  final String courseName;
  final int checkedInCount;
  final bool isActive;
  final bool isExpired;

  AttendanceSession({
    required this.id,
    required this.code,
    required this.startTime,
    required this.endTime,
    required this.teacherLocation,
    required this.classSectionId,
    required this.className,
    required this.courseName,
    required this.checkedInCount,
    required this.isActive,
    required this.isExpired,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      startTime: DateTime.parse(json['startTime']?.toString() ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime']?.toString() ?? DateTime.now().toIso8601String()),
      teacherLocation: json['teacherLocation'] ?? '',
      classSectionId: json['classSectionId'] ?? 0,
      className: json['className'] ?? '',
      courseName: json['courseName'] ?? '',
      checkedInCount: json['checkedInCount'] ?? 0,
      isActive: json['isActive'] ?? false,
      isExpired: json['isExpired'] ?? false,
    );
  }
}

class AttendanceRecord {
  final int id;
  final DateTime checkedInAt;
  final String status;
  final bool isLate;
  final int sessionId;
  final String code;
  final int classId;
  final String className;
  final String courseName;
  final String teacherLocation;
  final String? studentLocation;
  final DateTime sessionStart;
  final DateTime sessionEnd;

  AttendanceRecord({
    required this.id,
    required this.checkedInAt,
    required this.status,
    required this.isLate,
    required this.sessionId,
    required this.code,
    required this.classId,
    required this.className,
    required this.courseName,
    required this.teacherLocation,
    this.studentLocation,
    required this.sessionStart,
    required this.sessionEnd,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? 0,
      checkedInAt: DateTime.parse(json['checkedInAt']?.toString() ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'OK',
      isLate: json['isLate'] ?? false,
      sessionId: json['sessionId'] ?? 0,
      code: json['code'] ?? '',
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      courseName: json['courseName'] ?? '',
      teacherLocation: json['teacherLocation'] ?? '',
      studentLocation: json['studentLocation'],
      sessionStart: DateTime.parse(json['sessionStart']?.toString() ?? DateTime.now().toIso8601String()),
      sessionEnd: DateTime.parse(json['sessionEnd']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
}

class CheckInResponse {
  final String message;
  final String status;
  final DateTime checkInTime;
  final String? location;
  final int sessionId;
  final int classSectionId;

  CheckInResponse({
    required this.message,
    required this.status,
    required this.checkInTime,
    this.location,
    required this.sessionId,
    required this.classSectionId,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 'OK',
      checkInTime: DateTime.parse(json['checkInTime']?.toString() ?? DateTime.now().toIso8601String()),
      location: json['location'],
      sessionId: json['sessionId'] ?? 0,
      classSectionId: json['classSectionId'] ?? 0,
    );
  }
}

class AttendanceStats {
  final int total;
  final int onTime;
  final int late;
  final int absent;

  AttendanceStats({
    required this.total,
    required this.onTime,
    required this.late,
    required this.absent,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      total: json['total'] ?? 0,
      onTime: json['onTime'] ?? 0,
      late: json['late'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }
}