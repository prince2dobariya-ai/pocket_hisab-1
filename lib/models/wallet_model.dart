class WalletModel {
  final int? id;
  final String walletName;
  final double balance;
  final String createdAt;

  WalletModel({
    this.id,
    required this.walletName,
    required this.balance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'wallet_name': walletName,
      'balance': balance,
      'created_at': createdAt,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as int?,
      walletName: map['wallet_name'] as String,
      balance: (map['balance'] as num).toDouble(),
      createdAt: map['created_at'] as String,
    );
  }

  WalletModel copyWith({
    int? id,
    String? walletName,
    double? balance,
    String? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      walletName: walletName ?? this.walletName,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
