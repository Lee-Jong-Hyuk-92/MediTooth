import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class DSettingsScreen extends StatefulWidget {
  final String baseUrl;
  const DSettingsScreen({super.key, required this.baseUrl});

  @override
  State<DSettingsScreen> createState() => _DSettingsScreenState();
}

class _DSettingsScreenState extends State<DSettingsScreen> {
  String _appVersion = '로딩 중...';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadThemePreference();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (build ${info.buildNumber})';
    });
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
    // 앱 전역 테마 변경은 Provider 등으로 처리 필요
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('앱을 재시작해야 변경사항이 적용됩니다.')),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      query: 'subject=의사 앱 문의사항&body=안녕하세요, 문의드립니다.',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메일 앱을 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: isDark ? Colors.black : Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 귀여운 치아 캐릭터 애니메이션
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Lottie.asset('assets/images/teeth_animation.json'),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            '계정 설정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('내 정보 수정'),
            onTap: () {
              context.push('/edit-profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('정말 로그아웃 하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/login');
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 32),
          const Text(
            '시스템',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('다크모드'),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('서버 주소'),
            subtitle: Text(widget.baseUrl),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('서버 주소: ${widget.baseUrl}')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text('앱 버전'),
            subtitle: Text(_appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('문의하기'),
            subtitle: const Text('support@example.com'),
            onTap: _launchEmail,
          ),
        ],
      ),
    );
  }
}
