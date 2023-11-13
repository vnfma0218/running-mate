import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/providers/user_provider.dart';
import 'package:running_mate/widgets/running_article/meeting_item.dart';

class MeetHistoriesScreen extends ConsumerStatefulWidget {
  const MeetHistoriesScreen({super.key});

  @override
  ConsumerState<MeetHistoriesScreen> createState() =>
      _MeetHistoriesScreenState();
}

class _MeetHistoriesScreenState extends ConsumerState<MeetHistoriesScreen>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getMeetingHistories();
  }

  void _getMeetingHistories() async {
    final userId = ref.watch(userProvider)!.id;

    final collectionRef = _firestore.collection('articles');
    final myMeetssnapshot =
        await collectionRef.where('user', isEqualTo: userId).get();
    final joinedMeets =
        await collectionRef.where('joinUesrIds', arrayContains: userId).get();

    ref
        .read(meetingArticleProvider.notifier)
        .addMyMeetings(myMeetssnapshot.docs);
    ref
        .read(meetingArticleProvider.notifier)
        .addJoinedMeetings(joinedMeets.docs);
  }

  @override
  Widget build(BuildContext context) {
    final myMeets = ref.watch(meetingArticleProvider).myMeets;
    final joinedMeets = ref.watch(meetingArticleProvider).joinedMeets;
    return Scaffold(
      appBar: AppBar(
        title: const Text('모임 목록'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '참여 목록'),
                Tab(text: '개설 목록'),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    itemCount: joinedMeets.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            MeetingItem(article: joinedMeets[index])
                          ],
                        );
                      }
                      return MeetingItem(article: joinedMeets[index]);
                    },
                  ),
                  ListView.builder(
                    itemCount: myMeets.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            MeetingItem(article: myMeets[index])
                          ],
                        );
                      }
                      return MeetingItem(article: myMeets[index]);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
