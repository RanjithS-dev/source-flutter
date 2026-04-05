import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../services/api_service.dart';

class AttendanceFormScreen extends StatefulWidget {
  const AttendanceFormScreen({
    super.key,
    required this.apiService,
    required this.token,
  });

  final ApiService apiService;
  final String token;

  @override
  State<AttendanceFormScreen> createState() => _AttendanceFormScreenState();
}

class _AttendanceFormScreenState extends State<AttendanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();
  final TextEditingController _workedHoursController =
      TextEditingController(text: '0');
  final TextEditingController _notesController = TextEditingController();

  bool _loadingEmployees = true;
  bool _saving = false;
  String _error = '';
  List<Employee> _employees = const <Employee>[];
  String _selectedEmployeeId = '';
  String _status = 'present';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    _workedHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _loadingEmployees = true;
      _error = '';
    });

    try {
      final employees = await widget.apiService.getEmployees(widget.token);
      setState(() {
        _employees = employees;
        if (employees.isNotEmpty) {
          _selectedEmployeeId = employees.first.id;
        }
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
          _loadingEmployees = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final initialDate =
        DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _dateController.text = _dateOnly(picked);
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final parsed = _parseTime(controller.text) ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: parsed,
    );

    if (picked != null) {
      controller.text = _formatTime(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = '';
    });

    try {
      await widget.apiService.createAttendance(
        token: widget.token,
        employeeId: _selectedEmployeeId,
        date: _dateController.text.trim(),
        status: _status,
        checkIn: _checkInController.text.trim(),
        checkOut: _checkOutController.text.trim().isEmpty
            ? null
            : _checkOutController.text.trim(),
        workedHours: double.tryParse(_workedHoursController.text.trim()) ?? 0,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to save attendance';
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: SafeArea(
        child: _loadingEmployees
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _employees.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Add employees first',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                    'At least one employee is required before attendance can be marked.'),
                                if (_error.isNotEmpty) ...<Widget>[
                                  const SizedBox(height: 12),
                                  Text(
                                    _error,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                  ),
                                ],
                              ],
                            )
                          : Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedEmployeeId,
                                    decoration: const InputDecoration(
                                        labelText: 'Employee'),
                                    items: _employees
                                        .map(
                                          (employee) =>
                                              DropdownMenuItem<String>(
                                            value: employee.id,
                                            child: Text(
                                                '${employee.fullName} (${employee.employeeCode})'),
                                          ),
                                        )
                                        .toList(growable: false),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedEmployeeId = value ?? '';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _dateController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Date',
                                      suffixIcon:
                                          Icon(Icons.calendar_today_rounded),
                                    ),
                                    onTap: _pickDate,
                                    validator: _requiredValidator,
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    initialValue: _status,
                                    decoration: const InputDecoration(
                                        labelText: 'Status'),
                                    items: const <DropdownMenuItem<String>>[
                                      DropdownMenuItem(
                                          value: 'present',
                                          child: Text('Present')),
                                      DropdownMenuItem(
                                          value: 'late', child: Text('Late')),
                                      DropdownMenuItem(
                                          value: 'remote',
                                          child: Text('Remote')),
                                      DropdownMenuItem(
                                          value: 'absent',
                                          child: Text('Absent')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _status = value ?? 'present';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _checkInController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Check-in time',
                                      suffixIcon: Icon(Icons.schedule_rounded),
                                    ),
                                    onTap: () => _pickTime(_checkInController),
                                    validator: _requiredValidator,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _checkOutController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Check-out time',
                                      suffixIcon: Icon(Icons.schedule_rounded),
                                    ),
                                    onTap: () => _pickTime(_checkOutController),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _workedHoursController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                        labelText: 'Worked hours'),
                                    validator: _requiredValidator,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _notesController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                        labelText: 'Notes'),
                                  ),
                                  if (_error.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 12),
                                    Text(
                                      _error,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                    ),
                                  ],
                                  const SizedBox(height: 18),
                                  FilledButton(
                                    onPressed: _saving ? null : _submit,
                                    child: Text(_saving
                                        ? 'Saving attendance...'
                                        : 'Save attendance'),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
