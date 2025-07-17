// lib/presentation/screens/result_history_detail_screen.dart
import 'package:flutter/material.dart';
import 'result_image_base.dart';

class ResultHistoryDetailScreen extends StatelessWidget {
  final String imageUrl;
  final Map<int, String> processedImageUrls;
  final Map<int, Map<String, dynamic>> modelInfos;

  const ResultHistoryDetailScreen({
    super.key,
    required this.imageUrl,
    required this.processedImageUrls,
    required this.modelInfos,
  });

  @override
  Widget build(BuildContext context) {
    int selectedModelIndex = 1;
    final modelInfo = modelInfos[selectedModelIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("이전 결과 보기")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ResultImageWithToggle(
              selectedModelIndex: selectedModelIndex,
              onModelToggle: (_) {},
              imageUrl: processedImageUrls[selectedModelIndex] ?? imageUrl,
            ),
            const SizedBox(height: 12),
            if (modelInfo != null)
              AIResultBox(
                modelName: modelInfo['model_used'],
                confidence: modelInfo['confidence'],
                className: 'Dental Plaque',
              ),
          ],
        ),
      ),
    );
  }
}
