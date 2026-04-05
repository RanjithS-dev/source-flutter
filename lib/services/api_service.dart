import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/attendance_record.dart';
import '../models/attendance_summary.dart';
import '../models/auth_session.dart';
import '../models/employee.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  const ApiService();

  Future<AppSession> login({
    required String username,
    required String password,
  }) {
    return _request<AppSession>(
      '/auth/login',
      method: 'POST',
      body: <String, dynamic>{
        'username': username,
        'password': password,
      },
      parser: (data) => AppSession.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Employee>> getEmployees(String token) {
    return _request<List<Employee>>(
      '/employees',
      token: token,
      parser: (data) {
        final items = data as List<dynamic>? ?? <dynamic>[];
        return items
            .map((item) => Employee.fromJson(item as Map<String, dynamic>))
            .toList(growable: false);
      },
    );
  }

  Future<Employee> createEmployee(String token, Employee employee) {
    return _request<Employee>(
      '/employees',
      method: 'POST',
      token: token,
      body: employee.toJson(),
      parser: (data) => Employee.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Employee> updateEmployee(String token, Employee employee) {
    return _request<Employee>(
      '/employees/${employee.id}',
      method: 'PUT',
      token: token,
      body: employee.toJson(),
      parser: (data) => Employee.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteEmployee(String token, String employeeId) {
    return _request<void>(
      '/employees/$employeeId',
      method: 'DELETE',
      token: token,
      parser: (_) {},
    );
  }

  Future<AttendanceSummary> getSummary(String token) {
    return _request<AttendanceSummary>(
      '/attendance/summary',
      token: token,
      parser: (data) =>
          AttendanceSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<AttendanceRecord>> getAttendanceRecords(String token) {
    return _request<List<AttendanceRecord>>(
      '/attendance/records',
      token: token,
      parser: (data) {
        final items = data as List<dynamic>? ?? <dynamic>[];
        return items
            .map((item) =>
                AttendanceRecord.fromJson(item as Map<String, dynamic>))
            .toList(growable: false);
      },
    );
  }

  Future<AttendanceRecord> createAttendance({
    required String token,
    required String employeeId,
    required String date,
    required String status,
    required String checkIn,
    String? checkOut,
    required double workedHours,
    String? notes,
  }) {
    return _request<AttendanceRecord>(
      '/attendance/mark',
      method: 'POST',
      token: token,
      body: <String, dynamic>{
        'employeeId': employeeId,
        'date': date,
        'status': status,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'workedHours': workedHours,
        'notes': notes,
      },
      parser: (data) => AttendanceRecord.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<T> _request<T>(
    String path, {
    String method = 'GET',
    String? token,
    Object? body,
    required T Function(dynamic data) parser,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    late final http.Response response;

    switch (method) {
      case 'POST':
        response =
            await http.post(uri, headers: headers, body: jsonEncode(body));
      case 'PUT':
        response =
            await http.put(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
      default:
        response = await http.get(uri, headers: headers);
    }

    final payload = _tryDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_extractMessage(payload, response));
    }

    if (payload is! Map<String, dynamic> || !payload.containsKey('data')) {
      throw const ApiException('Invalid server response');
    }

    return parser(payload['data']);
  }

  dynamic _tryDecode(String raw) {
    if (raw.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }

  String _extractMessage(dynamic payload, http.Response response) {
    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    final raw = response.body.trim();
    if (raw.startsWith('<')) {
      return 'Request failed (${response.statusCode})';
    }

    return raw.isNotEmpty ? raw : 'Request failed';
  }
}
