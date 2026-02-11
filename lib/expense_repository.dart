import 'expense_model.dart';

class ExpenseRepository {
  static final List<Expense> expenses = [];

  static void addExpense(Expense expense) {
    expenses.add(expense);
  }

  static List<Expense> filterByDateRange(
      DateTime start,
      DateTime end,
      ) {
    return expenses.where((e) {
      return !e.date.isBefore(start) && !e.date.isAfter(end);
    }).toList();
  }

  static double get totalExpenses =>
      expenses.fold(0, (sum, e) => sum + e.amount);
}
