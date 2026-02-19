class PipelineMetricModel {
  final String id;
  final String userId;
  final String teamId;
  final String date; // YYYY-MM-DD
  final int calls;
  final int connects;
  final int meetingsBooked;
  final DateTime timestamp;

  PipelineMetricModel({
    required this.id,
    required this.userId,
    required this.teamId,
    required this.date,
    required this.calls,
    required this.connects,
    required this.meetingsBooked,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'teamId': teamId,
      'date': date,
      'calls': calls,
      'connects': connects,
      'meetingsBooked': meetingsBooked,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory PipelineMetricModel.fromMap(String id, Map<String, dynamic> map) {
    return PipelineMetricModel(
      id: id,
      userId: map['userId'] ?? '',
      teamId: map['teamId'] ?? '',
      date: map['date'] ?? '',
      calls: map['calls']?.toInt() ?? 0,
      connects: map['connects']?.toInt() ?? 0,
      meetingsBooked: map['meetingsBooked']?.toInt() ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }
}
