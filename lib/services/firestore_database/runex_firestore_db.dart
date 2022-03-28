// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:runex/models/models.dart';

class RunexFirestoreDatabase {
  static const String COLLECTION_NAME = 'runex';

  DocumentReference runexDocument =
      FirebaseFirestore.instance.collection(COLLECTION_NAME).doc();
  CollectionReference runexCollection =
      FirebaseFirestore.instance.collection(COLLECTION_NAME);

  Future<FirestoreReturn> create(Runex runex) {
    return runexDocument.set({
      'provider_id': runex.providerId,
      'start_time': runex.startTime,
      'end_time': runex.endTime,
      'distance_total_km': runex.distanceKm,
      'time_total_hours': runex.timeHrs,
      '_doc_id': runexDocument.id,
      'is_saved': runex.isSaved,
      'month_and_year': runex.monthAndYear,
      'pace': runex.pace,
      'calories': runex.calories
    }).then((value) {
      return FirestoreReturn(success: true, data: runexDocument.id);
    }).catchError((error) {
      return FirestoreReturn(success: false, data: error);
    });
  }

  Future<FirestoreReturn> read() {
    return FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .get()
        .then((QuerySnapshot querySnapshot) {
      // dynamic json = convert.jsonDecode(querySnapshot.docs.toList().toString());
      // List<Runex> runex = json.map((e) => Runex.fromJson(e)).toList();
      return FirestoreReturn(success: true, data: querySnapshot.docs.toList());
    }).catchError((error) {
      return FirestoreReturn(success: false, data: error);
    });
  }

  Future<FirestoreReturn> readByProviderId(String providerId) {
    return FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .where('provider_id', isEqualTo: providerId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      return FirestoreReturn(success: true, data: querySnapshot.docs.toList());
    }).catchError((error) {
      return FirestoreReturn(success: false, data: error);
    });
  }

  Future<FirestoreReturn> readByMonthAndYear(String providerId) {
    var runexCountMap = Map();
    var distanceMap = Map();
    var timeMap = Map();
    var calMap = Map();

    return FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .where(
          'provider_id',
          isEqualTo: providerId,
        )
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.map((e) {
        if (!distanceMap.containsKey(e['month_and_year'])) {
          distanceMap[e['month_and_year']] = 0.0;
          distanceMap[e['month_and_year']] += e['distance_total_km'];

          timeMap[e['month_and_year']] = 0.0;
          timeMap[e['month_and_year']] += e['time_total_hours'];

          runexCountMap[e['month_and_year']] = 1;

          calMap[e['month_and_year']] = 0.0;
          calMap[e['month_and_year']] += e['calories'];
        } else {
          distanceMap[e['month_and_year']] += e['distance_total_km'];
          timeMap[e['month_and_year']] += e['time_total_hours'];
          calMap[e['month_and_year']] += e['calories'];
          runexCountMap[e['month_and_year']] += 1;
        }
      }).toList();
      final runexCountList = runexCountMap.keys.toList();
      final runexCountValuesList = runexCountMap.values.toList();
      final distanceList = distanceMap.values.toList();
      final timeList = timeMap.values.toList();
      final caloriesList = calMap.values.toList();
      List<MonthAndYear> monthAndYear = [];
      for (var i = 0; i < runexCountList.length; i++) {
        monthAndYear.add(MonthAndYear(
            monthAndYear: runexCountList[i],
            runexCount: runexCountValuesList[i],
            distanceTotal: distanceList[i],
            timeTotal: timeList[i],
            caloriesTotal: caloriesList[i]));
      }
      return FirestoreReturn(success: true, data: monthAndYear);
    }).catchError((error) {
      return FirestoreReturn(success: false, data: error);
    });
  }

  Future<FirestoreReturn> update(String docId, bool isSaved) {
    return runexCollection
        .doc(docId)
        .update({'is_saved': isSaved}).then((value) {
      return FirestoreReturn(success: true, data: docId);
    }).catchError((error) {
      return FirestoreReturn(success: false, data: error);
    });
  }

  Future<FirestoreReturn> delete(String docId) {
    return runexCollection.doc(docId).delete().then((value) {
      return FirestoreReturn(success: true, data: docId);
    }).catchError((error) {
      return FirestoreReturn(success: false, data: error);
    });
  }
}
