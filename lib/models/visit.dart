// --- API v2 (guide migration mobile) : liste / création / paiement ---

/// Visite telle que retournée par GET /api/me/visits (member[]).
class MyVisit {
  final String id;
  final String propertyId;
  final String? propertyTitle;
  final String? visitorId;
  final String? visitorName;
  final DateTime? scheduledAt;
  final String status;
  final String? statusLabel;
  final String? statusColor;
  final String? notes;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final bool isPaid;
  final String? paymentTransactionId;
  /// Montant demandé / payé si l’API le renvoie sur la liste.
  final num? paymentAmount;
  final String? paymentCurrency;
  final String? propertyAddress;
  final String? propertyCity;
  final DateTime? cancelledAt;

  MyVisit({
    required this.id,
    required this.propertyId,
    this.propertyTitle,
    this.visitorId,
    this.visitorName,
    this.scheduledAt,
    required this.status,
    this.statusLabel,
    this.statusColor,
    this.notes,
    this.confirmedAt,
    this.completedAt,
    this.createdAt,
    this.isPaid = false,
    this.paymentTransactionId,
    this.paymentAmount,
    this.paymentCurrency,
    this.propertyAddress,
    this.propertyCity,
    this.cancelledAt,
  });

  /// Annulation autorisée côté app (API refuse si déjà payée).
  bool get canCancelVisit =>
      !isPaid &&
      status.toLowerCase() != 'cancelled' &&
      status.toLowerCase() != 'completed';

  factory MyVisit.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    String pid = json['propertyId']?.toString() ?? '';
    String? ptitle = json['propertyTitle'] as String?;
    String? pAddress;
    String? pCity;
    if (json['property'] is Map<String, dynamic>) {
      final m = json['property'] as Map<String, dynamic>;
      if (pid.isEmpty) pid = m['id']?.toString() ?? '';
      ptitle ??= m['title'] as String?;
      pAddress = m['address']?.toString();
      final cityVal = m['city'];
      if (cityVal is Map<String, dynamic>) {
        pCity = cityVal['name']?.toString() ?? cityVal['title']?.toString();
      } else if (cityVal != null) {
        pCity = cityVal.toString();
      }
    }

    DateTime? sched = parseDt(json['scheduledAt']);
    if (sched == null && json['startTime'] != null) {
      sched = parseDt(json['startTime']);
    }

    return MyVisit(
      id: json['id']?.toString() ?? '',
      propertyId: pid,
      propertyTitle: ptitle,
      visitorId: json['visitorId']?.toString(),
      visitorName: json['visitorName'] as String?,
      scheduledAt: sched,
      status: json['status']?.toString() ?? '',
      statusLabel: json['statusLabel'] as String?,
      statusColor: json['statusColor'] as String?,
      notes: json['notes'] as String? ?? json['message'] as String?,
      confirmedAt: parseDt(json['confirmedAt']),
      completedAt: parseDt(json['completedAt']),
      createdAt: parseDt(json['createdAt']) ?? parseDt(json['createdTimestamp']),
      isPaid: json['isPaid'] == true,
      paymentTransactionId: json['paymentTransactionId']?.toString(),
      paymentAmount: json['paymentAmount'] is num
          ? json['paymentAmount'] as num
          : num.tryParse('${json['paymentAmount']}'),
      paymentCurrency: json['paymentCurrency']?.toString(),
      propertyAddress: pAddress ?? json['propertyAddress']?.toString(),
      propertyCity: pCity ?? json['propertyCity']?.toString(),
      cancelledAt: parseDt(json['cancelledAt']),
    );
  }

  bool get needsPaymentPolling =>
      !isPaid && paymentTransactionId != null && paymentTransactionId!.isNotEmpty;
}

/// Réponse POST /api/visits (201).
class VisitCreateResult {
  final String id;
  final String? paymentTransactionId;
  final bool isPaid;
  final String? propertyTitle;
  final DateTime? scheduledAt;
  final String? status;

  VisitCreateResult({
    required this.id,
    this.paymentTransactionId,
    this.isPaid = false,
    this.propertyTitle,
    this.scheduledAt,
    this.status,
  });

  factory VisitCreateResult.fromJson(Map<String, dynamic> json) {
    return VisitCreateResult(
      id: json['id']?.toString() ?? '',
      paymentTransactionId: json['paymentTransactionId']?.toString(),
      isPaid: json['isPaid'] == true,
      propertyTitle: json['propertyTitle'] as String?,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
      status: json['status']?.toString(),
    );
  }

