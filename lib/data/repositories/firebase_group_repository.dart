import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../core/utils/firestore_query_helper.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../models/group_model.dart';

class FirebaseGroupRepository implements GroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'groups';

  @override
  Future<String> createGroup(Group group) async {
    try {
      final groupModel = GroupModel(
        id: group.id,
        name: group.name,
        type: group.type,
        createdBy: group.createdBy,
        createdAt: group.createdAt,
        memberIds: group.memberIds,
        currency: group.currency,
        inviteCode: group.inviteCode,
        startDate: group.startDate,
        endDate: group.endDate,
        enableSettleUpReminders: group.enableSettleUpReminders,
        enableBalanceAlert: group.enableBalanceAlert,
        balanceAlertAmount: group.balanceAlertAmount,
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(groupModel.toFirestore());
      
      await _firestore
          .collection(_collection)
          .doc(docRef.id)
          .update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  @override
  Future<List<Group>> getUserGroups(String userId) async {
    try {
      // Use safe query helper to handle index requirements
      final querySnapshot = await FirestoreQueryHelper.safeQuery(
        collection: _firestore.collection(_collection),
        arrayContainsField: 'memberIds',
        arrayContainsValue: userId,
        orderByField: 'createdAt',
        descending: true,
      );

      final groups = querySnapshot.docs
          .map((doc) => GroupModel.fromFirestore(doc))
          .toList();

      // If the query couldn't order by createdAt, sort in memory
      if (!_isOrderedByCreatedAt(groups)) {
        groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      return groups;
    } catch (e) {
      throw Exception('Failed to get user groups: $e');
    }
  }
  
  bool _isOrderedByCreatedAt(List<Group> groups) {
    if (groups.length <= 1) return true;
    
    for (int i = 1; i < groups.length; i++) {
      if (groups[i - 1].createdAt.isBefore(groups[i].createdAt)) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<Group?> getGroup(String groupId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(groupId).get();
      
      if (!doc.exists) {
        return null;
      }

      return GroupModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  @override
  Future<void> updateGroup(Group group) async {
    try {
      final groupModel = GroupModel(
        id: group.id,
        name: group.name,
        type: group.type,
        createdBy: group.createdBy,
        createdAt: group.createdAt,
        memberIds: group.memberIds,
        currency: group.currency,
        inviteCode: group.inviteCode,
        startDate: group.startDate,
        endDate: group.endDate,
        enableSettleUpReminders: group.enableSettleUpReminders,
        enableBalanceAlert: group.enableBalanceAlert,
        balanceAlertAmount: group.balanceAlertAmount,
      );

      await _firestore
          .collection(_collection)
          .doc(group.id)
          .update(groupModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update group: $e');
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).delete();
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  @override
  Stream<List<Group>> watchUserGroups(String userId) {
    return FirestoreQueryHelper.safeSnapshotQuery(
      collection: _firestore.collection(_collection),
      arrayContainsField: 'memberIds',
      arrayContainsValue: userId,
      orderByField: 'createdAt',
      descending: true,
    ).map((snapshot) {
      final groups = snapshot.docs
          .map((doc) => GroupModel.fromFirestore(doc))
          .toList();
      
      // If the query couldn't order by createdAt, sort in memory
      if (!_isOrderedByCreatedAt(groups)) {
        groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      return groups;
    });
  }

  @override
  Future<void> addMemberToGroup(String groupId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      throw Exception('Failed to add member to group: $e');
    }
  }

  @override
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      throw Exception('Failed to remove member from group: $e');
    }
  }

  @override
  Future<Group?> getGroupByInviteCode(String inviteCode) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return GroupModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get group by invite code: $e');
    }
  }

  @override
  Future<String> generateInviteCode(String groupId) async {
    try {
      String inviteCode;
      bool isUnique = false;
      int attempts = 0;
      const maxAttempts = 10;

      do {
        inviteCode = _generateRandomCode();
        
        // Check if the code is already in use
        final existingGroup = await getGroupByInviteCode(inviteCode);
        isUnique = existingGroup == null;
        attempts++;
        
        if (attempts >= maxAttempts) {
          throw Exception('Failed to generate unique invite code after $maxAttempts attempts');
        }
      } while (!isUnique);

      // Update the group with the new invite code
      await _firestore.collection(_collection).doc(groupId).update({
        'inviteCode': inviteCode
      });

      return inviteCode;
    } catch (e) {
      throw Exception('Failed to generate invite code: $e');
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}