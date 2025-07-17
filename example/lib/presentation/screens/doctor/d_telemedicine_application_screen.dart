import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '/presentation/screens/doctor/d_real_home_screen.dart'; // DoctorDrawer

class DTelemedicineApplicationScreen extends StatefulWidget {
  final String baseUrl;

  const DTelemedicineApplicationScreen({super.key, required this.baseUrl});

  @override
  State<DTelemedicineApplicationScreen> createState() => _DTelemedicineApplicationScreenState();
}

class _DTelemedicineApplicationScreenState extends State<DTelemedicineApplicationScreen> {
  List<dynamic> consults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchConsultRequests();
  }

  Future<void> fetchConsultRequests() async {
    final url = Uri.parse('${widget.baseUrl}/consult/list');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          consults = data['consults']; // ✅ 여기!
          isLoading = false;
        });
      } else {
        throw Exception('불러오기 실패');
      }
    } catch (e) {
      print('❌ 오류 발생: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showReplyDialog(dynamic consult) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('신청자: ${consult['user_name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('진료 요청 시간: ${consult['request_datetime']}'),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: '답변 내용 입력'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('답변 등록'),
            onPressed: () async {
              final replyUrl = Uri.parse('${widget.baseUrl}/consult/reply');
              final response = await http.post(replyUrl,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'request_id': consult['request_id'],
                    'doctor_id': 'doctor001', // 🔁 로그인 정보 기반으로 수정 필요
                    'comment': commentController.text,
                    'reply_datetime': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
                  }));

              if (response.statusCode == 200) {
                Navigator.pop(context);
                fetchConsultRequests(); // 목록 갱신
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('답변이 등록되었습니다.')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('답변 등록 실패')));
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비대면 진료 신청'),
        backgroundColor: Colors.blueAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      drawer: DoctorDrawer(baseUrl: widget.baseUrl),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : consults.isEmpty
              ? const Center(child: Text('신청된 진료가 없습니다.'))
              : ListView.builder(
                  itemCount: consults.length,
                  itemBuilder: (context, index) {
                    final consult = consults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.medical_services),
                        title: Text('${consult['user_name']}님의 진료 신청'),
                        subtitle: Text('시간: ${consult['request_datetime']}'),
                        trailing: consult['is_replied'] == 'Y'
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.pending_actions, color: Colors.orange),
                        onTap: consult['is_replied'] == 'Y'
                            ? null
                            : () => _showReplyDialog(consult),
                      ),
                    );
                  },
                ),
    );
  }
}