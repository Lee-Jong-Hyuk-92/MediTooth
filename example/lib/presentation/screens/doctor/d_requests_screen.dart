import 'package:flutter/material.dart';

class DRequestsScreen extends StatelessWidget {
  final String? baseUrl;

  const DRequestsScreen({Key? key, this.baseUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
      ),
      body: Center(
        child: Text(
          'This is the Requests Screen.\nBase URL: ${baseUrl ?? "No baseUrl provided"}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
