class Expense {
  final String name;
  final double amount;
  final DateTime date;
  final String? note; // optional

  Expense({
    required this.name,
    required this.amount,
    required this.date,
    this.note,
  });
}
