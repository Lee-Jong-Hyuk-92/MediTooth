import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChatbotViewModel extends ChangeNotifier {
  final String baseUrl;

  ChatbotViewModel({required this.baseUrl});

  Future<String> sendMessage(String message, String userId) async {
    final response = await http.post(
      // 🌟🌟🌟 이 부분을 '/api/chat'으로 수정합니다 🌟🌟🌟
      Uri.parse('$baseUrl/api/chat'), 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'user_id': userId, // patient_id 대신 백엔드와 일치하도록 'user_id'로 변경
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 백엔드에서 'response' 필드로 응답하므로 'reply' 대신 'response' 사용
      return data['response']; 
    } else {
      // 서버 오류 메시지를 더 자세히 표시하도록 수정
      final errorData = jsonDecode(response.body);
      throw Exception('챗봇 서버 오류 (${response.statusCode}): ${errorData['error'] ?? response.body}');
    }
  }
}