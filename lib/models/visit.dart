class Visit {
  final String id;
  final String visitor;
  final String property;
  final DateTime dates;
  final String status;
  final String? message;
  final String? contact;
  final DateTime? createdTimestamp;
  final DateTime? updatedTimestamp;

  Visit({
    required this.id,
    required this.visitor,
    required this.property,
    required this.dates,
    required this.status,
    this.message,
    this.contact,
    this.createdTimestamp,
    this.updatedTimestamp,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] ?? '',
      visitor: json['visitor'] ?? '',
      property: json['property'] ?? '',
      dates: DateTime.parse(json['dates']),
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
      'visitor': visitor,
      'property': property,
      'dates': dates.toIso8601String(),
      'status': status,
      'message': message,
      'contact': contact,
      'createdTimestamp': createdTimestamp?.toIso8601String(),
      'updatedTimestamp': updatedTimestamp?.toIso8601String(),
    };
  }

  Visit copyWith({
    String? id,
    String? visitor,
    String? property,
    DateTime? dates,
    String? status,
    String? message,
    String? contact,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) {
    return Visit(
      id: id ?? this.id,
      visitor: visitor ?? this.visitor,
      property: property ?? this.property,
      dates: dates ?? this.dates,
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
  final List<String> visits;

  VisitResponse({
    required this.metaData,
    required this.visits,
  });

  factory VisitResponse.fromJson(Map<String, dynamic> json) {
    return VisitResponse(
      metaData: json['metaData'] ?? {},
      visits: List<String>.from(json['visits'] ?? []),
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
