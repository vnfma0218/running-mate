import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:running_mate/models/inquiry.dart';

class InquiryDetailPage extends StatelessWidget {
  const InquiryDetailPage({super.key, required this.inquiry});
  final InquiryModel inquiry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('문의 상세')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '문의 내용',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '제목',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  inquiry.title,
                ),
                const SizedBox(height: 20),
                const Text(
                  '내용',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  inquiry.content,
                ),
                const SizedBox(height: 15),
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(inquiry.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          if (inquiry.reply != null)
            Container(
              color: Colors.blueAccent.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.subdirectory_arrow_right),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      const Text(
                        '관리자',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(inquiry.reply?['content']),
                      Text(
                        DateFormat('yyyy년 MM월 dd일')
                            .format(inquiry.reply?['savedAt']),
                      ),
                    ],
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
