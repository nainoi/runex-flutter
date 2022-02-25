class FirestoreReturn {
  bool success;
  dynamic data;

  FirestoreReturn({required this.success, required this.data});

  factory FirestoreReturn.fromJson(Map<String, dynamic> json) =>
      FirestoreReturn(success: json['success'], data: json['data']);

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data};
  }
}
