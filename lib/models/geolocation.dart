// ignore_for_file: unused_label, unnecessary_new

class Geolocation {
  final double? odometer;
  final Activity? activity;
  final String? extras;
  final String? event;
  final Battery? battery;
  final String? uuid;
  final Coords? coords;
  final bool? isMoving;
  final String? timestamp;

  Geolocation(
      {this.odometer,
      this.activity,
      this.extras,
      this.event,
      this.battery,
      this.uuid,
      this.coords,
      this.isMoving,
      this.timestamp});

  factory Geolocation.fromJson(Map<String, dynamic> json) => new Geolocation(
    odometer: json['odometer'],
    activity: json['activity'] ?? new Activity.fromJson(json['activity']),
    extras: json['extras'],
    event: json['event'],
    battery: json['battery'] ?? new Battery.fromJson(json['battery']),
    uuid: json['uuid'],
    coords: json['coords'] ?? new Coords.fromJson(json['coords']),
    isMoving: json['isMoving'],
    timestamp: json['timestamp'],

  );
}

class Activity {
  final double? confidence;
  final String? type;

  Activity({this.confidence, this.type});

  factory Activity.fromJson(Map<String, dynamic> json) =>
      new Activity(confidence: json['confidence'], type: json['type']);

  Map<String, dynamic> toJson() {
    return {'confidence': confidence, 'type': type};
  }

}

class Battery {
  final int? level;
  final bool? isCharging;

  Battery({this.level, this.isCharging});

  factory Battery.fromJson(Map<String, dynamic> json) =>
      new Battery(level: json['level'], isCharging: json['isCharging']);

  Map<String, dynamic> toJson() {
    return {'level': level, 'isCharging': isCharging};
  }
}

class Coords {
  final double? altitude;
  final double? heading;
  final double? latitude;
  final double? accuracy;
  final int? headingAccuracy;
  final double? altitudeAccuracy;
  final int? speedAccuracy;
  final double? speed;
  final double? longitude;

  Coords(
      {this.altitude,
      this.heading,
      this.latitude,
      this.accuracy,
      this.headingAccuracy,
      this.altitudeAccuracy,
      this.speedAccuracy,
      this.speed,
      this.longitude});

  factory Coords.fromJson(Map<String, dynamic> json) => new Coords(
      altitude: json['altitude'],
      heading: json['heading'],
      latitude: json['latitude'],
      accuracy: json['accuracy'],
      headingAccuracy: json['heading_accuracy'],
      altitudeAccuracy: json['altitude_accuracy'],
      speedAccuracy: json['speed_accuracy'],
      speed: json['speed'],
      longitude: json['longitude']);

  Map<String, dynamic> toJson() {
    return {
      'altitude': altitude,
      'heading': heading,
      'latitude': latitude,
      'accuracy': accuracy,
      'heading_accuracy': headingAccuracy,
      'altitude_accuracy': altitudeAccuracy,
      'speed_accuracy': speedAccuracy,
      'speed': speed,
      'longitude': longitude
    };
  }
}
