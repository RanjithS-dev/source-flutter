import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../models/land.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';
import '../services/offline_queue_service.dart';

class WorkLogEntryScreen extends StatefulWidget {
  const WorkLogEntryScreen({
    super.key,
    required this.apiService,
    required this.token,
    required this.onQueuedCountChanged,
  });

  final ApiService apiService;
  final String token;
  final ValueChanged<int> onQueuedCountChanged;

  @override
  State<WorkLogEntryScreen> createState() => _WorkLogEntryScreenState();
}

class _WorkLogEntryScreenState extends State<WorkLogEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _coconutCountController =
      TextEditingController(text: '0');
  final TextEditingController _bagCountController =
      TextEditingController(text: '0');
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String _error = '';
  List<Land> _lands = const <Land>[];
  List<Employee> _employees = const <Employee>[];
  List<Vehicle> _vehicles = const <Vehicle>[];
  String _selectedLandId = '';
  String _selectedSupervisorId = '';
  String _selectedVehicleId = '';
  final Set<String> _selectedWorkerIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadLookups();
    _refreshQueueCount();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _coconutCountController.dispose();
    _bagCountController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        widget.apiService.getLands(widget.token),
        widget.apiService.getEmployees(widget.token),
        widget.apiService.getVehicles(widget.token),
      ]);

      setState(() {
        _lands = results[0] as List<Land>;
        _employees = results[1] as List<Employee>;
        _vehicles = results[2] as List<Vehicle>;
        if (_lands.isNotEmpty) {
          _selectedLandId = _lands.first.id;
        }
      });
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to load work log references';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _refreshQueueCount() async {
    final queued = await OfflineQueueService.instance.getQueuedCount();
    widget.onQueuedCountChanged(queued);
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
      final month = picked.month.toString().padLeft(2, '0');
      final day = picked.day.toString().padLeft(2, '0');
      _dateController.text = '${picked.year}-$month-$day';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = <String, dynamic>{
      'workDate': _dateController.text.trim(),
      'landId': _selectedLandId,
      'supervisorId':
          _selectedSupervisorId.isEmpty ? null : _selectedSupervisorId,
      'vehicleId': _selectedVehicleId.isEmpty ? null : _selectedVehicleId,
      'coconutCount': int.tryParse(_coconutCountController.text.trim()) ?? 0,
      'bagCount': int.tryParse(_bagCountController.text.trim()) ?? 0,
      'workerIds': _selectedWorkerIds.toList(growable: false),
      'latitude': double.tryParse(_latitudeController.text.trim()),
      'longitude': double.tryParse(_longitudeController.text.trim()),
      'notes': _notesController.text.trim(),
    };

    setState(() {
      _saving = true;
      _error = '';
    });

    try {
      await widget.apiService.createWorkLog(
        token: widget.token,
        workDate: payload['workDate'] as String,
        landId: payload['landId'] as String,
        supervisorId: payload['supervisorId'] as String?,
        vehicleId: payload['vehicleId'] as String?,
        coconutCount: payload['coconutCount'] as int,
        bagCount: payload['bagCount'] as int,
        workerIds: payload['workerIds'] as List<String>,
        latitude: payload['latitude'] as double?,
        longitude: payload['longitude'] as double?,
        notes: payload['notes'] as String,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Work log saved to server')),
      );
      _resetForm();
    } catch (_) {
      await OfflineQueueService.instance.enqueueWorkLog(payload);
      await _refreshQueueCount();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network issue. Work log saved offline for sync.'),
        ),
      );
      _resetForm();
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _resetForm() {
    _dateController.clear();
    _coconutCountController.text = '0';
    _bagCountController.text = '0';
    _latitudeController.clear();
    _longitudeController.clear();
    _notesController.clear();
    _selectedSupervisorId = '';
    _selectedVehicleId = '';
    _selectedWorkerIds.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _lands.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Land master is empty',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Add lands from the web app first, then mobile teams can post work logs in the field.',
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Add work log',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'This screen is offline-friendly. If the network fails, the log is queued locally and can be synced later.',
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue:
                              _selectedLandId.isEmpty ? null : _selectedLandId,
                          decoration: const InputDecoration(labelText: 'Land'),
                          items: _lands
                              .map(
                                (land) => DropdownMenuItem<String>(
                                  value: land.id,
                                  child: Text('${land.name} (${land.village})'),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _selectedLandId = value ?? '';
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Work date',
                            suffixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                          onTap: _pickDate,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSupervisorId.isEmpty
                              ? null
                              : _selectedSupervisorId,
                          decoration:
                              const InputDecoration(labelText: 'Supervisor'),
                          items: _employees
                              .map(
                                (employee) => DropdownMenuItem<String>(
                                  value: employee.id,
                                  child: Text(employee.fullName),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _selectedSupervisorId = value ?? '';
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedVehicleId.isEmpty
                              ? null
                              : _selectedVehicleId,
                          decoration:
                              const InputDecoration(labelText: 'Vehicle'),
                          items: _vehicles
                              .map(
                                (vehicle) => DropdownMenuItem<String>(
                                  value: vehicle.id,
                                  child: Text(vehicle.registrationNumber),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicleId = value ?? '';
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _coconutCountController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Coconut count'),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bagCountController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Bag count'),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Assigned workers',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _employees.map((employee) {
                            final selected =
                                _selectedWorkerIds.contains(employee.id);
                            return FilterChip(
                              selected: selected,
                              label: Text(employee.fullName),
                              onSelected: (active) {
                                setState(() {
                                  if (active) {
                                    _selectedWorkerIds.add(employee.id);
                                  } else {
                                    _selectedWorkerIds.remove(employee.id);
                                  }
                                });
                              },
                            );
                          }).toList(growable: false),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Latitude'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Longitude'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Notes'),
                        ),
                        if (_error.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(
                            _error,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: _saving ? null : _submit,
                          child: Text(
                            _saving ? 'Saving...' : 'Save or queue work log',
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
