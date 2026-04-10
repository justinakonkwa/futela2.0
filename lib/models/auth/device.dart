class Device {
  final String id;
  final String deviceName;
  final String deviceFingerprint;
  final String ipAddress;
  final String? location;
  final bool isActive;
  final bool isTrusted;
  final bool isCurrent;
  final DateTime lastActivityAt;
  final DateTime createdAt;

  Device({
    required this.id,
    required this.deviceName,
    required this.deviceFingerprint,
    required this.ipAddress,
    this.location,
    required this.isActive,
    required this.isTrusted,
    required this.isCurrent,
    required this.lastActivityAt,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      deviceFingerprint: json['deviceFingerprint']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString() ?? '',
      location: json['location']?.toString(),
      isActive: json['isActive'] == true,
      isTrusted: json['isTrusted'] == true,
      isCurrent: json['isCurrent'] == true,
      lastActivityAt: DateTime.parse(json['lastActivityAt'].toString()),
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceName': deviceName,
      'deviceFingerprint': deviceFingerprint,
      'ipAddress': ipAddress,
      'location': location,
      'isActive': isActive,
      'isTrusted': isTrusted,
      'isCurrent': isCurrent,
      'lastActivityAt': lastActivityAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get deviceIcon {
    final nameLower = deviceName.toLowerCase();
    if (nameLower.contains('iphone') || nameLower.contains('ipad')) {
      return '📱';
    } else if (nameLower.contains('android')) {
      return '📱';
    } else if (nameLower.contains('chrome')) {
      return '💻';
    } else if (nameLower.contains('safari')) {
      return '💻';
    } else if (nameLower.contains('firefox')) {
      return '💻';
    }
    return '🖥️';
  }

  String get formattedLastActivity {
    final now = DateTime.now();
    final difference = now.difference(lastActivityAt);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return 'Il y a ${(difference.inDays / 7).floor()} sem';
    }
  }
}
