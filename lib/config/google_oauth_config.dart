// Aligné sur le guide SuperApp (Google Sign-In + backend JWT).
// Voir GOOGLE_SIGNIN_SETUP.md, GOOGLE_SIGNIN_IOS.md, GOOGLE_SIGNIN_PLAYSTORE.md

/// Client OAuth **Application Web** — même valeur que :
/// - `GoogleSignIn(serverClientId: …)`
/// - `GIDServerClientID` dans `ios/Runner/Info.plist`
/// - `default_web_client_id` dans `android/.../values/strings.xml`
/// - audience (`aud`) attendue par le backend pour l’`id_token`.
const String kGoogleWebClientId =
    '474613582555-etdekl4un7r2r11u08h1jv2jelg3br0q.apps.googleusercontent.com';

/// Client OAuth **iOS** (Google Cloud → Credentials → iOS, bundle `com.futelaapp.mobile`).
/// À remplir après création du client ; puis mettre à jour `Info.plist` :
/// `GIDClientID` + `CFBundleURLSchemes` (REVERSED_CLIENT_ID du client **iOS**, pas Web).
///
/// Tant que cette chaîne est vide, seul `serverClientId` (Web) est utilisé sur iOS
/// (peut suffire selon version du SDK ; en cas d’erreur audience / redirect, remplir iOS).
const String kGoogleIosClientId = '474613582555-hhr7atbpp8uesekpevt69gav51a8ep5c.apps.googleusercontent.com';

/// Endpoint (chemin relatif à la base API).
const String kGoogleLoginPath = '/api/auth/google';
