import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';

class ResultDetailScreen extends StatefulWidget {
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

  const ResultDetailScreen({
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
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  int? _selectedModelIndex = 1;
  bool _alreadyApplied = false;
  bool _isThisImageApplied = false;
  String? _requestId;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkAlreadyApplied();
  }

  Future<void> _checkAlreadyApplied() async {
    final originalPath = Uri.parse(widget.originalImageUrl).path;
    final url = '${widget.baseUrl}/consult/active?user_id=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['request_id'] != null && data['image_path'] != null) {
          setState(() {
            _alreadyApplied = true;
            _requestId = data['request_id'].toString();
            _isThisImageApplied = data['image_path'] == originalPath;
          });
        } else {
          setState(() {
            _alreadyApplied = false;
            _requestId = null;
            _isThisImageApplied = false;
          });
        }
      }
    } catch (e) {
      print("❌ 신청 여부 확인 실패: $e");
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 답변이 저장되었습니다.')),
        );
        _commentController.clear();
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

  Future<void> _applyConsultation() async {
    final url = "${widget.baseUrl}/consult";
    final now = DateTime.now();
    final formattedDatetime = DateFormat('yyyyMMddHHmmss').format(now);
    final imagePath = Uri.parse(widget.originalImageUrl).path;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": widget.userId,
          "image_path": imagePath,
          "request_datetime": formattedDatetime,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _alreadyApplied = true;
          _isThisImageApplied = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 신청이 완료되었습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 서버 오류: $e')),
      );
    }
  }

  Future<void> _cancelConsultation() async {
    if (_requestId == null) return;
    final url = '${widget.baseUrl}/consult/cancel';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"request_id": _requestId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _alreadyApplied = false;
          _isThisImageApplied = false;
          _requestId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑 신청이 취소되었습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 서버 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentUser = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    final imageUrl = (_selectedModelIndex != null)
        ? widget.processedImageUrls[_selectedModelIndex!] ?? widget.originalImageUrl
        : widget.originalImageUrl;
    final modelInfo = (_selectedModelIndex != null)
        ? widget.modelInfos[_selectedModelIndex!]
        : null;
    final double? confidence = modelInfo?['confidence'];
    final String? modelName = modelInfo?['model_used'];
    const className = "Dental Plaque";

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 예측 결과'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.role == 'D') {
              context.go('/d_inference_result', extra: widget.baseUrl);
            } else {
              if (widget.from == 'upload') {
                context.go('/upload', extra: widget.baseUrl);
              } else if (widget.from == 'history') {
                context.go('/history', extra: {
                  'baseUrl': widget.baseUrl,
                  'role': widget.role,
                });
              }
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: (modelInfo != null)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📊 AI 예측 결과:', style: textTheme.titleMedium),
                        const SizedBox(height: 6),
                        if (modelName != null)
                          Text('・모델: $modelName', style: textTheme.bodyMedium),
                        if (confidence != null)
                          Text('・확신도: ${(confidence * 100).toStringAsFixed(1)}%', style: textTheme.bodyMedium),
                        Text('・클래스: $className', style: textTheme.bodyMedium),
                      ],
                    )
                  : const SizedBox(height: 60),
            ),
            if (widget.role == 'D' && widget.requestId != null) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '의사 코멘트 입력',
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: _isSubmitting ? const Text("저장 중...") : const Text("답변 저장"),
                  onPressed: _isSubmitting ? null : _submitDoctorReply,
                ),
              ),
            ],
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
                if (currentUser?.role == 'P')
                  Expanded(child: _buildConsultButton()),
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

  Widget _buildConsultButton() {
    if (_alreadyApplied && _isThisImageApplied) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.cancel),
        label: const Text("신청 취소"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        onPressed: _cancelConsultation,
      );
    } else if (_alreadyApplied && !_isThisImageApplied) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.block),
        label: const Text("신청 불가"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        onPressed: null,
      );
    } else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.local_hospital),
        label: const Text("비대면 진료 신청하기"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: _applyConsultation,
      );
    }
  }
}
