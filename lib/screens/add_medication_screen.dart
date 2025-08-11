import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilltongapp/models/medication.dart';

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
  bool _isLoading = false;

  final List<String> _frequencies = [
    'Once a day',
    'Twice a day',
    '3 times a day',
    'Custom times'
  ];

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
                });
              },
            ),
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

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      List<String>? customTimesString;
      if (_selectedFrequency == 'Custom times') {
        customTimesString = _customTimes
            .map((time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}')
            .toList();
      }

      final medication = Medication(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        customNotificationTimes: customTimesString,
        notificationsEnabled: true,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medications')
          .add(medication.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('약물이 추가되었습니다')),
        );
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