import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/meeting_article.dart';

class ArticleState {
  ArticleState({required this.updateArticle, required this.articleList});
  MeetingArticle updateArticle;
  List<MeetingArticle> articleList;
}

class MeetingArticleNotifier extends StateNotifier<ArticleState> {
  MeetingArticleNotifier()
      : super(ArticleState(
            updateArticle: MeetingArticle(
              id: '',
              title: '',
              desc: '',
              user: '',
              date: '',
              time: '',
            ),
            articleList: []));

  void addUpdateArticle(MeetingArticle article) {
    state.updateArticle = article;
  }

  void updateArticleList(MeetingArticle article) {
    final newList = [...state.articleList];
    newList[newList.indexWhere((element) => element.id == article.id)] =
        article;

    state.articleList = newList;
    // foods[foods.indexWhere((element) => element.uid == food.uid)] = food;
  }

  void addArticleList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedArticles) {
    state.articleList = loadedArticles.map(
      (e) {
        final data = e.data();
        final id = e.id;
        Timestamp createdAt =
            data['createdAt'] ?? Timestamp.fromDate(DateTime.now());
        return MeetingArticle(
          id: id,
          user: data['user'],
          title: data['title'],
          desc: data['desc'],
          time: data['time'],
          date: data['date'],
          createdAt: createdAt,
          address: Address(data['location']['name'], data['location']['lat'],
              data['location']['lng']),
        );
      },
    ).toList();
  }
}

final meetingArticleProvider =
    StateNotifierProvider<MeetingArticleNotifier, ArticleState>((ref) {
  return MeetingArticleNotifier();
});
