// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:runex/models/models.dart';

class LocationFirestoreDatabase {
  static const String COLLECTION_NAME = 'location';

  DocumentReference locationDocument =
      FirebaseFirestore.instance.collection(COLLECTION_NAME).doc();
  CollectionReference locationCollection =
      FirebaseFirestore.instance.collection(COLLECTION_NAME);

  Future<FirestoreReturn> create(Location location) {
    return locationDocument.set({
      '_id': location.id,
      'runex_doc_id': location.docId,
      'odometer': location.odometer,
      'altitude': location.altitude,
      'heading': location.heading,
      'latitude': location.latitude,
      'accuracy': location.accuracy,
      'heading_accuracy': location.headingAccuracy,
      'altitude_accuracy': location.altitudeAccuracy,
      'speed_accuracy': location.speedAccuracy,
      'speed': location.speed,
      'longitude': location.longitude,
      'timestamp': location.timestamp,
      'is_moving': location.isMoveing,
      'confidence': location.confidence,
      'type': location.type,
      'is_charging': location.isCharging,
      'level': location.level
    }).then((value) {
      return FirestoreReturn(success: true, data: locationDocument.id);
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
      // return {'success': true, 'data': querySnapshot.docs.toList()};
      return FirestoreReturn(success: true, data: querySnapshot.docs.toList());
    }).catchError((error) {
      return FirestoreReturn(success: false, data: error);
    });
  }

  Future<FirestoreReturn> readByRunexDocId(String runexDocId) {
    return FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.toList().isNotEmpty) {
        return FirebaseFirestore.instance
            .collection(COLLECTION_NAME)
            .where('runex_doc_id', isEqualTo: runexDocId)
            .orderBy('_id')
            .get()
            .then((QuerySnapshot querySnapshotFilter) {
          return FirestoreReturn(
              success: true, data: querySnapshotFilter.docs.toList());
        }).catchError((error) {
          return FirestoreReturn(success: false, data: error);
        });
      } else {
        return FirestoreReturn(success: true, data: []);
      }
    });
  }

  Future<FirestoreReturn> update(Location location) {
    return locationCollection.doc(location.docId).update({
      'odometer': location.odometer,
      'altitude': location.altitude,
      'heading': location.heading,
      'latitude': location.latitude,
      'accuracy': location.accuracy,
      'heading_accuracy': location.headingAccuracy,
      'altitude_accuracy': location.altitudeAccuracy,
      'speed_accuracy': location.speedAccuracy,
      'speed': location.speed,
      'longitude': location.longitude,
      'timestamp': location.timestamp,
      'is_moving': location.isMoveing,
      'confidence': location.confidence,
      'type': location.type,
      'is_charging': location.isCharging,
      'level': location.level
    }).then((value) {
      return FirestoreReturn(success: true, data: location.docId);
    }).catchError((error) {
      return FirestoreReturn(success: false, data: error);
    });
  }

  Future<FirestoreReturn> delete(String docId) {
    return locationCollection.doc(docId).delete().then((value) {
      return FirestoreReturn(success: true, data: docId);
    }).catchError((error) {
      return FirestoreReturn(success: false, data: error);
    });
  }
}
