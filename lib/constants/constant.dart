import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:running_mate/screens/calendar/event.dart';
import 'package:running_mate/screens/my_page/inquiry.dart';
import 'package:running_mate/screens/my_page/meet_histories.dart';
import 'package:running_mate/screens/my_page/record_histories.dart';
import 'package:running_mate/screens/notice/notice_list.dart';
import 'package:table_calendar/table_calendar.dart';

const userDefaultImgPath =
    'https://firebasestorage.googleapis.com/v0/b/running-mate-c7ed4.appspot.com/o/files%2Favatar-default.png?alt=media&token=5bdf3fb9-93ea-4a6e-8ddd-fa024654a756';

const emailRepex = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
    r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
    r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
    r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
    r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
    r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
    r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';

const nicknameRegex = r"^(?=.*[a-z0-9가-힣])[a-z0-9가-힣]{2,16}$";

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 3, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month, kToday.day);

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final _kEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}'))
}..addAll({
    kToday: [
      Event('Today\'s Event 1'),
      Event('Today\'s Event 2'),
    ],
  });

enum ResultCodeType {
  success(200, 'success'),
  fail(400, 'fail');

  const ResultCodeType(this.code, this.value);

  final int code;
  final String value;
}

final List<Map<String, dynamic>> kMyPageMenus = [
  {
    "name": '모임 목록',
    "iocn": const Icon(
      Icons.run_circle_outlined,
      size: 30,
    ),
    "router": const MeetHistoriesScreen()
  },
  {
    "name": '기록 관리',
    "iocn": const Icon(
      Icons.article_outlined,
      size: 30,
    ),
    "router": const RecordHistoriesScreen()
  },
  {
    "name": '공지 사항',
    "iocn": const Icon(
      Icons.announcement_outlined,
      size: 30,
    ),
    "router": const NoticeListPage()
  },
  {
    "name": '문의 하기',
    "iocn": const Icon(
      Icons.mail_outlined,
      size: 30,
    ),
    "router": const InquiryPage()
  },
];