  bool get hasPaymentFlow =>
      paymentTransactionId != null && paymentTransactionId!.isNotEmpty && !isPaid;
}

/// GET /api/visits/{id}/payment-status/{transactionId}
class VisitPaymentStatus {
  final String visitId;
  final String transactionId;
  final String status;
  final String? statusLabel;
  final String? statusColor;
  final num? amount;
  final String? currency;
  final DateTime? paidAt;
  /// Référence opérateur (ex. FlexPay) si fournie par l’API.
  final String? externalId;
  final String? message;

  VisitPaymentStatus({
    required this.visitId,
    required this.transactionId,
    required this.status,
    this.statusLabel,
    this.statusColor,
    this.amount,
    this.currency,
    this.paidAt,
    this.externalId,
    this.message,
  });

  static const _successStatuses = {
    'completed',
    'success',
    'paid',
    'confirmed',
  };
  static const _failedStatuses = {
    'failed',
    'error',
    'failure',
    'rejected',
  };

  factory VisitPaymentStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parsePaid() {
      for (final key in ['paidAt', 'processedAt']) {
        final v = json[key];
        if (v != null) {
          final d = DateTime.tryParse(v.toString());
          if (d != null) return d;
        }
      }
      return null;
    }

    return VisitPaymentStatus(
      visitId: json['visitId']?.toString() ?? '',
      transactionId: json['transactionId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['statusLabel'] as String? ?? json['message'] as String?,
      statusColor: json['statusColor'] as String?,
      amount: json['amount'] is num
          ? json['amount'] as num
          : num.tryParse('${json['amount']}'),
      currency: json['currency'] as String?,
      paidAt: parsePaid(),
      externalId: json['externalId']?.toString(),
      message: json['message'] as String?,
    );
  }

  /// Aligné sur le guide (`pending` / `completed` / `failed`) + variantes réelles (`success`, etc.).
  bool get isCompleted {
    final s = status.toLowerCase();
    return _successStatuses.contains(s);
  }

  bool get isFailed {
    final s = status.toLowerCase();
    return _failedStatuses.contains(s);
  }

  bool get isPending => !isCompleted && !isFailed;

  /// Libellé lisible pour l’UI (évite les titres techniques vides).
  String get displayHeadline =>
      (statusLabel != null && statusLabel!.trim().isNotEmpty)
          ? statusLabel!
          : (message != null && message!.trim().isNotEmpty)
              ? message!
              : status;
}

class PaginatedVisitsResponse {
  final List<MyVisit> member;
  final int totalItems;
  final int page;
  final int itemsPerPage;
  final int totalPages;

  PaginatedVisitsResponse({
    required this.member,
    required this.totalItems,
    required this.page,
    required this.itemsPerPage,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;

  factory PaginatedVisitsResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> raw = const [];
    if (json['member'] is List) {
      raw = json['member'] as List;
    } else if (json['visits'] is List) {
      raw = json['visits'] as List;
    }

    final list = raw
        .whereType<Map<String, dynamic>>()
        .map((e) => MyVisit.fromJson(e))
        .toList();

    return PaginatedVisitsResponse(
      member: list,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? list.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 30,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Normalise le numéro pour FlexPay (format international +243…).
String normalizeVisitPaymentPhone(String input) {
  var s = input.trim().replaceAll(RegExp(r'\s|-'), '');
  if (s.startsWith('00')) s = '+${s.substring(2)}';
  if (!s.startsWith('+')) {
    final digits = s.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('243')) return '+$digits';
    return '+243$digits';
  }
  return s;
}

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

/// Payload POST /api/visits (guide migration).
/// Si [paymentPhone] est null/vide, pas de paiement mobile à la création.
class RequestVisitPayload {
  final String propertyId;
  final String scheduledAt;
  final String? notes;
  final num? paymentAmount;
  final String? paymentCurrency;
  final String? paymentPhone;

  RequestVisitPayload({
    required this.propertyId,
    required this.scheduledAt,
    this.notes,
    this.paymentAmount,
    this.paymentCurrency,
    this.paymentPhone,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'propertyId': propertyId,
      'scheduledAt': scheduledAt,
    };
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    final phone = paymentPhone?.trim();
    if (phone != null && phone.isNotEmpty) {
      map['paymentPhone'] = normalizeVisitPaymentPhone(phone);
      if (paymentAmount != null) map['paymentAmount'] = paymentAmount;
      if (paymentCurrency != null && paymentCurrency!.isNotEmpty) {
        map['paymentCurrency'] = paymentCurrency;
      }
    }
    return map;
  }
}

/// Rétrocompat : ancienne forme de réponse liste visites.
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
