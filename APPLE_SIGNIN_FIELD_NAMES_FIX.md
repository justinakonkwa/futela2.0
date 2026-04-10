# Apple Sign-In Field Names Fix

## Problem Identified

The Apple Sign-In authentication was failing with the error:
```
❌ [AuthService] Erreur Apple Sign-In: Exception: Le champ "idToken" est requis
```

## Root Cause

There was a mismatch between the field names sent by the mobile app and what the backend expected:

### Mobile App Was Sending (Incorrect):
```json
{
  "identity_token": "...",
  "authorization_code": "...",
  "user_identifier": "...",
  "given_name": "...",
  "family_name": "..."
}
```

### Backend Expected (Correct):
```json
{
  "idToken": "...",
  "authorizationCode": "...",
  "userIdentifier": "...",
  "firstName": "...",
  "lastName": "..."
}
```

## Solution Applied

### 1. Updated Mobile App (`lib/services/auth_service.dart`)

Changed the field names in the `_authenticateWithBackend` method:

```dart
final Map<String, dynamic> requestData = {
  'idToken': credential.identityToken,           // Was: 'identity_token'
  'authorizationCode': credential.authorizationCode,  // Was: 'authorization_code'
  'userIdentifier': credential.userIdentifier,   // Was: 'user_identifier'
  'email': credential.email,
  'firstName': credential.givenName,             // Was: 'given_name'
  'lastName': credential.familyName,             // Was: 'family_name'
};
```

### 2. Updated API Documentation (`API_ENDPOINTS_OAUTH.md`)

Updated the Apple Sign-In endpoint specification to reflect the actual backend implementation:

- `identityToken` → `idToken`
- Field names now match the Google OAuth pattern for consistency

### 3. Updated Backend Fix Documentation

Updated `.kiro/specs/apple-signin-backend-auth-fix/bugfix.md` to include both issues:
- JWT authentication requirement (backend issue)
- Field name mismatch (now fixed on mobile)

## Consistency with Google OAuth

The Apple Sign-In now uses the same field naming pattern as Google OAuth:
- Both use `idToken` as the main authentication token field
- Consistent camelCase naming throughout

## Testing

After this fix, Apple Sign-In should work correctly, assuming the backend:
1. Accepts the `/api/auth/apple` endpoint without requiring JWT authentication
2. Processes the correctly named fields (`idToken`, `authorizationCode`, etc.)

## Files Modified

1. `lib/services/auth_service.dart` - Fixed field names in request
2. `API_ENDPOINTS_OAUTH.md` - Updated documentation
3. `.kiro/specs/apple-signin-backend-auth-fix/bugfix.md` - Updated requirements
4. `APPLE_SIGNIN_FIELD_NAMES_FIX.md` - This documentation

The mobile app is now sending the correct field names that match the backend expectations.