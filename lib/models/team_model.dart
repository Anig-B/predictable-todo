import 'package:cloud_firestore/cloud_firestore.dart';

class TeamModel {
  final String id;
  final String name;
  final String inviteCode;
  final String ownerId;
  final Map<String, String> members; // uid: role
  final DateTime createdAt;

  TeamModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.ownerId,
    required this.members,
    required this.createdAt,
  });

  factory TeamModel.fromMap(String id, Map<String, dynamic> data) {
    return TeamModel(
      id: id,
      name: data['name'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      ownerId: data['ownerId'] ?? '',
      members: Map<String, String>.from(data['members'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'ownerId': ownerId,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
