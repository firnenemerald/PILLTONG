import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilltongapp/models/medication.dart';
import 'package:pilltongapp/screens/edit_medication_screen.dart';

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
  bool _isLoading = false;

  final List<String> _frequencies = [
    'Once a day',
    'Twice a day',
    '3 times a day',
    'Custom times'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _dosageController = TextEditingController(text: widget.medication.dosage);
    _selectedFrequency = widget.medication.frequency;
    _customTimes = widget.medication.customNotificationTimes != null
        ? widget.medication.customNotificationTimes!.map((t) {
            final parts = t.split(':');
            return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }).toList()
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
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
          .doc(widget.docId)
          .update(medication.toMap());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('약물이 수정되었습니다')),
        );
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
                  if (val != 'Custom times') _customTimes.clear();
                });
              },
              decoration: const InputDecoration(labelText: '복용 빈도'),
            ),
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
