import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../domain/usecases/create_group.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _groupRepository;
  final CreateGroup _createGroup;

  GroupBloc(this._groupRepository, this._createGroup) : super(GroupInitial()) {
    on<CreateGroupEvent>(_onCreateGroup);
    on<LoadUserGroupsEvent>(_onLoadUserGroups);
    on<UpdateGroupEvent>(_onUpdateGroup);
    on<DeleteGroupEvent>(_onDeleteGroup);
  }

  Future<void> _onCreateGroup(
    CreateGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(GroupLoading());
      final groupId = await _createGroup(event.group);
      emit(GroupCreated(groupId));
    } catch (e) {
      emit(GroupError('Failed to create group: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUserGroups(
    LoadUserGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(GroupLoading());
      final groups = await _groupRepository.getUserGroups(event.userId);
      emit(GroupsLoaded(groups));
    } catch (e) {
      emit(GroupError('Failed to load groups: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateGroup(
    UpdateGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(GroupLoading());
      await _groupRepository.updateGroup(event.group);
      emit(GroupUpdated(event.group));
    } catch (e) {
      emit(GroupError('Failed to update group: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteGroup(
    DeleteGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(GroupLoading());
      await _groupRepository.deleteGroup(event.groupId);
      emit(GroupDeleted(event.groupId));
    } catch (e) {
      emit(GroupError('Failed to delete group: ${e.toString()}'));
    }
  }
}