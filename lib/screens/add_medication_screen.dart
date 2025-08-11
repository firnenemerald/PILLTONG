import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilltongapp/models/medication.dart';
import 'package:pilltongapp/services/notification_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String _selectedFrequency = 'Once a day';
  List<TimeOfDay> _customTimes = [];
  List<TimeOfDay> _scheduledTimes = []; // For once/twice a day selections
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
    _initializeScheduledTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약물 추가'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedication,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '약물 이름',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '약물 이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: '용량 (예: 500mg)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '용량을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              decoration: const InputDecoration(
                labelText: '복용 빈도',
                border: OutlineInputBorder(),
              ),
              items: _frequencies.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFrequency = value!;
                  if (_selectedFrequency != 'Custom times') {
                    _customTimes.clear();
                  }
                  if (_selectedFrequency != 'Once a day' && _selectedFrequency != 'Twice a day' && _selectedFrequency != 'Every 8 hours') {
                    _scheduledTimes.clear();
                  } else {
                    // Initialize scheduled times with default values
                    _initializeScheduledTimes();
                  }
                });
              },
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
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '복용 시간 설정',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ..._customTimes.map((time) => Chip(
                                label: Text(time.format(context)),
                                onDeleted: () {
                                  setState(() {
                                    _customTimes.remove(time);
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
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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

      // Save to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medications')
          .add(medication.toMap());

      // Schedule notifications
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
            medicationId: docRef.id,
            medicationName: medication.name,
            times: notificationTimes,
          );
          
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('약물이 추가되고 알림이 설정되었습니다')),
            );
          }
        } catch (e) {
          print('Failed to schedule notifications: $e');
          // Show warning but don't prevent medication from being saved
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('약물이 추가되었지만 알림 설정에 실패했습니다. 설정에서 알림을 다시 설정해주세요.'),
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
            const SnackBar(content: Text('약물이 추가되었습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
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
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}