import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Provider is used for ChangeNotifierProvider

// 필요한 화면들 임포트
import '/presentation/screens/doctor/d_inference_result_screen.dart';
import '/presentation/screens/doctor/d_real_home_screen.dart'; // 의사 첫 홈 (DoctorDrawer 포함)
import '/presentation/screens/doctor/d_telemedicine_application_screen.dart'; // 새로 추가된 비대면 진료 신청 화면
import '/presentation/screens/main_scaffold.dart'; // 일반 사용자용 스캐폴드
import '/presentation/screens/login_screen.dart';
import '/presentation/screens/register_screen.dart';
import '/presentation/screens/home_screen.dart';
import '/presentation/screens/camera_inference_screen.dart';
import '/presentation/screens/web_placeholder_screen.dart';
import '/presentation/viewmodel/auth_viewmodel.dart'; // 사용자 로그인 정보 접근

// 하단 탭 바 화면들
import '/presentation/screens/chatbot_screen.dart'; // ChatbotScreen 임포트
import '/presentation/screens/mypage_screen.dart';
import '/presentation/screens/upload_screen.dart';
import '/presentation/screens/history_screen.dart';
import '/presentation/screens/clinics_screen.dart';
import '/presentation/screens/doctor/d_calendar_screen.dart';

// DoctorDashboardViewModel은 전용 파일에서만 임포트합니다.
import '/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart'; // ViewModel의 정식 경로

// DoctorDrawer가 아직 정의되지 않았다면, 필요에 따라 임시로 추가하거나 실제 경로로 대체해야 합니다.
// 예시: DoctorDrawer가 없어서 발생하는 에러를 방지하기 위한 임시 코드
// 실제 프로젝트에 맞게 수정하세요.
class DoctorDrawer extends StatelessWidget {
  final String baseUrl;
  const DoctorDrawer({Key? key, required this.baseUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Doctor Menu'),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              context.go('/d_home', extra: baseUrl);
            },
          ),
          ListTile(
            title: const Text('비대면 진료 신청'),
            onTap: () {
              context.go('/d_dashboard', extra: baseUrl);
            },
          ),
          ListTile(
            title: const Text('진료 캘린더'),
            onTap: () {
              context.go('/d_calendar', extra: baseUrl);
            },
          ),
          // 필요한 다른 메뉴 항목 추가
        ],
      ),
    );
  }
}

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
        builder: (context, state) => const RegisterScreen(), // const 추가
      ),
      GoRoute(
        path: '/web',
        builder: (context, state) => const WebPlaceholderScreen(), // const 추가
      ),

      // 의사 전용 ShellRoute 추가: 이 ShellRoute 내의 모든 화면은 Drawer를 유지합니다.
      ShellRoute(
        builder: (context, state, child) {
          // DRealHomeScreen이 DoctorDrawer를 포함하므로, 여기서는 단순히 child를 반환합니다.
          // 각 의사 화면에서 DoctorDrawer를 직접 포함하도록 변경되었음을 반영합니다.
          return child;
        },
        routes: [
          // 의사 로그인 후 메인 홈
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

          // 의사 메뉴: 비대면 진료 신청 화면
          GoRoute(
            path: '/d_dashboard',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return DTelemedicineApplicationScreen(baseUrl: passedBaseUrl); // 새로운 화면 위젯 사용
            },
          ),

          // 의사 메뉴: 예약 현황
          GoRoute(
            path: '/d_appointments',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('예약 현황')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl), // DoctorDrawer 추가
                body: const Center(child: Text('예약 현황 화면입니다.')),
              );
            },
          ),

          // 의사 메뉴: 진료 결과
          GoRoute(
            path: '/d_inference_result',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('진료 결과')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl), // DoctorDrawer 추가
                body: DInferenceResultScreen(baseUrl: passedBaseUrl),
              );
            },
          ),

          // 의사 메뉴: 진료 캘린더
          GoRoute(
            path: '/d_calendar',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('진료 캘린더')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl), // DoctorDrawer 추가
                body: const DCalendarScreen(), // const 추가
              );
            },
          ),

          // 의사 메뉴: 환자 목록
          GoRoute(
            path: '/d_patients',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return Scaffold(
                appBar: AppBar(title: const Text('환자 목록')),
                drawer: DoctorDrawer(baseUrl: passedBaseUrl), // DoctorDrawer 추가
                body: const Center(child: Text('환자 목록 화면입니다.')),
              );
            },
          ),
        ],
      ),

      // 일반 사용자 ShellRoute
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
            builder: (context, state) => ChatbotScreen(), // ★ 이 부분에 const가 없습니다.
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final authViewModel = state.extra as Map<String, dynamic>? ?? {};
              final userId = authViewModel['userId'] ?? 'guest';
              return HomeScreen(baseUrl: baseUrl, userId: userId);
            },
          ),
          GoRoute(
            path: '/mypage',
            builder: (context, state) => const MyPageScreen(), // const 추가
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) {
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              return UploadScreen(baseUrl: passedBaseUrl);
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
              final passedBaseUrl = state.extra as String? ?? baseUrl;
              final role = Provider.of<AuthViewModel>(context, listen: false).currentUser?.role ?? 'P'; // 기본값 'P'
              return HistoryScreen(baseUrl: passedBaseUrl, role: role);
            },
          ),
          GoRoute(
            path: '/clinics',
            builder: (context, state) => const ClinicsScreen(), // const 추가
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
        ],
      ),
    ],
  );
}