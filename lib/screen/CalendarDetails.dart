import 'package:dingdong_flutter_teacher/model/calendar_model.dart';
import 'package:dingdong_flutter_teacher/screen/calendar_update.dart';
import 'package:flutter/material.dart';

class Calendardetails extends StatefulWidget {
  final dynamic event;
  final Function(int id) DeleteEvent;
  final Function(dynamic event) UpdateEvent;
  const Calendardetails({super.key, required this.event, required this.DeleteEvent, required this.UpdateEvent});

  @override
  State<Calendardetails> createState() => _CalendardetailsState();
}

class _CalendardetailsState extends State<Calendardetails> {
  final CalendarModel _calendarModel = CalendarModel();
  dynamic event2;
  @override
  void initState() {
    super.initState();
    event2 = widget.event; // 여기서 widget에 안전하게 접근 가능
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0), // 왼쪽 여백 추가
          child: Center(
            child: Text(
              '${event2['start'].toString().substring(0, 10)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // 원하는 색상 설정
              ),
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.add), // 오른쪽 상단에 추가 버튼
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // 모달 창이 전체 화면에 가까워지도록 설정
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return CalendarUpdate(

                    setEvent: widget.event,
                    updateDate: 0,
                    onEventAdded: (title, location, description, startDate, endDate) {
                      // 이벤트 추가 로직

                      final DateTime datestart =
                      startDate.add(const Duration(hours: 9)).toUtc();
                      final DateTime dateend =
                      endDate.add(const Duration(hours: 9)).toUtc();
                      final event = {
                        'calendarId' : widget.event['calendarId'],
                        'title': title,
                        'description': description,
                        'start': datestart.toString().substring(0, 10),
                        'end': dateend.toString().substring(0, 10),
                      };
                      setState(() {
                        event2['title'] = title;
                        event2['description'] = description;
                        event2['start'] = datestart.toString().substring(0, 10);
                        event2['end'] = dateend.toString().substring(0, 10);
                      });
                      widget.UpdateEvent(event);
                      },
                  );
                },
              );
            },
          ),
        ],
      ),
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
              color: Colors.grey, // Divider color
            ),
            Container(
              height: 200, // 고정된 높이 설정
              width: double.infinity, // 전체 너비 사용
              padding: const EdgeInsets.only(top: 5, left: 5), // 위쪽 여백 최소화

              child: Column(crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                children:[ const Text(
                  '메모',
                  style: TextStyle(fontSize: 16),
                ),Text(
                  '${event2['description']}',
                  style: const TextStyle(fontSize: 16),
                ),]
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey, // Divider color
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
                        '이 이벤트를 삭제하겠습니까?', // Confirmation text
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

                        widget.DeleteEvent(widget.event['calendarId']);
                        Navigator.pop(context); // Close modal
                        Navigator.pop(context);

                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          '이벤트 삭제', // Delete text
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
                    '취소', // Cancel text
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
