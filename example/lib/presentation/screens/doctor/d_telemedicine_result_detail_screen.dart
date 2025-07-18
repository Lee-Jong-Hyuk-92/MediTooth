import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';

class DTelemedicineResultDetailScreen extends StatefulWidget {
  final String originalImageUrl;
  final Map<int, String> processedImageUrls;
  final Map<int, Map<String, dynamic>> modelInfos;
  final String userId;
  final String inferenceResultId;
  final String baseUrl;
  final String role;
  final String from;
  final String? doctorId;
  final String? requestId;

  const DTelemedicineResultDetailScreen({
    super.key,
    required this.originalImageUrl,
    required this.processedImageUrls,
    required this.modelInfos,
    required this.userId,
    required this.inferenceResultId,
    required this.baseUrl,
    required this.role,
    required this.from,
    this.doctorId,
    this.requestId,
  });

  @override
  State<DTelemedicineResultDetailScreen> createState() => _DTelemedicineResultDetailScreenState();
}

class _DTelemedicineResultDetailScreenState extends State<DTelemedicineResultDetailScreen> {
  int? _selectedModelIndex = 1;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isReplied = false;
  String? _doctorComment;

  @override
  void initState() {
    super.initState();
    _fetchReplyStatus();
  }

  Future<void> _fetchReplyStatus() async {
    if (widget.requestId == null) return;
    final url = '${widget.baseUrl}/consult/detail?request_id=${widget.requestId}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isReplied = data['is_replied'] == 'Y';
          _doctorComment = data['doctor_comment'];
        });
      }
    } catch (e) {
      print('❌ 답변 상태 확인 실패: $e');
    }
  }

  Future<void> _submitDoctorReply() async {
    if (widget.requestId == null || widget.doctorId == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final url = '${widget.baseUrl}/consult/reply';
    final now = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'request_id': widget.requestId,
          'doctor_id': widget.doctorId,
          'comment': _commentController.text,
          'reply_datetime': now,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isReplied = true;
          _doctorComment = _commentController.text;
        });
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 답변이 저장되었습니다.')),
        );
      } else {
        final errorMsg = jsonDecode(response.body)['error'] ?? '오류 발생';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 저장 실패: $errorMsg')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 네트워크 오류: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (_selectedModelIndex != null)
        ? widget.processedImageUrls[_selectedModelIndex!] ?? widget.originalImageUrl
        : widget.originalImageUrl;
    final modelInfo = (_selectedModelIndex != null)
        ? widget.modelInfos[_selectedModelIndex!]
        : null;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('비대면 진료 신청자 AI 예측 결과'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            //context.pop('/d_telemedicine_application', extra: widget.baseUrl);
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_isReplied) Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSwitch("충치/치주염/치은염", 1),
                _buildSwitch("치석/보철물", 2),
                _buildSwitch("치아번호", 3),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            if (!_isReplied && modelInfo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📊 AI 예측 결과:', style: textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('・모델: ${modelInfo['model_used']}', style: textTheme.bodyMedium),
                    Text('・확신도: ${(modelInfo['confidence'] * 100).toStringAsFixed(1)}%', style: textTheme.bodyMedium),
                    const Text('・클래스: Dental Plaque', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (!_isReplied)
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '의사 코멘트 입력',
                ),
              ),
            if (_isReplied)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('의사 코멘트:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(_doctorComment ?? "코멘트 없음"),
                  ],
                ),
              ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_alt),
                    label: const Text("이미지 저장"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이미지를 저장했습니다.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_isReplied ? Icons.check_circle : Icons.save),
                    label: Text(_isReplied ? "답변 완료" : "답변 저장"),
                    onPressed: (_isReplied || _isSubmitting) ? null : _submitDoctorReply,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, int index) {
    return Column(
      children: [
        Switch(
          value: _selectedModelIndex == index,
          onChanged: (val) {
            setState(() {
              _selectedModelIndex = val ? index : null;
            });
          },
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}