import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/inquiry.dart';
import 'package:running_mate/providers/inquiry_provider.dart';

class InquiryPage extends ConsumerStatefulWidget {
  const InquiryPage({super.key});

  @override
  ConsumerState<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends ConsumerState<InquiryPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final inqList = ref.watch(inquiryListProvider(null));
    return Scaffold(
      appBar: AppBar(title: const Text('1:1 문의관리')),
      body: inqList.when(
        data: (data) {
          final replyCompleteList =
              data.where((inq) => inq.reply != null).toList();
          final replyWatingList =
              data.where((inq) => inq.reply == null).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: '답변 완료(${replyCompleteList.length})'),
                    Tab(text: '답변 완료(${replyWatingList.length})'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      InquiryCardList(
                        inqList: replyCompleteList,
                      ),
                      InquiryCardList(
                        inqList: replyWatingList,
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
        error: (error, stackTrace) {
          return const Center(
            child: Text('Uh oh. Something went wrong!'),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class InquiryCardList extends StatelessWidget {
  const InquiryCardList({super.key, required this.inqList});
  final List<InquiryModel> inqList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: inqList.length,
      itemBuilder: (context, index) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        inqList[index].title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '문의일',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            inqList[index]
                                .createdAt
                                .toIso8601String()
                                .split('T')
                                .first,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      if (inqList[index].reply != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '답변일',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              inqList[index]
                                  .reply?['savedAt']
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 40),
                      if (inqList[index].reply != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                                onPressed: () {}, child: const Text('답변 확인')),
                            const SizedBox(height: 5),
                          ],
                        )
                    ],
                  ),
                ],
              ),
            )),
          ),
        );
      },
    );
  }
}
