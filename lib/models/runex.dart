// ignore_for_file: unnecessary_new

class Runex {
  int? id;
  String timestamp;
  bool isSaved;

  Runex({this.id, required this.timestamp, required this.isSaved});

  factory Runex.fromJson(Map<String, dynamic> json) => new Runex(
      id: json['id'], timestamp: json['timestamp'], isSaved: json['is_saved'] == 1);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'is_saved' : isSaved ? 1 : 0
    };
  }
}
