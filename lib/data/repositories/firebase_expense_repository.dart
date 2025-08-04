import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

class FirebaseExpenseRepository implements ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'expenses';

  @override
  Future<String> createExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel(
        id: expense.id,
        groupId: expense.groupId,
        description: expense.description,
        amount: expense.amount,
        currency: expense.currency,
        category: expense.category,
        createdAt: expense.createdAt,
        date: expense.date,
        createdBy: expense.createdBy,
        paidBy: expense.paidBy,
        splits: expense.splits,
        splitMethod: expense.splitMethod,
        notes: expense.notes,
        receiptUrl: expense.receiptUrl,
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(expenseModel.toFirestore());
      
      await _firestore
          .collection(_collection)
          .doc(docRef.id)
          .update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  @override
  Future<List<Expense>> getGroupExpenses(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get group expenses: $e');
    }
  }

  @override
  Future<Expense?> getExpense(String expenseId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(expenseId).get();
      
      if (!doc.exists) {
        return null;
      }

      return ExpenseModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get expense: $e');
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel(
        id: expense.id,
        groupId: expense.groupId,
        description: expense.description,
        amount: expense.amount,
        currency: expense.currency,
        category: expense.category,
        createdAt: expense.createdAt,
        date: expense.date,
        createdBy: expense.createdBy,
        paidBy: expense.paidBy,
        splits: expense.splits,
        splitMethod: expense.splitMethod,
        notes: expense.notes,
        receiptUrl: expense.receiptUrl,
      );

      await _firestore
          .collection(_collection)
          .doc(expense.id)
          .update(expenseModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection(_collection).doc(expenseId).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  @override
  Stream<List<Expense>> watchGroupExpenses(String groupId) {
    return _firestore
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromFirestore(doc))
            .toList());
  }
}