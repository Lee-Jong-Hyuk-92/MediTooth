import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/doctor/d_consultation_record.dart';

class ConsultationRecordViewModel with ChangeNotifier {
  final String baseUrl;
  List<ConsultationRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  String? _currentAppliedImagePath;
  String? get currentAppliedImagePath => _currentAppliedImagePath;

  ConsultationRecordViewModel({required this.baseUrl});

  List<ConsultationRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setCurrentAppliedImagePath(String path) {
    _currentAppliedImagePath = path;
    notifyListeners();
  }

  /// ✅ 현재 신청 중인 이미지 하나 가져오기 (MySQL)
  Future<void> fetchAppliedImagePath(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/consult/active?user_id=$userId');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _currentAppliedImagePath = data['image_path'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('신청 이미지 경로 불러오기 실패: $e');
    }
  }

  /// ✅ 전체 진단 기록 가져오기 (MongoDB)
  Future<void> fetchRecords(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/inference-results?role=P&user_id=$userId'); // ✅ 수정됨
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        _records = data.map((e) => ConsultationRecord.fromJson(e)).toList();
      } else {
        _error = '서버 오류: ${res.statusCode}';
      }
    } catch (e) {
      _error = '네트워크 오류: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
