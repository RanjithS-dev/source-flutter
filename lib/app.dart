import 'package:flutter/material.dart';

import 'models/auth_session.dart';
import 'screens/login_screen.dart';
import 'screens/workspace_shell.dart';
import 'services/api_service.dart';

class AttendanceApp extends StatefulWidget {
  const AttendanceApp({super.key});

  @override
  State<AttendanceApp> createState() => _AttendanceAppState();
}

class _AttendanceAppState extends State<AttendanceApp> {
  final ApiService _apiService = const ApiService();
  AppSession? _session;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BSZone Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC65D2E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F1E8),
        useMaterial3: true,
      ),
      home: _session == null
          ? LoginScreen(
              apiService: _apiService,
              onLoggedIn: (session) {
                setState(() {
                  _session = session;
                });
              },
            )
          : WorkspaceShell(
              apiService: _apiService,
              session: _session!,
              onLogout: () {
                setState(() {
                  _session = null;
                });
              },
            ),
    );
  }
}
