class Visit {
  final String id;
  final String visitorId;
  final String propertyId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? message;
  final String? contact;
  final DateTime? createdTimestamp;
  final DateTime? updatedTimestamp;

  Visit({
    required this.id,
    required this.visitorId,
    required this.propertyId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.message,
    this.contact,
    this.createdTimestamp,
    this.updatedTimestamp,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    // L'API retourne visitor et property comme objets { id: "..." }
    final dynamic visitorObj = json['visitor'];
    final dynamic propertyObj = json['property'];
    return Visit(
      id: json['id'] ?? '',
      visitorId: visitorObj is Map<String, dynamic> ? (visitorObj['id'] ?? '') : (json['visitor'] ?? ''),
      propertyId: propertyObj is Map<String, dynamic> ? (propertyObj['id'] ?? '') : (json['property'] ?? ''),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'] ?? '',
      message: json['message'],
      contact: json['contact'],
      createdTimestamp: json['createdTimestamp'] != null
          ? DateTime.parse(json['createdTimestamp'])
          : null,
      updatedTimestamp: json['updatedTimestamp'] != null
          ? DateTime.parse(json['updatedTimestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitor': { 'id': visitorId },
      'property': { 'id': propertyId },
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'message': message,
      'contact': contact,
      'createdTimestamp': createdTimestamp?.toIso8601String(),
      'updatedTimestamp': updatedTimestamp?.toIso8601String(),
    };
  }

  Visit copyWith({
    String? id,
    String? visitorId,
    String? propertyId,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? message,
    String? contact,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) {
    return Visit(
      id: id ?? this.id,
      visitorId: visitorId ?? this.visitorId,
      propertyId: propertyId ?? this.propertyId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      message: message ?? this.message,
      contact: contact ?? this.contact,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      updatedTimestamp: updatedTimestamp ?? this.updatedTimestamp,
    );
  }
}

class VisitRequest {
  final String visitor;
  final String property;
  final DateTime startTime;
  final DateTime endTime;
  final String? message;
  final String? contact;

  VisitRequest({
    required this.visitor,
    required this.property,
    required this.startTime,
    required this.endTime,
    this.message,
    this.contact,
  });

  factory VisitRequest.fromJson(Map<String, dynamic> json) {
    return VisitRequest(
      visitor: json['visitor'] ?? '',
      property: json['property'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      message: json['message'],
      contact: json['contact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitor': visitor,
      'property': property,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'message': message ?? '',
      'contact': contact ?? '',
    };
  }
}

class VisitResponse {
  final Map<String, dynamic> metaData;
  final List<Visit> visits;

  VisitResponse({
    required this.metaData,
    required this.visits,
  });

  factory VisitResponse.fromJson(Map<String, dynamic> json) {
    final rawVisits = (json['visits'] as List?) ?? const [];
    return VisitResponse(
      metaData: json['metaData'] ?? {},
      visits: rawVisits
          .whereType<Map<String, dynamic>>()
          .map((v) => Visit.fromJson(v))
          .toList(),
    );
  }
}

class PaymentRequest {
  final String type;
  final String phone;
  final double amount;
  final String currency;

  PaymentRequest({
    required this.type,
    required this.phone,
    required this.amount,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'phone': phone,
      'amount': amount,
      'currency': currency,
    };
  }
}

class PaymentResponse {
  final String code;
  final String message;
  final String? orderNumber;
  final String status;

  PaymentResponse({
    required this.code,
    required this.message,
    this.orderNumber,
    required this.status,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      orderNumber: json['orderNumber'],
      status: json['status'] ?? '',
    );
  }
}

class PaymentCheckResponse {
  final String code;
  final String message;
  final Map<String, dynamic> transaction;

  PaymentCheckResponse({
    required this.code,
    required this.message,
    required this.transaction,
  });

  factory PaymentCheckResponse.fromJson(Map<String, dynamic> json) {
    return PaymentCheckResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      transaction: json['transaction'] ?? {},
    );
  }
}

class WithdrawalRequest {
  final String currency;
  final double amount;
  final String phone;
  final String type;

  WithdrawalRequest({
    required this.currency,
    required this.amount,
    required this.phone,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'amount': amount,
      'phone': phone,
      'type': type,
    };
  }
}
