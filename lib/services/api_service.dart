import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/attendance_record.dart';
import '../models/attendance_summary.dart';
import '../models/auth_session.dart';
import '../models/dashboard_summary.dart';
import '../models/employee.dart';
import '../models/land.dart';
import '../models/reports_snapshot.dart';
import '../models/vehicle.dart';
import '../models/worklog.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  const ApiService();

  String get _legacyBaseUrl => AppConfig.apiBaseUrl;

  String get _apiBaseUrl {
    if (AppConfig.apiBaseUrl.endsWith('/api/v1')) {
      return AppConfig.apiBaseUrl;
    }
    if (AppConfig.apiBaseUrl.endsWith('/api')) {
      return '${AppConfig.apiBaseUrl}/v1';
    }
    return '${AppConfig.apiBaseUrl}/api/v1';
  }

  Future<AppSession> login({
    required String username,
    required String password,
  }) {
    return _request<AppSession>(
      '/auth/token',
      method: 'POST',
      body: <String, dynamic>{
        'username': username,
        'password': password,
      },
      parser: (data) => AppSession.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<DashboardSummary> getDashboardSummary(String token) {
    return _request<DashboardSummary>(
      '/dashboard/summary',
      token: token,
      parser: (data) => DashboardSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Land>> getLands(String token) {
    return _requestList<Land>(
      '/lands',
      token: token,
      itemParser: (item) => Land.fromJson(item),
    );
  }

  Future<List<Employee>> getEmployees(String token) {
    return _requestList<Employee>(
      '/employees',
      token: token,
      itemParser: (item) => Employee.fromJson(item),
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

  Future<List<Vehicle>> getVehicles(String token) {
    return _requestList<Vehicle>(
      '/vehicles',
      token: token,
      itemParser: (item) => Vehicle.fromJson(item),
    );
  }

  Future<List<WorkLog>> getWorkLogs(String token) {
    return _requestList<WorkLog>(
      '/worklogs',
      token: token,
      itemParser: (item) => WorkLog.fromJson(item),
    );
  }

  Future<WorkLog> createWorkLog({
    required String token,
    required String workDate,
    required String landId,
    required int coconutCount,
    required int bagCount,
    required List<String> workerIds,
    String? supervisorId,
    String? vehicleId,
    double? latitude,
    double? longitude,
    String? notes,
  }) {
    return _request<WorkLog>(
      '/worklogs',
      method: 'POST',
      token: token,
      body: <String, dynamic>{
        'work_date': workDate,
        'land_id': landId,
        'supervisor_id': supervisorId,
        'vehicle_id': vehicleId,
        'coconut_count': coconutCount,
        'bag_count': bagCount,
        'worker_ids': workerIds.map(int.parse).toList(growable: false),
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
      },
      parser: (data) => WorkLog.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<LandProductionReportItem>> getLandProductionReport(String token) {
    return _request<List<LandProductionReportItem>>(
      '/reports/land-production',
      token: token,
      parser: (data) {
        final items = data as List<dynamic>? ?? <dynamic>[];
        return items
            .map((item) =>
                LandProductionReportItem.fromJson(item as Map<String, dynamic>))
            .toList(growable: false);
      },
    );
  }

  Future<List<EmployeeWorkReportItem>> getEmployeeWorkReport(String token) {
    return _request<List<EmployeeWorkReportItem>>(
      '/reports/employee-work',
      token: token,
      parser: (data) {
        final items = data as List<dynamic>? ?? <dynamic>[];
        return items
            .map((item) =>
                EmployeeWorkReportItem.fromJson(item as Map<String, dynamic>))
            .toList(growable: false);
      },
    );
  }

  Future<ProfitLossReport> getProfitLossReport(String token) {
    return _request<ProfitLossReport>(
      '/reports/profit-loss',
      token: token,
      parser: (data) => ProfitLossReport.fromJson(data as Map<String, dynamic>),
    );
  }

  // Legacy compatibility helpers left in place while older screens still
  // exist in the repo.
  Future<AttendanceSummary> getSummary(String token) {
    return _request<AttendanceSummary>(
      '/attendance/summary',
      token: token,
      parser: (data) =>
          AttendanceSummary.fromJson(data as Map<String, dynamic>),
      useLegacy: true,
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
      useLegacy: true,
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
      useLegacy: true,
    );
  }

  Future<T> _request<T>(
    String path, {
    String method = 'GET',
    String? token,
    Object? body,
    required T Function(dynamic data) parser,
    bool useLegacy = false,
  }) async {
    final uri = Uri.parse('${useLegacy ? _legacyBaseUrl : _apiBaseUrl}$path');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await _send(method, uri, headers, body);
    final payload = _tryDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_extractMessage(payload, response));
    }

    if (useLegacy) {
      if (payload is! Map<String, dynamic> || !payload.containsKey('data')) {
        throw const ApiException('Invalid server response');
      }
      return parser(payload['data']);
    }

    if (payload == null) {
      throw const ApiException('Invalid server response');
    }

    return parser(payload);
  }

  Future<List<T>> _requestList<T>(
    String path, {
    required String token,
    required T Function(Map<String, dynamic> item) itemParser,
  }) async {
    return _request<List<T>>(
      path,
      token: token,
      parser: (data) {
        if (data is List<dynamic>) {
          return data
              .map((item) => itemParser(item as Map<String, dynamic>))
              .toList(growable: false);
        }

        final payload = data as Map<String, dynamic>;
        final items = payload['results'] as List<dynamic>? ?? <dynamic>[];
        return items
            .map((item) => itemParser(item as Map<String, dynamic>))
            .toList(growable: false);
      },
    );
  }

  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, String> headers,
    Object? body,
  ) {
    switch (method) {
      case 'POST':
        return http.post(uri, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return http.put(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        return http.get(uri, headers: headers);
    }
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
      final detail = payload['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

      final message = payload['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      for (final value in payload.values) {
        if (value is List && value.isNotEmpty && value.first is String) {
          return value.first as String;
        }
      }
    }

    final raw = response.body.trim();
    if (raw.startsWith('<')) {
      return 'Request failed (${response.statusCode})';
    }

    return raw.isNotEmpty ? raw : 'Request failed';
  }
}
