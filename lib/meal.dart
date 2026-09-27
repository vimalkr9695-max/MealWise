class Meal {
  final String id;
  final String type; // "Breakfast" | "Lunch" | "Dinner" | "Snack"
  final String name;
  final String location;
  final double amount;
  final String note;
  final DateTime createdAt;
  final String?
      category; // "Fruits" | "Vegetables" | "Protein" | "Grains" | null (old meals)

  Meal({
    required this.id,
    required this.type,
    required this.name,
    required this.location,
    required this.amount,
    required this.note,
    required this.createdAt,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'location': location,
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      type: map['type'],
      name: map['name'],
      location: map['location'],
      amount: map['amount'].toDouble(),
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
      category: map['category'],
    );
  }
}