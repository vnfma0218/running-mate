import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/inquiry.dart';

typedef ArticleDetailParameters = ({String id});

final inquiryListProvider = FutureProvider.autoDispose
    .family<List<InquiryModel>, ArticleDetailParameters?>(
        (ref, arguments) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final snapshots = await firestore.collection('inquiries').get();
  List<InquiryModel> inquiryList = [];
  for (var snapshot in snapshots.docs) {
    inquiryList.add(InquiryModel.fromJson(snapshot));
  }

  return inquiryList;
});
