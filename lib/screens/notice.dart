import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/providers/notice_provider.dart';

class NoticeListPage extends ConsumerWidget {
  const NoticeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeList = ref.watch(noticeProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('공지 사항'),
        ),
        body: noticeList.when(
          data: (data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data[index].title,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      data[index].createdAt,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    const Divider(
                      thickness: 1,
                    )
                  ],
                ),
              );
            },
          ),
          error: (error, stackTrace) => const Center(
            child: Text('Uh oh. Something went wrong!'),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }
}
