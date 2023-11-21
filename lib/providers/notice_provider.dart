import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/notice.dart';

final noticeProvider = FutureProvider.autoDispose((ref) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('notices').get();

  final noticeList = snapshot.docs.map((docSnapshot) {
    return NoticeModel.fromJson(docSnapshot, null);
  }).toList();

  return noticeList;
});
