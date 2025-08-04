import 'package:equatable/equatable.dart';

enum SplitMethod {
  equal,
  exact,
  percentage,
  shares,
  adjustment,
}

class ExpenseSplit extends Equatable {
  final String userId;
  final double amount;
  final double? percentage;
  final int? shares;
  final bool isPayer;

  const ExpenseSplit({
    required this.userId,
    required this.amount,
    this.percentage,
    this.shares,
    this.isPayer = false,
  });

  ExpenseSplit copyWith({
    String? userId,
    double? amount,
    double? percentage,
    int? shares,
    bool? isPayer,
  }) {
    return ExpenseSplit(
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      shares: shares ?? this.shares,
      isPayer: isPayer ?? this.isPayer,
    );
  }

  @override
  List<Object?> get props => [userId, amount, percentage, shares, isPayer];
}

class Expense extends Equatable {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String currency;
  final String category;
  final DateTime createdAt;
  final DateTime date;
  final String createdBy;
  final List<String> paidBy; // Can be multiple people
  final List<ExpenseSplit> splits;
  final SplitMethod splitMethod;
  final String? notes;
  final String? receiptUrl;

  const Expense({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.currency,
    required this.category,
    required this.createdAt,
    required this.date,
    required this.createdBy,
    required this.paidBy,
    required this.splits,
    required this.splitMethod,
    this.notes,
    this.receiptUrl,
  });

  Expense copyWith({
    String? id,
    String? groupId,
    String? description,
    double? amount,
    String? currency,
    String? category,
    DateTime? createdAt,
    DateTime? date,
    String? createdBy,
    List<String>? paidBy,
    List<ExpenseSplit>? splits,
    SplitMethod? splitMethod,
    String? notes,
    String? receiptUrl,
  }) {
    return Expense(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      paidBy: paidBy ?? this.paidBy,
      splits: splits ?? this.splits,
      splitMethod: splitMethod ?? this.splitMethod,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        description,
        amount,
        currency,
        category,
        createdAt,
        date,
        createdBy,
        paidBy,
        splits,
        splitMethod,
        notes,
        receiptUrl,
      ];
}