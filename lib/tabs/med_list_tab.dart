import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilltongapp/models/medication.dart';
import 'package:pilltongapp/screens/add_medication_screen.dart';
import 'package:pilltongapp/screens/edit_medication_screen.dart';

class MedListTab extends StatelessWidget {
  const MedListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 약물 리스트'),
      ),
      body: userId == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('medications')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      '저장된 약물이 없습니다.\n아래 버튼을 눌러 추가해주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('오류가 발생했습니다.'));
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final med = Medication.fromFirestore(doc);
                    final times = med.getNotificationTimes();
                    final docId = doc.id;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMedicationScreen(medication: med, docId: docId),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: const Icon(Icons.medication, color: Colors.blueAccent),
                          title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('용량: ${med.dosage} / 빈도: ${med.frequency}'),
                              Text('복용 시간: ${times.map((t) => t.format(context)).join(', ')}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('약물 삭제'),
                                  content: Text('${med.name}을(를) 삭제하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('삭제'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .collection('medications')
                                    .doc(docId)
                                    .delete();
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
