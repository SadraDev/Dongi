class Group {
  final int id;
  final String name;
  final double balance;
  final double totalOwed;
  final double totalOwe;
  final int createdBy;

  Group({
    required this.id,
    required this.name,
    required this.balance,
    required this.totalOwed,
    required this.totalOwe,
    required this.createdBy,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Group',
      balance: (json['balance'] ?? 0).toDouble(),
      totalOwed: (json['total_owed'] ?? 0).toDouble(),
      totalOwe: (json['total_owe'] ?? 0).toDouble(),
      createdBy: json['created_by'] ?? 0,
    );
  }
}