class Group {
  final int id;
  final String name;
  final double balance;
  final int createdBy;

  Group({
    required this.id,
    required this.name,
    required this.balance,
    required this.createdBy,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      // Use the exact keys that Django sends in the JSON response
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Group',

      // Parse balance safely (Django might send an int if it's exactly 0)
      balance: (json['balance'] ?? 0).toDouble(),

      // Match the 'created_by' field name from your Django GroupSerializer
      createdBy: json['created_by'] ?? 0,
    );
  }
}
