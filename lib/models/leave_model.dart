class LeaveType {
  final int id;
  final String name;
  final double defaultDays;

  LeaveType({
    required this.id,
    required this.name,
    required this.defaultDays,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      defaultDays: double.tryParse(json['default_days']?.toString() ?? '12') ?? 12.0,
    );
  }
}

class LeaveBalance {
  final int leaveTypeId;
  final String leaveTypeName;
  final double totalDays;
  final double usedDays;

  LeaveBalance({
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.totalDays,
    required this.usedDays,
  });

  double get remainingDays => totalDays - usedDays;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      leaveTypeId: json['leave_type_id'] is int ? json['leave_type_id'] : int.tryParse(json['leave_type_id']?.toString() ?? '0') ?? 0,
      leaveTypeName: json['name']?.toString() ?? json['leave_type_name']?.toString() ?? 'Leave',
      totalDays: double.tryParse(json['total_days']?.toString() ?? '0') ?? 0.0,
      usedDays: double.tryParse(json['used_days']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class LeaveRequest {
  final int id;
  final String leaveTypeName;
  final String startDate;
  final String endDate;
  final double daysRequested;
  final String reason;
  final String status;
  final String? createdAt;
  final bool isHalfDay;
  final String? halfDayPeriod;

  LeaveRequest({
    required this.id,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.daysRequested,
    required this.reason,
    required this.status,
    this.createdAt,
    this.isHalfDay = false,
    this.halfDayPeriod,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      leaveTypeName: json['leave_type_name']?.toString() ?? json['type_name']?.toString() ?? 'General Leave',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      daysRequested: double.tryParse(json['days_requested']?.toString() ?? '1') ?? 1.0,
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['created_at']?.toString(),
      isHalfDay: json['is_half_day'] == true || json['is_half_day'] == 'true',
      halfDayPeriod: json['half_day_period']?.toString(),
    );
  }
}

class ApproverUser {
  final int id;
  final String name;
  final String email;

  ApproverUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ApproverUser.fromJson(Map<String, dynamic> json) {
    final first = json['first_name']?.toString() ?? '';
    final last = json['last_name']?.toString() ?? '';
    final fullName = ('$first $last').trim();
    return ApproverUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: fullName.isNotEmpty ? fullName : (json['name']?.toString() ?? json['email']?.toString() ?? 'Manager'),
      email: json['email']?.toString() ?? '',
    );
  }
}
