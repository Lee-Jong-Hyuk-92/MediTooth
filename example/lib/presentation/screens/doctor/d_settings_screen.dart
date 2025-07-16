import 'package:flutter/material.dart';

class DSettingsScreen extends StatelessWidget {
  final String baseUrl;
  const DSettingsScreen({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Center(
        child: Text('설정 화면 - 서버: $baseUrl'),
      ),
    );
  }
}
