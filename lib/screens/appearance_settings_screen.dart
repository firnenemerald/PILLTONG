import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String _selectedTheme = 'system';
  String _selectedLanguage = 'ko';
  String _selectedFontSize = 'medium';
  
  final Map<String, String> _themeOptions = {
    'light': '라이트 모드',
    'dark': '다크 모드',
    'system': '시스템 설정',
  };
  
  final Map<String, String> _languageOptions = {
    'ko': '한국어',
    'en': 'English',
  };
  
  final Map<String, String> _fontSizeOptions = {
    'small': '작게',
    'medium': '보통',
    'large': '크게',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme') ?? 'system';
      _selectedLanguage = prefs.getString('language') ?? 'ko';
      _selectedFontSize = prefs.getString('fontSize') ?? 'medium';
    });
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    setState(() {
      _selectedTheme = theme;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('테마 설정이 저장되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('언어 설정이 저장되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveFontSize(String fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontSize', fontSize);
    setState(() {
      _selectedFontSize = fontSize;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('글꼴 크기가 저장되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('화면 설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.palette_outlined),
                      SizedBox(width: 12),
                      Text(
                        '테마',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._themeOptions.entries.map((entry) => RadioListTile<String>(
                    title: Text(entry.value),
                    value: entry.key,
                    groupValue: _selectedTheme,
                    onChanged: (value) {
                      if (value != null) {
                        _saveTheme(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.language_outlined),
                      SizedBox(width: 12),
                      Text(
                        '언어',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._languageOptions.entries.map((entry) => RadioListTile<String>(
                    title: Text(entry.value),
                    value: entry.key,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        _saveLanguage(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Font Size Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.text_fields_outlined),
                      SizedBox(width: 12),
                      Text(
                        '글꼴 크기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._fontSizeOptions.entries.map((entry) => RadioListTile<String>(
                    title: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: entry.key == 'small' 
                            ? 14.0 
                            : entry.key == 'large' 
                                ? 18.0 
                                : 16.0,
                      ),
                    ),
                    value: entry.key,
                    groupValue: _selectedFontSize,
                    onChanged: (value) {
                      if (value != null) {
                        _saveFontSize(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Preview Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.preview_outlined, color: Colors.blue),
                      SizedBox(width: 12),
                      Text(
                        '미리보기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '설정이 적용된 화면입니다.',
                    style: TextStyle(
                      fontSize: _selectedFontSize == 'small' 
                          ? 14.0 
                          : _selectedFontSize == 'large' 
                              ? 18.0 
                              : 16.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '테마: ${_themeOptions[_selectedTheme]}\n'
                    '언어: ${_languageOptions[_selectedLanguage]}\n'
                    '글꼴 크기: ${_fontSizeOptions[_selectedFontSize]}',
                    style: TextStyle(
                      fontSize: _selectedFontSize == 'small' 
                          ? 12.0 
                          : _selectedFontSize == 'large' 
                              ? 16.0 
                              : 14.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
