import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/constants/constant.dart';
import 'package:running_mate/models/record.dart';
import 'package:running_mate/providers/record_provider.dart';
import 'package:running_mate/widgets/record/record_item.dart';
import 'package:running_mate/widgets/ui_elements/input_label.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class EventCalendarScreen extends ConsumerStatefulWidget {
  const EventCalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EventCalendarScreen> createState() =>
      _EventCalendarScreenState();
}

class _EventCalendarScreenState extends ConsumerState<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  Map<String, List<RecordModel>> events = {};
  final _formKey = GlobalKey<FormState>();
  int? _enteredDistance;
  String? _enteredMemo;
  String? _recordId;
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _miniutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
    ref.read(recordProvider.notifier).fetchCalendarRecords(_focusedDay);
  }

  List<RecordModel> _listOfDayEvents(DateTime dateTime) {
    if (events[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return events[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  void _submitRecord() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final record = RecordModel(
        id: _recordId,
        date: _selectedDate!,
        distance: _enteredDistance!,
        miniutes: _miniutesController.text.isNotEmpty
            ? int.tryParse(_miniutesController.text)!
            : 0,
        hour: _hourController.text.isNotEmpty
            ? int.tryParse(_hourController.text)!
            : 0,
        memo: _enteredMemo,
      );

      await ref.read(recordProvider.notifier).saveRecord(record);
      if (!mounted) {
        return;
      }
      if (_recordId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('수정하였습니다'),
          ),
        );
      }
      _formKey.currentState!.reset();
      _hourController.clear();
      _miniutesController.clear();
      _enteredDistance = null;
      _enteredMemo = null;
      _recordId = null;

      Navigator.of(context).pop();
    }
  }

  _showAddEventDialog(bool isUpdating) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('기록 추가'),
          content: SingleChildScrollView(
            child: SizedBox(
              height: 450,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InputLabel(text: '거리'),
                    TextFormField(
                      initialValue: _enteredDistance != null
                          ? _enteredDistance.toString()
                          : '',
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Text('km'),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '거리를 입력해주세요';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredDistance = int.tryParse(value!);
                      },
                    ),
                    const SizedBox(height: 20),
                    const InputLabel(text: '달린 시간'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hourController,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(top: 14),
                                child: Text('시간'),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (_miniutesController.text.isNotEmpty) {
                                return null;
                              }
                              if (value == null || value.isEmpty) {
                                return '시간을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(top: 14),
                                child: Text('분'),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            controller: _miniutesController,
                            validator: (value) {
                              if (_hourController.text.isNotEmpty) {
                                return null;
                              }
                              if (value == null || value.isEmpty) {
                                return '시간 입력';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const InputLabel(text: '메모'),
                    TextFormField(
                      initialValue:
                          _enteredMemo != null ? _enteredMemo.toString() : '',
                      maxLength: 200,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSaved: (value) {
                        _enteredMemo = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _hourController.clear();
                            _miniutesController.clear();
                            _enteredDistance = null;
                            _enteredMemo = null;
                            _recordId = null;
                            Navigator.of(context).pop();
                          },
                          child: const Text('취소'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _submitRecord,
                          child: const Text('확인'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  getMapEvents(List<RecordModel> recordList) {
    events = {};
    for (var element in recordList) {
      if (events[DateFormat('yyyy-MM-dd').format(element.date)] != null) {
        events[DateFormat('yyyy-MM-dd').format(element.date)]?.add(element);
      } else {
        events[DateFormat('yyyy-MM-dd').format(element.date)] = [element];
      }
    }
  }

  _updateRecord(RecordModel record) {
    _enteredDistance = record.distance;
    _hourController.text = record.hour.toString();
    _miniutesController.text = record.miniutes.toString();
    _enteredMemo = record.memo;
    _recordId = record.id;
    _showAddEventDialog(true);
  }

  @override
  Widget build(BuildContext context) {
    getMapEvents(ref.watch(recordProvider).recordList);
    var events = _listOfDayEvents(_selectedDate!);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 350,
              child: TableCalendar(
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                locale: 'ko_KR',
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDate, selectedDay)) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _listOfDayEvents,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Text(
                    '운동기록',
                    style: Theme.of(context).textTheme.bodyLarge!,
                  ),
                  const Spacer(),
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4))),
                      onPressed: () => _showAddEventDialog(false),
                      child: const Text('추가하기')),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true, // <==== limit height. 리스트뷰 크기 고정
              primary: false, // <====  disable scrolling. 리스트뷰 내부는 스크롤 안할거임
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    RecordItem(
                      record: events[index],
                      onUpdateRecord: _updateRecord,
                    ),
                    const SizedBox(height: 15)
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
