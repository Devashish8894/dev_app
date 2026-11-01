import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AttendanceRecord? _todayRecord;
  List<AttendanceRecord> _history = [];
  AttendanceKpis? _kpis;
  bool _isLoading = false;
  bool _isPunching = false;
  String? _errorMessage;

  AttendanceRecord? get todayRecord => _todayRecord;
  List<AttendanceRecord> get history => _history;
  AttendanceKpis? get kpis => _kpis;
  bool get isLoading => _isLoading;
  bool get isPunching => _isPunching;
  String? get errorMessage => _errorMessage;

  String get currentStatus {
    if (_todayRecord == null || _todayRecord!.checkInTime == null) {
      return 'Not Checked In';
    }
    if (_todayRecord!.checkOutTime != null) {
      return 'Checked Out';
    }
    return 'Checked In';
  }

  Future<void> loadTodayAttendance(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.getTodayAttendance(userId);
      _todayRecord = res['today'] as AttendanceRecord?;
      _history = res['history'] as List<AttendanceRecord>;
    } catch (e) {
      _errorMessage = 'Failed to load attendance';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadKpisAndRecords(int userId, {String? month}) async {
    try {
      final res = await _apiService.getAttendancePage(userId, month: month);
      _kpis = res['kpis'] as AttendanceKpis?;
      if (res['dailyRecords'] != null) {
        _history = res['dailyRecords'] as List<AttendanceRecord>;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> punch({
    required int userId,
    required String type, // 'CHECK_IN' or 'CHECK_OUT'
  }) async {
    _isPunching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location and device name
      final locDetails = await LocationService.getCurrentLocationAndDevice();

      final res = await _apiService.punchAttendance(
        userId: userId,
        type: type,
        location: locDetails.locationName,
        device: locDetails.deviceName,
        latitude: locDetails.latitude,
        longitude: locDetails.longitude,
      );

      if (res['success'] == true) {
        _todayRecord = res['record'] as AttendanceRecord?;
        // Refresh full today & history
        await loadTodayAttendance(userId);
        _isPunching = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Failed to register punch';
        _isPunching = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error while punching attendance';
      _isPunching = false;
      notifyListeners();
      return false;
    }
  }
}
