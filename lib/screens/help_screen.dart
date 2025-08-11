import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Getting Started Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.play_circle_outline, color: Colors.green),
                      SizedBox(width: 12),
                      Text(
                        '시작하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildHelpItem(
                    '1. 약물 추가하기',
                    '홈 화면의 "+" 버튼을 눌러 약물 정보를 입력하세요.\n'
                    '약물명, 용량, 복용 시간을 설정할 수 있습니다.',
                    Icons.add_circle_outline,
                  ),
                  _buildHelpItem(
                    '2. 알림 설정하기',
                    '약물 추가 시 자동으로 알림이 설정됩니다.\n'
                    '설정 > 알림 관리에서 알림을 관리할 수 있습니다.',
                    Icons.notifications_outlined,
                  ),
                  _buildHelpItem(
                    '3. 처방전 스캔하기',
                    '카메라 탭에서 처방전을 촬영하면 텍스트를 인식합니다.\n'
                    '인식된 정보는 자동으로 저장됩니다.',
                    Icons.camera_alt_outlined,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Features Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.star_outline, color: Colors.orange),
                      SizedBox(width: 12),
                      Text(
                        '주요 기능',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    '스마트 알림',
                    '설정한 시간에 정확한 복용 알림을 받아보세요',
                    Icons.schedule,
                  ),
                  _buildFeatureItem(
                    '약물 관리',
                    '복용 중인 모든 약물을 한 곳에서 관리하세요',
                    Icons.medication_liquid,
                  ),
                  _buildFeatureItem(
                    'OCR 스캔',
                    '처방전을 촬영하여 자동으로 텍스트를 인식합니다',
                    Icons.document_scanner,
                  ),
                  _buildFeatureItem(
                    '클라우드 동기화',
                    '모든 데이터는 안전하게 클라우드에 저장됩니다',
                    Icons.cloud_outlined,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Troubleshooting Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.build_outlined, color: Colors.blue),
                      SizedBox(width: 12),
                      Text(
                        '문제 해결',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTroubleshootItem(
                    '알림이 오지 않아요',
                    '• 설정 > 알림 관리에서 "모든 알림 다시 설정" 버튼을 눌러보세요\n'
                    '• 휴대폰 설정에서 앱 알림 권한이 허용되어 있는지 확인하세요\n'
                    '• 배터리 최적화 설정에서 앱을 제외해주세요',
                  ),
                  _buildTroubleshootItem(
                    '약물 추가가 안 돼요',
                    '• 인터넷 연결 상태를 확인해주세요\n'
                    '• 앱을 완전히 종료한 후 다시 실행해보세요\n'
                    '• 저장 공간이 충분한지 확인해주세요',
                  ),
                  _buildTroubleshootItem(
                    '카메라가 작동하지 않아요',
                    '• 앱에 카메라 권한이 허용되어 있는지 확인하세요\n'
                    '• 다른 앱에서 카메라를 사용 중인지 확인하세요\n'
                    '• 휴대폰을 재시작해보세요',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tips Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber),
                      SizedBox(width: 12),
                      Text(
                        '유용한 팁',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipItem(
                    '💡 알림 시간을 식사 시간에 맞춰 설정하면 복용을 잊지 않아요'),
                  _buildTipItem(
                    '💡 약물 리스트에서 스위치를 사용해 임시로 알림을 끌 수 있어요'),
                  _buildTipItem(
                    '💡 처방전 스캔 시 조명이 밝은 곳에서 촬영하면 인식률이 높아져요'),
                  _buildTipItem(
                    '💡 백업을 위해 주기적으로 Google 계정에 로그인 상태를 유지하세요'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q. $title',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        tip,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}
