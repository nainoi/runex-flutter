// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert' as convert;
import 'package:runex/models/models.dart';

class RunexFirestoreDatabase {

  static const String COLLECTION_NAME = 'runex';
  
  DocumentReference runexDocument =
      FirebaseFirestore.instance.collection(COLLECTION_NAME).doc();
  CollectionReference runexCollection =
      FirebaseFirestore.instance.collection(COLLECTION_NAME);

  Future create(Runex runex) {
    return runexDocument.set({
      'provider_id': runex.providerId,
      'start_time': runex.startTime,
      'end_time': runex.endTime,
      'distance_total_km': runex.distanceKm,
      'time_total_hours': runex.timeHrs,
      '_doc_id': runexDocument.id
    }).then((value) {
      return {'success': true, 'data': value};
    }).catchError((error) {
      return {'success': false, 'data': error};
    });
  }

  Future read() {
    return FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .get()
        .then((QuerySnapshot querySnapshot) {
      // dynamic json = convert.jsonDecode(querySnapshot.docs.toList().toString());
      // List<Runex> runex = json.map((e) => Runex.fromJson(e)).toList();
      return {'success': true, 'data': querySnapshot.docs.toList()};
    }).catchError((error) {
      return convert.jsonDecode("{'success': ${false}, 'data': $error}");
    });
  }

  Future readByProviderId(String providerId) {
    return FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .where('provider_id', isEqualTo: providerId)
        .orderBy('_id')
        .get()
        .then((QuerySnapshot querySnapshot) {
      return {'success': true, 'data': querySnapshot.docs.toList()};
    }).catchError((error) {
      return convert.jsonDecode("{'success': ${false}, 'data': $error}");
    });
  }

  Future update(Runex runex) {
    return runexCollection.doc(runex.docId).update({
      'start_time': runex.startTime,
      'end_time': runex.endTime,
      'distance_total_km': runex.distanceKm,
      'time_total_hours': runex.timeHrs,
    }).then((value) {
      return {'success': true, 'data': value};
    }).catchError((error) {
      return {'success': false, 'data': error};
    });
  }

  Future delete(String docId) {
    return runexCollection.doc(docId).delete().then((value) {
      return {'success': true, 'data': value};
    }).catchError((error) {
      return {'success': false, 'data': error};
    });
  }
}
