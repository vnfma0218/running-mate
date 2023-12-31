import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/models/user.dart';

class ArticleState {
  ArticleState({
    required this.updateArticle,
    required this.articleList,
    required this.joinedMeets,
    required this.myMeets,
  });
  MeetingArticle updateArticle;
  List<MeetingArticle> articleList;
  List<MeetingArticle> myMeets;
  List<MeetingArticle> joinedMeets;
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
            distance: 0,
            limitPeople: 0,
          ),
          articleList: [],
          myMeets: [],
          joinedMeets: [],
        ));

  void addUpdateArticle(MeetingArticle article) {
    state.updateArticle = article;
    final newArticleList = [...state.articleList];
    newArticleList[newArticleList
        .indexWhere((element) => element.id == article.id)] = article;

    state = ArticleState(
      updateArticle: state.updateArticle,
      articleList: newArticleList,
      myMeets: state.myMeets,
      joinedMeets: state.joinedMeets,
    );
  }

  void resetUpdatingArticle() {
    final resetArticle = MeetingArticle(
      id: '',
      title: '',
      desc: '',
      user: '',
      date: '',
      time: '',
      distance: 0,
      limitPeople: 0,
    );
    state = ArticleState(
      updateArticle: resetArticle,
      articleList: state.articleList,
      myMeets: state.myMeets,
      joinedMeets: state.joinedMeets,
    );
  }

  void updateArticleList(MeetingArticle article) {
    final newList = [...state.articleList];
    newList[newList.indexWhere((element) => element.id == article.id)] =
        article;
    state = ArticleState(
      updateArticle: article,
      articleList: newList,
      myMeets: state.myMeets,
      joinedMeets: state.joinedMeets,
    );
  }

  void resetArticleList() {
    state.articleList = [];
  }

  void deleteArticle(int index) {
    final deletedList = [...state.articleList];
    deletedList.removeAt(index);
    state = ArticleState(
      updateArticle: state.updateArticle,
      articleList: deletedList.toList(),
      myMeets: state.myMeets,
      joinedMeets: state.joinedMeets,
    );
  }

  void addCreatedArticle(MeetingArticle article) {
    final articleList = [article, ...state.articleList];
    articleList.sort((a, b) => a.meetDatetime!.compareTo(b.meetDatetime!));

    state = ArticleState(
      updateArticle: state.updateArticle,
      articleList: articleList,
      myMeets: state.myMeets,
      joinedMeets: state.joinedMeets,
    );
  }

  void addMyMeetings(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedArticles) {
    final myMeets = fromJson(loadedArticles);
    state = ArticleState(
        updateArticle: state.updateArticle,
        articleList: state.articleList,
        myMeets: myMeets,
        joinedMeets: state.joinedMeets);
  }

  void addJoinedMeetings(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedArticles) {
    final joinedMeets = fromJson(loadedArticles);
    state = ArticleState(
      updateArticle: state.updateArticle,
      articleList: state.articleList,
      myMeets: state.myMeets,
      joinedMeets: joinedMeets,
    );
  }

  void addRemoteArticleList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedArticles) {
    List<MeetingArticle> newArticles = fromJson(loadedArticles);

    newArticles = newArticles
        .where((element) => element.status != ArticleStatus.stop.index)
        .toList();

    state = ArticleState(
      updateArticle: state.updateArticle,
      articleList: [...state.articleList, ...newArticles],
      myMeets: state.myMeets,
      joinedMeets: state.joinedMeets,
    );
  }
}

fromJson(List<QueryDocumentSnapshot<Map<String, dynamic>>> articles) {
  final newArticles = articles.map(
    (e) {
      final data = e.data();
      final id = e.id;
      Timestamp createdAt =
          data['createdAt'] ?? Timestamp.fromDate(DateTime.now());
      DateTime meetDatetime = data['timeStampDate'].toDate();
      return MeetingArticle(
        id: id,
        user: data['user'],
        title: data['title'],
        desc: data['desc'],
        time: data['time'],
        date: data['date'],
        joinUsers: data['joinUsers'] != null
            ? List<String>.from(data['joinUsers'])
            : null,
        status: data['status'] ?? 1,
        joinPeople: data['joinPeople'] != null
            ? (data['joinPeople'] as List<dynamic>)
                .map((e) => JoinUserModel(
                      id: e['id'],
                      imageUrl: e['imageUrl'],
                      name: e['name'],
                    ))
                .toList()
            : null,
        distance: int.parse(data['distance']),
        limitPeople: data['limitPeople'].toString().isEmpty
            ? null
            : int.parse(data['limitPeople']),
        createdAt: createdAt,
        address: Address(
          formattedAddress: data['location']['formattedAddress'],
          title: data['location']['name'],
          lat: data['location']['lat'],
          lng: data['location']['lng'],
        ),
        meetDatetime: meetDatetime,
      );
    },
  ).toList();
  return newArticles;
}

final meetingArticleProvider =
    StateNotifierProvider<MeetingArticleNotifier, ArticleState>((ref) {
  return MeetingArticleNotifier();
});

typedef ArticleDetailParameters = ({String id});

final articleDetailProvider = FutureProvider.autoDispose
    // We now use the newly defined record as the argument type.
    .family<MeetingArticle, ArticleDetailParameters>((ref, arguments) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final snapshot =
      await firestore.collection('articles').doc(arguments.id).get();
  MeetingArticle articleItem = MeetingArticle.fromJson(snapshot, null);
  List<JoinUserModel> users = [];

  if (articleItem.joinUsers != null) {
    for (var id in articleItem.joinUsers!) {
      final user = await firestore.collection('users').doc(id).get();
      var joinUser = user.data();
      joinUser!['id'] = id;

      users.add(JoinUserModel.fromJson(joinUser));
    }
  }
  articleItem.joinPeople = users;

  return articleItem;
});
