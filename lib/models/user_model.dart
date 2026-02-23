class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String? currentTeamId;
  final List<UserTeamRole> teams;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    this.currentTeamId,
    required this.teams,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      currentTeamId: data['currentTeamId'],
      teams: (data['teams'] as List? ?? [])
          .map((t) => UserTeamRole.fromMap(t))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'currentTeamId': currentTeamId,
      'teams': teams.map((t) => t.toMap()).toList(),
    };
  }
}

class UserTeamRole {
  final String teamId;
  final String role;

  UserTeamRole({required this.teamId, required this.role});

  factory UserTeamRole.fromMap(Map<String, dynamic> data) {
    return UserTeamRole(
      teamId: data['teamId'] ?? '',
      role: data['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toMap() {
    return {'teamId': teamId, 'role': role};
  }
}
