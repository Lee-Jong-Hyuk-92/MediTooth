import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
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
  });

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  int? _selectedModelIndex = 1;

  Future<void> _showAddressDialogAndApply() async {
    final TextEditingController controller = TextEditingController();
    final String apiUrl = "${widget.baseUrl}/apply";

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("주소 입력", style: Theme.of(context).textTheme.titleLarge),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "상세 주소를 입력하세요"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text("확인"),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "user_id": widget.userId,
            "location": result,
            "inference_result_id": widget.inferenceResultId,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 신청이 완료되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ 신청 실패: ${jsonDecode(response.body)['error'] ?? '알 수 없는 오류'}',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 서버 오류: \$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentUser = Provider.of<AuthViewModel>(context, listen: false).currentUser;

    final String imageUrl = (_selectedModelIndex != null)
        ? widget.processedImageUrls[_selectedModelIndex!] ?? widget.originalImageUrl
        : widget.originalImageUrl;

    final modelInfo = (_selectedModelIndex != null)
        ? widget.modelInfos[_selectedModelIndex!]
        : null;

    final double? confidence = modelInfo?['confidence'];
    final String? modelName = modelInfo?['model_used'];
    final String className = "Dental Plaque";

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
            // 토글 버튼들 (가로 정렬)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSwitch("충치/치주염/치은염", 1),
                _buildSwitch("치석/보철물", 2),
                _buildSwitch("치아번호", 3),
              ],
            ),
            const SizedBox(height: 12),

            // 이미지 표시
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: MediaQuery.of(context).size.height * 0.45,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),

            // 예측 정보
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
                          Text('・모델: \$modelName', style: textTheme.bodyMedium),
                        if (confidence != null)
                          Text('・확신도: \${(confidence * 100).toStringAsFixed(1)}%', style: textTheme.bodyMedium),
                        Text('・클래스: \$className', style: textTheme.bodyMedium),
                      ],
                    )
                  : const SizedBox(height: 60), // 자리만 유지
            ),

            const Spacer(),

            // 하단 버튼들
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
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.local_hospital),
                      label: const Text("비대면 진료 신청하기"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: _showAddressDialogAndApply,
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
