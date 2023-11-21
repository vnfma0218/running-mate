import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  NoticeModel(
      {required this.id,
      required this.title,
      required this.content,
      required this.createdAt});

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  factory NoticeModel.fromJson(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final json = snapshot.data();
    Timestamp createdAt = json?['createdAt'];

    return NoticeModel(
      id: snapshot.id,
      title: json?['title'],
      content: json?['content'],
      createdAt: createdAt.toDate(),
    );
  }
}
