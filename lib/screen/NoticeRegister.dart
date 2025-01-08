import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class NoticeRegister extends StatefulWidget {
  const NoticeRegister({super.key});

  @override
  State<NoticeRegister> createState() => _NoticeRegisterState();
}

class _NoticeRegisterState extends State<NoticeRegister> {
  final _dio = Dio();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  File? _selectedFile;
  final List<String> categories = ["가정통신문","알림장","학교생활"];
  String _selectedCategory = "가정통신문";


  Future<void> _checkPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("권한이 필요합니다.")),
      );
      throw Exception("권한이 거부되었습니다.");
    }
  }

  //이미지 선택
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  //파일 선택
  // Future<void> _pickFile() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedFile = File(pickedFile.path);
  //     });
  //   }
  // }
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // type: FileType.custom,
      // allowedExtensions: ['pdf', 'jpg', 'png', 'docx' ,'txt'],
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
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
        'classId': 1, // 임시로 고정된 classId 사용
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

        // 초기화
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
        backgroundColor: Color(0xffF4F4F4),
        shape: const Border(  // AppBar 밑줄
          bottom: BorderSide(
            color: Colors.grey,
            width: 1
          )
        ),
      ),
      backgroundColor: Color(0xffF4F4F4),  // 배경색 변경
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "제목",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories
                  .map((category) =>
                  DropdownMenuItem(value: category, child: Text(category)))
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
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,

              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "내용",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("이미지 선택"),
                  style: ElevatedButton.styleFrom(  // '이미지 선택' 버튼 스타일 변경
                    backgroundColor: Color(0xff515151), // 버튼 배경색 변경 (어둡계
                    foregroundColor: Colors.white,  // 버튼 텍스트 색 변경 (흰색)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // 버튼 테두리 둥글기 조절 (네모로)
                    )
                  ),
                ),
              ),
               SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: categories
                    .map((category) =>
                    DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration:  InputDecoration(
                  labelText: "카테고리",
                  border: OutlineInputBorder(),
                ),
              ),
               SizedBox(height: 16),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration:  InputDecoration(
                  labelText: "내용",
                  border: OutlineInputBorder(),
                ),
              ),
               SizedBox(height: 16),
              Row(
                children: [
                  // 이미 선택된 이미지가 있으면 왼쪽에 표시
                  if (_selectedImage != null)
                    Image.file(
                      _selectedImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  if (_selectedImage == null)
                  // 이미지가 없을 때 공간을 차지하지 않음
                    const SizedBox(width: 100, height: 100),
                  const Spacer(), // 이미지와 버튼 사이의 공간을 균등하게 채우기
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("이미지 선택"),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text("파일 선택"),
                  style: ElevatedButton.styleFrom(  // '파일 선택' 버튼 스타일 변경
                    backgroundColor: Color(0xff515151),  // 버튼 배경색 변경 (어둡게)
                    foregroundColor: Colors.white,  // 버튼 텍스트 색 변경 (흰색)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
                    )
                  ),
                ),
                if (_selectedFile != null)
                  Text( _selectedFile!.uri.pathSegments.last, // 파일 이름만 추출
                    style: TextStyle(color: Colors.green),),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _registerNotice,
              child: const Text("등록하기"),
              style: ElevatedButton.styleFrom(  // '등록하기' 버튼 스타일 변경
                backgroundColor: Color(0xff515151),  // 버튼 배경색 변경 (어둡게)
                foregroundColor: Colors.white,  // 버튼 텍스트 색 변경 (흰색)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
                )
              ),
            ),
          ],
        ),
      ),
    );
  }}