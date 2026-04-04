import 'package:flutter/material.dart';

import '../models/attendance_summary.dart';
import '../services/api_service.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<AttendanceSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = const ApiService().getSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFBF5), Color(0xFFF1E9DC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<AttendanceSummary>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              final summary = snapshot.data ??
                  const AttendanceSummary(
                    todayPresent: 84,
                    lateArrivals: 6,
                    remoteEmployees: 11,
                    attendanceRate: 93,
                  );

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Attendance overview',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A mobile-first snapshot of today\'s attendance activity.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF5A6472),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SummaryCard(
                        label: 'Present',
                        value: summary.todayPresent.toString(),
                      ),
                      SummaryCard(
                        label: 'Late',
                        value: summary.lateArrivals.toString(),
                      ),
                      SummaryCard(
                        label: 'Remote',
                        value: summary.remoteEmployees.toString(),
                      ),
                      SummaryCard(
                        label: 'Rate',
                        value: '${summary.attendanceRate}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC65D2E),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next mobile milestones',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Add QR check-in, location validation, leave requests, and profile-based access once the final product flow is confirmed.',
                          style: TextStyle(
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
