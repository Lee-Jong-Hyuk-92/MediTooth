import 'package:flutter/material.dart';
import '/presentation/screens/doctor/d_real_home_screen.dart'; // DoctorDrawer를 사용하기 위해 임포트

class DTelemedicineApplicationScreen extends StatelessWidget {
  final String baseUrl;

  const DTelemedicineApplicationScreen({Key? key, required this.baseUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비대면 진료 신청'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      // ✅ DoctorDrawer 적용
      drawer: DoctorDrawer(baseUrl: baseUrl),
      body: const Center(
        child: Text(
          '비대면 진료 신청 화면 구현 예정입니다.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
