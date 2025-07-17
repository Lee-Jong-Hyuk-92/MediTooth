import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/doctor/d_consultation_record.dart';

class ConsultationRecordViewModel with ChangeNotifier {
  final String baseUrl;
  List<ConsultationRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  ConsultationRecordViewModel({required this.baseUrl});

  List<ConsultationRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await http.get(Uri.parse('$baseUrl/inference-results'));

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

  Future<void> deleteRecord(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await http.delete(Uri.parse('$baseUrl/records/$id'));

      if (res.statusCode == 200) {
        _records.removeWhere((record) => record.id == id);
        _error = null;
      } else {
        _error = '삭제 실패: ${res.statusCode}';
      }
    } catch (e) {
      _error = '삭제 중 오류 발생: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
