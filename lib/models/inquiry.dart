import 'package:cloud_firestore/cloud_firestore.dart';

class InquiryModel {
  InquiryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.reply,
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic>? reply;

  factory InquiryModel.fromJson(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return InquiryModel(
      id: snapshot.id,
      title: data?['title'],
      content: data?['content'],
      createdAt: (data?['createdAt'] as Timestamp).toDate(),
      reply: data?['reply'] != null
          ? {
              'content': data?['reply']?['content'],
              'savedAt': (data?['reply']?['savedAt'] as Timestamp?)?.toDate(),
            }
          : null,
    );
  }

  // Map<String, dynamic> toJson() => {
  //       'id': id,
  //       'hour': hour,
  //       'miniutes': miniutes,
  //       'distance': distance,
  //       'date': date,
  //       'memo': memo,
  //     };
}
