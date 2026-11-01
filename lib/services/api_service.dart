import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_model.dart';
import '../models/employee_model.dart';

class ApiService {
  final http.Client _client = http.Client();

  // =========================================================================
  // 1. AUTHENTICATION
  // =========================================================================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return {
        'success': true,
        'requirePasswordChange': data['requirePasswordChange'] == true,
        'user': UserModel.fromJson(data['user']),
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Authentication failed',
      };
    }
  }

  Future<bool> firstTimeChangePassword(int userId, String newPassword) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.firstTimeChangePassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'newPassword': newPassword,
      }),
    );
    return response.statusCode == 200;
  }

  // =========================================================================
  // 2. ATTENDANCE
  // =========================================================================
  Future<Map<String, dynamic>> getTodayAttendance(int userId) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.todayAttendance(userId)),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final today = data['today'] != null ? AttendanceRecord.fromJson(data['today']) : null;
      final historyList = (data['history'] as List? ?? [])
          .map((item) => AttendanceRecord.fromJson(item))
          .toList();

      return {
        'today': today,
        'history': historyList,
      };
    }
    return {'today': null, 'history': <AttendanceRecord>[]};
  }

  Future<Map<String, dynamic>> punchAttendance({
    required int userId,
    required String type, // 'CHECK_IN' or 'CHECK_OUT'
    required String location,
    required String device,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.punchAttendance),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'type': type,
        'location': location,
        'device': device,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': data['message'] ?? 'Punch registered',
        'record': data['record'] != null ? AttendanceRecord.fromJson(data['record']) : null,
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to register punch',
      };
    }
  }

  Future<Map<String, dynamic>> getAttendancePage(int userId, {String? month}) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.attendancePage(userId, month: month)),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final kpis = data['kpis'] != null ? AttendanceKpis.fromJson(data['kpis']) : null;
      final records = (data['dailyRecords'] as List? ?? [])
          .map((item) => AttendanceRecord.fromJson(item))
          .toList();

      return {
        'kpis': kpis,
        'dailyRecords': records,
      };
    }
    return {'kpis': null, 'dailyRecords': <AttendanceRecord>[]};
  }

  // =========================================================================
  // 3. LEAVES
  // =========================================================================
  Future<Map<String, dynamic>> getLeaveData(int userId) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.leaveData(userId)),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final balances = (data['balances'] as List? ?? [])
          .map((item) => LeaveBalance.fromJson(item))
          .toList();
      final leaveTypes = (data['leaveTypes'] as List? ?? [])
          .map((item) => LeaveType.fromJson(item))
          .toList();
      final approvers = (data['approvers'] as List? ?? [])
          .map((item) => ApproverUser.fromJson(item))
          .toList();
      final requests = (data['requests'] as List? ?? [])
          .map((item) => LeaveRequest.fromJson(item))
          .toList();

      return {
        'balances': balances,
        'leaveTypes': leaveTypes,
        'approvers': approvers,
        'requests': requests,
      };
    }
    return {
      'balances': <LeaveBalance>[],
      'leaveTypes': <LeaveType>[],
      'approvers': <ApproverUser>[],
      'requests': <LeaveRequest>[],
    };
  }

  Future<Map<String, dynamic>> applyLeave({
    required int userId,
    required int leaveTypeId,
    required int approverId,
    required String startDate,
    required String endDate,
    required String reason,
    bool isHalfDay = false,
    String? halfDayPeriod,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.applyLeave),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'leaveTypeId': leaveTypeId,
        'approverId': approverId,
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason,
        'isHalfDay': isHalfDay,
        'halfDayPeriod': halfDayPeriod,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'message': 'Leave application submitted'};
    } else {
      return {'success': false, 'message': data['error'] ?? data['message'] ?? 'Failed to apply'};
    }
  }

  Future<bool> cancelLeave(int requestId) async {
    final response = await _client.put(
      Uri.parse(ApiConstants.cancelLeave(requestId)),
    );
    return response.statusCode == 200;
  }

  // =========================================================================
  // 4. EMPLOYEE PROFILE
  // =========================================================================
  Future<EmployeeModel?> getEmployeeProfile(int userId) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.employeeProfile(userId)),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return EmployeeModel.fromJson(data);
    }
    return null;
  }

  // =========================================================================
  // 5. ADMIN / HR FUNCTIONS
  // =========================================================================
  Future<List<EmployeeModel>> getAdminEmployees({int orgId = 1}) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.adminEmployees(orgId: orgId)),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['employees'] as List? ?? []);
      return list.map((item) => EmployeeModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getAnnouncements({int orgId = 1}) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.announcements(orgId: orgId, all: true)),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['announcements'] as List? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }
}
