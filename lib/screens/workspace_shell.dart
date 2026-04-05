import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../services/api_service.dart';
import '../services/offline_queue_service.dart';
import 'dashboard_screen.dart';
import 'reports_screen.dart';
import 'worklog_entry_screen.dart';

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
  int _selectedIndex = 0;
  int _queuedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQueuedCount();
  }

  Future<void> _loadQueuedCount() async {
    final queued = await OfflineQueueService.instance.getQueuedCount();
    if (!mounted) {
      return;
    }
    setState(() {
      _queuedCount = queued;
    });
  }

  Future<void> _syncOfflineQueue() async {
    await OfflineQueueService.instance.syncQueuedWorkLogs(
      apiService: widget.apiService,
      token: widget.session.token,
    );
    await _loadQueuedCount();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _queuedCount == 0
              ? 'Offline work logs are synced'
              : 'Some work logs are still waiting for network',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = <String>[
      'Dashboard',
      'Add Work Log',
      'Reports',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sync offline work logs',
            onPressed: _syncOfflineQueue,
            icon: Badge.count(
              isLabelVisible: _queuedCount > 0,
              count: _queuedCount,
              child: const Icon(Icons.sync_rounded),
            ),
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
                      'BSZone Coconut ERP',
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
                      '${widget.session.username} • ${widget.session.role}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5A6472),
                          ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('Dashboard'),
                selected: _selectedIndex == 0,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.agriculture_outlined),
                title: const Text('Work Log'),
                selected: _selectedIndex == 1,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: const Text('Reports'),
                selected: _selectedIndex == 2,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedIndex = 2;
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
          DashboardScreen(
            apiService: widget.apiService,
            token: widget.session.token,
          ),
          WorkLogEntryScreen(
            apiService: widget.apiService,
            token: widget.session.token,
            onQueuedCountChanged: (value) {
              setState(() {
                _queuedCount = value;
              });
            },
          ),
          ReportsScreen(
            apiService: widget.apiService,
            token: widget.session.token,
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.agriculture_outlined),
            selectedIcon: Icon(Icons.agriculture_rounded),
            label: 'Work Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
