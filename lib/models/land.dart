class Land {
  const Land({
    required this.id,
    required this.name,
    required this.village,
    required this.ownerName,
    required this.treeCount,
  });

  final String id;
  final String name;
  final String village;
  final String ownerName;
  final int treeCount;

  factory Land.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return Land(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      village: json['village'] as String? ?? '',
      ownerName: owner['name'] as String? ?? '',
      treeCount: json['tree_count'] as int? ?? 0,
    );
  }
}
