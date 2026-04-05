import 'package:flutter/material.dart';

import '../models/reports_snapshot.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({
    super.key,
    required this.apiService,
    required this.token,
  });

  final ApiService apiService;
  final String token;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  String _error = '';
  List<LandProductionReportItem> _landItems =
      const <LandProductionReportItem>[];
  List<EmployeeWorkReportItem> _employeeItems =
      const <EmployeeWorkReportItem>[];
  ProfitLossReport _profit = const ProfitLossReport(
    totalRevenue: 0,
    totalExpenses: 0,
    totalProfit: 0,
  );

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
        widget.apiService.getLandProductionReport(widget.token),
        widget.apiService.getEmployeeWorkReport(widget.token),
        widget.apiService.getProfitLossReport(widget.token),
      ]);

      setState(() {
        _landItems = results[0] as List<LandProductionReportItem>;
        _employeeItems = results[1] as List<EmployeeWorkReportItem>;
        _profit = results[2] as ProfitLossReport;
      });
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to load reports';
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
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Profit and loss',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                      'Revenue: Rs ${_profit.totalRevenue.toStringAsFixed(0)}'),
                  Text(
                    'Expenses: Rs ${_profit.totalExpenses.toStringAsFixed(0)}',
                  ),
                  Text('Profit: Rs ${_profit.totalProfit.toStringAsFixed(0)}'),
                  if (_error.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      _error,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Top land production',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_landItems.isEmpty)
                    const Text('No land production report available yet.')
                  else
                    ..._landItems.take(5).map((item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.park_outlined),
                          title: Text(item.name),
                          subtitle: Text(item.village),
                          trailing: Text(item.totalCoconuts.toString()),
                        )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Employee work report',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_employeeItems.isEmpty)
                    const Text('No employee work report available yet.')
                  else
                    ..._employeeItems.take(5).map((item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.badge_outlined),
                          title: Text(item.name),
                          subtitle: Text(item.department),
                          trailing: Text(item.assignmentCount.toString()),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
