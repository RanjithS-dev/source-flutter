import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/attendance_summary.dart';
import '../services/api_service.dart';
import '../widgets/summary_card.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({
    super.key,
    required this.apiService,
    required this.token,
    required this.onMarkAttendance,
  });

  final ApiService apiService;
  final String token;
  final Future<void> Function() onMarkAttendance;

  @override
  State<AttendanceListScreen> createState() => AttendanceListScreenState();
}

class AttendanceListScreenState extends State<AttendanceListScreen> {
  bool _loading = true;
  String _error = '';
  AttendanceSummary _summary = const AttendanceSummary(
    todayPresent: 0,
    lateArrivals: 0,
    remoteEmployees: 0,
    attendanceRate: 0,
  );
  List<AttendanceRecord> _records = const <AttendanceRecord>[];

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        widget.apiService.getSummary(widget.token),
        widget.apiService.getAttendanceRecords(widget.token),
      ]);

      setState(() {
        _summary = results[0] as AttendanceSummary;
        _records = results[1] as List<AttendanceRecord>;
      });
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to load attendance';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _AttendanceHeaderCard(onMarkAttendance: widget.onMarkAttendance),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              SummaryCard(
                  label: 'Present', value: _summary.todayPresent.toString()),
              SummaryCard(
                  label: 'Late', value: _summary.lateArrivals.toString()),
              SummaryCard(
                  label: 'Remote', value: _summary.remoteEmployees.toString()),
              SummaryCard(label: 'Rate', value: '${_summary.attendanceRate}%'),
            ],
          ),
          const SizedBox(height: 16),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          if (_records.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'No attendance saved yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        'Use the separate mark attendance screen to add entries.'),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: widget.onMarkAttendance,
                      child: const Text('Mark attendance'),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Employee')),
                      DataColumn(label: Text('Department')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Schedule')),
                      DataColumn(label: Text('Hours')),
                      DataColumn(label: Text('Date')),
                    ],
                    rows: _records
                        .map(
                          (record) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(record.employeeName),
                                    Text(
                                      '${record.employeeCode} • ${record.designation}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(record.department)),
                              DataCell(Text(record.status)),
                              DataCell(Text(
                                  '${record.checkIn} - ${record.checkOut ?? 'Open'}')),
                              DataCell(Text(
                                  '${record.workedHours.toStringAsFixed(1)}h')),
                              DataCell(Text(record.dateLabel)),
                            ],
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AttendanceHeaderCard extends StatelessWidget {
  const _AttendanceHeaderCard({required this.onMarkAttendance});

  final Future<void> Function() onMarkAttendance;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ATTENDANCE LOG',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.2,
                    color: const Color(0xFF1F5D6B),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Full table view for saved attendance',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
                'Review entries here and use a separate input screen to mark new attendance.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onMarkAttendance,
              icon: const Icon(Icons.playlist_add_check_circle_rounded),
              label: const Text('Mark attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
