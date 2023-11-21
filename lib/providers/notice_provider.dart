import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/notice.dart';

class NoticeProviderNotifier extends StateNotifier<List<NoticeModel>> {
  NoticeProviderNotifier() : super([]);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addNoticeList() {
    List<NoticeModel> noticeList = [];
    _firestore.collection('notices').get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          NoticeModel notice = NoticeModel.fromJson(docSnapshot, null);
          noticeList.add(notice);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    state = noticeList;
  }
}

final noticeProvider =
    StateNotifierProvider<NoticeProviderNotifier, List<NoticeModel>>((ref) {
  return NoticeProviderNotifier();
});
