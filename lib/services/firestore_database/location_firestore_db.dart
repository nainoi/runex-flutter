// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert' as convert;
import 'package:runex/models/models.dart';

class LocationFirestoreDatabase {
  static const String COLLECTION_NAME = 'location';

  DocumentReference locationDocument =
      FirebaseFirestore.instance.collection(COLLECTION_NAME).doc();
  CollectionReference locationCollection =
      FirebaseFirestore.instance.collection(COLLECTION_NAME);

  Future create(Location location) {
    return locationDocument.set({
      '_id': location.id,
      'runex_doc_id': locationDocument.id,
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

  Future update(Location location) {
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
      return {'success': true, 'data': value};
    }).catchError((error) {
      return {'success': false, 'data': error};
    });
  }

  Future delete(String docId) {
    return locationCollection.doc(docId).delete().then((value) {
      return {'success': true, 'data': value};
    }).catchError((error) {
      return {'success': false, 'data': error};
    });
  }
}
