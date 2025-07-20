import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // Provider 임포트
import '/presentation/viewmodel/auth_viewmodel.dart'; // AuthViewModel 임포트 경로 확인

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key}); // const 생성자 추가 (선택 사항, 상태가 변경되지 않는다면)

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // API 호출하여 챗봇 응답 받기
  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    // AuthViewModel에서 현재 로그인된 사용자 ID 가져오기
    final String? currentUserId = Provider.of<AuthViewModel>(context, listen: false).currentUser?.registerId;

    setState(() {
      _messages.add({'role': 'user', 'message': message});
    });

    _controller.clear(); // 메시지 전송 후 입력 필드 초기화
    _scrollToBottom(); // 새 메시지 추가 후 스크롤 하단으로 이동

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.19:5000/api/chat'), // 백엔드 챗봇 API 엔드포인트
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': currentUserId ?? 'guest', // 실제 사용자의 ID 사용, 없으면 'guest'
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes)); // 한글 깨짐 방지
        final botMessage = responseData['response'];

        setState(() {
          _messages.add({'role': 'bot', 'message': botMessage});
        });
      } else {
        setState(() {
          // 서버 응답 오류를 더 상세하게 표시
          _messages.add({'role': 'bot', 'message': '챗봇 서버 오류 (${response.statusCode}): ${utf8.decode(response.bodyBytes)}'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'message': '네트워크 오류: 챗봇 서버에 연결할 수 없습니다. ($e)'});
      });
    } finally {
      _scrollToBottom(); // 최종적으로 스크롤 하단으로 이동
    }
  }

  // 스크롤을 항상 가장 아래로 이동시키는 함수
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("챗봇"), // const 추가
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // 스크롤 컨트롤러 지정
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message['role'] == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(8.0),
                        color: message['role'] == 'user'
                            ? Colors.green[200]
                            : Colors.blue[200],
                        elevation: 2.0, // 그림자 효과 추가
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 15.0,
                          ),
                          child: Text(
                            message['message']!,
                            style: const TextStyle(fontSize: 16), // const 추가
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10), // 입력 필드 위에 간격 추가
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration( // const 추가
                      hintText: "질문을 입력하세요...",
                      border: OutlineInputBorder(), // 테두리 추가
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // 패딩 조정
                    ),
                    onSubmitted: _sendMessage, // 엔터 키로 메시지 전송
                  ),
                ),
                const SizedBox(width: 8), // 아이콘 버튼과 간격 추가
                IconButton(
                  icon: const Icon(Icons.send), // const 추가
                  onPressed: () {
                    _sendMessage(_controller.text);
                    FocusScope.of(context).unfocus(); // 키보드 닫기
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



