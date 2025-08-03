import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class GroupModel extends Equatable {
  final String id;
  final String name;
  final String type;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final String currency;
  
  // Trip specific fields
  final DateTime? startDate;
  final DateTime? endDate;
  
  // Home specific fields
  final bool enableSettleUpReminders;
  
  // Couple specific fields
  final bool enableBalanceAlert;
  final double balanceAlertAmount;

  const GroupModel({
    required this.id,
    required this.name,
    required this.type,
    required this.createdBy,
    required this.createdAt,
    required this.memberIds,
    this.currency = 'USD',
    this.startDate,
    this.endDate,
    this.enableSettleUpReminders = false,
    this.enableBalanceAlert = false,
    this.balanceAlertAmount = 100.0,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'Other',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      currency: data['currency'] ?? 'USD',
      startDate: data['startDate'] != null 
          ? (data['startDate'] as Timestamp).toDate() 
          : null,
      endDate: data['endDate'] != null 
          ? (data['endDate'] as Timestamp).toDate() 
          : null,
      enableSettleUpReminders: data['enableSettleUpReminders'] ?? false,
      enableBalanceAlert: data['enableBalanceAlert'] ?? false,
      balanceAlertAmount: (data['balanceAlertAmount'] ?? 100.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'memberIds': memberIds,
      'currency': currency,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'enableSettleUpReminders': enableSettleUpReminders,
      'enableBalanceAlert': enableBalanceAlert,
      'balanceAlertAmount': balanceAlertAmount,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? type,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    bool? enableSettleUpReminders,
    bool? enableBalanceAlert,
    double? balanceAlertAmount,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? this.memberIds,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      enableSettleUpReminders: enableSettleUpReminders ?? this.enableSettleUpReminders,
      enableBalanceAlert: enableBalanceAlert ?? this.enableBalanceAlert,
      balanceAlertAmount: balanceAlertAmount ?? this.balanceAlertAmount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        createdBy,
        createdAt,
        memberIds,
        currency,
        startDate,
        endDate,
        enableSettleUpReminders,
        enableBalanceAlert,
        balanceAlertAmount,
      ];
}