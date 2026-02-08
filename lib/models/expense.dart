class Expense {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String? icon;
  final String? note;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    this.icon,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'category': category,
      'icon': icon,
      'note': note,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      icon: json['icon'] as String?,
      note: json['note'] as String?,
    );
  }
}
