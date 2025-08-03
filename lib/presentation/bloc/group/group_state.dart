import 'package:equatable/equatable.dart';
import '../../../domain/entities/group.dart';

abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupCreated extends GroupState {
  final String groupId;

  const GroupCreated(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class GroupsLoaded extends GroupState {
  final List<Group> groups;

  const GroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class GroupUpdated extends GroupState {
  final Group group;

  const GroupUpdated(this.group);

  @override
  List<Object?> get props => [group];
}

class GroupDeleted extends GroupState {
  final String groupId;

  const GroupDeleted(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class GroupError extends GroupState {
  final String message;

  const GroupError(this.message);

  @override
  List<Object?> get props => [message];
}