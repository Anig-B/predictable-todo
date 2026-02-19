class ChecklistTemplateModel {
  final String id;
  final String teamId;
  final List<String> items;

  ChecklistTemplateModel({
    required this.id,
    required this.teamId,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {'teamId': teamId, 'items': items};
  }

  factory ChecklistTemplateModel.fromMap(String id, Map<String, dynamic> map) {
    return ChecklistTemplateModel(
      id: id,
      teamId: map['teamId'] ?? '',
      items: List<String>.from(map['items'] ?? []),
    );
  }
}

class HandoffChecklistModel {
  final String id;
  final String leadName;
  final String sdrId;
  final String teamId;
  final Map<String, bool> items; // item text -> isCompleted
  final DateTime timestamp;

  HandoffChecklistModel({
    required this.id,
    required this.leadName,
    required this.sdrId,
    required this.teamId,
    required this.items,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'leadName': leadName,
      'sdrId': sdrId,
      'teamId': teamId,
      'items': items,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory HandoffChecklistModel.fromMap(String id, Map<String, dynamic> map) {
    return HandoffChecklistModel(
      id: id,
      leadName: map['leadName'] ?? '',
      sdrId: map['sdrId'] ?? '',
      teamId: map['teamId'] ?? '',
      items: Map<String, bool>.from(map['items'] ?? {}),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }
}
