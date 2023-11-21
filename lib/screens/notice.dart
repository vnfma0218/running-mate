import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/providers/notice_provider.dart';

class NoticeListPage extends ConsumerStatefulWidget {
  const NoticeListPage({super.key});

  @override
  ConsumerState<NoticeListPage> createState() => _NoticeListPageState();
}

class _NoticeListPageState extends ConsumerState<NoticeListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final noticeList = ref.watch(noticeProvider);
    Widget content = const Center(
      child: CircularProgressIndicator(),
    );
    if (noticeList.isNotEmpty) {
      content = ListView.builder(
        itemCount: noticeList.length,
        itemBuilder: (context, index) {
          return Text(noticeList[index].title);
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지 사항'),
      ),
      body: content,
    );
  }
}
