import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // GoRouter를 쓰므로 필요

class ClinicsScreen extends StatelessWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 치과'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(); // 홈으로 되돌아가기
          },
        ),
      ),
      body: const Center(child: Text('주변 치과 지도 및 목록')),
    );
  }
}
