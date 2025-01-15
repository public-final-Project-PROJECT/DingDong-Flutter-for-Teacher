import 'package:dingdong_flutter_teacher/screen/calendar_update.dart';
import 'package:flutter/material.dart';

class CalendarDetails extends StatefulWidget {
  final dynamic event;
  final Function(int id) deleteEvent;
  final Function(dynamic event) updateEvent;

  const CalendarDetails(
      {super.key,
      required this.event,
      required this.deleteEvent,
      required this.updateEvent});

  @override
  State<CalendarDetails> createState() => _CalendarDetailsState();
}

class _CalendarDetailsState extends State<CalendarDetails> {
  dynamic event2;
  bool canDismiss = false;
  @override
  void initState() {
    super.initState();
    event2 = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('이벤트 세부사항'),
          centerTitle: true,
          leadingWidth: 90,
          leading: SizedBox(
            width: 130,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.1),
                    child: Text(
                      event2 != null && event2['start'] != null
                          ? '${event2['start'].toString().substring(5, 7)} 월'
                          : 'No Date',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showModalBottomSheet(
                  isDismissible: false,
                  enableDrag: false,
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return GestureDetector(
                        child: CalendarUpdate(
                          setEvent: widget.event,
                          updateDate: 0,
                          onEventAdded: (title, location, description,
                              startDate, endDate) {
                            final DateTime dateStart =
                                startDate.add(const Duration(hours: 9)).toUtc();
                            final DateTime dateEnd =
                                endDate.add(const Duration(hours: 9)).toUtc();
                            final event = {
                              'calendarId': widget.event['calendarId'],
                              'title': title,
                              'description': description,
                              'start': dateStart.toString().substring(0, 10),
                              'end': dateEnd.toString().substring(0, 10),
                            };
                            setState(() {
                              event2['title'] = title;
                              event2['description'] = description;
                              event2['start'] =
                                  dateStart.toString().substring(0, 10);
                              event2['end'] =
                                  dateEnd.toString().substring(0, 10);
                            });
                            widget.updateEvent(event);
                          },
                        ),
                      );
                    });
                  },
                );
              },
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event2['title']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '시작일 : ${event2['start'].toString().substring(0, 10)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '종료일 : ${event2['end'].toString().substring(0, 10)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey,
            ),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 5, left: 5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '메모',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${event2['description']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ]),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: TextButton(
            onPressed: () {
              _showDeleteModal(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.red,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Delete Event'),
          ),
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
                        '이 이벤트를 삭제하겠습니까?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    InkWell(
                      onTap: () {
                        widget.deleteEvent(widget.event['calendarId']);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          '이벤트 삭제',
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
                    '취소',
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

class EditEventScreen extends StatelessWidget {
  final dynamic event;

  const EditEventScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
      ),
      body: Center(
        child: Text('Edit screen for: ${event['title']}'),
      ),
    );
  }
}
