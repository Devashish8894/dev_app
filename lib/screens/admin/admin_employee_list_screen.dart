import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/employee_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class AdminEmployeeListScreen extends StatefulWidget {
  const AdminEmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<AdminEmployeeListScreen> createState() => _AdminEmployeeListScreenState();
}

class _AdminEmployeeListScreenState extends State<AdminEmployeeListScreen> {
  final ApiService _apiService = ApiService();
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filtered = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final list = await _apiService.getAdminEmployees(orgId: user.tenantId);
      setState(() {
        _employees = list;
        _filtered = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _employees;
      } else {
        _filtered = _employees.where((e) {
          return e.fullName.toLowerCase().contains(q) ||
              e.email.toLowerCase().contains(q) ||
              e.employeeCode.toLowerCase().contains(q) ||
              e.designation.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Directory (${_filtered.length})'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or code...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Employee List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchEmployees,
                    child: _filtered.isEmpty
                        ? const Center(child: Text('No employees found', style: TextStyle(color: AppColors.textSecondary)))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final emp = _filtered[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.primaryLight,
                                      backgroundImage: emp.avatarUrl != null && emp.avatarUrl!.startsWith('http')
                                          ? NetworkImage(emp.avatarUrl!)
                                          : null,
                                      child: emp.avatarUrl == null || !emp.avatarUrl!.startsWith('http')
                                          ? Text(
                                              emp.fullName.isNotEmpty ? emp.fullName[0].toUpperCase() : 'E',
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            emp.fullName.isNotEmpty ? emp.fullName : emp.email.split('@')[0],
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${emp.designation} · ${emp.department}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            emp.email,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.successLight,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        emp.status,
                                        style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
