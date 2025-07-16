// lib/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 최근 진료 완료 카드에서 사용할 단순 모델
class CompletedConsult {
  final String patientName;
  final DateTime completedAt;

  const CompletedConsult({required this.patientName, required this.completedAt});

  String get completedAtFormatted => DateFormat('MM/dd HH:mm').format(completedAt);
}

/// 의사 대시보드에 필요한 모든 통계 값을 보유하는 ViewModel
class DoctorDashboardViewModel extends ChangeNotifier {
  //------------------------- Raw Counters -------------------------
  int _requestsToday = 0;   // 오늘 접수된 비대면 진료 신청 건수
  int _answeredToday = 0;   // 오늘 답변 완료 건수
  List<CompletedConsult> _recentCompleted = []; // 최근 완료 내역 (신규 → 오래된 순)

  //------------------------- Getters ------------------------------
  int get requestsToday => _requestsToday;
  int get answeredToday => _answeredToday;
  int get pendingToday => (_requestsToday - _answeredToday).clamp(0, 1 << 31);
  List<CompletedConsult> get recentCompleted => List.unmodifiable(_recentCompleted);

  //------------------------- Public API ---------------------------
  /// 통계 값을 한꺼번에 업데이트
  void updateDashboardData({
    int? requests,
    int? answered,
    List<CompletedConsult>? recentList,
  }) {
    if (requests != null) _requestsToday = requests;
    if (answered != null) _answeredToday = answered;
    if (recentList != null) _recentCompleted = recentList;
    notifyListeners();
  }

  /// 서버에서 최신 대시보드 통계를 로드 (더미 로직)
  Future<void> loadDashboardData(String baseUrl) async {
    // TODO: http 패키지로 실제 REST API 호출 → JSON 파싱
    debugPrint('Loading dashboard data from $baseUrl');

    // ---------------- DEMO 데이터 ----------------
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    updateDashboardData(
      requests: 7,
      answered: 5,
      recentList: [
        CompletedConsult(patientName: '홍길동', completedAt: DateTime.now().subtract(const Duration(hours: 1))),
        CompletedConsult(patientName: '김영희', completedAt: DateTime.now().subtract(const Duration(hours: 3))),
        CompletedConsult(patientName: '박철수', completedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2))),
      ],
    );
  }
}
