import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:running_mate/models/record.dart';
import 'package:running_mate/providers/record_provider.dart';

class RecordHistoriesScreen extends ConsumerStatefulWidget {
  const RecordHistoriesScreen({super.key});

  @override
  ConsumerState<RecordHistoriesScreen> createState() =>
      _RecordHistoriesScreenState();
}

class _RecordHistoriesScreenState extends ConsumerState<RecordHistoriesScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final date = DateTime.now();
    final startDate = DateTime.utc(date.year, date.month, 1);
    final endDate = DateTime.utc(date.year, date.month, date.day);

    ref.read(recordProvider.notifier).fetchRecordHistories(startDate, endDate);
  }

  _showCalendar(DateTime initialDate) async {
    final selectedDate = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );
    return selectedDate;
  }

  void _showDatePickModal() {
    final dateRange = ref.watch(recordProvider).dateRange;

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        DateTime? enteredStartDate;
        DateTime? enteredendDate;
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return SizedBox(
              height: 400,
              width: double.infinity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          '조회 기간 설정',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.cancel_rounded,
                              size: 40,
                            ))
                      ],
                    ),
                    const SizedBox(height: 30),
                    // 시작, 끝 날짜 선택
                    Row(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            iconColor: Colors.black,
                          ),
                          onPressed: () async {
                            final selectedDate = await _showCalendar(
                                enteredStartDate ?? dateRange.startDate);
                            setState(() {
                              enteredStartDate = selectedDate;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('yyyy.MM.dd').format(
                                    enteredStartDate ?? dateRange.startDate),
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 24.0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('~'),
                        const Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            iconColor: Colors.black,
                          ),
                          onPressed: () async {
                            final selectedDate = await _showCalendar(
                                enteredendDate ?? dateRange.endDate);
                            setState(() {
                              enteredendDate = selectedDate;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('yyyy.MM.dd').format(
                                    enteredendDate ?? dateRange.endDate),
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 24.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        minimumSize: const Size.fromHeight(50), // NEW
                      ),
                      onPressed: () {
                        DateTime start =
                            enteredStartDate ?? dateRange.startDate;
                        DateTime end = enteredendDate ?? dateRange.endDate;
                        ref.read(recordProvider.notifier).setDateRange(
                            DateRange(startDate: start, endDate: end));

                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        '조회',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMemoDialog(RecordModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모'),
        content: SingleChildScrollView(child: Text(record.memo!)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Map<String, List<RecordModel>> getMapEvents(List<RecordModel> recordList) {
    // print('recordList: $recordList');
    Map<String, List<RecordModel>> events = {};
    // final Map<String, List<RecordModel>> events = {};
    for (var element in recordList) {
      if (events[DateFormat('yyyy-MM-dd').format(element.date)] != null) {
        events[DateFormat('yyyy-MM-dd').format(element.date)]?.add(element);
      } else {
        events[DateFormat('yyyy-MM-dd').format(element.date)] = [element];
      }
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = ref.watch(recordProvider).dateRange;
    final recordHistories = ref.watch(recordProvider).recordHistories;
    var dateMappingRecords = getMapEvents(recordHistories);
    final dateList = dateMappingRecords.keys.toList();

    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('기록관리'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          // 요약
          Container(
            // color: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    children: [
                      TextSpan(
                          text: '이번달은',
                          style: Theme.of(context).textTheme.displaySmall!),
                      TextSpan(
                        text: ' 10시간',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                RichText(
                  text: TextSpan(
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    children: [
                      TextSpan(
                        text: '10km',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                      ),
                      TextSpan(
                        text: ' 달리고 있어요',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 100,
              width: double.infinity,
              child: Divider(color: Colors.grey, thickness: 2.0)),
          // 날짜 기간
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.,
              children: [
                Text(DateFormat('yyyy.MM.dd').format(dateRange.startDate)),
                const Text('~'),
                Text(DateFormat('yyyy.MM.dd').format(dateRange.endDate)),
                Text(
                  ' (${recordHistories.length.toString()}건)',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _showDatePickModal();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('기간 설정'),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_downward,
                        size: 24.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
              height: 1,
              width: double.infinity,
              child: Divider(color: Colors.grey, thickness: 1.0)),
          const SizedBox(height: 30),
          // 기록 목록
          SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: dateList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('yyyy.MM.dd')
                              .format(recordHistories[index].date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(
                          height: 1,
                          width: double.infinity,
                          child: Divider(color: Colors.grey, thickness: 1.0),
                        ),
                        if (dateMappingRecords[dateList[index]] != null)
                          SizedBox(
                            height:
                                dateMappingRecords[dateList[index]]!.length > 1
                                    ? 130
                                    : 70,
                            child: ListView.builder(
                              physics:
                                  dateMappingRecords[dateList[index]]!.length >
                                          1
                                      ? const ScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                              itemCount:
                                  dateMappingRecords[dateList[index]]!.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              const Text('운동시간'),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  const Icon(Icons.timer),
                                                  Text(
                                                      '${recordHistories[index].hour.toString()}시간 ${recordHistories[index].miniutes.toString()}분'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 20),
                                          Column(
                                            children: [
                                              const Text('거리'),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.line_axis_sharp),
                                                  Text(
                                                      '${recordHistories[index].distance.toString()}km'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 20),
                                          if (recordHistories[index].memo !=
                                                  null &&
                                              recordHistories[index]
                                                  .memo!
                                                  .isNotEmpty)
                                            GestureDetector(
                                              onTap: () => _showMemoDialog(
                                                  recordHistories[index]),
                                              child: const Column(
                                                children: [
                                                  Text('메모'),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.article),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
