import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.limitPeople,
  });

  final String id;
  final String title;
  final String desc;
  Address? address;
  final String user;
  final String date;
  final String time;
  final int distance;
  int? limitPeople;
  Timestamp? createdAt;
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
