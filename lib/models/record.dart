class RecordModel {
  String? id;
  final int hour;
  final int miniutes;
  final int distance;
  final String? memo;
  final DateTime date;

  RecordModel({
    this.id,
    required this.hour,
    required this.miniutes,
    required this.distance,
    this.memo,
    required this.date,
  });

  RecordModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? json['id'] as String : null,
        distance = json['distance'] as int,
        miniutes = json['miniutes'] as int,
        memo = json['memo'] != null ? json['memo'] as String : null,
        hour = json['hour'] as int,
        date = json['date'].toDate() as DateTime;

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'miniutes': miniutes,
        'distance': distance,
        'date': date,
        'memo': memo,
      };
}
