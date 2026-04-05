import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import 'attendance_form_screen.dart';
import 'attendance_list_screen.dart';
import 'employee_form_screen.dart';
import 'employees_list_screen.dart';

class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({
    super.key,
    required this.apiService,
    required this.session,
    required this.onLogout,
  });

  final ApiService apiService;
  final AppSession session;
  final VoidCallback onLogout;

  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  final GlobalKey<EmployeesListScreenState> _employeesKey =
      GlobalKey<EmployeesListScreenState>();
  final GlobalKey<AttendanceListScreenState> _attendanceKey =
      GlobalKey<AttendanceListScreenState>();
  int _selectedIndex = 0;

  Future<void> _openEmployeeForm([Employee? employee]) async {
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => EmployeeFormScreen(
          apiService: widget.apiService,
          token: widget.session.token,
          employee: employee,
        ),
      ),
    );

    if (refreshed == true) {
      _employeesKey.currentState?.reload();
    }
  }

  Future<void> _openAttendanceForm() async {
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => AttendanceFormScreen(
          apiService: widget.apiService,
          token: widget.session.token,
        ),
      ),
    );

    if (refreshed == true) {
      _attendanceKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = <String>['Employee List', 'Attendance List'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: <Widget>[
          IconButton(
            tooltip: _selectedIndex == 0 ? 'Add employee' : 'Mark attendance',
            onPressed: () => _selectedIndex == 0
                ? _openEmployeeForm()
                : _openAttendanceForm(),
            icon: Icon(_selectedIndex == 0
                ? Icons.person_add_alt_1_rounded
                : Icons.playlist_add_check_circle_rounded),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'BSZone Admin',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.session.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      widget.session.username,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5A6472),
                          ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Employees'),
                selected: _selectedIndex == 0,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.fact_check_outlined),
                title: const Text('Attendance'),
                selected: _selectedIndex == 1,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log out'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          EmployeesListScreen(
            key: _employeesKey,
            apiService: widget.apiService,
            token: widget.session.token,
            onAddEmployee: _openEmployeeForm,
            onEditEmployee: _openEmployeeForm,
          ),
          AttendanceListScreen(
            key: _attendanceKey,
            apiService: widget.apiService,
            token: widget.session.token,
            onMarkAttendance: _openAttendanceForm,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded),
            label: 'Employees',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded),
            label: 'Attendance',
          ),
        ],
      ),
    );
  }
}
