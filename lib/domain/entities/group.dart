import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final String type;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final String currency;
  final String? inviteCode;
  
  // Trip specific fields
  final DateTime? startDate;
  final DateTime? endDate;
  
  // Home specific fields
  final bool enableSettleUpReminders;
  
  // Couple specific fields
  final bool enableBalanceAlert;
  final double balanceAlertAmount;

  const Group({
    required this.id,
    required this.name,
    required this.type,
    required this.createdBy,
    required this.createdAt,
    required this.memberIds,
    this.currency = 'USD',
    this.inviteCode,
    this.startDate,
    this.endDate,
    this.enableSettleUpReminders = false,
    this.enableBalanceAlert = false,
    this.balanceAlertAmount = 100.0,
  });

  Group copyWith({
    String? id,
    String? name,
    String? type,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    String? currency,
    String? inviteCode,
    DateTime? startDate,
    DateTime? endDate,
    bool? enableSettleUpReminders,
    bool? enableBalanceAlert,
    double? balanceAlertAmount,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? this.memberIds,
      currency: currency ?? this.currency,
      inviteCode: inviteCode ?? this.inviteCode,
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
        inviteCode,
        startDate,
        endDate,
        enableSettleUpReminders,
        enableBalanceAlert,
        balanceAlertAmount,
      ];
}