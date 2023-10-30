import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/widgets/running_article/board_item.dart';

class ArticleListScreen extends ConsumerStatefulWidget {
  const ArticleListScreen({super.key});

  @override
  ConsumerState<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends ConsumerState<ArticleListScreen> {
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
    if (!isMoreData) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    final collectionRef = _firestore.collection('articles');

    late QuerySnapshot<Map<String, dynamic>> querySnapshot;

    if (lastDoc == null) {
      querySnapshot = await collectionRef.limit(6).get();
    } else {
      querySnapshot =
          await collectionRef.limit(6).startAfterDocument(lastDoc!).get();
    }

    ref
        .watch(meetingArticleProvider.notifier)
        .addArticleList(querySnapshot.docs);

    isLoading = false;
    setState(() {});

    lastDoc = querySnapshot.docs.last;
    if (querySnapshot.docs.length < 6) {
      isMoreData = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final articleList = ref.watch(meetingArticleProvider).articleList;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: controller,
            padding: const EdgeInsets.all(10),
            itemCount: articleList.length,
            itemBuilder: (context, index) {
              final loadedArticles =
                  ref.watch(meetingArticleProvider).articleList;

              return BoardItem(
                article: loadedArticles[index],
              );
            },
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
