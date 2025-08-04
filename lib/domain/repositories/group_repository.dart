import '../entities/group.dart';

abstract class GroupRepository {
  Future<String> createGroup(Group group);
  Future<List<Group>> getUserGroups(String userId);
  Future<Group?> getGroup(String groupId);
  Future<void> updateGroup(Group group);
  Future<void> deleteGroup(String groupId);
  Stream<List<Group>> watchUserGroups(String userId);
  Future<void> addMemberToGroup(String groupId, String userId);
  Future<void> removeMemberFromGroup(String groupId, String userId);
  Future<Group?> getGroupByInviteCode(String inviteCode);
  Future<String> generateInviteCode(String groupId);
}