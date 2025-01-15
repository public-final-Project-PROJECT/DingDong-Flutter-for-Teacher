import 'dart:io';

import 'package:flutter/material.dart';

class CalendarAdd extends StatefulWidget {
  final Function(String title, String location, String description,
      DateTime startDate, DateTime endDate) onEventAdded;
  final dynamic initialDate;
  final int updateDate;

  const CalendarAdd(
      {super.key,
      required this.onEventAdded,
      this.initialDate,
      required this.updateDate});

  @override
  State<CalendarAdd> createState() => _CalendarAddState();
}

class _CalendarAddState extends State<CalendarAdd> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late FocusNode focusNode;
  File? _selectedImage;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    int Id = widget.updateDate;

    DateTime defaulttime =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    startDate =
        widget.initialDate.subtract(const Duration(hours: 9)).toLocal() ??
            defaulttime;
    endDate = widget.initialDate.subtract(const Duration(hours: 9)).toLocal() ??
        defaulttime;
    focusNode = FocusNode();

    // FocusNode 리스너 추가
    focusNode.addListener(() {
      setState(() {
        // 포커스 상태가 바뀔 때마다 UI 갱신
      });
    });
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate,
      DateTime? start, DateTime? end) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? start ?? DateTime.now() // `isStartDate`가 true이면 `start` 사용
          : (end == null || (start != null && start.isAfter(end)))
              ? start ??
                  DateTime
                      .now() // `end`가 null이거나 `start`가 `end`보다 이후이면 `start`를 사용
              : end,
      // 기본적으로 `end` 사용
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '',
      // 상단의 "Select Date" 제거
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange, // 선택된 날짜 배경색
              onPrimary: Colors.white, // 선택된 날짜 텍스트 색상
              onSurface: Colors.black, // 기본 텍스트 색상
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange, // 확인 및 취소 버튼 색상
              ),
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // 테두리 모서리를 직각으로 설정
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          // Start date 업데이트
          startDate = picked;

          // Start가 End 이후라면 End도 Start로 동기화
          if (end != null && start!.isAfter(end!)) {
            endDate = startDate;
          }
        } else {
          // End date 업데이트
          endDate = picked;

          // End가 Start 이전이면 Start와 동기화
          if (start != null && start!.isAfter(end!)) {
            endDate = startDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9, // 화면의 90% 높이
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.0), // 모서리 둥글게
          ),
        ),
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (titleController.text.isEmpty &&
                        descriptionController.text.isEmpty) {
                      Navigator.pop(context);

                    }
                    else
                    {
                      _showDeleteModal(context);
                    }

                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
                const Text(
                  'Add Event',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    if (startDate == null || endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please select both start and end dates'),
                        ),
                      );
                      return;
                    }
                    widget.onEventAdded(
                      titleController.text,
                      locationController.text,
                      descriptionController.text,
                      startDate!,
                      endDate!,
                    );
                    Navigator.of(context).pop(); // 모달 닫기
                  },
                  child: const Text(
                    '추가',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              focusNode: focusNode,
              controller: titleController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Enter event title',
                suffixIcon:
                    (focusNode.hasFocus && titleController.text.isNotEmpty)
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              titleController.clear(); // 텍스트 초기화
                              setState(() {});
                            },
                          )
                        : null, // 포커스가 없으면 X 버튼 숨김
              ),
              onChanged: (value) {
                setState(() {}); // 텍스트가 변경될 때 UI 갱신
              },
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter description',
              ),
            ),
            const SizedBox(height: 50),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () =>
                            _pickDate(context, true, startDate, endDate),
                        child: Text(
                          startDate == null
                              ? 'Select Start Date'
                              : '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
                        ),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(children: [
                    const Text(
                      'End Date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () =>
                          _pickDate(context, false, startDate, endDate),
                      child: Text(
                        endDate == null
                            ? 'Select End Date'
                            : (endDate!.isBefore(startDate!)
                                ? '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}'
                                : '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'),
                      ),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                    ),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16), // Rounded top corners
        ),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grouped container for the confirmation text and delete button
              Container(
                margin: const EdgeInsets.fromLTRB(16,16,16,8),
                decoration: BoxDecoration(
                  color: Colors.white70, // Button background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Confirmation text
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        '이 새로운 이벤트를 폐기하겠습니까?', // Confirmation text
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // Text color
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Divider
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey, // Divider color
                    ),
                    // Delete button
                    InkWell(
                      onTap: () {


                        Navigator.pop(context); // Close modal
                        Navigator.pop(context);

                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          '변경 사항 폐기', // Delete text
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red, // Red text color
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Cancel button (independent)
              InkWell(
                onTap: () {
                  Navigator.pop(context); // Close modal
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white, // Button background
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    '계속 편집하기', // Cancel text
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black, // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );

      },
    );
  }
}
