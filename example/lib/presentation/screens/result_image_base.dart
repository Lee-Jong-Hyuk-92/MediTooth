// lib/presentation/screens/result_image_base.dart

import 'package:flutter/material.dart';

/// 📷 토글 스위치와 이미지 표시 위젯
class ResultImageWithToggle extends StatelessWidget {
  final int? selectedModelIndex;
  final Function(int?) onModelToggle;
  final String imageUrl;

  const ResultImageWithToggle({
    super.key,
    required this.selectedModelIndex,
    required this.onModelToggle,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔘 모델 토글 스위치 3개
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSwitch("충치/치주염/치은염", 1),
            _buildSwitch("치석/보철물", 2),
            _buildSwitch("치아번호", 3),
          ],
        ),
        const SizedBox(height: 12),

        // 📷 선택된 이미지 출력
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: MediaQuery.of(context).size.height * 0.4,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text('이미지를 불러올 수 없습니다.');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, int index) {
    return Column(
      children: [
        Switch(
          value: selectedModelIndex == index,
          onChanged: (val) {
            onModelToggle(val ? index : null);
          },
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// 📊 AI 예측 결과 박스 위젯
class AIResultBox extends StatelessWidget {
  final String? modelName;
  final double? confidence;
  final String className;

  const AIResultBox({
    super.key,
    required this.modelName,
    required this.confidence,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
          if (modelName != null)
            Text('・모델: $modelName', style: textTheme.bodyMedium),
          if (confidence != null)
            Text('・확신도: ${(confidence! * 100).toStringAsFixed(1)}%', style: textTheme.bodyMedium),
          Text('・클래스: $className', style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
