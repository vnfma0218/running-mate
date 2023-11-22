import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/widgets/running_article/meeting_item.dart';

class ArticleListScreen extends ConsumerStatefulWidget {
  const ArticleListScreen({super.key});

  @override
  ConsumerState<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends ConsumerState<ArticleListScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? lastDoc;
  bool isMoreData = true;
  bool isLoading = false;
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    paginatedData();

    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        paginatedData();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void paginatedData() async {
    if (!isMoreData || isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final collectionRef = _firestore.collection('articles');
    late QuerySnapshot<Map<String, dynamic>> querySnapshot;
    final now = DateTime.now();
    if (lastDoc == null) {
      querySnapshot = await collectionRef
          .where("timeStampDate",
              isGreaterThanOrEqualTo:
                  DateTime.utc(now.year, now.month, now.day))
          .orderBy("timeStampDate", descending: true)
          .limit(10)
          .get();
      ref.watch(meetingArticleProvider.notifier).resetArticleList();
    } else {
      querySnapshot = await collectionRef
          .where("timeStampDate",
              isGreaterThanOrEqualTo:
                  DateTime.utc(now.year, now.month, now.day))
          .limit(10)
          .startAfterDocument(lastDoc!)
          .get();
    }

    if (querySnapshot.docs.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    ref
        .read(meetingArticleProvider.notifier)
        .addRemoteArticleList(querySnapshot.docs);

    isLoading = false;
    lastDoc = querySnapshot.docs.last;
    if (querySnapshot.docs.length < 6) {
      isMoreData = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final articleList = ref.watch(meetingArticleProvider).articleList;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              ref.watch(meetingArticleProvider.notifier).resetArticleList();
              isMoreData = true;
              lastDoc = null;
              paginatedData();
              return Future<void>.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ),
              itemCount: articleList.length,
              itemBuilder: (context, index) {
                return MeetingItem(
                  article: articleList[index],
                );
              },
            ),
          ),
        ),
        isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const SizedBox(),
      ],
    );
  }
}
