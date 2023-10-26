import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/screens/new_article.dart';
import 'package:running_mate/widgets/bottom_nav_bar.dart';
import 'package:running_mate/widgets/running_article/article_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _onNewArticle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const NewArticleScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authencatiedUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '오늘의 런닝 (${authencatiedUser != null ? authencatiedUser.displayName : ''})'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onNewArticle(context),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(),
      body: StreamBuilder(
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
            padding: const EdgeInsets.all(20),
            itemCount: loadedArticles.length,
            itemBuilder: (context, index) {
              final loadedArticles =
                  ref.watch(meetingArticleProvider).articleList;
              return ArticleItem(
                article: loadedArticles[index],
              );
            },
          );
        },
      ),
    );
  }
}
