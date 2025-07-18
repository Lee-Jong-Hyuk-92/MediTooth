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
  bool _showDisease = true;
  bool _showHygiene = true;
  bool _showToothNumber = true;

  Future<void> _showAddressDialogAndApply() async {
    final TextEditingController controller = TextEditingController();
    final String apiUrl = "${widget.baseUrl}/apply";

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("주소 입력"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "상세 주소를 입력하세요"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
            TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text("확인")),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 신청이 완료되었습니다.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ 신청 실패: ${jsonDecode(response.body)['error'] ?? '알 수 없는 오류'}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ 서버 오류: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentUser = Provider.of<AuthViewModel>(context, listen: false).currentUser;

    final modelInfo = widget.modelInfos[1];
    final modelName = modelInfo?['model_used'] ?? 'N/A';
    final confidence = modelInfo?['confidence'] ?? 0.0;
    final className = modelInfo?['class_name'] ?? 'Dental Issue';
    final imageUrl = widget.originalImageUrl;
    final processedUrl = widget.processedImageUrls[1];

    const Color cardBorder = Color(0xFF3869A8);
    const Color toggleBackground = Color(0xFFEAEAEA);
    const Color outerBackground = Color(0xFFE7F0FF);
    const Color buttonColor = Color(0xFF3869A8);

    return Scaffold(
      backgroundColor: outerBackground,
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: const Text('진단 결과', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToggleCard(toggleBackground),
            const SizedBox(height: 16),
            _buildFixedImageCard(imageUrl, processedUrl),
            const SizedBox(height: 16),
            _buildSummaryCard(modelName, confidence, className, textTheme),
            const SizedBox(height: 24),

            if (currentUser?.role == 'P') ...[
              _buildActionButton(Icons.download, '진단 결과 이미지 저장', () {}),
              const SizedBox(height: 12),
              _buildActionButton(Icons.image, '원본 이미지 저장', () {}),
              const SizedBox(height: 12),
              _buildActionButton(Icons.medical_services, 'AI 예측 기반 비대면 진단 신청', _showAddressDialogAndApply),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard(Color toggleBg) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF3869A8), width: 1.5),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('마스크 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildStyledToggle("충치/치주염/치은염", _showDisease, (val) => setState(() => _showDisease = val), toggleBg),
        _buildStyledToggle("치석/보철물", _showHygiene, (val) => setState(() => _showHygiene = val), toggleBg),
        _buildStyledToggle("치아번호", _showToothNumber, (val) => setState(() => _showToothNumber = val), toggleBg),
      ],
    ),
  );

  Widget _buildStyledToggle(String label, bool value, ValueChanged<bool> onChanged, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildFixedImageCard(String imageUrl, String? overlayUrl) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF3869A8), width: 1.5),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('진단 이미지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF3869A8), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.fill, // ✅ 변경
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                  ),
                  if (_showDisease && overlayUrl != null)
                    Image.network(
                      overlayUrl,
                      fit: BoxFit.fill, // ✅ 동일하게 변경
                      opacity: const AlwaysStoppedAnimation(0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSummaryCard(String model, double conf, String cls, TextTheme theme) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF3869A8), width: 1.5),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('진단 요약', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("모델: $model", style: theme.bodyMedium),
        Text("확신도: ${(conf * 100).toStringAsFixed(1)}%", style: theme.bodyMedium),
        Text("클래스: $cls", style: theme.bodyMedium),
      ],
    ),
  );

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) => ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: Colors.white),
    label: Text(label, style: const TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3869A8),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}