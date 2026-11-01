import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stat_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final attendance = Provider.of<AttendanceProvider>(context, listen: false);
      attendance.loadTodayAttendance(user.id);
      attendance.loadKpisAndRecords(user.id, month: _selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context);
    final user = auth.user;

    final today = attendance.todayRecord;
    final isCheckedIn = today?.isCheckedIn ?? false;
    final isCheckedOut = today?.isCheckedOut ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today Punch Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Device: ${today?.checkInDevice ?? "Mobile App (GPS Verified)"}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCheckedIn ? AppColors.successLight : AppColors.warningLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            attendance.currentStatus,
                            style: TextStyle(
                              color: isCheckedIn ? AppColors.success : AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimeColumn(
                          label: 'Check In',
                          time: today?.checkInTime != null ? today!.checkInTime!.substring(11, 16) : '--:--',
                          icon: Icons.login,
                          color: AppColors.primary,
                        ),
                        Container(height: 40, width: 1, color: AppColors.cardBorder),
                        _buildTimeColumn(
                          label: 'Check Out',
                          time: today?.checkOutTime != null ? today!.checkOutTime!.substring(11, 16) : '--:--',
                          icon: Icons.logout,
                          color: AppColors.danger,
                        ),
                        Container(height: 40, width: 1, color: AppColors.cardBorder),
                        _buildTimeColumn(
                          label: 'Total Hours',
                          time: today?.workingHoursDisplay ?? '--',
                          icon: Icons.timelapse,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: isCheckedIn ? 'Checked In' : 'Clock In Now',
                            icon: Icons.login,
                            backgroundColor: isCheckedIn ? Colors.grey.shade300 : AppColors.primary,
                            textColor: isCheckedIn ? Colors.grey.shade600 : Colors.white,
                            isLoading: attendance.isPunching && !isCheckedIn,
                            onPressed: (isCheckedIn || attendance.isPunching || user == null)
                                ? null
                                : () async {
                                    final ok = await attendance.punch(
                                      userId: user.id,
                                      type: 'CHECK_IN',
                                    );
                                    if (ok && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Checked In successfully with GPS location.'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: isCheckedOut ? 'Checked Out' : 'Clock Out Now',
                            icon: Icons.logout,
                            backgroundColor: (!isCheckedIn || isCheckedOut)
                                ? Colors.grey.shade300
                                : AppColors.danger,
                            textColor: (!isCheckedIn || isCheckedOut) ? Colors.grey.shade600 : Colors.white,
                            isLoading: attendance.isPunching && isCheckedIn && !isCheckedOut,
                            onPressed: (!isCheckedIn || isCheckedOut || attendance.isPunching || user == null)
                                ? null
                                : () async {
                                    final ok = await attendance.punch(
                                      userId: user.id,
                                      type: 'CHECK_OUT',
                                    );
                                    if (ok && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Checked Out successfully! Work hours synced.'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Monthly KPIs
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Present Days',
                      value: '${attendance.kpis?.presentDays ?? 0}',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                      backgroundColor: AppColors.successLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Working Hours',
                      value: attendance.kpis?.totalHoursDisplay ?? '0h 0m',
                      icon: Icons.hourglass_bottom,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Attendance Logs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              if (attendance.history.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Center(
                    child: Text('No attendance records found for this period', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attendance.history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = attendance.history[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.date_range, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.attendanceDate ?? 'Date',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'In: ${item.checkInTime?.substring(11, 16) ?? "--:--"} · Out: ${item.checkOutTime?.substring(11, 16) ?? "--:--"}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.status ?? 'Present',
                                  style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (item.workingHoursDisplay != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.workingHoursDisplay!,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ],
                          ),
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

  Widget _buildTimeColumn({
    required String label,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
