import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/leave_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({Key? key}) : super(key: key);

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final ApiService _apiService = ApiService();

  List<LeaveBalance> _balances = [];
  List<LeaveType> _leaveTypes = [];
  List<ApproverUser> _approvers = [];
  List<LeaveRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaveData();
  }

  Future<void> _fetchLeaveData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getLeaveData(user.id);
      setState(() {
        _balances = res['balances'] as List<LeaveBalance>;
        _leaveTypes = res['leaveTypes'] as List<LeaveType>;
        _approvers = res['approvers'] as List<ApproverUser>;
        _requests = res['requests'] as List<LeaveRequest>;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showApplyLeaveModal() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    int? selectedLeaveTypeId = _leaveTypes.isNotEmpty ? _leaveTypes.first.id : null;
    int? selectedApproverId = _approvers.isNotEmpty ? _approvers.first.id : null;
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    final reasonController = TextEditingController();
    bool isHalfDay = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Apply for Leave',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Leave Type Dropdown
                    const Text('Leave Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: selectedLeaveTypeId,
                      decoration: const InputDecoration(),
                      items: _leaveTypes.map((lt) {
                        return DropdownMenuItem<int>(
                          value: lt.id,
                          child: Text(lt.name),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedLeaveTypeId = val),
                    ),
                    const SizedBox(height: 16),

                    // Approver Dropdown
                    if (_approvers.isNotEmpty) ...[
                      const Text('Approver', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: selectedApproverId,
                        decoration: const InputDecoration(),
                        items: _approvers.map((appr) {
                          return DropdownMenuItem<int>(
                            value: appr.id,
                            child: Text(appr.name),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => selectedApproverId = val),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Half day switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Half Day Leave', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        Switch(
                          value: isHalfDay,
                          onChanged: (val) => setModalState(() => isHalfDay = val),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Date Selectors
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: Text(DateFormat('yyyy-MM-dd').format(startDate)),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: startDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    setModalState(() {
                                      startDate = picked;
                                      if (endDate.isBefore(startDate)) endDate = picked;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        if (!isHalfDay) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('End Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: Text(DateFormat('yyyy-MM-dd').format(endDate)),
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: endDate,
                                      firstDate: startDate,
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (picked != null) {
                                      setModalState(() => endDate = picked);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: reasonController,
                      label: 'Reason',
                      hint: 'Provide reason for leave...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Submit Application',
                      isLoading: isSubmitting,
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (reasonController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a reason')),
                                );
                                return;
                              }
                              setModalState(() => isSubmitting = true);
                              final res = await _apiService.applyLeave(
                                userId: user.id,
                                leaveTypeId: selectedLeaveTypeId ?? 1,
                                approverId: selectedApproverId ?? 1,
                                startDate: DateFormat('yyyy-MM-dd').format(startDate),
                                endDate: DateFormat('yyyy-MM-dd').format(isHalfDay ? startDate : endDate),
                                reason: reasonController.text.trim(),
                                isHalfDay: isHalfDay,
                              );
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                Navigator.pop(context);
                                if (res['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Leave applied successfully!'), backgroundColor: AppColors.success),
                                  );
                                  _fetchLeaveData();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(res['message'] ?? 'Failed'), backgroundColor: AppColors.danger),
                                  );
                                }
                              }
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Management'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyLeaveModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Apply Leave', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLeaveData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Leave Balances', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _balances.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final bal = _balances[index];
                          return Container(
                            width: 140,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  bal.leaveTypeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                                Text(
                                  '${bal.remainingDays.toStringAsFixed(1)}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                                Text(
                                  'of ${bal.totalDays.toInt()} Days',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Text('Leave History & Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    if (_requests.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Center(
                          child: Text('No leave applications submitted yet', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _requests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final req = _requests[index];
                          final isPending = req.status.toLowerCase() == 'pending';
                          final isApproved = req.status.toLowerCase() == 'approved';

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      req.leaveTypeName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isApproved
                                            ? AppColors.successLight
                                            : isPending
                                                ? AppColors.warningLight
                                                : AppColors.dangerLight,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        req.status,
                                        style: TextStyle(
                                          color: isApproved
                                              ? AppColors.success
                                              : isPending
                                                  ? AppColors.warning
                                                  : AppColors.danger,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${req.startDate} to ${req.endDate} (${req.daysRequested} Day${req.daysRequested > 1 ? "s" : ""})',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                                if (req.reason.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    req.reason,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                                if (isPending) ...[
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () async {
                                        final ok = await _apiService.cancelLeave(req.id);
                                        if (ok && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Leave cancelled.')),
                                          );
                                          _fetchLeaveData();
                                        }
                                      },
                                      child: const Text('Cancel Request', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
