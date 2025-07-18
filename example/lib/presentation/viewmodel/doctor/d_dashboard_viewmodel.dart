import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DoctorDashboardViewModel extends ChangeNotifier {
  int _newPatientsToday = 0;
  int _completedConsultationsToday = 0;
  int _pendingConsultations = 0;

  // 통계 데이터 접근 게터
  int get newPatientsToday => _newPatientsToday;
  int get completedConsultationsToday => _completedConsultationsToday;
  int get pendingConsultations => _pendingConsultations;

  // 대시보드 데이터 갱신 메서드
  void updateDashboardData({int? newPatients, int? completed, int? pending}) {
    if (newPatients != null) _newPatientsToday = newPatients;
    if (completed != null) _completedConsultationsToday = completed;
    if (pending != null) _pendingConsultations = pending;
    notifyListeners();
  }

  // ✅ 실제 API 호출 및 데이터 파싱 메서드
  Future<void> loadDashboardData(String baseUrl) async {
    try {
      final today = DateFormat('yyyyMMdd').format(DateTime.now());
      final url = Uri.parse('$baseUrl/consult/stats?date=$today');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        updateDashboardData(
          newPatients: data['total'],
          completed: data['completed'],
          pending: data['pending'],
        );
      } else {
        print('📛 [loadDashboardData] 서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('📛 [loadDashboardData] 예외 발생: $e');
    }
  }
}
