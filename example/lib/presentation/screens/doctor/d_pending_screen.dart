import 'package:flutter/material.dart';

class DPendingScreen extends StatelessWidget {
  final String baseUrl;
  const DPendingScreen({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('미답변 목록'),
      ),
      body: Center(
        child: Text('미답변 화면 - 서버: $baseUrl'),
      ),
    );
  }
}
