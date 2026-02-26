import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String userId;
  final int isSynced;
  final int isDeleted;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.userId,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      userId: map['user_id'] ?? 'system',
      isSynced: map['is_synced'] ?? 0,
      isDeleted: map['is_deleted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'is_synced': isSynced,
      'is_deleted': isDeleted,
    };
  }

  Map<String, dynamic> toJsonSync() {
    return {'id': id, 'name': name};
  }

  @override
  List<Object?> get props => [id, name, userId, isSynced, isDeleted];
}
