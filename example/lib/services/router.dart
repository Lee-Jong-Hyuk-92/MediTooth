import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/presentation/screens/login_screen.dart';
import '/presentation/screens/register_screen.dart';
import '/presentation/screens/web_placeholder_screen.dart';
import '/presentation/screens/main_scaffold.dart';

// ─── 의사 화면 ────────────────────────────────────────────────
import '/presentation/screens/doctor/d_real_home_screen.dart';
import '/presentation/screens/doctor/d_telemedicine_application_screen.dart';
import '/presentation/screens/doctor/d_inference_result_screen.dart';
import '/presentation/screens/doctor/d_calendar_screen.dart';
import '/presentation/screens/doctor/d_patients_screen.dart'; // 추가된 부분
import '/presentation/screens/doctor/d_requests_screen.dart';
import '/presentation/screens/doctor/d_answers_screen.dart';
import '/presentation/screens/doctor/d_pending_screen.dart';

import '/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';

// ─── 사용자 하단 탭 화면 ─────────────────────────────────────
import '/presentation/screens/chatbot_screen.dart';
import '/presentation/screens/home_screen.dart';
import '/presentation/screens/mypage_screen.dart';
import '/presentation/screens/upload_screen.dart';
import '/presentation/screens/history_screen.dart';
import '/presentation/screens/clinics_screen.dart';
import '/presentation/screens/camera_inference_screen.dart';

// ──────────────────────────────

GoRouter createRouter(String baseUrl) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      // 로그인 / 회원가입 / Web Placeholder
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(baseUrl: baseUrl),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/web',
        builder: (context, state) => const WebPlaceholderScreen(),
      ),

      // 의사 전용 ShellRoute
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          // 대시보드 홈
          GoRoute(
            path: '/d_home',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return ChangeNotifierProvider(
                create: (_) => DoctorDashboardViewModel(),
                child: DRealHomeScreen(baseUrl: passedBaseUrl),
              );
            },
          ),

          // 비대면 진료 현황(신청) – '/d_dashboard'
          GoRoute(
            path: '/d_dashboard',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return DTelemedicineApplicationScreen(baseUrl: passedBaseUrl);
            },
          ),

          // 통계 카드 3개 화면 이동
          GoRoute(
            path: '/d_requests',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return DRequestsScreen(baseUrl: passedBaseUrl);
            },
          ),
          GoRoute(
            path: '/d_answers',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return DAnswersScreen(baseUrl: passedBaseUrl);
            },
          ),
          GoRoute(
            path: '/d_pending',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return DPendingScreen(baseUrl: passedBaseUrl);
            },
          ),

          // 진료 결과
          GoRoute(
            path: '/d_inference_result',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('진료 결과')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl),
                body: DInferenceResultScreen(baseUrl: passedBaseUrl),
              );
            },
          ),

          // 진료 캘린더
          GoRoute(
            path: '/d_calendar',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('예약 캘린더')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl),
                body: DCalendarScreen(),
              );
            },
          ),

          // 환자 목록 화면 연결 ← 여기가 중요!
          GoRoute(
            path: '/d_patients',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return DPatientsScreen(baseUrl: passedBaseUrl);
            },
          ),

          // 설정 화면 (필요시)
          GoRoute(
            path: '/d_settings',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('설정')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl),
                body: const Center(child: Text('설정 화면 준비 중')),
              );
            },
          ),
        ],
      ),

      // 일반 사용자 ShellRoute
      ShellRoute(
        builder: (context, state, child) => MainScaffold(
          child: child,
          currentLocation: state.uri.toString(),
        ),
        routes: [
          GoRoute(path: '/chatbot', builder: (_, __) => const ChatbotScreen()),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              final userId = data['userId'] ?? 'guest';
              return HomeScreen(baseUrl: baseUrl, userId: userId);
            },
          ),
          GoRoute(path: '/mypage', builder: (_, __) => const MyPageScreen()),
          GoRoute(
            path: '/upload',
            builder: (context, state) =>
                UploadScreen(baseUrl: state.extra as String? ?? baseUrl),
          ),
          GoRoute(
            path: '/diagnosis/realtime',
            builder: (context, state) {
              final auth = Provider.of<AuthViewModel>(context, listen: false);
              final userId = auth.currentUser?.registerId ?? 'guest';
              final data = state.extra as Map<String, dynamic>? ?? {};
              return CameraInferenceScreen(
                baseUrl: data['baseUrl'] ?? baseUrl,
                userId: userId,
              );
            },
          ),
          GoRoute(
            path: '/history',
            builder: (_, state) =>
                HistoryScreen(baseUrl: state.extra as String? ?? baseUrl),
          ),
          GoRoute(path: '/clinics', builder: (_, __) => const ClinicsScreen()),
          GoRoute(
            path: '/camera',
            builder: (_, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              return CameraInferenceScreen(
                baseUrl: data['baseUrl'] ?? baseUrl,
                userId: data['userId'] ?? 'guest',
              );
            },
          ),
        ],
      ),
    ],
  );
}
