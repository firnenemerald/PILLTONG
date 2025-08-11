import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('알림 관리'),
            onTap: () {
              // TODO: Navigate to notification settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림 관리 기능은 준비 중입니다.')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // AuthGate will automatically handle navigation to the LoginScreen.
            },
          ),
        ],
      ),
    );
  }
}
