class PropertyPhoto {
  final String id;
  final String? url; // Peut être null si seule la filename est disponible
  final String filename;
  final bool isPrimary;
  final int displayOrder;
  final String? caption;

  PropertyPhoto({
    required this.id,
    this.url,
    required this.filename,
    required this.isPrimary,
    required this.displayOrder,
    this.caption,
  });

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) {
    return PropertyPhoto(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString(), // Peut être null
      filename: json['filename']?.toString() ?? '',
      isPrimary: json['isPrimary'] is bool
          ? json['isPrimary'] as bool
          : (json['isPrimary']?.toString().toLowerCase() == 'true'),
      displayOrder: json['displayOrder'] is int
          ? json['displayOrder'] as int
          : (json['displayOrder'] != null
              ? int.tryParse(json['displayOrder'].toString()) ?? 0
              : 0),
      caption: json['caption']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'filename': filename,
      'isPrimary': isPrimary,
      'displayOrder': displayOrder,
      'caption': caption,
    };
  }
}
