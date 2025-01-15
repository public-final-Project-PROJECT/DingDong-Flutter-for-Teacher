import 'package:flutter/material.dart';

class CalendarUpdate extends StatefulWidget {
  final Function(String title, String location, String description,
      DateTime startDate, DateTime endDate) onEventAdded;
  final dynamic setEvent;
  final int updateDate;
  const CalendarUpdate(
      {super.key,
      required this.onEventAdded,
      required this.updateDate,
      required this.setEvent});

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

    titleController = TextEditingController(text: widget.setEvent['title']);
    descriptionController =
        TextEditingController(text: widget.setEvent['description']);
    startDate = DateTime.parse(widget.setEvent['start'])
        .add(const Duration(hours: 9))
        .toUtc();
    endDate = DateTime.parse(widget.setEvent['end'])
        .add(const Duration(hours: 9))
        .toUtc();
    focusNode = FocusNode();

    focusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate,
      DateTime? start, DateTime? end) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? start ?? DateTime.now()
          : (end == null || (start != null && start.isAfter(end)))
              ? start ?? DateTime.now()
              : end,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
            dialogTheme: const DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
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
          startDate = picked;

          if (end != null && start!.isAfter(end)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;

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
      heightFactor: 0.9,

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
                    if (titleController.text != widget.setEvent['title'] ||
                        descriptionController.text !=
                            widget.setEvent['description'] ||
                        startDate !=
                            DateTime.parse(widget.setEvent['start'])
                                .add(const Duration(hours: 9))
                                .toUtc() ||
                        endDate !=
                            DateTime.parse(widget.setEvent['end'])
                                .add(const Duration(hours: 9))
                                .toUtc()) {
                      _showDeleteModal(context);
                    } else {
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
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '수정',
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
                              titleController.clear();
                              setState(() {});
                            },
                          )
                        : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: '내용',
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
          top: Radius.circular(16),
        ),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        '이 새로운 이벤트를 폐기하겠습니까?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(
                      height: 1, thickness: 1,
                      color: Colors.grey,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          '변경 사항 폐기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    '계속 편집하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
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
