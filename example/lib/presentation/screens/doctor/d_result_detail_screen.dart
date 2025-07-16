import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';

class ResultDetailScreen extends StatefulWidget {
  final String originalImageUrl;
  final Map<int, String> processedImageUrls;
  final Map<int, Map<String, dynamic>> modelInfos;
  final String userId;
  final String inferenceResultId;
  final String baseUrl;

  const ResultDetailScreen({
    super.key,
    required this.originalImageUrl,
    required this.processedImageUrls,
    required this.modelInfos,
    required this.userId,
    required this.inferenceResultId,
    required this.baseUrl,
  });

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  int? _selectedModelIndex = 1;

  void _toggleModel(int index) {
    setState(() {
      _selectedModelIndex = (_selectedModelIndex == index) ? null : index;
    });
  }

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
            SnackBar(content: Text('❌ 신청 실패: ${jsonDecode(response.body)['error'] ?? '알 수 없는 오류'}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 서버 오류: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double imageHeight = MediaQuery.of(context).size.height * 0.3;
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
        title: const Text('결과 이미지 상세 보기'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('🖼️ 표시 중인 이미지', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: imageHeight,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),
            Text('🧪 사용할 AI 모델 선택', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3].map((index) {
                return ChoiceChip(
                  label: Text("모델 $index"),
                  selected: _selectedModelIndex == index,
                  onSelected: (_) => _toggleModel(index),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            if (modelInfo != null) ...[
              Text('📊 모델 분석 정보', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              if (modelName != null) Text('모델: $modelName', style: textTheme.bodyMedium),
              if (confidence != null) Text('확신도: ${(confidence * 100).toStringAsFixed(1)}%', style: textTheme.bodyMedium),
              Text('클래스: $className', style: textTheme.bodyMedium),
            ],

            const SizedBox(height: 32),
            if (currentUser?.role == 'P')
              ElevatedButton.icon(
                onPressed: _showAddressDialogAndApply,
                icon: const Icon(Icons.send),
                label: const Text('신청하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
