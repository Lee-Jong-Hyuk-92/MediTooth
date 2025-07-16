import 'package:flutter/material.dart';

class DPatientsScreen extends StatelessWidget {
  final String baseUrl;
  const DPatientsScreen({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환자 목록'),
      ),
      body: Center(
        child: Text('환자 목록 화면 - 서버: $baseUrl'),
      ),
    );
  }
}
