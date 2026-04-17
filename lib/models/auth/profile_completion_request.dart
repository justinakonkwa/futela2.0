class ProfileCompletionRequest {
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  final String? idDocumentType;
  final String? idDocumentNumber;
  final String? businessName;
  final String? businessAddress;
  final String? taxId;

  ProfileCompletionRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    this.idDocumentType,
    this.idDocumentNumber,
    this.businessName,
    this.businessAddress,
    this.taxId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
    };

    if (idDocumentType != null) data['idDocumentType'] = idDocumentType!;
    if (idDocumentNumber != null) data['idDocumentNumber'] = idDocumentNumber!;
    if (businessName != null) data['businessName'] = businessName!;
    if (businessAddress != null) data['businessAddress'] = businessAddress!;
    if (taxId != null) data['taxId'] = taxId!;

    return data;
  }
}
