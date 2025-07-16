import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';
import '/presentation/viewmodel/userinfo_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  final String baseUrl;

  const LoginScreen({
    super.key,
    required this.baseUrl,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController registerIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _selectedRole = 'P';

  Future<void> login() async {
    print('로그인 버튼 클릭됨');
    final authViewModel = context.read<AuthViewModel>();
    final userInfoViewModel = context.read<UserInfoViewModel>();

    final registerId = registerIdController.text.trim();
    final password = passwordController.text.trim();

    if (registerId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요')),
      );
      print('아이디 또는 비밀번호 누락');
      return;
    }

    print('로그인 시도: ID=$registerId, Role=$_selectedRole');
    try {
      final user = await authViewModel.loginUser(registerId, password, _selectedRole);
      print('loginUser 결과: $user');

      if (user != null) {
        userInfoViewModel.loadUser(user);
        print('로그인 성공. 사용자 역할: ${user.role}');
        if (user.role == 'D') {
          context.go('/d_home');
          print('의사 홈으로 이동: /d_home');
        } else {
          context.go('/home', extra: {'userId': user.registerId});
          print('환자 홈으로 이동: /home, userId: ${user.registerId}');
        }
      } else {
        final error = authViewModel.errorMessage ?? '로그인 실패';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        print('로그인 실패: $error');
      }
    } catch (e) {
      print('로그인 중 예외 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 처리 중 오류 발생: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '로그인',
          style: textTheme.headlineLarge,
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 👇 여기에 추가
            Column(
              children: [
                Image.asset(
                  'assets/images/meditooth_logo.png',
                  height: 120, // 원하는 크기 조절
                ),
                const SizedBox(height: 12),
                Text(
                  '안녕하세요! MediTooth 입니다.',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 기존 사용자 유형 선택부터 아래는 그대로 유지
            Row(
              children: [
                Text(
                  '사용자 유형:',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('환자', style: textTheme.labelLarge),
                    value: 'P',
                    groupValue: _selectedRole,
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('의사', style: textTheme.labelLarge),
                    value: 'D',
                    groupValue: _selectedRole,
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: registerIdController,
              decoration: const InputDecoration(
                labelText: '아이디',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: login,
                child: const Text('로그인'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('회원가입 하기'),
            ),
          ],
        ),
      ),
    );
  }
}
