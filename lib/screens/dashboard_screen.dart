import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';
import '../services/api_service.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.apiService,
    required this.token,
  });

  final ApiService apiService;
  final String token;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String _error = '';
  DashboardSummary _summary = const DashboardSummary(
    totalLands: 0,
    activeWorkers: 0,
    dailyHarvest: 0,
    totalRevenue: 0,
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
      final summary = await widget.apiService.getDashboardSummary(widget.token);
      setState(() {
        _summary = summary;
      });
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to load dashboard';
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
                    'FIELD OVERVIEW',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          letterSpacing: 1.2,
                          color: const Color(0xFF1A6A48),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Today\'s coconut operations',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Track lands, active workers, harvest volume, and revenue from one rural-friendly mobile dashboard.',
                  ),
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
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              SummaryCard(
                  label: 'Lands', value: _summary.totalLands.toString()),
              SummaryCard(
                  label: 'Workers', value: _summary.activeWorkers.toString()),
              SummaryCard(
                  label: 'Harvest', value: _summary.dailyHarvest.toString()),
              SummaryCard(
                  label: 'Revenue',
                  value: 'Rs ${_summary.totalRevenue.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }
}
