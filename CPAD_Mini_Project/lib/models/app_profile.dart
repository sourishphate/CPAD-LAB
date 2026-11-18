class AppProfile {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final bool hasOrdered;
  final DateTime createdAt;
  const AppProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.hasOrdered,
    required this.createdAt,
  });
  factory AppProfile.fromMap(Map<String, dynamic> map) => AppProfile(
    id: map['id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String?,
    address: map['address'] as String?,
    hasOrdered: map['has_ordered'] as bool,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'has_ordered': hasOrdered,
    'created_at': createdAt.toIso8601String(),
  };
}
