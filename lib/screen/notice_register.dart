import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class NoticeRegister extends StatefulWidget {
  final int classId;
  const NoticeRegister({super.key, required this.classId});

  @override
  State<NoticeRegister> createState() => _NoticeRegisterState();
}

class _NoticeRegisterState extends State<NoticeRegister> {
  final _dio = Dio();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  File? _selectedFile;
  final List<String> categories = ["가정통신문", "알림장", "학교생활"];
  String _selectedCategory = "가정통신문";

  final _focusNodeTitle = FocusNode();
  final _focusNodeContent = FocusNode();
  bool _isFocusTransitioning = false;

  Future<void> _checkPermission(Permission permission) async {
    PermissionStatus permissionStatus = await permission.status;
    if (permissionStatus.isGranted) {
      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("권한이 필요합니다.")));
      openAppSettings();
    }
  }

  Future<void> _pickImage() async {
    if (!_isFocusTransitioning) {
      await _checkPermission(Permission.storage);
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("입력 필드에 포커스를 맞추고 다시 시도하세요."),
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    if (!_isFocusTransitioning) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("입력 필드에 포커스를 맞추고 다시 시도하세요."),
        ),
      );
    }
  }

  Future<void> _registerNotice() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목과 내용을 입력해주세요.")),
      );
      return;
    }

    try {
      final formData = FormData.fromMap({
        'noticeTitle': title,
        'noticeCategory': _selectedCategory,
        'noticeContent': content,
        'classId': widget.classId,
        if (_selectedImage != null)
          'noticeImg': await MultipartFile.fromFile(_selectedImage!.path),
        if (_selectedFile != null)
          'noticeFile': await MultipartFile.fromFile(_selectedFile!.path),
      });

      final response = await _dio.post(
        'http://112.221.66.174:3013/api/notice/insert',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("공지사항이 등록되었습니다.")),
        );

        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedImage = null;
          _selectedFile = null;
          _selectedCategory = categories.first;
        });
        Navigator.pop(context, true);
      } else {
        throw Exception("등록 실패: ${response.data}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("공지사항 작성"),
          backgroundColor: const Color(0xffF4F4F4),
          shape: const Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1,
              )),
        ),
        backgroundColor: const Color(0xffF4F4F4),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FocusScope(
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "제목",
                      border: OutlineInputBorder(),
                    ),
                    focusNode: _focusNodeTitle,
                    onEditingComplete: () {
                      setState(() {
                        _isFocusTransitioning = true;
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _focusNodeContent.requestFocus();
                        setState(() {
                          _isFocusTransitioning = false;
                        });
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: categories
                        .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "카테고리",
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor: const Color(0xffFFFFFF),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: "내용",
                      border: OutlineInputBorder(),
                    ),
                    focusNode: _focusNodeContent,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_selectedImage != null)
                        Image.file(
                          _selectedImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      if (_selectedImage == null)
                        const SizedBox(width: 100, height: 100),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFocusTransitioning
                              ? Colors.grey
                              : const Color(0xff515151),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text("이미지 선택"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_selectedFile != null)
                        Text(
                          getFileName(_selectedFile!.path),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ElevatedButton(
                        onPressed: _pickFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFocusTransitioning
                              ? Colors.grey
                              : const Color(0xff515151),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text("파일 선택"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _registerNotice,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff515151),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                    child: const Text("등록하기"),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  String getFileName(String filePath) {
    String fileName = filePath.split('/').last;

    String processedFileName;
    if (fileName.contains('%')) {
      processedFileName = Uri.encodeFull(fileName);
    } else {
      processedFileName = fileName;
    }

    int underscoreIndex = processedFileName.lastIndexOf('_');
    if (underscoreIndex != -1) {
      return processedFileName.substring(underscoreIndex + 1);
    } else {
      return processedFileName;
    }
  }
}
