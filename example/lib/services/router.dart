import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/presentation/screens/doctor/d_inference_result_screen.dart';
import '/presentation/screens/doctor/d_real_home_screen.dart';
import '/presentation/screens/doctor/d_telemedicine_application_screen.dart';
import '/presentation/screens/main_scaffold.dart';
import '/presentation/screens/login_screen.dart';
import '/presentation/screens/register_screen.dart';
import '/presentation/screens/home_screen.dart';
import '/presentation/screens/camera_inference_screen.dart';
import '/presentation/screens/web_placeholder_screen.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';

import '/presentation/screens/chatbot_screen.dart';
import '/presentation/screens/mypage_screen.dart';
import '/presentation/screens/upload_screen.dart';
import '/presentation/screens/history_screen.dart';
import '/presentation/screens/clinics_screen.dart';
import '/presentation/screens/doctor/d_result_detail_screen.dart'; // ✅ 환자 결과 화면
import '/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart';

GoRouter createRouter(String baseUrl) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
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

      // ✅ 의사용 ShellRoute
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
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
          GoRoute(
            path: '/d_dashboard',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return DTelemedicineApplicationScreen(baseUrl: passedBaseUrl);
            },
          ),
          GoRoute(
            path: '/d_appointments',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('예약 현황')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl),
                body: const Center(child: Text('예약 현황 화면입니다.')),
              );
            },
          ),
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
          GoRoute(
            path: '/d_calendar',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('진료 캘린더')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl),
                body: const Center(child: Text('진료 캘린더 화면입니다.')),
              );
            },
          ),
          GoRoute(
            path: '/d_patients',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('환자 목록')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl),
                body: const Center(child: Text('환자 목록 화면입니다.')),
              );
            },
          ),
        ],
      ),

      // ✅ 일반 사용자용 ShellRoute
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(
            child: child,
            currentLocation: state.uri.toString(),
          );
        },
        routes: [
          GoRoute(
            path: '/chatbot',
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final authViewModel = state.extra as Map<String, dynamic>?;
              final userId = authViewModel?['userId'] ?? 'guest';
              return HomeScreen(baseUrl: baseUrl, userId: userId);
            },
          ),
          GoRoute(
            path: '/mypage',
            builder: (context, state) => const MyPageScreen(),
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return UploadScreen(baseUrl: passedBaseUrl);
            },
          ),

          // ✅ 예측 결과 상세 화면
          GoRoute(
            path: '/result_detail',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>;
              return ResultDetailScreen(
                originalImageUrl: data['originalImageUrl'],
                processedImageUrls: Map<int, String>.from(data['processedImageUrls']),
                modelInfos: Map<int, Map<String, dynamic>>.from(
                  (data['modelInfos'] ?? {}).map((key, value) =>
                      MapEntry(int.parse(key.toString()), Map<String, dynamic>.from(value))),
                ),
                userId: data['userId'],
                inferenceResultId: data['inferenceResultId'],
                baseUrl: data['baseUrl'],
                role: data['role'], // ✅ 여기도 받아야 함
                from: data['from'], // ✅ 추가
              );
            },
          ),
          GoRoute(
            path: '/diagnosis/realtime',
            builder: (context, state) {
              final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
              final currentUser = authViewModel.currentUser;
              final realUserId = currentUser?.registerId ?? 'guest';
              final data = state.extra as Map<String, dynamic>? ?? {};
              final baseUrl = data['baseUrl'] ?? '';
              return CameraInferenceScreen(
                baseUrl: baseUrl,
                userId: realUserId,
              );
            },
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              final passedBaseUrl = data['baseUrl'] ?? baseUrl;
              final role = data['role'] ?? 'P'; // 기본값은 'P' (환자)
              return HistoryScreen(
                baseUrl: passedBaseUrl,
                role: role,
              );
            },
          ),
          GoRoute(
            path: '/clinics',
            builder: (context, state) => const ClinicsScreen(),
          ),
          GoRoute(
            path: '/camera',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              return CameraInferenceScreen(
                baseUrl: data['baseUrl'] ?? '',
                userId: data['userId'] ?? 'guest',
              );
            },
          ),
          GoRoute(
            path: '/d_consult_request_comment',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>;
              return ResultDetailScreen(
                originalImageUrl: data['originalImageUrl'],
                processedImageUrls: Map<int, String>.from(data['processedImageUrls']),
                modelInfos: Map<int, Map<String, dynamic>>.from(
                  (data['modelInfos'] ?? {}).map(
                    (key, value) => MapEntry(
                      int.parse(key.toString()),
                      Map<String, dynamic>.from(value),
                    ),
                  ),
                ),
                userId: data['userId'],
                inferenceResultId: data['inferenceResultId'],
                baseUrl: data['baseUrl'],
                role: data['role'],
                from: data['from'],
              );
            },
          ),
        ],
      ),
    ],
  );
}
