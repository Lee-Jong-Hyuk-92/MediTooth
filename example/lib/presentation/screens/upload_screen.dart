import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/presentation/viewmodel/auth_viewmodel.dart';

class UploadScreen extends StatefulWidget {
  final String baseUrl;

  const UploadScreen({super.key, required this.baseUrl});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _webImage = null;
      _imageFile = null;
    });

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImage = bytes;
      });
    } else {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null && _webImage == null) return;

    final authViewModel = context.read<AuthViewModel>();
    final registerId = authViewModel.currentUser?.registerId;

    if (registerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보가 없습니다.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('${widget.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = registerId;

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _imageFile!.path,
          contentType: MediaType('image', 'png'),
        ));
      } else if (_webImage != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _webImage!,
          filename: 'web_image.png',
          contentType: MediaType('image', 'png'),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        final inferenceResultId = responseData['inference_result_id'] as String? ?? 'UNKNOWN';
        final processedPath = responseData['image_url'] as String?;
        final inferenceData = responseData['inference_data'] as Map<String, dynamic>?;
        final originalPath = responseData['original_image_path'] as String?;

        if (processedPath != null && inferenceData != null && originalPath != null) {
          final baseStaticUrl = widget.baseUrl.replaceFirst('/api', '');

          final originalImageUrl = '$baseStaticUrl$originalPath';
          final processedImageUrl = '$baseStaticUrl$processedPath';

          context.go(
            '/result_detail',
            extra: {
              'originalImageUrl': originalImageUrl,
              'processedImageUrls': {
                1: processedImageUrl,
              },
              'modelInfos': {
                1: inferenceData,
              },
              'userId': registerId,
              'inferenceResultId': inferenceResultId,
              'baseUrl': widget.baseUrl,
              'role': authViewModel.currentUser?.role ?? 'P',
              'from': 'upload', // ✅ 추가
            },
          );
        } else {
          throw Exception('image_url 또는 inference_data 없음');
        }
      } else {
        print('서버 오류: ${response.statusCode}');
        print('응답 본문: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 오류 발생')),
        );
      }
    } catch (e) {
      print('업로드 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 업로드 실패')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('사진으로 예측하기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final userId = context.read<AuthViewModel>().currentUser?.registerId ?? 'guest';
            context.go('/home', extra: {'userId': userId});
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.5,
              child: Center(
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.contain)
                    : _webImage != null
                        ? Image.memory(_webImage!, fit: BoxFit.contain)
                        : const Icon(Icons.image, size: 120, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('사진 선택'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadImage,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: const Text('예측하기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
