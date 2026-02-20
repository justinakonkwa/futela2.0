class Device {
  final String id;
  final String deviceName;
  final String deviceFingerprint;
  final String ipAddress;
  final String location;
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
    required this.location,
    required this.isActive,
    required this.isTrusted,
    required this.isCurrent,
    required this.lastActivityAt,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      deviceName: json['deviceName'],
      deviceFingerprint: json['deviceFingerprint'],
      ipAddress: json['ipAddress'],
      location: json['location'],
      isActive: json['isActive'],
      isTrusted: json['isTrusted'],
      isCurrent: json['isCurrent'],
      lastActivityAt: DateTime.parse(json['lastActivityAt']),
      createdAt: DateTime.parse(json['createdAt']),
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
}
