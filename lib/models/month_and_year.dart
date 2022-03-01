// ignore_for_file: unnecessary_new
class MonthAndYear {
  String monthAndYear;
  bool isExpanded = false;

  MonthAndYear({required this.monthAndYear});

  factory MonthAndYear.fromJson(Map<String, dynamic> json) =>
      new MonthAndYear(monthAndYear: json['month_and_year']);

  Map<String, dynamic> toJson() {
    return {'month_and_year': monthAndYear};
  }
}
