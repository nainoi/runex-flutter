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
      'month_and_year': runex.monthAndYear

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
        // .orderBy('_id')
        .get()
        .then((QuerySnapshot querySnapshot) {
      return FirestoreReturn(success: true, data: querySnapshot.docs.toList());
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
