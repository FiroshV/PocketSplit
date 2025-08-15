import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    required super.type,
    required super.createdBy,
    required super.createdAt,
    required super.memberIds,
    required super.currency,
    super.inviteCode,
    super.startDate,
    super.endDate,
    super.enableSettleUpReminders = false,
    super.enableBalanceAlert = false,
    super.balanceAlertAmount = 100.0,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'Other',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      currency: data['currency'] ?? 'USD',
      inviteCode: data['inviteCode'] as String?,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      enableSettleUpReminders: data['enableSettleUpReminders'] ?? false,
      enableBalanceAlert: data['enableBalanceAlert'] ?? false,
      balanceAlertAmount: (data['balanceAlertAmount'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'memberIds': memberIds,
      'currency': currency,
      'inviteCode': inviteCode,
      'startDate': startDate,
      'endDate': endDate,
      'enableSettleUpReminders': enableSettleUpReminders,
      'enableBalanceAlert': enableBalanceAlert,
      'balanceAlertAmount': balanceAlertAmount,
    };
  }
}
