import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';

class ExpenseSplitModel extends ExpenseSplit {
  const ExpenseSplitModel({
    required super.userId,
    required super.amount,
    super.percentage,
    super.shares,
    super.isPayer,
  });

  factory ExpenseSplitModel.fromMap(Map<String, dynamic> map) {
    return ExpenseSplitModel(
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      percentage: map['percentage'] != null ? (map['percentage'] as num).toDouble() : null,
      shares: map['shares'] as int?,
      isPayer: map['isPayer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'percentage': percentage,
      'shares': shares,
      'isPayer': isPayer,
    };
  }
}

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.groupId,
    required super.description,
    required super.amount,
    required super.currency,
    required super.category,
    required super.createdAt,
    required super.date,
    required super.createdBy,
    required super.paidBy,
    required super.splits,
    required super.splitMethod,
    super.notes,
    super.receiptUrl,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ExpenseModel(
      id: doc.id,
      groupId: data['groupId'] as String,
      description: data['description'] as String,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
      category: data['category'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      date: (data['date'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String,
      paidBy: List<String>.from(data['paidBy'] as List),
      splits: (data['splits'] as List)
          .map((split) => ExpenseSplitModel.fromMap(split as Map<String, dynamic>))
          .toList(),
      splitMethod: SplitMethod.values.firstWhere(
        (method) => method.name == data['splitMethod'],
        orElse: () => SplitMethod.equal,
      ),
      notes: data['notes'] as String?,
      receiptUrl: data['receiptUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'description': description,
      'amount': amount,
      'currency': currency,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'paidBy': paidBy,
      'splits': splits.map((split) => ExpenseSplitModel(
        userId: split.userId,
        amount: split.amount,
        percentage: split.percentage,
        shares: split.shares,
        isPayer: split.isPayer,
      ).toMap()).toList(),
      'splitMethod': splitMethod.name,
      'notes': notes,
      'receiptUrl': receiptUrl,
    };
  }
}