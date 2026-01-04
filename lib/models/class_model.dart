import 'package:flutter/material.dart';

class ClassSection {
  final int id;
  final String name;
  final String? description;
  final String? room;
  final int courseId;
  final String courseName;
  final String teacherId;
  final String teacherName;
  final String joinCode;
  final bool isTeacher;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> studyDays;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int studentCount;
  final bool isActive;
  final String scheduleSummary;

  ClassSection({
    required this.id,
    required this.name,
    this.description,
    this.room,
    required this.courseId,
    required this.courseName,
    required this.teacherId,
    required this.teacherName,
    required this.joinCode,
    required this.isTeacher,
    required this.startDate,
    required this.endDate,
    required this.studyDays,
    required this.startTime,
    required this.endTime,
    required this.studentCount,
    required this.isActive,
    required this.scheduleSummary,
  });

  factory ClassSection.fromJson(Map<String, dynamic> json) {
    // Parse time strings to TimeOfDay
    final startTimeStr = json['startTime'] as String? ?? '00:00';
    final endTimeStr = json['endTime'] as String? ?? '00:00';

    final startTimeParts = startTimeStr.split(':');
    final endTimeParts = endTimeStr.split(':');

    return ClassSection(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      room: json['room'],
      courseId: json['courseId'] ?? 0,
      courseName: json['courseName'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      joinCode: json['joinCode'] ?? '',
      isTeacher: json['isTeacher'] ?? false,
      startDate: DateTime.parse(json['startDate']?.toString() ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate']?.toString() ?? DateTime.now().toIso8601String()),
      studyDays: List<int>.from(json['studyDays'] ?? []),
      startTime: TimeOfDay(
        hour: int.tryParse(startTimeParts[0]) ?? 0,
        minute: int.tryParse(startTimeParts[1]) ?? 0,
      ),
      endTime: TimeOfDay(
        hour: int.tryParse(endTimeParts[0]) ?? 0,
        minute: int.tryParse(endTimeParts[1]) ?? 0,
      ),
      studentCount: json['studentCount'] ?? 0,
      isActive: json['isActive'] ?? false,
      scheduleSummary: json['scheduleSummary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'room': room,
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'joinCode': joinCode,
      'isTeacher': isTeacher,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'studyDays': studyDays,
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'studentCount': studentCount,
      'isActive': isActive,
      'scheduleSummary': scheduleSummary,
    };
  }

  String get dayNames {
    final days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return studyDays.map((day) => days[day]).join(', ');
  }

  // Không cần context ở đây
  String get timeRange {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  // Thêm phương thức format riêng nếu cần context
  String formatTimeRange(BuildContext context) {
    return '${_formatTime(context, startTime)} - ${_formatTime(context, endTime)}';
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }
}