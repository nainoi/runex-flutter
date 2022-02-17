class Location {
  final int? id;
  final double latitude;
  final double longitude;
  final String timestamp;
  final int runexId;

  Location(
      {this.id,
      required this.latitude,
      required this.longitude,
      required this.timestamp,
      required this.runexId});

  // ignore: unnecessary_new
  factory Location.fromJson(Map<String, dynamic> json) => new Location(
      id: json['id'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      timestamp: json['timestamp'],
      runexId: json['runex_id']);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'runex_id': runexId
    };
  }
}
