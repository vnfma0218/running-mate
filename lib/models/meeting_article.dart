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
  });

  final String id;
  final String title;
  final String desc;
  Address? address;
  final String user;
  final String date;
  final String time;
  Timestamp? createdAt;
}

class Address {
  Address(this.name, this.lat, this.lng);

  final String name;
  final double lat;
  final double lng;
}
