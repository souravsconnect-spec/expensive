import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final double amount;
  final String note;
  final String type; // 'credit' or 'debit'
  final String categoryId;
  final String? categoryName; // From JOIN query
  final String userId;
  final String timestamp;
  final int isSynced;
  final int isDeleted;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    this.categoryName,
    required this.userId,
    required this.timestamp,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] ?? '',
      type: map['type'],
      categoryId: map['category_id'],
      categoryName: map['category_name'],
      userId: map['user_id'] ?? 'system',
      timestamp: map['timestamp'],
      isSynced: map['is_synced'] ?? 0,
      isDeleted: map['is_deleted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type,
      'category_id': categoryId,
      'user_id': userId,
      'timestamp': timestamp,
      'is_synced': isSynced,
      'is_deleted': isDeleted,
    };
  }

  Map<String, dynamic> toJsonSync() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type,
      'category_id': categoryId,
      'category': categoryName ?? 'Others',
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    note,
    type,
    categoryId,
    categoryName,
    userId,
    timestamp,
    isSynced,
    isDeleted,
  ];
}
