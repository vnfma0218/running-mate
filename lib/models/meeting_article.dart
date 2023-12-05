import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:running_mate/models/user.dart';

enum ArticleStatus { _, normal, stop }

class MeetingArticle {
  MeetingArticle({
    required this.id,
    required this.title,
    required this.desc,
    this.address,
    required this.user,
    this.createdAt,
    required this.date,
    required this.time,
    required this.distance,
    this.meetDatetime,
    this.joinPeople,
    this.joinUsers,
    this.limitPeople,
    this.status,
  });

  final String id;
  final String title;
  final String desc;
  Address? address;
  List<JoinUserModel>? joinPeople;
  List<String>? joinUsers;
  final String user;
  final String date;
  final String time;
  final int distance;
  int? limitPeople;
  Timestamp? createdAt;
  DateTime? meetDatetime;
  int? status;

  factory MeetingArticle.fromJson(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final json = snapshot.data();
    Timestamp createdAt =
        json?['createdAt'] ?? Timestamp.fromDate(DateTime.now());
    DateTime meetDatetime = json?['timeStampDate'].toDate();
    return MeetingArticle(
      id: snapshot.id,
      title: json?['title'],
      desc: json?['desc'],
      user: json?['user'],
      createdAt: createdAt,
      distance: int.parse(json?['distance']),
      time: json?['time'],
      date: json?['date'],
      joinUsers: json?['joinUsers'] != null
          ? List<String>.from(json?['joinUsers'])
          : null,
      joinPeople: json?['joinPeople'] != null
          ? (json?['joinPeople'] as List<dynamic>)
              .map((e) => JoinUserModel(
                    id: e['id'],
                    imageUrl: e['imageUrl'],
                    name: e['name'],
                  ))
              .toList()
          : null,
      limitPeople: json?['limitPeople'] != null &&
              json!['limitPeople'].toString().isEmpty
          ? null
          : int.parse(json?['limitPeople']),
      status: json?['status'] ?? 1,
      address: Address(
        formattedAddress: json?['location']['formattedAddress'],
        title: json?['location']['name'],
        lat: json?['location']['lat'],
        lng: json?['location']['lng'],
      ),
      meetDatetime: meetDatetime,
    );
  }
}

class Address {
  Address(
      {required this.title,
      required this.lat,
      required this.lng,
      required this.formattedAddress});

  final String title;
  final double lat;
  final double lng;
  final String formattedAddress;
}

class Report {
  Report(
      {required this.id,
      required this.articleId,
      required this.createdAt,
      required this.count});

  final String id;
  final String articleId;
  final DateTime createdAt;
  final Map<String, num> count;

  factory Report.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final Map<String, num> count = {
      'abuseContent': data?['count']['abuseContent'],
      'etc': data?['count']['etc'],
      'marketingContent': data?['count']['marketingContent'],
      'sexualContent': data?['count']['sexualContent'],
    };
    return Report(
      id: snapshot.id,
      articleId: data?['articleId'],
      count: count,
      createdAt: data?['createdAt'].toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "articleId": articleId,
      "count": count,
      "createdAt": createdAt,
    };
  }
}
