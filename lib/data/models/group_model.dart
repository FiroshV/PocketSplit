import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group.dart';

class GroupModel extends Group {
  const GroupModel({
    required String id,
    required String name,
    required String type,
    required String createdBy,
    required DateTime createdAt,
    required List<String> memberIds,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
    bool enableSettleUpReminders = false,
    bool enableBalanceAlert = false,
    double balanceAlertAmount = 100.0,
  }) : super(
          id: id,
          name: name,
          type: type,
          createdBy: createdBy,
          createdAt: createdAt,
          memberIds: memberIds,
          currency: currency,
          startDate: startDate,
          endDate: endDate,
          enableSettleUpReminders: enableSettleUpReminders,
          enableBalanceAlert: enableBalanceAlert,
          balanceAlertAmount: balanceAlertAmount,
        );

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
      'startDate': startDate,
      'endDate': endDate,
      'enableSettleUpReminders': enableSettleUpReminders,
      'enableBalanceAlert': enableBalanceAlert,
      'balanceAlertAmount': balanceAlertAmount,
    };
  }
}
