import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/screens/new_article.dart';
import 'package:running_mate/widgets/bottom_nav_bar.dart';
import 'package:running_mate/widgets/running_article/article_item.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: loadedArticles.length,
            itemBuilder: (context, index) {
              var data = loadedArticles[index].data();
              Timestamp createdAt =
                  data['createdAt'] ?? Timestamp.fromDate(DateTime.now());
              final article = MettingArticle(
                user: data['user'],
                title: data['title'],
                desc: data['desc'],
                time: data['time'],
                date: data['date'],
                createdAt: createdAt,
                // createdAt: Timestamp.fromDate(DateTime.now()),
                address: Address(data['location']['name'],
                    data['location']['lat'], data['location']['lng']),
              );
              return ArticleItem(
                article: article,
              );
            },
          );
        },
      ),
    );
  }
}
