class ApiConstants {
  // Live Render backend deployed URL connecting to Render PostgreSQL DB
  static const String baseUrl = "https://hrms-backend-5xo8.onrender.com";

  // Auth endpoints
  static const String login = "$baseUrl/api/auth/login";
  static const String firstTimeChangePassword = "$baseUrl/api/auth/first-time-change-password";
  static const String changePassword = "$baseUrl/api/auth/change-password";
  static const String forgotPasswordQuestions = "$baseUrl/api/auth/forgot-password/get-questions";
  static const String forgotPasswordVerify = "$baseUrl/api/auth/forgot-password/verify-answer";
  static const String forgotPasswordReset = "$baseUrl/api/auth/forgot-password/reset";

  // Attendance endpoints
  static String todayAttendance(int userId) => "$baseUrl/api/attendance/today/$userId";
  static const String punchAttendance = "$baseUrl/api/attendance/punch";
  static String attendancePage(int userId, {String? month}) {
    if (month != null && month.isNotEmpty) {
      return "$baseUrl/api/attendance/page/$userId?month=$month";
    }
    return "$baseUrl/api/attendance/page/$userId";
  }
  static String attendanceStats(int userId, {String period = 'week'}) => 
      "$baseUrl/api/attendance/stats/$userId?period=$period";

  // Leave endpoints
  static String leaveData(int userId) => "$baseUrl/api/leaves/data/$userId";
  static const String applyLeave = "$baseUrl/api/leaves/apply";
  static String cancelLeave(int id) => "$baseUrl/api/leaves/cancel/$id";

  // Profile endpoints
  static String employeeProfile(int userId) => "$baseUrl/api/employee/profile/$userId";
  static String employmentInfo(int userId) => "$baseUrl/api/employee/employment-info/$userId";
  static String bankInfo(int userId) => "$baseUrl/api/employee/bank-info/$userId";

  // Admin endpoints
  static String adminEmployees({int orgId = 1}) => "$baseUrl/api/admin/employees?orgId=$orgId";
  static String adminLeaveBalances({int orgId = 1}) => "$baseUrl/api/admin/employee-leave-balances-overview?orgId=$orgId";
  static String announcements({int orgId = 1, bool all = true}) => "$baseUrl/api/announcements?orgId=$orgId&all=$all";
  static String adminWfhRequests({int orgId = 1}) => "$baseUrl/api/admin/wfh-requests?orgId=$orgId";
}
