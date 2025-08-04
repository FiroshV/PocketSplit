import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<String> createExpense(Expense expense);
  Future<List<Expense>> getGroupExpenses(String groupId);
  Future<Expense?> getExpense(String expenseId);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);
  Stream<List<Expense>> watchGroupExpenses(String groupId);
}