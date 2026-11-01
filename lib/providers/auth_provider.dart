import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/employee_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  UserModel? _user;
  EmployeeModel? _employeeProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  EmployeeModel? get employeeProfile => _employeeProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  // Initialize session from SharedPreferences on app launch
  Future<void> initSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _storageService.getUser();
      if (_user != null) {
        await refreshProfile();
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.login(email, password);
      if (res['success'] == true) {
        _user = res['user'] as UserModel;
        await _storageService.saveUser(_user!);
        await refreshProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    if (_user == null) return;
    try {
      _employeeProfile = await _apiService.getEmployeeProfile(_user!.id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    _user = null;
    _employeeProfile = null;
    await _storageService.clearUser();
    notifyListeners();
  }
}
