import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:running_mate/models/user.dart';

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
    this.joinPeople,
    this.joinUsers,
    this.limitPeople,
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

  factory MeetingArticle.fromJson(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final json = snapshot.data();
    Timestamp createdAt =
        json?['createdAt'] ?? Timestamp.fromDate(DateTime.now());

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
      // limitPeople: int.parse(json?['limitPeople']),
      limitPeople: 2,
      address: Address(
        formattedAddress: json?['location']['formattedAddress'],
        title: json?['location']['name'],
        lat: json?['location']['lat'],
        lng: json?['location']['lng'],
      ),
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
