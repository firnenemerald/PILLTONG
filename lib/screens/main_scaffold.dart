import 'package:flutter/material.dart';
import 'package:pilltongapp/tabs/home_tab.dart';
import 'package:pilltongapp/tabs/med_list_tab.dart';
import 'package:pilltongapp/tabs/scan_tab.dart';
import 'package:pilltongapp/tabs/settings_tab.dart';

/// The main screen of the app, which contains the bottom navigation bar.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // List of the screens to be displayed for each tab.
  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    MedListTab(),
    ScanTab(),
    // We will create the prescription list tab later
    Text('Prescriptions (Coming Soon)'), 
    SettingsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: '약물 리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: '약물 스캔',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner_outlined),
            activeIcon: Icon(Icons.document_scanner),
            label: '처방전 스캔',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // These properties are important for a bottom nav bar with more than 3 items.
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
      ),
    );
  }
}
