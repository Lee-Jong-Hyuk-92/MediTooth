import 'package:flutter/material.dart';

class DAnswersScreen extends StatelessWidget {
  final String baseUrl;
  const DAnswersScreen({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('답변 완료 목록'),
      ),
      body: Center(
        child: Text('답변 완료 화면 - 서버: $baseUrl'),
      ),
    );
  }
}
