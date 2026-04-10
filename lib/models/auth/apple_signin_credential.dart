class AppleSignInCredential {
  final String? userIdentifier;
  final String? email;
  final String? givenName;
  final String? familyName;
  final String? authorizationCode;
  final String? identityToken;

  AppleSignInCredential({
    this.userIdentifier,
    this.email,
    this.givenName,
    this.familyName,
    this.authorizationCode,
    this.identityToken,
  });

  factory AppleSignInCredential.fromAppleIDCredential(
    dynamic credential, {
    String? savedFirstName,
    String? savedLastName,
  }) {
    return AppleSignInCredential(
      userIdentifier: credential.userIdentifier,
      email: credential.email,
      // Utiliser les noms sauvegardés si les noms actuels sont null (connexions suivantes)
      givenName: credential.givenName ?? savedFirstName,
      familyName: credential.familyName ?? savedLastName,
      authorizationCode: credential.authorizationCode,
      identityToken: credential.identityToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_identifier': userIdentifier,
      'email': email,
      'given_name': givenName,
      'family_name': familyName,
      'authorization_code': authorizationCode,
      'identity_token': identityToken,
    };
  }

  @override
  String toString() {
    return 'AppleSignInCredential(userIdentifier: $userIdentifier, email: $email, givenName: $givenName, familyName: $familyName)';
  }
}