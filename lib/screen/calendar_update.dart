import 'package:flutter/material.dart';

class CalendarUpdate extends StatefulWidget {
  final Function(String title, String location, String description, DateTime startDate, DateTime endDate) onEventAdded;
  final dynamic setEvent;
  final int updateDate;
  const CalendarUpdate({super.key, required this.onEventAdded, required this.updateDate, required this.setEvent});

  @override
  State<CalendarUpdate> createState() => _CalendarUpdateState();
}

class _CalendarUpdateState extends State<CalendarUpdate> {
  late TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late FocusNode focusNode;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    int Id = widget.updateDate;
    titleController = TextEditingController(text: widget.setEvent['title']);
    descriptionController = TextEditingController(text: widget.setEvent['description']);
    DateTime defaulttime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    print(defaulttime);
    startDate = DateTime.parse(widget.setEvent['start']).add(const Duration(hours: 9)).toUtc();
    endDate = DateTime.parse(widget.setEvent['end']).add(const Duration(hours: 9)).toUtc();
    focusNode = FocusNode();

    // FocusNode 리스너 추가
    focusNode.addListener(() {
      setState(() {
        // 포커스 상태가 바뀔 때마다 UI 갱신
      });
    });

  }

  Future<void> _pickDate(
      BuildContext context, bool isStartDate, DateTime? start, DateTime? end) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? start ?? DateTime.now() // `isStartDate`가 true이면 `start` 사용
          : (end == null || (start != null && start.isAfter(end)))
          ? start ?? DateTime.now() // `end`가 null이거나 `start`가 `end`보다 이후이면 `start`를 사용
          : end, // 기본적으로 `end` 사용
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '', // 상단의 "Select Date" 제거
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xff3CB371), // 선택된 날짜 배경색
              onPrimary: Colors.white, // 선택된 날짜 텍스트 색상
              onSurface: Colors.black, // 기본 텍스트 색상
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xff3CB371), // 확인 및 취소 버튼 색상
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
          if (end != null && start!.isAfter(end)) {
            endDate = startDate;
          }
        } else {
          // End date 업데이트
          endDate = picked;

          // End가 Start 이전이면 Start와 동기화
          if (start != null && start.isAfter(end!)) {
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

      child: Padding(
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
                    if (titleController.text != widget.setEvent['title'] || descriptionController.text != widget.setEvent['description']
                        || startDate != DateTime.parse(widget.setEvent['start']).add(const Duration(hours: 9)).toUtc()
                        || endDate != DateTime.parse(widget.setEvent['end']).add(const Duration(hours: 9)).toUtc()) {
                      _showDeleteModal(context);
                    }
                    else
                    {
                      Navigator.pop(context);
                    }

                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
                const Text(
                  '이벤트 수정',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    if (startDate == null || endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select both start and end dates'),
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
                    Navigator.pop(context); // 모달 닫기
                  },
                  child: const Text(
                    '수정',
                    style: TextStyle(fontSize: 16, color: Color(0xff205736)),
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
                suffixIcon: (focusNode.hasFocus  && titleController.text.isNotEmpty)
                    ?IconButton(
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
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration:  InputDecoration(
                border: OutlineInputBorder(),
                labelText: '내용', // 필드에 라벨 추가
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff205736)),
                      ),
                      const SizedBox(height: 8),

                      OutlinedButton(
                        onPressed: () => _pickDate(context, true, startDate, endDate),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white, // 텍스트 색상
                          backgroundColor: Color(0xff3CB371)
                          , // 배경색
                          side: BorderSide(color: Color(0xff309729), width: 0), // 테두리 색상 및 두께
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 패딩
                        ),
                        child: Text(
                          startDate == null
                              ? 'Select Start Date'
                              : '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 16, // 텍스트 크기
                            fontWeight: FontWeight.bold, // 텍스트 굵기
                          ),
                        ),

                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                  Column(
                      children: [

                        const Text(
                          'End Date',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff205736)),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _pickDate(context, false, startDate, endDate),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white, // 텍스트 색상
                            backgroundColor: Color(0xff3CB371)
                            , // 배경색
                            side: BorderSide(color: Color(0xff309729), width: 0), // 테두리 색상 및 두께
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 패딩
                          ),
                          child: Text(
                            endDate == null
                                ? 'Select End Date'
                                : (endDate!.isBefore(startDate!)
                                ? '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}'
                                : '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'),
                            style: TextStyle(
                              fontSize: 16, // 텍스트 크기
                              fontWeight: FontWeight.bold, // 텍스트 굵기
                            ),
                          ),
                        ),
                      ]
                  ),
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