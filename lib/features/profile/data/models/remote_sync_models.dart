import 'package:equatable/equatable.dart';

class RemoteCategory extends Equatable {
  final String? categoryId;
  final String name;

  const RemoteCategory({this.categoryId, required this.name});

  factory RemoteCategory.fromJson(Map<String, dynamic> json) {
    return RemoteCategory(
      categoryId: json['category_id']?.toString(), // Handle null or int/string
      name: json['name'] ?? 'Unknown',
    );
  }

  @override
  List<Object?> get props => [categoryId, name];
}

class RemoteTransaction extends Equatable {
  final String id;
  final double amount;
  final String note;
  final String type;
  final String? category;
  final String timestamp;

  const RemoteTransaction({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    this.category,
    required this.timestamp,
  });

  factory RemoteTransaction.fromJson(Map<String, dynamic> json) {
    return RemoteTransaction(
      id: json['id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] ?? '',
      type: json['type'] ?? 'debit',
      category: json['category']?.toString(),
      timestamp: json['timestamp'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, amount, note, type, category, timestamp];
}
