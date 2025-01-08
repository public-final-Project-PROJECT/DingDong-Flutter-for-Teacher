import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Noticeupdate extends StatefulWidget {
  final dynamic notice;
  const Noticeupdate({super.key, required this.notice});

  @override
  State<Noticeupdate> createState() => _NoticeupdateState();
}

class _NoticeupdateState extends State<Noticeupdate> {
  final _dio = Dio();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  String? beforeImg;
  File? _selectedFile;
  String? selectedFileName;
  final List<String> categories = ["가정통신문", "알림장", "학교생활"];
  String _selectedCategory = "";
  int? noticeId;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.notice['noticeTitle'] ?? "";
    _contentController.text = widget.notice['noticeContent'] ?? "";
    _selectedCategory = widget.notice['noticeCategory'] ?? "가정통신문";
    noticeId = widget.notice['noticeId'];

    if (widget.notice['noticeImg'] != null) {
      beforeImg = widget.notice['noticeImg'];
    }
    if (widget.notice['noticeFile'] != null) {
      selectedFileName = getFileName(widget.notice['noticeFile']);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 파일 피커
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        selectedFileName = getFileName(result.files.single.path!);
      });
    }
  }

  Future<void> _updateNotice() async {
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
        if (_selectedFile != null && _selectedFile!.path.isNotEmpty)
          'noticeFile': await MultipartFile.fromFile(_selectedFile!.path),
      });
      final response = await _dio.post(
        'http://112.221.66.174:3013/api/notice/update/$noticeId',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("공지사항이 업데이트되었습니다.")),
        );

        // 초기화
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedImage = null;
          _selectedFile = null;
          selectedFileName = null;
          _selectedCategory = categories.first;
        });
        Navigator.pop(context, true);
      } else {
        throw Exception("업데이트 실패: ${response.data}");
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
        title: const Text("공지사항 수정"),
        backgroundColor: Color(0xffF4F4F4),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          )
        ),
      ),
      backgroundColor: Color(0xffF4F4F4),  // 배경색 변경
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "제목",
                  hintText: "제목",
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
                  hintText: "내용",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // 이미지 선택 UI
              if (_selectedImage != null)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.file(
                          _selectedImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text("이미지 선택"),
                          style: ElevatedButton.styleFrom(  // '이미지 선택' 버튼 스타일 변경
                            backgroundColor: Color(0xff515151), // 버튼 배경색 어둡게 변경
                            foregroundColor: Colors.white,  // 버튼 텍스트 흰색으로 변경
                            shape: RoundedRectangleBorder(  // 버튼 테두리 조절
                              borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
                            )
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                )
              else if (widget.notice['noticeImg'] != null &&
                  widget.notice['noticeImg'].isNotEmpty)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.network(
                          "http://112.221.66.174:3013$beforeImg",
                          width: 100, // 섬네일 크기로 조정
                          height: 100, // 섬네일 크기로 조정
                          fit: BoxFit.cover,
                        ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text("이미지 변경하기"),
                          style: ElevatedButton.styleFrom(  // '이미지 변경하기' 버튼 스타일 변경
                            backgroundColor: Color(0xff515151), // 버튼 배경색 어둡게 변경
                            foregroundColor: Colors.white,  // 버튼 텍스트 흰색으로 변경
                            shape: RoundedRectangleBorder(  // 버튼 테두리 조절
                              borderRadius: BorderRadius.circular(8.0), // 버튼 테두리 둥글기 조절 (네모로)
                            )
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text("이미지 선택"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff515151),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // 파일 선택 UI
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_selectedFile == null && selectedFileName != null)
                    Text(
                      selectedFileName!,
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                      overflow: TextOverflow.ellipsis, // 너무 긴 텍스트는 생략 부호 추가
                      maxLines: 1,
                    ),
                  if (_selectedFile != null)
                    Text(
                      getFileName(_selectedFile!.path), // 파일 이름 가져오기
                      style: const TextStyle(color: Colors.black, fontSize: 12), // 스타일 정의
                      overflow: TextOverflow.ellipsis, // 너무 긴 텍스트는 생략 부호 추가
                      maxLines: 1,
                    ),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text("파일 선택"),
                    style: ElevatedButton.styleFrom(  // '파일 선택' 버튼 스타일 변경
                      backgroundColor: Color(0xff515151), // 버튼 배경색 어둡게 변경
                      foregroundColor: Colors.white,  // 버튼 텍스트 흰색으로 변경
                      shape: RoundedRectangleBorder(  // 버튼 테두리 조절
                        borderRadius: BorderRadius.circular(8.0), // 버튼 테두리 둥글기 조절 (네모로)
                      )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 수정 버튼
              ElevatedButton(
                onPressed: _updateNotice,
                child: const Text("수정하기"),
                style: ElevatedButton.styleFrom(  // '수정하기' 버튼 스타일 변경
                  backgroundColor: Color(0xff515151), // 버튼 배경색 어둡게 변경
                  foregroundColor: Colors.white,  // 버튼 텍스트 흰색으로 변경
                  shape: RoundedRectangleBorder(  // 버튼 테두리 조절
                    borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getFileName(String filePath) {
    String fileName = filePath.split('/').last;

    String processedFileName;
    if (fileName.contains('%')) {
      processedFileName = Uri.encodeFull(fileName);
    } else {
      processedFileName = fileName;
    }

    // 첫 번째 '_' 뒤부터 자르기
    int underscoreIndex = processedFileName.lastIndexOf('_');
    if (underscoreIndex != -1) {
      return processedFileName.substring(underscoreIndex + 1);
    } else {
      return processedFileName;
    }
  }
}