import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/widgets/running_article/board_item.dart';

class ArticleListScreen extends ConsumerWidget {
  const ArticleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('articles').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final loadedArticles = snapshot.data!.docs;
        ref
            .read(meetingArticleProvider.notifier)
            .addArticleList(loadedArticles);

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: loadedArticles.length,
          itemBuilder: (context, index) {
            final loadedArticles =
                ref.watch(meetingArticleProvider).articleList;
            // return ArticleItem(
            //   article: loadedArticles[index],
            // );
            return BoardItem(
              article: loadedArticles[index],
            );
          },
        );
      },
    );
  }
}
