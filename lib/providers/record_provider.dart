import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/record.dart';
import 'package:running_mate/providers/user_provider.dart';

class RecordProviderState {
  RecordProviderState({required this.recordList});
  final List<RecordModel> recordList;
}

class RecordNotifier extends StateNotifier<RecordProviderState> {
  RecordNotifier(this.userId) : super(RecordProviderState(recordList: []));
  final String userId;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future saveRecord(RecordModel recordModel) async {
    await firestore
        .collection("records")
        .doc(recordModel.id)
        .set({...recordModel.toJson(), 'user': userId});

    List<RecordModel> recordList = [];
    if (recordModel.id != null) {
      state.recordList[state.recordList
          .indexWhere((element) => element.id == recordModel.id)] = recordModel;
      recordList = [...state.recordList];
    } else {
      recordList = [...state.recordList, recordModel];
    }

    state = RecordProviderState(recordList: recordList);
  }

  void fetchRecords(DateTime? datetime) async {
    final date = datetime ?? DateTime.now();
    final loadedRecords = await firestore
        .collection('records')
        .where('user', isEqualTo: userId)
        .where("date",
            isGreaterThanOrEqualTo: DateTime(date.year, date.month - 1, 1))
        .where("date",
            isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 1))
        .get();

    final recordList = loadedRecords.docs.map((record) {
      final data = record.data();
      data['id'] = record.id;
      return RecordModel.fromJson(data);
    }).toList();
    state = RecordProviderState(
      recordList: recordList,
    );
  }

  Future<int> deleteRecord(String id) async {
    int resultCode = 400;
    await firestore.collection("records").doc(id).delete().then(
      (doc) {
        resultCode = 200;
      },
      onError: (e) => resultCode = 400,
    );
    var newList = [...state.recordList];
    newList.removeWhere((element) => element.id == id);
    state = RecordProviderState(
      recordList: newList,
    );
    return resultCode;
  }
}

final recordProvider =
    StateNotifierProvider<RecordNotifier, RecordProviderState>((ref) {
  return RecordNotifier(ref.watch(userProvider)!.id);
});
