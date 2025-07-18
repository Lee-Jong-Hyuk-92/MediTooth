import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'presentation/viewmodel/clinics_viewmodel.dart';
import 'presentation/viewmodel/userinfo_viewmodel.dart';
import 'presentation/viewmodel/auth_viewmodel.dart';
import 'presentation/viewmodel/doctor/d_patient_viewmodel.dart';
import 'presentation/viewmodel/doctor/d_consultation_record_viewmodel.dart';
import 'presentation/viewmodel/doctor/d_dashboard_viewmodel.dart'; // ✅ 유지

import 'core/theme/app_theme.dart';
import 'services/router.dart';

void main() {
  const String globalBaseUrl = "http://192.168.0.19:5000/api";  // 백엔드 URL

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => UserInfoViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => DPatientViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => ClinicsViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => ConsultationRecordViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => DoctorDashboardViewModel(), // ✅ 단 하나만 등록
        ),
      ],
      child: YOLOExampleApp(baseUrl: globalBaseUrl),
    ),
  );
}

class YOLOExampleApp extends StatelessWidget {
  final String baseUrl;

  const YOLOExampleApp({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MediTooth',
      debugShowCheckedModeBanner: false,
      routerConfig: createRouter(baseUrl),
      theme: AppTheme.lightTheme,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String baseUrl;

  const ChatScreen({super.key, required this.baseUrl});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String response = ""; // 챗봇의 응답을 저장할 변수

  // API 호출 함수
  Future<void> chatWithGemini(String userId, String message) async {
    final url = Uri.parse('${widget.baseUrl}/chat');  // Flask API URL
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      'user_id': userId,
      'message': message,
    });

    try {
      final res = await http.post(url, headers: headers, body: body);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          response = data['response'] ?? '응답을 받을 수 없습니다.';  // 응답 처리
        });
      } else {
        setState(() {
          response = '서버 오류: ${res.body}';  // 서버 오류 처리
        });
      }
    } catch (e) {
      setState(() {
        response = 'API 호출 오류: $e';  // API 호출 오류 처리
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('챗봇'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 환자 ID 입력 필드
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '환자 ID 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            
            // '진료일 확인' 버튼
            ElevatedButton(
              onPressed: () {
                final userId = _controller.text.trim();
                if (userId.isNotEmpty) {
                  // 예시 메시지, 실제 메시지는 사용자 입력을 받는 방식으로 수정
                  chatWithGemini(userId, "마지막 진료일을 확인해주세요.");
                } else {
                  setState(() {
                    response = '환자 ID를 입력해주세요.';  // 환자 ID 입력되지 않았을 때 처리
                  });
                }
              },
              child: Text('진료일 확인'),
            ),
            SizedBox(height: 20),
            
            // 챗봇의 응답 출력
            Text(
              response,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
