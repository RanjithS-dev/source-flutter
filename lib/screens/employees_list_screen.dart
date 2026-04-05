import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../services/api_service.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({
    super.key,
    required this.apiService,
    required this.token,
    required this.onAddEmployee,
    required this.onEditEmployee,
  });

  final ApiService apiService;
  final String token;
  final Future<void> Function() onAddEmployee;
  final Future<void> Function(Employee employee) onEditEmployee;

  @override
  State<EmployeesListScreen> createState() => EmployeesListScreenState();
}

class EmployeesListScreenState extends State<EmployeesListScreen> {
  bool _loading = true;
  String _error = '';
  String _deletingId = '';
  List<Employee> _employees = const <Employee>[];

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
      final employees = await widget.apiService.getEmployees(widget.token);
      setState(() {
        _employees = employees;
      });
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to load employees';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete employee'),
            content: Text('Delete ${employee.fullName}?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    setState(() {
      _deletingId = employee.id;
      _error = '';
    });

    try {
      await widget.apiService.deleteEmployee(widget.token, employee.id);
      setState(() {
        _employees = _employees
            .where((item) => item.id != employee.id)
            .toList(growable: false);
      });
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to delete employee';
      });
    } finally {
      if (mounted) {
        setState(() {
          _deletingId = '';
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
          _HeaderCard(
            eyebrow: 'Employee directory',
            title: '${_employees.length} employees saved',
            description:
                'Review, edit, or delete employee records from the full table view.',
            actionLabel: 'Add employee',
            onAction: widget.onAddEmployee,
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
          if (_employees.isEmpty)
            _EmptyStateCard(
              title: 'No employees added yet',
              description:
                  'Use the add screen to create your first employee record.',
              actionLabel: 'Add employee',
              onAction: widget.onAddEmployee,
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
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Department')),
                      DataColumn(label: Text('Designation')),
                      DataColumn(label: Text('Contact')),
                      DataColumn(label: Text('Joined')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _employees
                        .map(
                          (employee) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(employee.employeeCode)),
                              DataCell(Text(employee.fullName)),
                              DataCell(Text(employee.department)),
                              DataCell(Text(employee.designation)),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(employee.email),
                                    Text(
                                      employee.phoneNumber,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(employee.joinedOnLabel)),
                              DataCell(
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: <Widget>[
                                    OutlinedButton(
                                      onPressed: () =>
                                          widget.onEditEmployee(employee),
                                      child: const Text('Edit'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: _deletingId == employee.id
                                          ? null
                                          : () => _deleteEmployee(employee),
                                      child: Text(_deletingId == employee.id
                                          ? 'Deleting...'
                                          : 'Delete'),
                                    ),
                                  ],
                                ),
                              ),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;
  final Future<void> Function() onAction;

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
              eyebrow.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.2,
                    color: const Color(0xFF8A4A28),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String description;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(description),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
