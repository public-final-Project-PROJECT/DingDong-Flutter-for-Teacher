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
        color: Colors.white, // 흰색으로 바꾸니까 분명 둥글었던 게 네모네모빔 맞아버림 ,,
        // 곧 다시 둥글게 바꿔놓겠습니다 ㅠ
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Event',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter location',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter description',
              ),
            ),
            const SizedBox(height: 16),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )
              ),
            ),
            const SizedBox(height: 16),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
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
                child: const Text('Add Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff515151),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
