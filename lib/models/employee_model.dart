class EmployeeModel {
  final int id;
  final int? userId;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String email;
  final String designation;
  final String department;
  final String status;
  final String? avatarUrl;
  final String? location;
  final double? profileCompletion;
  final double? leaveBalance;
  final String? reportingManager;

  EmployeeModel({
    required this.id,
    this.userId,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.designation,
    required this.department,
    required this.status,
    this.avatarUrl,
    this.location,
    this.profileCompletion,
    this.leaveBalance,
    this.reportingManager,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['employee_id'] is int
          ? json['employee_id']
          : json['id'] is int
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      employeeCode: json['employee_code']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      designation: json['designation']?.toString() ?? 'Developer',
      department: json['department']?.toString() ?? 'Engineering',
      status: json['status']?.toString() ?? json['employment_status']?.toString() ?? 'Active',
      avatarUrl: json['avatar_url']?.toString() ?? json['profile_pic']?.toString(),
      location: json['location']?.toString() ?? json['city']?.toString() ?? 'Office',
      profileCompletion: double.tryParse(json['profile_completion_percentage']?.toString() ?? '0'),
      leaveBalance: double.tryParse(json['leave_balance']?.toString() ?? '0'),
      reportingManager: json['reporting_manager_name']?.toString() ?? json['reporting_manager']?.toString(),
    );
  }
}
