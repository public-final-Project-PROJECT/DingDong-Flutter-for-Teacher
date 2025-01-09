import 'package:flutter/material.dart';

class CalendarAdd extends StatelessWidget {
  final Function(String title, String location, String description, DateTime startDate, DateTime endDate) onEventAdded;

  final dynamic initialDate;

  const CalendarAdd({super.key, required this.onEventAdded,  this.initialDate});



  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    DateTime? startDate = initialDate;
    DateTime? endDate = initialDate;

    Future<void> _pickDate(BuildContext context, bool isStartDate) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      }
    }


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
              onPressed: () => _pickDate(context, true),
              child: Text(
                startDate == null
                    ? 'Select Start Date'
                    : '${startDate!.year}-${startDate!.month}-${startDate!.day}',
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
              onPressed: () => _pickDate(context, false),
              child: Text(
                endDate == null
                    ? 'Select End Date'
                    : '${endDate!.year}-${endDate!.month}-${endDate!.day}',
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
                  onEventAdded(
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
