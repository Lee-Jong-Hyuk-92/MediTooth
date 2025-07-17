import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DCalendarScreen extends StatefulWidget {
  const DCalendarScreen({super.key});

  @override
  State<DCalendarScreen> createState() => _DCalendarScreenState();
}

class _DCalendarScreenState extends State<DCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// 샘플 예약 데이터 (실제로는 API 연동으로 교체 예정)
  final Map<DateTime, List<String>> _appointments = {
    DateTime.utc(2025, 7, 17): ['홍길동 환자 진료 10:00', '김영희 환자 진료 14:00'],
    DateTime.utc(2025, 7, 18): ['이순신 환자 진료 09:00'],
  };

  /// 날짜를 '년-월-일'로 정규화 (시간 제거)
  DateTime _normalizeDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  /// 선택한 날짜의 예약 리스트 반환
  List<String> _getEventsForDay(DateTime day) {
    return _appointments[_normalizeDate(day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _selectedDay ?? _focusedDay;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 예약 캘린더'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // 캘린더 UI
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 18),
            ),
          ),

          const SizedBox(height: 12),

          // 날짜 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 예약 목록',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 예약 리스트
          Expanded(
            child: _getEventsForDay(selectedDate).isEmpty
                ? const Center(
                    child: Text(
                      '예약이 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _getEventsForDay(selectedDate).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(selectedDate)[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            event,
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            // TODO: 예약 상세 페이지로 이동 or 팝업
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
