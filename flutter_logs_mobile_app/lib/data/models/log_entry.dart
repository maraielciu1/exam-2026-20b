class LogEntry {
  const LogEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
  });

  final int id;
  final String date;
  final double amount;
  final String type;
  final String category;
  final String description;

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as int,
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: (json['category'] ?? '') as String,
      description: (json['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
    };
  }
}

class LogDraft {
  const LogDraft({
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
  });

  final String date;
  final double amount;
  final String type;
  final String category;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
    };
  }
}
