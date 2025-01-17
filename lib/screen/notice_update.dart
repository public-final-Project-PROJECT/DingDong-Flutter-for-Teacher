import 'dart:io';

import 'package:dingdong_flutter_teacher/screen/notice.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NoticeUpdate extends StatefulWidget {
  final dynamic notice;
  final int classId;
  const NoticeUpdate({super.key, required this.notice, required this.classId});

  @override
  State<NoticeUpdate> createState() => _NoticeUpdateState();
}

class _NoticeUpdateState extends State<NoticeUpdate> {
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
        'classId': widget.classId,
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

        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedImage = null;
          _selectedFile = null;
          selectedFileName = null;
          _selectedCategory = categories.first;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Notice(classId: widget.classId)),
        );
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
                    .map((category) => DropdownMenuItem(
                        value: category, child: Text(category)))
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
                dropdownColor: Colors.white,
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
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff3CB371),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                          child: const Text("이미지 선택"),
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
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff3CB371),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                          child: const Text("이미지 변경하기"),
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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff3CB371),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )),
                      child: const Text("이미지 선택"),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_selectedFile == null && selectedFileName != null)
                    Text(
                      selectedFileName!,
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  if (_selectedFile != null)
                    Text(
                      getFileName(_selectedFile!.path),
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3CB371),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                    child: const Text("파일 선택"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateNotice,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff205736),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                child: const Text("수정하기"),
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

    int underscoreIndex = processedFileName.lastIndexOf('_');
    if (underscoreIndex != -1) {
      return processedFileName.substring(underscoreIndex + 1);
    } else {
      return processedFileName;
    }
  }
}
