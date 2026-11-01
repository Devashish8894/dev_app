class AttendanceRecord {
  final int? id;
  final String? attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? totalHours;
  final String? workingHoursDisplay;
  final String? status;
  final String? workMode;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkInDevice;
  final String? checkOutDevice;

  AttendanceRecord({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.totalHours,
    this.workingHoursDisplay,
    this.status,
    this.workMode,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInDevice,
    this.checkOutDevice,
  });

  bool get isCheckedIn => checkInTime != null && checkInTime!.isNotEmpty;
  bool get isCheckedOut => checkOutTime != null && checkOutTime!.isNotEmpty;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      attendanceDate: json['attendance_date']?.toString() ?? json['date']?.toString(),
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
      totalHours: json['total_hours']?.toString(),
      workingHoursDisplay: json['working_hours_display']?.toString(),
      status: json['status']?.toString() ?? json['attendance_status']?.toString() ?? 'Absent',
      workMode: json['work_mode']?.toString() ?? 'Office',
      checkInLocation: json['check_in_location']?.toString(),
      checkOutLocation: json['check_out_location']?.toString(),
      checkInDevice: json['check_in_device']?.toString(),
      checkOutDevice: json['check_out_device']?.toString(),
    );
  }
}

class AttendanceKpis {
  final int presentDays;
  final int workingDays;
  final String totalHoursDisplay;
  final int leaveDays;
  final String overtimeDisplay;
  final int absentDays;

  AttendanceKpis({
    required this.presentDays,
    required this.workingDays,
    required this.totalHoursDisplay,
    required this.leaveDays,
    required this.overtimeDisplay,
    required this.absentDays,
  });

  factory AttendanceKpis.fromJson(Map<String, dynamic> json) {
    return AttendanceKpis(
      presentDays: json['presentDays'] is int ? json['presentDays'] : int.tryParse(json['presentDays']?.toString() ?? '0') ?? 0,
      workingDays: json['workingDays'] is int ? json['workingDays'] : int.tryParse(json['workingDays']?.toString() ?? '0') ?? 0,
      totalHoursDisplay: json['totalHoursDisplay']?.toString() ?? '00h 00m',
      leaveDays: json['leaveDays'] is int ? json['leaveDays'] : int.tryParse(json['leaveDays']?.toString() ?? '0') ?? 0,
      overtimeDisplay: json['overtimeDisplay']?.toString() ?? '00h 00m',
      absentDays: json['absentDays'] is int ? json['absentDays'] : int.tryParse(json['absentDays']?.toString() ?? '0') ?? 0,
    );
  }
}
