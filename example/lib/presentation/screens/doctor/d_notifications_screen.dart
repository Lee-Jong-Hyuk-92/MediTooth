import 'package:flutter/material.dart';

class DNotificationsScreen extends StatelessWidget {
  final String baseUrl;
  const DNotificationsScreen({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
      ),
      body: Center(
        child: Text('알림 화면 - 서버: $baseUrl'),
      ),
    );
  }
}
