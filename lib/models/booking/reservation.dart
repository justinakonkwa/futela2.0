class Reservation {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String guestId;
  final String guestName;
  final String hostId;
  final String hostName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String currency;
  final String status; // pending, confirmed, cancelled, completed
  final int numberOfGuests;
  final String? specialRequests;
  final int numberOfNights;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.guestId,
    required this.guestName,
    required this.hostId,
    required this.hostName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.numberOfGuests,
    this.specialRequests,
    required this.numberOfNights,
    this.confirmedAt,
    this.cancelledAt,
    this.completedAt,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      propertyId: json['propertyId'],
      propertyTitle: json['propertyTitle'],
      guestId: json['guestId'],
      guestName: json['guestName'],
      hostId: json['hostId'],
      hostName: json['hostName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      numberOfGuests: json['numberOfGuests'],
      specialRequests: json['specialRequests'],
      numberOfNights: json['numberOfNights'],
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'guestId': guestId,
      'guestName': guestName,
      'hostId': hostId,
      'hostName': hostName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'currency': currency,
      'status': status,
      'numberOfGuests': numberOfGuests,
      'specialRequests': specialRequests,
      'numberOfNights': numberOfNights,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
