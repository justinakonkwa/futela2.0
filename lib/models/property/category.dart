class Category {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String? description;
  final int? propertyCount;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    this.description,
    this.propertyCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      description: json['description']?.toString(),
      propertyCount: json['propertyCount'] is int
          ? json['propertyCount'] as int
          : (json['propertyCount'] != null
              ? int.tryParse(json['propertyCount'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
      'propertyCount': propertyCount,
    };
  }
}
