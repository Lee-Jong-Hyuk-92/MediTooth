import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/presentation/screens/doctor/d_real_home_screen.dart'; // DoctorDrawer
import '/presentation/viewmodel/auth_viewmodel.dart'; // 🔁 AuthViewModel 추가

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
          consults = data['consults'];
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

  // ✅ 선택 사항: 사용하지 않으면 제거 가능
  void _showReplyDialog(dynamic consult, String doctorId) {
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
              final response = await http.post(
                replyUrl,
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'request_id': consult['request_id'],
                  'doctor_id': doctorId,
                  'comment': commentController.text,
                  'reply_datetime': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
                }),
              );

              if (response.statusCode == 200) {
                Navigator.pop(context);
                fetchConsultRequests();
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
    final currentDoctor = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    final doctorId = currentDoctor?.registerId;

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
                        onTap: () {

                          context.go('/d_telemedicine_result_detail', extra: {
                            'baseUrl': widget.baseUrl,
                            'originalImageUrl': '${widget.baseUrl}${consult['image_path']}',
                            'processedImageUrls': {
                              1: '${widget.baseUrl}/processed_uploads/model1/${consult['image_path'].split('/').last}',
                              2: '${widget.baseUrl}/processed_uploads/model2/${consult['image_path'].split('/').last}',
                              3: '${widget.baseUrl}/processed_uploads/model3/${consult['image_path'].split('/').last}',
                            },
                            'modelInfos': {
                              1: {'model_used': 'Model 1', 'confidence': 0.85},
                              2: {'model_used': 'Model 2', 'confidence': 0.88},
                              3: {'model_used': 'Model 3', 'confidence': 0.92},
                            },
                            'userId': consult['user_id'],
                            'inferenceResultId': 'UNKNOWN',
                            'role': 'D',
                            'from': 'consult',
                            'doctorId': doctorId,
                            'requestId': consult['request_id'].toString(),
                          });
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
