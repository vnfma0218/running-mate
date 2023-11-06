import 'package:flutter/material.dart';
import 'package:running_mate/screens/calendar/event.dart';
import 'package:running_mate/widgets/record/record_item.dart';
import 'package:running_mate/widgets/ui_elements/input_label.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Event>> events = {
    // DateTime.utc(2023, 11, 13): [Event('title'), Event('title2')],
    // DateTime.utc(2023, 11, 14): [Event('title3')],
  };
  late final ValueNotifier<List<Event>> _selectedEvents;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _paceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    print('_selectedEvents : $_selectedEvents');
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  void _onNewRecord() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('기록 추가'),
          content: SizedBox(
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InputLabel(text: '거리'),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _distanceController,
                ),
                const SizedBox(height: 30),
                const InputLabel(text: '달린 시간'),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _timeController,
                ),
                const SizedBox(height: 30),
                const InputLabel(text: '페이스'),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _paceController,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        final prevEvents = events[_selectedDay] ?? [];
                        prevEvents.add(
                          Event(_distanceController.text),
                        );
                        events.addAll({_selectedDay!: prevEvents});
                        _selectedEvents.value = _getEventsForDay(_selectedDay!);

                        Navigator.of(context).pop();
                      },
                      child: const Text('확인'),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          locale: 'ko_KR',
          calendarFormat: _calendarFormat,
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          eventLoader: _getEventsForDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          calendarStyle: CalendarStyle(
            markerSize: 10.0,
            markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _selectedEvents.value = _getEventsForDay(selectedDay);
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '나의기록',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ElevatedButton(
                            onPressed: _onNewRecord, child: const Text('추가하기'))
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return const RecordItem();
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
