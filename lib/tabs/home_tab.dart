import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilltongapp/models/medication.dart';
import 'package:pilltongapp/screens/edit_medication_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
      ),
      body: userId == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('medications')
                  .where('notificationsEnabled', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication_liquid, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '오늘 복용할 약물이 없습니다',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '약물 리스트에서 약물을 추가해주세요',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final med = Medication.fromFirestore(doc);
                    final times = med.getNotificationTimes();
                    final docId = doc.id;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMedicationScreen(medication: med, docId: docId),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.medication, color: Colors.blueAccent),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      med.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('용량: ${med.dosage}'),
                              Text('빈도: ${med.frequency}'),
                              const SizedBox(height: 8),
                              const Text(
                                '복용 시간:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: times.map((time) {
                                  return Chip(
                                    label: Text(time.format(context)),
                                    backgroundColor: Colors.blue.shade50,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
