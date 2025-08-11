import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilltongapp/models/medication.dart';
import 'package:pilltongapp/services/notification_service.dart';

class EditMedicationScreen extends StatefulWidget {
  final Medication medication;
  final String docId;
  const EditMedicationScreen({super.key, required this.medication, required this.docId});

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late String _selectedFrequency;
  late List<TimeOfDay> _customTimes;
  late List<TimeOfDay> _scheduledTimes; // For once/twice a day selections
  bool _isLoading = false;

  final List<String> _frequencies = [
    'Once a day',
    'Twice a day',
    '3 times a day',
    'Every 8 hours',
    'Custom times'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _dosageController = TextEditingController(text: widget.medication.dosage);
    _selectedFrequency = widget.medication.frequency;
    
    // Initialize custom times
    _customTimes = widget.medication.customNotificationTimes != null
        ? widget.medication.customNotificationTimes!.map((t) {
            final parts = t.split(':');
            return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }).toList()
        : [];
    
    // Initialize scheduled times
    _scheduledTimes = widget.medication.scheduledTimes != null
        ? widget.medication.scheduledTimes!.map((t) {
            final parts = t.split(':');
            return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }).toList()
        : [];
    
    // If no scheduled times exist but frequency is once/twice a day/every 8 hours, initialize with defaults
    if (_scheduledTimes.isEmpty && 
        (_selectedFrequency == 'Once a day' || _selectedFrequency == 'Twice a day' || _selectedFrequency == 'Every 8 hours')) {
      _initializeScheduledTimes();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _initializeScheduledTimes() {
    if (_selectedFrequency == 'Once a day') {
      _scheduledTimes = [const TimeOfDay(hour: 9, minute: 0)];
    } else if (_selectedFrequency == 'Twice a day') {
      _scheduledTimes = [
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 21, minute: 0),
      ];
    } else if (_selectedFrequency == 'Every 8 hours') {
      _scheduledTimes = [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 16, minute: 0),
        const TimeOfDay(hour: 0, minute: 0),
      ];
    }
  }

  List<Widget> _buildScheduledTimeWidgets() {
    List<Widget> widgets = [];
    
    for (int i = 0; i < _scheduledTimes.length; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text('${i + 1}회차: '),
              Expanded(
                child: InkWell(
                  onTap: () => _selectScheduledTime(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _scheduledTimes[i].format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return widgets;
  }

  Future<void> _selectScheduledTime(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledTimes[index],
    );
    if (time != null) {
      setState(() {
        _scheduledTimes[index] = time;
      });
    }
  }

  Future<void> _addCustomTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _customTimes.add(time);
      });
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedFrequency == 'Custom times' && _customTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('복용 시간을 최소 하나 추가해주세요')),
      );
      return;
    }

    if ((_selectedFrequency == 'Once a day' || _selectedFrequency == 'Twice a day' || _selectedFrequency == 'Every 8 hours') && 
        _scheduledTimes.isEmpty) {
      _initializeScheduledTimes();
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      List<String>? customTimesString;
      List<String>? scheduledTimesString;
      
      if (_selectedFrequency == 'Custom times') {
        customTimesString = _customTimes
            .map((time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}')
            .toList();
      } else if (_selectedFrequency == 'Once a day' || _selectedFrequency == 'Twice a day' || _selectedFrequency == 'Every 8 hours') {
        scheduledTimesString = _scheduledTimes
            .map((time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}')
            .toList();
      }
      
      final medication = Medication(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        customNotificationTimes: customTimesString,
        scheduledTimes: scheduledTimesString,
        notificationsEnabled: true,
      );
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medications')
          .doc(widget.docId)
          .update(medication.toMap());

      // Update notifications
      final notificationTimes = medication.getNotificationTimes();
      if (notificationTimes.isNotEmpty) {
        try {
          // Check if notifications are enabled first
          final notificationService = NotificationService();
          final bool permissionsGranted = await notificationService.areNotificationsEnabled();
          
          if (!permissionsGranted) {
            // Request permissions
            final bool requested = await notificationService.requestPermissions();
            if (!requested) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('알림 권한이 없습니다. 설정에서 권한을 허용해주세요.'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 5),
                  ),
                );
              }
              return;
            }
          }
          
          await notificationService.scheduleMedicationNotifications(
            medicationId: widget.docId,
            medicationName: medication.name,
            times: notificationTimes,
          );
          
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('약물이 수정되고 알림이 설정되었습니다')),
            );
          }
        } catch (e) {
          print('Failed to update notifications: $e');
          // Show warning but don't prevent medication from being updated
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('약물이 수정되었지만 알림 설정에 실패했습니다. 설정에서 알림을 다시 설정해주세요.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('약물이 수정되었습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약물 수정'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '약물명'),
              validator: (value) => value == null || value.isEmpty ? '약물명을 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: '용량'),
              validator: (value) => value == null || value.isEmpty ? '용량을 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedFrequency = val!;
                  if (val != 'Custom times') {
                    _customTimes.clear();
                  }
                  if (val != 'Once a day' && val != 'Twice a day' && val != 'Every 8 hours') {
                    _scheduledTimes.clear();
                  } else {
                    _initializeScheduledTimes();
                  }
                });
              },
              decoration: const InputDecoration(labelText: '복용 빈도'),
            ),
            // Time selection for Once a day, Twice a day, and Every 8 hours
            if (_selectedFrequency == 'Once a day' || _selectedFrequency == 'Twice a day' || _selectedFrequency == 'Every 8 hours') ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '복용 시간 설정 (${_selectedFrequency})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._buildScheduledTimeWidgets(),
                    ],
                  ),
                ),
              ),
            ],
            if (_selectedFrequency == 'Custom times') ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ..._customTimes.map((t) => Chip(
                        label: Text('${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'),
                        onDeleted: () {
                          setState(() {
                            _customTimes.remove(t);
                          });
                        },
                      )),
                  ActionChip(
                    label: const Text('시간 추가'),
                    onPressed: _addCustomTime,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMedication,
              child: _isLoading ? const CircularProgressIndicator() : const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
