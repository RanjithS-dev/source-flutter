import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../services/api_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({
    super.key,
    required this.apiService,
    required this.token,
    this.employee,
  });

  final ApiService apiService;
  final String token;
  final Employee? employee;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _employeeCodeController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _departmentController;
  late final TextEditingController _designationController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _joinedOnController;
  bool _saving = false;
  String _error = '';

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final employee = widget.employee;
    _employeeCodeController =
        TextEditingController(text: employee?.employeeCode ?? '');
    _fullNameController = TextEditingController(text: employee?.fullName ?? '');
    _departmentController =
        TextEditingController(text: employee?.department ?? '');
    _designationController =
        TextEditingController(text: employee?.designation ?? '');
    _emailController = TextEditingController(text: employee?.email ?? '');
    _phoneController = TextEditingController(text: employee?.phoneNumber ?? '');
    _joinedOnController =
        TextEditingController(text: employee?.joinedOnLabel ?? '');
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _fullNameController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _joinedOnController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate =
        DateTime.tryParse(_joinedOnController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final month = picked.month.toString().padLeft(2, '0');
      final day = picked.day.toString().padLeft(2, '0');
      _joinedOnController.text = '${picked.year}-$month-$day';
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

    final employee = Employee(
      id: widget.employee?.id ?? '',
      employeeCode: _employeeCodeController.text.trim(),
      fullName: _fullNameController.text.trim(),
      department: _departmentController.text.trim(),
      designation: _designationController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      joinedOn: DateTime.parse(_joinedOnController.text.trim()),
    );

    try {
      if (_isEditing) {
        await widget.apiService.updateEmployee(widget.token, employee);
      } else {
        await widget.apiService.createEmployee(widget.token, employee);
      }

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
        _error = _isEditing
            ? 'Unable to update employee'
            : 'Unable to save employee';
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
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Employee' : 'Add Employee'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _employeeCodeController,
                        decoration:
                            const InputDecoration(labelText: 'Employee code'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _fullNameController,
                        decoration:
                            const InputDecoration(labelText: 'Full name'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _departmentController,
                        decoration:
                            const InputDecoration(labelText: 'Department'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _designationController,
                        decoration:
                            const InputDecoration(labelText: 'Designation'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration:
                            const InputDecoration(labelText: 'Phone number'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _joinedOnController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Joined date',
                          suffixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        onTap: _pickDate,
                        validator: _requiredValidator,
                      ),
                      if (_error.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          _error,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: Text(_saving
                            ? (_isEditing ? 'Updating...' : 'Saving...')
                            : (_isEditing
                                ? 'Update employee'
                                : 'Save employee')),
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
}
