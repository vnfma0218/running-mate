import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:running_mate/models/record.dart';
import 'package:running_mate/providers/record_provider.dart';
import 'package:running_mate/widgets/ui_elements/alert_dialog.dart';

enum TypeDateRange { oneMonth, threeMonth, custom }

class RecordHistoriesScreen extends ConsumerStatefulWidget {
  const RecordHistoriesScreen({super.key});

  @override
  ConsumerState<RecordHistoriesScreen> createState() =>
      _RecordHistoriesScreenState();
}

class _RecordHistoriesScreenState extends ConsumerState<RecordHistoriesScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  final Map<TypeDateRange, String> dateRangeType = {
    TypeDateRange.oneMonth: '1개월',
    TypeDateRange.threeMonth: '3개월',
    TypeDateRange.custom: '직접설정',
  };

  var activeDateRangeType = TypeDateRange.oneMonth;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    final [startDate, endDate] = getDateRange(activeDateRangeType);

    ref.read(recordProvider.notifier).fetchRecordHistories(startDate, endDate);
    ref.read(recordProvider.notifier).getMonthSummary(DateTime.now());
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

  getDateRange(TypeDateRange type) {
    final date = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (type) {
      case TypeDateRange.threeMonth:
        startDate = DateTime.utc(date.year, date.month - 3, date.day);
        endDate = DateTime.utc(date.year, date.month, date.day);
        break;
      default:
        startDate = DateTime.utc(date.year, date.month - 1, date.day);
        endDate = DateTime.utc(date.year, date.month, date.day);
    }

    return [startDate, endDate];
  }

  void _showDatePickModal() async {
    final dateRange = ref.watch(recordProvider).dateRange;

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        TypeDateRange selectedTypeRange = activeDateRangeType;
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
                    Text(
                      '조회기간',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ...dateRangeType.entries.map((type) {
                          bool isActive = type.key == selectedTypeRange;
                          return OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 25),
                                side: isActive
                                    ? const BorderSide(
                                        color: Colors.red,
                                        width: 1.0,
                                      )
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            onPressed: () {
                              final [startDate, endDate] =
                                  getDateRange(type.key);
                              setState(() {
                                enteredStartDate = startDate;
                                enteredendDate = endDate;
                                selectedTypeRange = type.key;
                              });
                            },
                            child: Text(
                              type.value,
                              style: isActive
                                  ? const TextStyle(color: Colors.red)
                                  : null,
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 시작, 끝 날짜 선택 (직접설정)
                    if (selectedTypeRange == TypeDateRange.custom)
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
                                      fontSize: 15, color: Colors.black),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18.0,
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
                                      fontSize: 15, color: Colors.black),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18.0,
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
                        setState(() {
                          activeDateRangeType = selectedTypeRange;
                        });
                        if (start.isBefore(end)) {
                          ref.read(recordProvider.notifier).setDateRange(
                                DateRange(
                                    startDate: start,
                                    endDate: end,
                                    isChanged: true),
                              );

                          Navigator.of(context).pop();
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => const AlertDialogWidget(
                                title: '조회기간 오류',
                                content: '조회 시작일이 종료일보다 큽니다.'),
                          );
                        }
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
    final newDateRange = ref.watch(recordProvider).dateRange;

    if (newDateRange.isChanged) {
      ref
          .read(recordProvider.notifier)
          .fetchRecordHistories(newDateRange.startDate, newDateRange.endDate);
    }
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

  void _showMonthPicker() {
    showMonthPicker(
      context: context,
      dismissible: true,
      initialDate: DateTime.utc(selectedYear, selectedMonth),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedYear = date.year;
          selectedMonth = date.month;
        });
        ref.read(recordProvider.notifier).getMonthSummary(date);
      }
    });
  }

  Map<String, List<RecordModel>> getMapEvents(List<RecordModel> recordList) {
    Map<String, List<RecordModel>> events = {};
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
    final sumOfData = ref.watch(recordProvider).sumOfData;
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
          Stack(
            children: [
              Container(
                // color: const Color.fromRGBO(163, 183, 99, 0.5),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          children: [
                            TextSpan(
                              text: '$selectedMonth월',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(color: Colors.blueAccent),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _showMonthPicker();
                                },
                            ),
                            TextSpan(
                                text: '은',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith()),
                            TextSpan(
                              text: ' ${sumOfData.totalHour}시간',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                      // color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          children: [
                            TextSpan(
                              text: '${sumOfData.totalDistance}km',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                      // color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                            ),
                            TextSpan(
                              text: ' 달렸어요',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(
          //     // height: 70,
          //     width: double.infinity,
          //     child: Divider(color: Colors.grey, thickness: 1.0)),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${dateRangeType[activeDateRangeType]}'),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
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
          Container(
            padding: const EdgeInsets.only(bottom: 30),
            height: MediaQuery.of(context).size.height * 0.42,
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: dateList.length,
                itemBuilder: (context, index) {
                  // print('test');
                  // print(recordHistories[index].date);
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
