import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '/presentation/viewmodel/doctor/d_consultation_record_viewmodel.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';
import '/presentation/model/doctor/d_consultation_record.dart';
import 'doctor/d_result_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String baseUrl;

  const HistoryScreen({super.key, required this.baseUrl});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ConsultationRecordViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConsultationRecordViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('이전 진단 기록')),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(child: Text('오류: ${viewModel.error}'))
              : currentUser == null
                  ? const Center(child: Text('로그인이 필요합니다.'))
                  : _buildListView(
                      viewModel.records.where((r) => r.userId == currentUser.registerId).toList(),
                    ),
    );
  }

  Widget _buildListView(List<ConsultationRecord> records) {
    final imageBaseUrl = widget.baseUrl.replaceAll('/api', '');

    final List<ConsultationRecord> sortedRecords = List.from(records)
      ..sort((a, b) {
        final atime = _extractDateTimeFromFilename(a.originalImagePath);
        final btime = _extractDateTimeFromFilename(b.originalImagePath);
        return btime.compareTo(atime);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        final listIndex = sortedRecords.length - index;

        String formattedTime;
        try {
          final time = _extractDateTimeFromFilename(record.originalImagePath);
          formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(time);
        } catch (e) {
          formattedTime = '시간 파싱 오류';
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('[$listIndex] $formattedTime'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('사용자 ID: ${record.userId}'),
                Text('파일명: ${record.originalImageFilename}'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultDetailScreen(
                    originalImageUrl: '$imageBaseUrl${record.originalImagePath}',
                    processedImageUrls: {
                      1: '$imageBaseUrl${record.processedImagePath}',
                    },
                    modelInfos: {
                      1: {
                        'model_used': record.modelUsed, // ✅ DB에서 불러온 값 사용
                        'confidence': record.confidence ?? 0.0,
                        'lesion_points': record.lesionPoints ?? [],
                      },
                    },
                    userId: record.userId, // ✅ 추가
                    inferenceResultId: record.id,
                    baseUrl: widget.baseUrl, // ✅ 여기를 수정
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  DateTime _extractDateTimeFromFilename(String imagePath) {
    final filename = imagePath.split('/').last;
    final parts = filename.split('_');
    if (parts.length < 2) throw FormatException('잘못된 파일명 형식: $filename');
    final timePart = parts[1];
    final y = timePart.substring(0, 4);
    final m = timePart.substring(4, 6);
    final d = timePart.substring(6, 8);
    final h = timePart.substring(8, 10);
    final min = timePart.substring(10, 12);
    final sec = timePart.substring(12, 14);
    return DateTime.parse('$y-$m-$d' 'T' '$h:$min:$sec');
  }
}