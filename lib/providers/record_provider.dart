import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/record.dart';
import 'package:running_mate/providers/user_provider.dart';

class DateRange {
  DateRange({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;
}

class RecordProviderState {
  RecordProviderState(
      {required this.recordList,
      required this.recordHistories,
      required this.dateRange});
  final List<RecordModel> recordList;
  final List<RecordModel> recordHistories;
  final DateRange dateRange;
}

class RecordNotifier extends StateNotifier<RecordProviderState> {
  RecordNotifier(this.userId)
      : super(RecordProviderState(
          recordList: [],
          recordHistories: [],
          dateRange:
              DateRange(startDate: DateTime.now(), endDate: DateTime.now()),
        ));
  final String userId;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime date = DateTime.now();

  void setDateRange(DateRange dateRange) {
    state = RecordProviderState(
      recordList: state.recordList,
      recordHistories: state.recordHistories,
      dateRange: dateRange,
    );
  }

  Future saveRecord(RecordModel recordModel) async {
    List<RecordModel> recordList = [];
    if (recordModel.id != null) {
      await firestore
          .collection("records")
          .doc(recordModel.id)
          .set({...recordModel.toJson(), 'user': userId});

      state.recordList[state.recordList
          .indexWhere((element) => element.id == recordModel.id)] = recordModel;
      recordList = [...state.recordList];
    } else {
      final document = await firestore
          .collection("records")
          .add({...recordModel.toJson(), 'user': userId});
      recordModel.id = document.id;
      recordList = [...state.recordList, recordModel];
    }

    state = RecordProviderState(
      recordList: recordList,
      recordHistories: state.recordHistories,
      dateRange: state.dateRange,
    );
  }

  void fetchRecordHistories(DateTime start, DateTime end) async {
    final loadedRecords = await firestore
        .collection('records')
        .where('user', isEqualTo: userId)
        .where("date",
            isGreaterThanOrEqualTo:
                DateTime(start.year, start.month, start.day))
        .where("date",
            isLessThanOrEqualTo: DateTime(end.year, end.month, end.day))
        .get();

    final recordList = loadedRecords.docs.map((record) {
      final data = record.data();
      data['id'] = record.id;
      return RecordModel.fromJson(data);
    }).toList();

    final startDate = DateTime.utc(date.year, date.month, 1);
    final endDate = DateTime.utc(date.year, date.month, date.day);

    state = RecordProviderState(
      recordList: state.recordList,
      recordHistories: recordList,
      dateRange: DateRange(startDate: startDate, endDate: endDate),
    );
  }

  void fetchCalendarRecords(DateTime? datetime) async {
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
      recordHistories: state.recordHistories,
      dateRange: state.dateRange,
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
      recordHistories: state.recordHistories,
      dateRange: state.dateRange,
    );
    return resultCode;
  }
}

final recordProvider =
    StateNotifierProvider<RecordNotifier, RecordProviderState>((ref) {
  return RecordNotifier(ref.watch(userProvider)!.id);
});
