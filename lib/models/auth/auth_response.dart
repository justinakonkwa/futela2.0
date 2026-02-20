class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final int expiresIn;
  final String tokenType;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.expiresIn,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      sessionId: json['sessionId']?.toString() ?? '',
      expiresIn: (json['expiresIn'] is int) ? json['expiresIn'] as int : int.tryParse(json['expiresIn']?.toString() ?? '0') ?? 0,
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'sessionId': sessionId,
      'expiresIn': expiresIn,
      'tokenType': tokenType,
    };
  }
}
