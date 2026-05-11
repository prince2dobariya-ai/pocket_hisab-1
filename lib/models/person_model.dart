class PersonModel {
  final int? id;
  final String personName;
  final String createdAt;
  final double? balance; // Calculated balance (not stored in table)

  PersonModel({
    this.id,
    required this.personName,
    required this.createdAt,
    this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'person_name': personName,
      'created_at': createdAt,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'] as int?,
      personName: map['person_name'] as String,
      createdAt: map['created_at'] as String,
      balance: (map['balance'] as num?)?.toDouble(),
    );
  }

  PersonModel copyWith({
    int? id,
    String? personName,
    String? createdAt,
    double? balance,
  }) {
    return PersonModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      createdAt: createdAt ?? this.createdAt,
      balance: balance ?? this.balance,
    );
  }
}
