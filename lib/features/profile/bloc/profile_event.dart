import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateNicknameEvent extends ProfileEvent {
  final String nickname;
  const UpdateNicknameEvent(this.nickname);
  @override
  List<Object?> get props => [nickname];
}

class SetBudgetLimitEvent extends ProfileEvent {
  final double limit;
  const SetBudgetLimitEvent(this.limit);
  @override
  List<Object?> get props => [limit];
}

class AddCategoryEvent extends ProfileEvent {
  final String name;
  const AddCategoryEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class DeleteCategoryEvent extends ProfileEvent {
  final String id;
  const DeleteCategoryEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class SyncToCloudEvent extends ProfileEvent {}
