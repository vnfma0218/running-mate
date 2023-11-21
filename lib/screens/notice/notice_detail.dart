import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:running_mate/models/notice.dart';

class NoticeDetailPage extends StatelessWidget {
  const NoticeDetailPage({super.key, required this.notice});

  final NoticeModel notice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지 사항'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 7),
            Text(
              notice.createdAt,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Divider(
              thickness: 1,
            ),
            const SizedBox(height: 12),
            Html(data: notice.content)
          ],
        ),
      ),
    );
  }
}
