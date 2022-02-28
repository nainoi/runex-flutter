// ignore_for_file: unnecessary_new

class Runex {
  int? id;
  String providerId;
  String startTime;
  String? endTime;
  double? distanceKm;
  double? timeHrs;
  bool isSaved;
  String? docId;
  String monthAndYear;

  Runex(
      {this.id,
      required this.providerId,
      required this.startTime,
      this.endTime,
      this.distanceKm,
      this.timeHrs,
      required this.isSaved,
      this.docId,
      required this.monthAndYear});

  factory Runex.fromJson(Map<String, dynamic> json) => new Runex(
      id: json['_id'],
      providerId: json['provider_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      distanceKm: double.parse(json['distance_total_km']),
      timeHrs: double.parse(json['time_total_hours']),
      isSaved: json['is_saved'] == 1,
      docId: json['_doc_id'],
      monthAndYear: json['month_and_year']);

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'provider_id': providerId,
      'start_time': startTime,
      'end_time': endTime,
      'distance_total_km': distanceKm,
      'time_total_hours': timeHrs,
      'is_saved': isSaved ? 1 : 0,
      '_doc_id': docId,
      'month_and_year': monthAndYear
    };
  }
}
