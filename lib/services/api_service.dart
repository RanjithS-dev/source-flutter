import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/attendance_summary.dart';

class ApiService {
  const ApiService();

  Future<AttendanceSummary> getSummary() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/attendance/summary');

    try {
      final response = await http.get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
        return AttendanceSummary.fromJson(data);
      }
    } catch (_) {
      // Empty-state fallback keeps the app usable when the API is unavailable.
    }

    return const AttendanceSummary(
      todayPresent: 0,
      lateArrivals: 0,
      remoteEmployees: 0,
      attendanceRate: 0,
    );
  }
}
