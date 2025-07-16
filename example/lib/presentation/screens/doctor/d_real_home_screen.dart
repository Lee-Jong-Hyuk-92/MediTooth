import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart';

//--------------------------------------------------------------
//  DoctorDrawer
//--------------------------------------------------------------
class DoctorDrawer extends StatelessWidget {
  final String baseUrl;
  const DoctorDrawer({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          _drawerItem(context, Icons.home, '홈', '/d_home'),
          _drawerItem(context, Icons.personal_injury, '비대면 진료 현황', '/d_dashboard'),
          _drawerItem(context, Icons.assignment, '비대면 진료 결과', '/d_inference_result'),
          _drawerItem(context, Icons.event, '비대면 진료 캘린더', '/d_calendar'),
          _drawerItem(context, Icons.people, '비대면 환자 목록', '/d_patients'),
          const Divider(),
          _drawerItem(context, Icons.settings, '설정', '/d_settings'),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TOOTH AI 닥터 메뉴',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: '로그아웃',
              onPressed: () => context.go('/login'),
            )
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blueGrey[800],
              )),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      hoverColor: Colors.blue.withOpacity(.1),
      onTap: () {
        Navigator.pop(context);
        context.go(route, extra: baseUrl);
      },
    );
  }
}

//--------------------------------------------------------------
//  DRealHomeScreen  (Dashboard Home)
//--------------------------------------------------------------
class DRealHomeScreen extends StatefulWidget {
  final String baseUrl;
  const DRealHomeScreen({super.key, required this.baseUrl});

  @override
  State<DRealHomeScreen> createState() => _DRealHomeScreenState();
}

class _DRealHomeScreenState extends State<DRealHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorDashboardViewModel>().loadDashboardData(widget.baseUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorDashboardViewModel>();
    final int pending = (vm.requestsToday - vm.answeredToday).clamp(0, 1 << 31);

    return Scaffold(
      appBar: AppBar(
        title: const Text('의사 대시보드 홈'),
        backgroundColor: Colors.blueAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.go('/d_notifications'),
          ),
        ],
      ),
      drawer: DoctorDrawer(baseUrl: widget.baseUrl),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('환영합니다, 의사 선생님!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    )),
            const SizedBox(height: 20),
            // 연결된 서버 텍스트 삭제됨
            const SizedBox(height: 30),
            _todayStatsCard(context, requests: vm.requestsToday, answered: vm.answeredToday, pending: pending),
            const SizedBox(height: 25),
            Expanded(child: _additionalStatsSection(context)),
          ],
        ),
      ),
    );
  }

  Widget _todayStatsCard(BuildContext context, {required int requests, required int answered, required int pending}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘의 진료 현황', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statTile(context, title: '신청 건수', value: requests, onTap: () => context.go('/d_requests', extra: widget.baseUrl)),
                _statTile(context, title: '답변 완료', value: answered, onTap: () => context.go('/d_answers', extra: widget.baseUrl)),
                _statTile(context, title: '미답변', value: pending, onTap: () => context.go('/d_pending', extra: widget.baseUrl)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(BuildContext context, {required String title, required int value, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            Text('$value', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 5),
            Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  //------------------ 추가 : 통계/그래프/최근 활동 영역 ------------------
  Widget _additionalStatsSection(BuildContext context) {
    final vm = context.watch<DoctorDashboardViewModel>();
    return ListView(
      children: [
        // 1) 최근 7일 신청/답변 추이 그래프 (플레이스홀더)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            height: 180,
            child: Center(
              child: Text('📈 최근 7일 신청/답변 추이 (그래프 자리)', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 2) 진료 유형 비율 파이 차트 (플레이스홀더)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            height: 180,
            child: Center(
              child: Text('🧩 진료 유형 비율 (파이 차트 자리)', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ),
        // *** 3) 최근 진료 완료 내역 리스트 제거함 ***
      ],
    );
  }
}
