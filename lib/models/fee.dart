class Fee {
  final String id;
  final String motive;
  final double percentage;
  final DateTime createdTimestamp;
  final DateTime updatedTimestamp;

  Fee({
    required this.id,
    required this.motive,
    required this.percentage,
    required this.createdTimestamp,
    required this.updatedTimestamp,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['id'] ?? '',
      motive: json['motive'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
      createdTimestamp: DateTime.parse(json['createdTimestamp']),
      updatedTimestamp: DateTime.parse(json['updatedTimestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motive': motive,
      'percentage': percentage,
      'createdTimestamp': createdTimestamp.toIso8601String(),
      'updatedTimestamp': updatedTimestamp.toIso8601String(),
    };
  }

  Fee copyWith({
    String? id,
    String? motive,
    double? percentage,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) {
    return Fee(
      id: id ?? this.id,
      motive: motive ?? this.motive,
      percentage: percentage ?? this.percentage,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      updatedTimestamp: updatedTimestamp ?? this.updatedTimestamp,
    );
  }
}

class FeeResponse {
  final Map<String, dynamic> metaData;
  final List<Fee> fees;

  FeeResponse({
    required this.metaData,
    required this.fees,
  });

  factory FeeResponse.fromJson(Map<String, dynamic> json) {
    return FeeResponse(
      metaData: json['metaData'] ?? {},
      fees: (json['fees'] as List?)
          ?.map((feeJson) => Fee.fromJson(feeJson))
          .toList() ?? [],
    );
  }
}
