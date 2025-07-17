// lib/presentation/screens/result_detail_screen.dart
import 'package:flutter/material.dart';
import 'result_image_base.dart';

class ResultDetailScreen extends StatefulWidget {
  final String imageUrl;
  final Map<int, String> processedImageUrls;
  final Map<int, Map<String, dynamic>> modelInfos;

  const ResultDetailScreen({
    super.key,
    required this.imageUrl,
    required this.processedImageUrls,
    required this.modelInfos,
  });

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  int? _selectedModelIndex = 1;

  @override
  Widget build(BuildContext context) {
    final modelInfo = (_selectedModelIndex != null)
        ? widget.modelInfos[_selectedModelIndex!]
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text("AI 예측 결과")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ResultImageWithToggle(
              selectedModelIndex: _selectedModelIndex,
              onModelToggle: (index) => setState(() => _selectedModelIndex = index),
              imageUrl: widget.processedImageUrls[_selectedModelIndex!] ?? widget.imageUrl,
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
