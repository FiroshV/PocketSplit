import 'package:equatable/equatable.dart';
import '../../../domain/entities/group.dart';

abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

class CreateGroupEvent extends GroupEvent {
  final Group group;

  const CreateGroupEvent(this.group);

  @override
  List<Object?> get props => [group];
}

class LoadUserGroupsEvent extends GroupEvent {
  final String userId;

  const LoadUserGroupsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeleteGroupEvent extends GroupEvent {
  final String groupId;

  const DeleteGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class UpdateGroupEvent extends GroupEvent {
  final Group group;

  const UpdateGroupEvent(this.group);

  @override
  List<Object?> get props => [group];
}