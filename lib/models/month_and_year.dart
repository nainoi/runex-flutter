// ignore_for_file: unnecessary_new
class MonthAndYear {
  String monthAndYear;
  bool isExpanded = false;
  int runexCount;
  double distanceTotal;
  double timeTotal;

  MonthAndYear(
      {required this.monthAndYear,
      required this.runexCount,
      required this.distanceTotal,
      required this.timeTotal});

  factory MonthAndYear.fromJson(Map<String, dynamic> json) => new MonthAndYear(
      monthAndYear: json['month_and_year'],
      distanceTotal: json['distance_total'],
      runexCount: json['runex_conunt'],
      timeTotal: json['time_total']);
}
