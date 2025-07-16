import 'package:flutter/material.dart';

class PatientsPlaceholder extends StatelessWidget {
  const PatientsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '환자 목록 - 구현 예정',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
