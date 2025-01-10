import 'package:flutter/material.dart';

class CalendarAdd extends StatefulWidget {
  final Function(String title, String location, String description, DateTime startDate, DateTime endDate) onEventAdded;
  final dynamic initialDate;
  final int updateDate;
  const CalendarAdd({super.key, required this.onEventAdded, this.initialDate, required this.updateDate});

  @override
  State<CalendarAdd> createState() => _CalendarAddState();
}

class _CalendarAddState extends State<CalendarAdd> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    int Id = widget.updateDate;

    DateTime defaulttime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    print(defaulttime);
    startDate = widget.initialDate.subtract(const Duration(hours: 9)).toLocal() ?? defaulttime;
    endDate = widget.initialDate.subtract(const Duration(hours: 9)).toLocal() ?? defaulttime;


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
                    Navigator.of(context).pop(); // 취소 버튼 기능
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
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter event title',
              ),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            OutlinedButton(
              onPressed: () => _pickDate(context, true, startDate, endDate),
              child: Text(
                startDate == null
                    ? 'Select Start Date'
                    : '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _pickDate(context, false, startDate,endDate),
              child: Text(
                endDate == null
                    ? 'Select End Date'
                    : (endDate!.isBefore(startDate!)
                    ? '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}'
                    : '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'),
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
}
