import 'package:flutter/material.dart';

class DoctorDashboardViewModel extends ChangeNotifier {
  int _newPatientsToday = 0;
  int _completedConsultationsToday = 0;
  int _pendingConsultations = 0;

  // 대시보드 통계 데이터에 접근하기 위한 게터 (getter)
  int get newPatientsToday => _newPatientsToday;
  int get completedConsultationsToday => _completedConsultationsToday;
  int get pendingConsultations => _pendingConsultations;

  // 대시보드 데이터를 업데이트하는 메서드
  void updateDashboardData({int? newPatients, int? completed, int? pending}) {
    if (newPatients != null) {
      _newPatientsToday = newPatients;
    }
    if (completed != null) {
      _completedConsultationsToday = completed;
    }
    if (pending != null) {
      _pendingConsultations = pending;
    }
    // 데이터 변경을 리스너에게 알립니다.
    notifyListeners();
  }

  // 실제 서버에서 대시보드 데이터를 로드하는 비동기 메서드 (예시)
  Future<void> loadDashboardData(String baseUrl) async {
    // 실제 API 호출 로직을 여기에 구현합니다.
    // 예를 들어, http 패키지를 사용하여 서버에서 데이터를 가져올 수 있습니다.
    print('Loading dashboard data from: $baseUrl');

    // 임시 데이터 설정 (실제 데이터를 가져온 후에는 이 부분을 제거하세요)
    // 실제 데이터를 가져오는 비동기 작업이 완료된 후 updateDashboardData를 호출합니다.
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    updateDashboardData(newPatients: 7, completed: 15, pending: 4);
  }
}
