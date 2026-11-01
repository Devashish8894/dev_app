import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/custom_button.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context);
    final profile = auth.employeeProfile;
    final user = auth.user;

    final displayName = profile != null && profile.fullName.isNotEmpty
        ? profile.fullName
        : user?.email.split('@')[0] ?? 'Employee';

    final isCheckedIn = attendance.todayRecord?.isCheckedIn ?? false;
    final isCheckedOut = attendance.todayRecord?.isCheckedOut ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $displayName 👋',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              profile?.designation ?? 'Software Engineer',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await auth.refreshProfile();
            await attendance.loadTodayAttendance(user.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Punch-In / Out Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            attendance.currentStatus,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          attendance.todayRecord?.workMode ?? 'Office / Remote',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Today\'s Working Hours',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      attendance.todayRecord?.workingHoursDisplay ?? '00h 00m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: isCheckedIn ? 'Clocked In' : 'Clock In',
                            icon: Icons.login,
                            backgroundColor: isCheckedIn ? Colors.white24 : Colors.white,
                            textColor: isCheckedIn ? Colors.white : AppColors.primary,
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
                                          content: Text('Clocked in successfully with GPS location!'),
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
                            text: isCheckedOut ? 'Clocked Out' : 'Clock Out',
                            icon: Icons.logout,
                            backgroundColor: (!isCheckedIn || isCheckedOut)
                                ? Colors.white24
                                : AppColors.danger,
                            textColor: Colors.white,
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
                                          content: Text('Clocked out successfully! Total hours recorded.'),
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
              const Text(
                'Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Remaining Leaves',
                      value: '${profile?.leaveBalance?.toStringAsFixed(1) ?? '12.0'} Days',
                      icon: Icons.beach_access,
                      color: AppColors.warning,
                      backgroundColor: AppColors.warningLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Profile Progress',
                      value: '${profile?.profileCompletion?.toInt() ?? 80}%',
                      icon: Icons.verified_user_outlined,
                      color: AppColors.success,
                      backgroundColor: AppColors.successLight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Recent Attendance Activity',
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
                    child: Text(
                      'No attendance records yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attendance.history.take(4).length,
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
                            child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
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
                                  'In: ${item.checkInTime?.substring(11, 16) ?? '--:--'} · Out: ${item.checkOutTime?.substring(11, 16) ?? '--:--'}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
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
