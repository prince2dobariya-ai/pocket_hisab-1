class GroupModel {
  final int? id;
  final String name;
  final DateTime createdAt;
  
  // Transient fields (populated after query)
  double totalExpenses = 0.0;
  List<GroupMemberModel> members = [];
  
  GroupModel({
    this.id,
    required this.name,
    required this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class GroupMemberModel {
  final int? id;
  final int groupId;
  final int? personId;
  final String name;
  final DateTime createdAt;
  
  GroupMemberModel({
    this.id,
    required this.groupId,
    this.personId,
    required this.name,
    required this.createdAt,
  });

  factory GroupMemberModel.fromMap(Map<String, dynamic> map) {
    return GroupMemberModel(
      id: map['id'],
      groupId: map['group_id'],
      personId: map['person_id'],
      name: map['name'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'person_id': personId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
