class Location {
  final int? id;
  final int runexId;
  final String? docId;

  final double odometer;
  // Coords
  final double altitude;
  final double heading;
  final double latitude;
  final double accuracy;
  final double headingAccuracy;
  final double altitudeAccuracy;
  final double speedAccuracy;
  final double speed;
  final double longitude;
  // Coords

  final String timestamp;
  final bool isMoveing;

  // Activity
  final int confidence;
  final String type;

  // Battery
  final bool isCharging;
  final double level;

  Location(
      {this.id,
      required this.runexId,
      this.docId,
      required this.odometer,
      required this.altitude,
      required this.heading,
      required this.latitude,
      required this.accuracy,
      required this.headingAccuracy,
      required this.altitudeAccuracy,
      required this.speedAccuracy,
      required this.speed,
      required this.longitude,
      required this.timestamp,
      required this.isMoveing,
      required this.confidence,
      required this.type,
      required this.isCharging,
      required this.level});

  // ignore: unnecessary_new
  factory Location.fromJson(Map<String, dynamic> json) => new Location(
      id: json['_id'],
      runexId: json['runex_id'],
      docId: json['runex_doc_id'],
      odometer: double.parse(json['odometer']),
      altitude: double.parse(json['altitude']),
      heading: double.parse(json['heading']),
      latitude: double.parse(json['latitude']),
      accuracy: double.parse(json['accuracy']),
      headingAccuracy: double.parse(json['heading_accuracy']),
      altitudeAccuracy: double.parse(json['altitude_accuracy']),
      speedAccuracy:  double.parse(json['speed_accuracy']),
      speed: double.parse(json['speed']),
      longitude: double.parse(json['longitude']),
      timestamp: json['timestamp'],
      isMoveing: json['is_moving'] == 1,
      confidence:  json['confidence'],
      type: json['type'],
      isCharging: json['is_charging'] == 1,
      level:  double.parse(json['level']));

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'runex_id': runexId,
      'runex_doc_id': docId,
      'odometer': odometer,
      'altitude': altitude,
      'heading': heading,
      'latitude': latitude,
      'accuracy': accuracy,
      'heading_accuracy': headingAccuracy,
      'altitude_accuracy': altitudeAccuracy,
      'speed_accuracy': speedAccuracy,
      'speed': speed,
      'longitude': longitude,
      'timestamp': timestamp,
      'is_moving': isMoveing ? 1 : 0,
      'confidence': confidence,
      'type': type,
      'is_charging': isCharging ? 1 : 0,
      'level': level
    };
  }
}
