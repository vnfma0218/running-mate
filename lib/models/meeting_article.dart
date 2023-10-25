import 'package:cloud_firestore/cloud_firestore.dart';

class MettingArticle {
  const MettingArticle({
    required this.title,
    required this.desc,
    required this.address,
    required this.user,
    required this.createdAt,
    required this.date,
    required this.time,
  });

  final String title;
  final String desc;
  final Address address;
  final String user;
  final String date;
  final String time;
  final Timestamp createdAt;
}

class Address {
  Address(this.name, this.lat, this.lng);

  final String name;
  final double lat;
  final double lng;
}
