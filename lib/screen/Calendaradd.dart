import 'package:flutter/material.dart';

class CalendarAdd extends StatelessWidget {
  final Function(String title, String location, String description, DateTime startDate, DateTime endDate) onEventAdded;

  const CalendarAdd({Key? key, required this.onEventAdded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController();
    final _locationController = TextEditingController();
    final _descriptionController = TextEditingController();

    DateTime? _startDate;
    DateTime? _endDate;

    Future<void> _pickDate(BuildContext context, bool isStartDate) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      }
    }

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
            const Text(
              'Add Event',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter event title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter location',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
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
                _startDate == null
                    ? 'Select Start Date'
                    : '${_startDate!.year}-${_startDate!.month}-${_startDate!.day}',
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
                _endDate == null
                    ? 'Select End Date'
                    : '${_endDate!.year}-${_endDate!.month}-${_endDate!.day}',
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_startDate == null || _endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select both start and end dates'),
                      ),
                    );
                    return;
                  }
                  onEventAdded(
                    _titleController.text,
                    _locationController.text,
                    _descriptionController.text,
                    _startDate!,
                    _endDate!,
                  );
                  Navigator.of(context).pop(); // 모달 닫기
                },
                child: const Text('Add Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
