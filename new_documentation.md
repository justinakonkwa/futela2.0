FUTELA


API authentification
12 endpoints


Gérez l'authentification des utilisateurs, l'inscription, le rafraîchissement des tokens et les sessions des appareils.
Navigation rapide
3 Publics
9 Authentifiés

Inscription & OAuth
POST
Inscrire utilisateur
/api/auth/register

Créer un nouveau compte utilisateur avec email et mot de passe. Un email de vérification sera envoyé pour confirmer l'adresse email.
Essayer


PUBLIC

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
password	string	Oui	Password (min 8 characters) ex. ********
firstName	string	Oui	User first name (min 2 characters) ex. John
lastName	string	Oui	User last name (min 2 characters) ex. Doe
email	string	Non	User email address (required if phoneNumber not provided) ex. user@example.com
phoneNumber	string	Non	Phone number (required if email not provided) ex. +243812345678
EXEMPLE DE RÉPONSE
JSON
201 User created successfully, returns authentication tokens

Copy
{
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "def50200a8b9c7d6e5f4...",
  "sessionId": "550e8400-e29b-41d4-a716-446655440001",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
POST
Google OAuth
/api/auth/google

S'authentifier via Google OAuth. Crée un compte si l'utilisateur n'existe pas, sinon connecte l'utilisateur existant.
Essayer


PUBLIC

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
idToken	string	Oui	Google ID token from OAuth flow
EXEMPLE DE RÉPONSE
JSON
200 Authentication successful

Copy
{
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "def50200a8b9c7d6e5f4...",
  "sessionId": "550e8400-e29b-41d4-a716-446655440002",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}

Connexion & gestion de session
POST
Connexion
/api/auth/login

Authentifier un utilisateur avec email et mot de passe. Retourne un token d'accès JWT et un token de rafraîchissement.
Essayer


PUBLIC

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
username	string	Oui	User identifier (email or phone number) ex. user@example.com
password	string	Oui	User password ex. ********
EXEMPLE DE RÉPONSE
JSON
200 Login successful

Copy
{
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "def50200a8b9c7d6e5f4...",
  "sessionId": "550e8400-e29b-41d4-a716-446655440003",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
GET
Utilisateur actuel
/api/auth/me

Récupérer les informations du profil de l'utilisateur connecté
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 Current user profile

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440010",
  "email": "user@example.com",
  "phoneNumber": "+243812345678",
  "firstName": "John",
  "lastName": "Doe",
  "roles": [ "ROLE_USER"
  ],
  "isEmailVerified": true,
  "isPhoneVerified": false,
  "createdAt": "2024-01-10T08: 00: 00+00: 00",
  "updatedAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Rafraîchir token
/api/auth/refresh

Obtenir un nouveau token d'accès avec un token de rafraîchissement valide. À utiliser quand le token d'accès expire.
Essayer


PUBLIC

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
refreshToken	string	Oui	Valid refresh token
EXEMPLE DE RÉPONSE
JSON
200 Token refreshed successfully

Copy
{
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "def50200newrefreshtoken...",
  "sessionId": "550e8400-e29b-41d4-a716-446655440003",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
POST
Déconnexion
/api/auth/logout

Invalider le token de rafraîchissement actuel, déconnectant l'utilisateur de l'appareil actuel.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
sessionId	string	Oui	Session ID to invalidate (from JWT claim) ex. 550e8400-e29b-41d4-a716-446655440003
EXEMPLE DE RÉPONSE
JSON
200 Logout successful

Copy
{
  "message": "Successfully logged out"
}
POST
Révoquer sessions
/api/auth/revoke-all

Invalider tous les tokens de rafraîchissement de l'utilisateur, le déconnectant de tous les appareils. Utile en cas de compte compromis.
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 All sessions revoked

Copy
{
  "message": "All sessions have been revoked",
  "revokedCount": 3
}
GET
Appareils connectés
/api/auth/devices

Obtenir la liste de tous les appareils connectés au compte utilisateur avec des tokens actifs.
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 List of connected devices

Copy
{
  "devices": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440010",
      "deviceName": "Chrome on Windows",
      "deviceFingerprint": "fp_abc123xyz",
      "ipAddress": "192.168.1.100",
      "location": "Kinshasa, DRC",
      "isActive": true,
      "isTrusted": true,
      "isCurrent": true,
      "lastActivityAt": "2024-01-15T10: 30: 00+00: 00",
      "createdAt": "2024-01-10T08: 00: 00+00: 00"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440011",
      "deviceName": "Safari on iPhone",
      "deviceFingerprint": "fp_def456uvw",
      "ipAddress": "192.168.1.101",
      "location": "Lubumbashi, DRC",
      "isActive": true,
      "isTrusted": false,
      "isCurrent": false,
      "lastActivityAt": "2024-01-14T15: 45: 00+00: 00",
      "createdAt": "2024-01-12T14: 20: 00+00: 00"
    }
  ]
}

Vérification email & téléphone
POST
Envoyer code email
/api/auth/send-email-code

Envoyer un code de vérification à l'adresse email de l'utilisateur.
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 Verification code sent

Copy
{
  "message": "Verification code sent to your email",
  "expiresAt": "2024-01-15T10: 45: 00+00: 00"
}
POST
Envoyer code tél.
/api/auth/send-phone-code

Envoyer un code de vérification par SMS au numéro de téléphone de l'utilisateur.
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 Verification code sent

Copy
{
  "message": "Verification code sent to your phone",
  "expiresAt": "2024-01-15T10: 45: 00+00: 00"
}
POST
Confirmer email
/api/auth/confirm-email

Vérifier l'adresse email avec le code de vérification reçu par email.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
code	string	Oui	6-digit verification code (digits only) ex. 123456
EXEMPLE DE RÉPONSE
JSON
200 Email verified successfully

Copy
{
  "message": "Email verified successfully",
  "emailVerified": true
}
POST
Confirmer téléphone
/api/auth/confirm-phone

Vérifier le numéro de téléphone avec le code de vérification reçu par SMS.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
code	string	Oui	6-digit verification code (digits only) ex. 123456
EXEMPLE DE RÉPONSE
JSON
200 Phone verified successfully

Copy
{
  "message": "Phone number verified successfully",
  "phoneVerified": true
}




GET
Liste des pays
/api/countries

Récupérer la liste de tous les pays disponibles.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Page number ex. 1
itemsPerPage	integer	Non	Items per page (default: 30) ex. 30
order[name]	string	Non	Sort by name (asc/desc) ex. asc
EXEMPLE DE RÉPONSE
JSON
200 List of countries

Copy
{
  "hydra:member": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Democratic Republic of the Congo",
      "code": "CD",
      "phoneCode": "+243",
      "isActive": true,
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Rwanda",
      "code": "RW",
      "phoneCode": "+250",
      "isActive": true,
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    }
  ],
  "hydra:totalItems": 54
}
GET
Détails pays
/api/countries/{id}

Obtenir les informations détaillées d'un pays spécifique.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Country UUID
EXEMPLE DE RÉPONSE
JSON
200 Country details

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Democratic Republic of the Congo",
  "code": "CD",
  "phoneCode": "+243",
  "isActive": true,
  "createdAt": "2024-01-01T00: 00: 00+00: 00"
}

Provinces
common.endpointCount
GET
Liste provinces
/api/provinces

Récupérer la liste des provinces, filtrable par pays.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Page number
country	string	Oui	Country UUID (also accepts countryId) ex. 019beafe-5539-7772-b776-c6a547edeff8
order[name]	string	Non	Sort by name
EXEMPLE DE RÉPONSE
JSON
200 List of provinces

Copy
{
  "hydra:member": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440010",
      "name": "Kinshasa",
      "code": "KIN",
      "isActive": true,
      "countryId": "550e8400-e29b-41d4-a716-446655440000",
      "countryName": "Democratic Republic of the Congo",
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440011",
      "name": "Katanga",
      "code": "KAT",
      "isActive": true,
      "countryId": "550e8400-e29b-41d4-a716-446655440000",
      "countryName": "Democratic Republic of the Congo",
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    }
  ],
  "hydra:totalItems": 26
}
GET
Détails province
/api/provinces/{id}

Obtenir les informations détaillées d'une province spécifique.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Province UUID
EXEMPLE DE RÉPONSE
JSON
200 Province details

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440010",
  "name": "Kinshasa",
  "code": "KIN",
  "isActive": true,
  "countryId": "550e8400-e29b-41d4-a716-446655440000",
  "countryName": "Democratic Republic of the Congo",
  "createdAt": "2024-01-01T00: 00: 00+00: 00"
}

Villes
common.endpointCount
GET
Liste des villes
/api/cities

Récupérer la liste des villes, filtrable par province.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Page number
province	string	Oui	Province UUID (also accepts provinceId) ex. 019beafe-5539-7822-b776-c6a547efb342
order[name]	string	Non	Sort by name
EXEMPLE DE RÉPONSE
JSON
200 List of cities

Copy
{
  "hydra:member": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440020",
      "name": "Kinshasa",
      "zipCode": null,
      "isActive": true,
      "provinceId": "550e8400-e29b-41d4-a716-446655440010",
      "provinceName": "Kinshasa",
      "countryName": "Democratic Republic of the Congo",
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440021",
      "name": "Lubumbashi",
      "zipCode": null,
      "isActive": true,
      "provinceId": "550e8400-e29b-41d4-a716-446655440011",
      "provinceName": "Katanga",
      "countryName": "Democratic Republic of the Congo",
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    }
  ],
  "hydra:totalItems": 145
}
GET
Détails ville
/api/cities/{id}

Obtenir les informations détaillées d'une ville spécifique.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	City UUID
EXEMPLE DE RÉPONSE
JSON
200 City details

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440020",
  "name": "Kinshasa",
  "zipCode": null,
  "isActive": true,
  "provinceId": "550e8400-e29b-41d4-a716-446655440010",
  "provinceName": "Kinshasa",
  "countryName": "Democratic Republic of the Congo",
  "createdAt": "2024-01-01T00: 00: 00+00: 00"
}

Communes
common.endpointCount
GET
Liste communes
/api/towns

Récupérer la liste des communes, filtrable par ville.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Page number
city	string	Oui	City UUID (also accepts cityId) ex. 019beafe-5539-788e-b776-c6a5488e83f7
order[name]	string	Non	Sort by name
EXEMPLE DE RÉPONSE
JSON
200 List of towns

Copy
{
  "hydra:member": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440030",
      "name": "Gombe",
      "zipCode": null,
      "isActive": true,
      "cityId": "550e8400-e29b-41d4-a716-446655440020",
      "cityName": "Kinshasa",
      "provinceName": "Kinshasa",
      "countryName": "Democratic Republic of the Congo",
      "fullName": "Gombe, Kinshasa, Kinshasa, Democratic Republic of the Congo",
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440031",
      "name": "Lingwala",
      "zipCode": null,
      "isActive": true,
      "cityId": "550e8400-e29b-41d4-a716-446655440020",
      "cityName": "Kinshasa",
      "provinceName": "Kinshasa",
      "countryName": "Democratic Republic of the Congo",
      "fullName": "Lingwala, Kinshasa, Kinshasa, Democratic Republic of the Congo",
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    }
  ],
  "hydra:totalItems": 24
}
GET
Détails commune
/api/towns/{id}

Obtenir les informations détaillées d'une commune spécifique.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Town UUID
EXEMPLE DE RÉPONSE
JSON
200 Town details

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440030",
  "name": "Gombe",
  "zipCode": null,
  "isActive": true,
  "cityId": "550e8400-e29b-41d4-a716-446655440020",
  "cityName": "Kinshasa",
  "provinceName": "Kinshasa",
  "countryName": "Democratic Republic of the Congo",
  "fullName": "Gombe, Kinshasa, Kinshasa, Democratic Republic of the Congo",
  "createdAt": "2024-01-01T00: 00: 00+00: 00"
}

Quartiers
common.endpointCount
GET
Liste quartiers
/api/districts

Récupérer la liste des quartiers, filtrable par commune.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Page number
town	string	Non	Town UUID (also accepts townId) - required if city not provided ex. 019beafe-5539-78e2-b776-c6a549845009
city	string	Non	City UUID (also accepts cityId) - required if town not provided ex. 019beafe-5539-788e-b776-c6a5488e83f7
order[name]	string	Non	Sort by name
EXEMPLE DE RÉPONSE
JSON
200 List of districts

Copy
{
  "hydra:member": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440040",
      "name": "Centre-Ville",
      "isActive": true,
      "cityId": null,
      "cityName": null,
      "townId": "550e8400-e29b-41d4-a716-446655440030",
      "townName": "Gombe",
      "fullName": "Centre-Ville, Gombe",
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440041",
      "name": "Socimat",
      "isActive": true,
      "cityId": null,
      "cityName": null,
      "townId": "550e8400-e29b-41d4-a716-446655440030",
      "townName": "Gombe",
      "fullName": "Socimat, Gombe",
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    }
  ],
  "hydra:totalItems": 150
}
GET
Détails quartier
/api/districts/{id}

Obtenir les informations détaillées d'un quartier spécifique.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	District UUID
EXEMPLE DE RÉPONSE
JSON
200 District details

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440040",
  "name": "Centre-Ville",
  "isActive": true,
  "cityId": null,
  "cityName": null,
  "townId": "550e8400-e29b-41d4-a716-446655440030",
  "townName": "Gombe",
  "fullName": "Centre-Ville, Gombe",
  "createdAt": "2024-01-01T00: 00: 00+00: 00"
}

Adresses & recherche
common.endpointCount
GET
Rechercher adresses
/api/addresses/search

Rechercher des adresses par mot-clé ou localisation.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
q	string	Oui	Search query ex. Gombe Kinshasa
limit	integer	Non	Max results (default: 10) ex. 10
EXEMPLE DE RÉPONSE
JSON
200 Search results

Copy
{
  "results": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440050",
      "street": "Avenue du Commerce",
      "number": "123",
      "additionalInfo": "Building A, Floor 2",
      "latitude": -4.3217,
      "longitude": 15.3125,
      "hasCoordinates": true,
      "townId": "550e8400-e29b-41d4-a716-446655440030",
      "townName": "Gombe",
      "cityName": "Kinshasa",
      "provinceName": "Kinshasa",
      "countryName": "Democratic Republic of the Congo",
      "districtId": "550e8400-e29b-41d4-a716-446655440040",
      "districtName": "Centre-Ville",
      "formattedAddress": "123 Avenue du Commerce, Centre-Ville, Gombe, Kinshasa, Kinshasa, Democratic Republic of the Congo",
      "shortAddress": "123 Avenue du Commerce, Gombe",
      "createdAt": "2024-01-01T00: 00: 00+00: 00"
    }
  ]
}
GET
Détails adresse
/api/addresses/{id}

Obtenir les informations détaillées d'une adresse spécifique.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Address UUID
EXEMPLE DE RÉPONSE
JSON
200 Address details

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440050",
  "street": "Avenue du Commerce",
  "number": "123",
  "additionalInfo": "Building A, Floor 2",
  "latitude": -4.3217,
  "longitude": 15.3125,
  "hasCoordinates": true,
  "townId": "550e8400-e29b-41d4-a716-446655440030",
  "townName": "Gombe",
  "cityName": "Kinshasa",
  "provinceName": "Kinshasa",
  "countryName": "Democratic Republic of the Congo",
  "districtId": "550e8400-e29b-41d4-a716-446655440040",
  "districtName": "Centre-Ville",
  "formattedAddress": "123 Avenue du Commerce, Centre-Ville, Gombe, Kinshasa, Kinshasa, Democratic Republic of the Congo",
  "shortAddress": "123 Avenue du Commerce, Gombe",
  "createdAt": "2024-01-01T00: 00: 00+00: 00"
}
POST
Créer adresse
/api/addresses

Créer une nouvelle entrée d'adresse.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
townId	string	Oui	Town UUID ex. 550e8400-e29b-41d4-a716-446655440030
districtId	string	Non	District UUID ex. 550e8400-e29b-41d4-a716-446655440040
street	string	Non	Street name (max 255 characters) ex. Avenue Lumumba
number	string	Non	Street number (max 50 characters) ex. 45
additionalInfo	string	Non	Additional address information ex. Near the main market
latitude	number	Non	GPS latitude (-90 to 90) ex. -4.3217
longitude	number	Non	GPS longitude (-180 to 180) ex. 15.3125
EXEMPLE DE RÉPONSE
JSON
201 Address created

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440051",
  "street": "Avenue Lumumba",
  "number": "45",
  "additionalInfo": "Near the main market",
  "latitude": -4.3217,
  "longitude": 15.3125,
  "hasCoordinates": true,
  "townId": "550e8400-e29b-41d4-a716-446655440030",
  "townName": "Gombe",
  "cityName": "Kinshasa",
  "provinceName": "Kinshasa",
  "countryName": "Democratic Republic of the Congo",
  "districtId": "550e8400-e29b-41d4-a716-446655440040",
  "districtName": "Centre-Ville",
  "formattedAddress": "45 Avenue Lumumba, Centre-Ville, Gombe, Kinshasa, Kinshasa, Democratic Republic of the Congo",
  "shortAddress": "45 Avenue Lumumba, Gombe",
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
PUT
Modifier adresse
/api/addresses/{id}

Mettre à jour une adresse existante.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Address UUID
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
townId	string	Oui	Town UUID ex. 550e8400-e29b-41d4-a716-446655440030
districtId	string	Non	District UUID ex. 550e8400-e29b-41d4-a716-446655440040
street	string	Non	Street name (max 255 characters) ex. Avenue du Commerce
number	string	Non	Street number (max 50 characters) ex. 123
additionalInfo	string	Non	Additional address information ex. Building A, Floor 2
latitude	number	Non	GPS latitude (-90 to 90) ex. -4.3217
longitude	number	Non	GPS longitude (-180 to 180) ex. 15.3125
EXEMPLE DE RÉPONSE
JSON
200 Address updated

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440050",
  "street": "Avenue du Commerce",
  "number": "123",
  "additionalInfo": "Building A, Floor 2",
  "latitude": -4.3217,
  "longitude": 15.3125,
  "hasCoordinates": true,
  "townId": "550e8400-e29b-41d4-a716-446655440030",
  "townName": "Gombe",
  "cityName": "Kinshasa",
  "provinceName": "Kinshasa",
  "countryName": "Democratic Republic of the Congo",
  "districtId": "550e8400-e29b-41d4-a716-446655440040",
  "districtName": "Centre-Ville",
  "formattedAddress": "123 Avenue du Commerce, Centre-Ville, Gombe, Kinshasa, Kinshasa, Democratic Republic of the Congo",
  "shortAddress": "123 Avenue du Commerce, Gombe",
  "createdAt": "2024-01-01T00: 00: 00+00: 00"
}


GET
Liste propriétés
/api/properties

Récupérer une liste paginée de propriétés avec des filtres optionnels par localisation, catégorie, fourchette de prix, etc.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Page number ex. 1
itemsPerPage	integer	Non	Items per page (default: 20) ex. 20
type	string	Non	Property type (apartment, house, land, event_hall, car) ex. apartment
cityId	string	Non	Filter by city UUID
townId	string	Non	Filter by town UUID
minPrice	number	Non	Minimum price ex. 100
maxPrice	number	Non	Maximum price ex. 1000
bedrooms	integer	Non	Minimum bedrooms ex. 2
available	boolean	Non	Filter by availability ex. true
query	string	Non	Full-text search query ex. apartment gombe
EXEMPLE DE RÉPONSE
JSON
200 Paginated list of properties (SearchPropertiesResponse)

Copy
{
  "properties": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440100",
      "type": "apartment",
      "title": "Appartement moderne a Gombe",
      "description": "Bel appartement de 3 chambres avec vue sur la ville, cuisine equipee et parking souterrain.",
      "pricePerDay": 80,
      "pricePerMonth": 800,
      "isPublished": true,
      "isActive": true,
      "isAvailable": true,
      "ownerId": "550e8400-e29b-41d4-a716-446655440010",
      "ownerName": "Jean Mukendi",
      "categoryId": "550e8400-e29b-41d4-a716-446655440020",
      "categoryName": "Appartement",
      "addressId": "550e8400-e29b-41d4-a716-446655440001",
      "address": {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "street": "Avenue du Commerce 123",
        "latitude": -4.3217,
        "longitude": 15.3125,
        "town": {
          "id": "550e8400-e29b-41d4-a716-446655440030",
          "name": "Gombe"
        },
        "city": {
          "id": "550e8400-e29b-41d4-a716-446655440040",
          "name": "Kinshasa"
        }
      },
      "viewCount": 156,
      "rating": 4.5,
      "reviewCount": 12,
      "photos": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440050",
          "url": "https://cdn.futela.com/properties/apt-001-1.jpg",
          "filename": "apt-001-1.jpg",
          "isPrimary": true,
          "displayOrder": 0,
          "caption": "Salon principal"
        },
        {
          "id": "550e8400-e29b-41d4-a716-446655440051",
          "url": "https://cdn.futela.com/properties/apt-001-2.jpg",
          "filename": "apt-001-2.jpg",
          "isPrimary": false,
          "displayOrder": 1,
          "caption": "Chambre principale"
        }
      ],
      "primaryPhotoIndex": 0,
      "createdAt": "2024-01-15T10: 30: 00+00: 00",
      "updatedAt": "2024-01-15T12: 00: 00+00: 00",
      "bedrooms": 3,
      "bathrooms": 2,
      "floor": 5,
      "hasElevator": true,
      "hasBalcony": true,
      "hasParking": true,
      "squareMeters": 120
    }
  ],
  "pagination": {
    "total": 150,
    "limit": 20,
    "offset": 0,
    "currentPage": 1,
    "totalPages": 8
  }
}
GET
Rechercher propriétés
/api/properties/search

Rechercher des propriétés avec des filtres avancés et recherche textuelle.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
type	string	Non	Property type enum (apartment, house, land, event_hall, car) ex. apartment
cityId	string	Non	City UUID
townId	string	Non	Town UUID
minPrice	number	Non	Minimum price (0 or positive) ex. 0
maxPrice	number	Non	Maximum price (positive) ex. 1000
bedrooms	integer	Non	Minimum bedrooms (0 or positive) ex. 2
available	boolean	Non	Filter by availability
query	string	Non	Search query (max 255 chars) ex. Appartement
limit	integer	Non	Results limit (default: 20, positive) ex. 20
offset	integer	Non	Results offset (default: 0, 0 or positive) ex. 0
EXEMPLE DE RÉPONSE
JSON
200 Search results (SearchPropertiesResponse)

Copy
{
  "properties": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440100",
      "type": "apartment",
      "title": "Appartement moderne a Gombe",
      "pricePerDay": 80,
      "pricePerMonth": 800,
      "isPublished": true,
      "isActive": true,
      "isAvailable": true,
      "ownerId": "550e8400-e29b-41d4-a716-446655440010",
      "ownerName": "Jean Mukendi",
      "rating": 4.5,
      "reviewCount": 12
    }
  ],
  "pagination": {
    "total": 15,
    "limit": 20,
    "offset": 0,
    "currentPage": 1,
    "totalPages": 1
  }
}
GET
Détails propriété
/api/properties/{id}

Obtenir les informations détaillées d'une propriété incluant photos, équipements et disponibilité.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
EXEMPLE DE RÉPONSE
JSON
200 Property details (PropertyResponse)

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440100",
  "type": "apartment",
  "title": "Appartement moderne a Gombe",
  "description": "Bel appartement de 3 chambres avec vue sur la ville, cuisine equipee et parking souterrain.",
  "pricePerDay": 80,
  "pricePerMonth": 800,
  "isPublished": true,
  "isActive": true,
  "isAvailable": true,
  "ownerId": "550e8400-e29b-41d4-a716-446655440010",
  "ownerName": "Jean Mukendi",
  "categoryId": "550e8400-e29b-41d4-a716-446655440020",
  "categoryName": "Appartement",
  "addressId": "550e8400-e29b-41d4-a716-446655440001",
  "address": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "street": "Avenue du Commerce 123",
    "latitude": -4.3217,
    "longitude": 15.3125,
    "town": {
      "id": "550e8400-e29b-41d4-a716-446655440030",
      "name": "Gombe"
    },
    "city": {
      "id": "550e8400-e29b-41d4-a716-446655440040",
      "name": "Kinshasa"
    }
  },
  "viewCount": 156,
  "rating": 4.5,
  "reviewCount": 12,
  "photos": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440050",
      "url": "https://cdn.futela.com/properties/apt-001-1.jpg",
      "filename": "apt-001-1.jpg",
      "isPrimary": true,
      "displayOrder": 0,
      "caption": "Salon principal"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440051",
      "url": "https://cdn.futela.com/properties/apt-001-2.jpg",
      "filename": "apt-001-2.jpg",
      "isPrimary": false,
      "displayOrder": 1,
      "caption": "Chambre principale"
    }
  ],
  "primaryPhotoIndex": 0,
  "createdAt": "2024-01-15T10: 30: 00+00: 00",
  "updatedAt": "2024-01-15T12: 00: 00+00: 00",
  "bedrooms": 3,
  "bathrooms": 2,
  "floor": 5,
  "hasElevator": true,
  "hasBalcony": true,
  "hasParking": true,
  "squareMeters": 120
}
POST
Créer propriété
/api/properties

Créer une nouvelle annonce de propriété.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
type	string	Oui	Property type (apartment, house, land, event_hall, car) ex. apartment
title	string	Oui	Property title ex. Appartement moderne a Gombe
description	string	Oui	Full description
pricePerDay	number	Non	Daily rental price ex. 80
pricePerMonth	number	Non	Monthly rental price ex. 800
addressId	string	Non	Existing address UUID (required if address not provided) ex. 550e8400-e29b-41d4-a716-446655440001
address	object	Non	New address to create inline (required if addressId not provided). Object with: townId (required), districtId, street, number, additionalInfo, latitude, longitude
categoryId	string	Non	Category UUID
bedrooms	integer	Non	Number of bedrooms ex. 3
bathrooms	integer	Non	Number of bathrooms ex. 2
floor	integer	Non	Floor number ex. 5
hasElevator	boolean	Non	Has elevator
hasBalcony	boolean	Non	Has balcony
hasParking	boolean	Non	Has parking
squareMeters	number	Non	Area in m2 ex. 120
EXEMPLE DE RÉPONSE
JSON
201 Property created (PropertyResponse)

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440100",
  "type": "apartment",
  "title": "Appartement moderne a Gombe",
  "description": "Bel appartement de 3 chambres avec vue sur la ville, cuisine equipee et parking souterrain.",
  "pricePerDay": 80,
  "pricePerMonth": 800,
  "isPublished": false,
  "isActive": true,
  "isAvailable": true,
  "ownerId": "550e8400-e29b-41d4-a716-446655440010",
  "ownerName": "Jean Mukendi",
  "categoryId": "550e8400-e29b-41d4-a716-446655440020",
  "categoryName": "Appartement",
  "addressId": "550e8400-e29b-41d4-a716-446655440001",
  "address": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "street": "Avenue du Commerce 123",
    "latitude": -4.3217,
    "longitude": 15.3125,
    "town": {
      "id": "550e8400-e29b-41d4-a716-446655440030",
      "name": "Gombe"
    },
    "city": {
      "id": "550e8400-e29b-41d4-a716-446655440040",
      "name": "Kinshasa"
    }
  },
  "viewCount": 0,
  "rating": null,
  "reviewCount": 0,
  "photos": [],
  "primaryPhotoIndex": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00",
  "updatedAt": "2024-01-15T12: 00: 00+00: 00",
  "bedrooms": 3,
  "bathrooms": 2,
  "floor": 5,
  "hasElevator": true,
  "hasBalcony": true,
  "hasParking": true,
  "squareMeters": 120
}
PUT
Modifier propriété
/api/properties/{id}

Mettre à jour les informations d'une propriété existante.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
title	string	Non	Property title
description	string	Non	Full description
pricePerDay	number	Non	Daily rental price
pricePerMonth	number	Non	Monthly rental price
addressId	string	Non	Address UUID
categoryId	string	Non	Category UUID
bedrooms	integer	Non	Number of bedrooms
bathrooms	integer	Non	Number of bathrooms
floor	integer	Non	Floor number
hasElevator	boolean	Non	Has elevator
hasBalcony	boolean	Non	Has balcony
hasParking	boolean	Non	Has parking
squareMeters	number	Non	Area in m2
EXEMPLE DE RÉPONSE
JSON
200 Property updated (PropertyResponse)

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440100",
  "type": "apartment",
  "title": "Appartement moderne a Gombe",
  "description": "Bel appartement de 3 chambres avec vue sur la ville, cuisine equipee et parking souterrain.",
  "pricePerDay": 80,
  "pricePerMonth": 800,
  "isPublished": true,
  "isActive": true,
  "isAvailable": true,
  "ownerId": "550e8400-e29b-41d4-a716-446655440010",
  "ownerName": "Jean Mukendi",
  "categoryId": "550e8400-e29b-41d4-a716-446655440020",
  "categoryName": "Appartement",
  "addressId": "550e8400-e29b-41d4-a716-446655440001",
  "address": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "street": "Avenue du Commerce 123",
    "latitude": -4.3217,
    "longitude": 15.3125,
    "town": {
      "id": "550e8400-e29b-41d4-a716-446655440030",
      "name": "Gombe"
    },
    "city": {
      "id": "550e8400-e29b-41d4-a716-446655440040",
      "name": "Kinshasa"
    }
  },
  "viewCount": 156,
  "rating": 4.5,
  "reviewCount": 12,
  "photos": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440050",
      "url": "https://cdn.futela.com/properties/apt-001-1.jpg",
      "filename": "apt-001-1.jpg",
      "isPrimary": true,
      "displayOrder": 0,
      "caption": "Salon principal"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440051",
      "url": "https://cdn.futela.com/properties/apt-001-2.jpg",
      "filename": "apt-001-2.jpg",
      "isPrimary": false,
      "displayOrder": 1,
      "caption": "Chambre principale"
    }
  ],
  "primaryPhotoIndex": 0,
  "createdAt": "2024-01-15T10: 30: 00+00: 00",
  "updatedAt": "2024-01-15T12: 00: 00+00: 00",
  "bedrooms": 3,
  "bathrooms": 2,
  "floor": 5,
  "hasElevator": true,
  "hasBalcony": true,
  "hasParking": true,
  "squareMeters": 120
}
DELETE
Supprimer propriété
/api/properties/{id}

Supprimer une annonce de propriété.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
EXEMPLE DE RÉPONSE
POST
Publier propriété
/api/properties/{id}/publish

Publier une propriété pour la rendre visible aux utilisateurs.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
EXEMPLE DE RÉPONSE
JSON
200 Property published (PropertyResponse)

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440100",
  "type": "apartment",
  "title": "Appartement moderne a Gombe",
  "isPublished": true,
  "isActive": true,
  "isAvailable": true,
  "updatedAt": "2024-01-15T12: 00: 00+00: 00"
}
POST
Dépublier propriété
/api/properties/{id}/unpublish

Dépublier une propriété pour la masquer aux utilisateurs.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
EXEMPLE DE RÉPONSE
JSON
200 Property unpublished (PropertyResponse)

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440100",
  "type": "apartment",
  "title": "Appartement moderne a Gombe",
  "isPublished": false,
  "isActive": true,
  "isAvailable": true,
  "updatedAt": "2024-01-15T14: 00: 00+00: 00"
}
POST
Ajouter photos
/api/properties/{id}/photos

Télécharger des photos pour une annonce de propriété.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
propertyId	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
photoUrl	string	Oui	Photo URL ex. https://cdn.futela.com/uploads/photo.jpg
caption	string	Non	Photo caption ex. Salon principal
isPrimary	boolean	Non	Set as primary photo (default: false)
EXEMPLE DE RÉPONSE
JSON
201 Photo uploaded

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440050",
  "url": "https://cdn.futela.com/properties/apt-001-1.jpg",
  "filename": "apt-001-1.jpg",
  "isPrimary": true,
  "displayOrder": 0,
  "caption": "Salon principal"
}
DELETE
Supprimer photo
/api/properties/{id}/photos/{photoId}

Supprimer une photo d'une annonce de propriété.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
photoId	string	Oui	Photo UUID ex. 550e8400-e29b-41d4-a716-446655440050
EXEMPLE DE RÉPONSE
GET
Réservations propriété
/api/properties/{id}/reservations

endpointDescriptions.getPropertyReservations
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
status	string	Non	Filter by status ex. confirmed
EXEMPLE DE RÉPONSE
GET
Avis propriété
/api/properties/{id}/reviews

Obtenir tous les avis pour une propriété spécifique.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
EXEMPLE DE RÉPONSE
GET
Calendrier propriété
/api/properties/{id}/calendar

endpointDescriptions.getPropertyCalendar
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
startDate	string	Oui	Start date (YYYY-MM-DD) ex. 2024-01-01
endDate	string	Oui	End date (YYYY-MM-DD) ex. 2024-01-31
EXEMPLE DE RÉPONSE
JSON
200 Calendar data

Copy
{
  "propertyId": "550e8400-e29b-41d4-a716-446655440100",
  "dates": [
    {
      "date": "2024-01-15",
      "available": false,
      "pricePerDay": 80
    },
    {
      "date": "2024-01-16",
      "available": true,
      "pricePerDay": 80
    }
  ]
}
GET
Vérifier dispo.
/api/properties/{id}/availability

Vérifier si une propriété est disponible pour les dates spécifiées.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
checkIn	string	Oui	Check-in date ex. 2024-01-15
checkOut	string	Oui	Check-out date ex. 2024-01-20
EXEMPLE DE RÉPONSE
JSON
200 Availability status

Copy
{
  "available": true,
  "totalPrice": 400,
  "nights": 5,
  "pricePerDay": 80
}
POST
Contacter propriétaire
/api/properties/{id}/contact

endpointDescriptions.contactOwner
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
name	string	Oui	Sender name (2-255 chars) ex. Jean Doe
email	string	Oui	Sender email ex. jean@example.com
message	string	Oui	Message content (10-2000 chars) ex. Bonjour, je suis interesse par votre appartement...
phone	string	Non	Sender phone (max 20 chars) ex. +243812345678
EXEMPLE DE RÉPONSE
JSON
200 Message sent (ContactPropertyResponse)

Copy
{
  "success": true,
  "message": "Votre message a ete envoye au proprietaire."
}
GET
Bail actif
/api/properties/{id}/lease

endpointDescriptions.getActiveLease
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
EXEMPLE DE RÉPONSE
GET
Historique baux
/api/properties/{id}/lease-history

endpointDescriptions.getLeaseHistory
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
EXEMPLE DE RÉPONSE

Catégories
(5 endpoints)
GET
Liste catégories
/api/categories

Récupérer la liste de toutes les catégories de propriétés.
Essayer


PUBLIC

EXEMPLE DE RÉPONSE
JSON
200 List of categories

Copy
{
  "hydra:member": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440020",
      "name": "Appartement",
      "slug": "apartment",
      "icon": "building"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440021",
      "name": "Maison",
      "slug": "house",
      "icon": "home"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440022",
      "name": "Terrain",
      "slug": "land",
      "icon": "map"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440023",
      "name": "Salle d'evenement",
      "slug": "event-hall",
      "icon": "calendar"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440024",
      "name": "Vehicule",
      "slug": "car",
      "icon": "car"
    }
  ]
}
GET
Détails catégorie
/api/categories/{id}

Obtenir les informations détaillées d'une catégorie spécifique.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Category UUID
EXEMPLE DE RÉPONSE
JSON
200 Category details

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440020",
  "name": "Appartement",
  "slug": "apartment",
  "description": "Appartements residentiels a louer",
  "icon": "building",
  "propertyCount": 245
}

Favoris
(3 endpoints)
GET
Mes favoris
/api/me/favorites

Obtenir la liste des propriétés enregistrées en favoris par l'utilisateur actuel.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Page number
itemsPerPage	integer	Non	Items per page
EXEMPLE DE RÉPONSE
JSON
200 List of favorite properties

Copy
{
  "hydra:member": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440060",
      "property": {
        "id": "550e8400-e29b-41d4-a716-446655440100",
        "type": "apartment",
        "title": "Appartement moderne a Gombe",
        "pricePerDay": 80,
        "pricePerMonth": 800,
        "isAvailable": true,
        "rating": 4.5
      },
      "addedAt": "2024-01-15T10: 30: 00+00: 00"
    }
  ],
  "hydra:totalItems": 5
}
POST
Ajouter favoris
/api/me/favorites

Ajouter une propriété à la liste des favoris de l'utilisateur.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
propertyId	string	Oui	Property UUID ex. 550e8400-e29b-41d4-a716-446655440100
notes	string	Non	Optional notes about the favorite ex. Love the view!
EXEMPLE DE RÉPONSE
JSON
201 Added to favorites

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440060",
  "propertyId": "550e8400-e29b-41d4-a716-446655440100",
  "addedAt": "2024-01-15T10: 30: 00+00: 00"
}
DELETE
Retirer favoris
/api/me/favorites/{propertyId}

Retirer une propriété de la liste des favoris de l'utilisateur.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
propertyId	string	Oui	Property UUID
EXEMPLE DE RÉPONSE




API réservations
30 endpoints


Gérez les réservations, les réservations et les visites de propriétés. Gérez le flux complet de réservation de la demande à la réalisation.
Flux de réservation
Create

Pending

Confirmed

Paid

Completed

Réservations
(12 endpoints)
GET
Détails réservation
/api/reservations/{id}

Obtenir les informations détaillées d'une réservation spécifique.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Reservation UUID
EXEMPLE DE RÉPONSE
JSON
200 Reservation details

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "guestId": "770e8400-e29b-41d4-a716-446655440002",
  "guestName": "John Doe",
  "hostId": "880e8400-e29b-41d4-a716-446655440003",
  "hostName": "Jane Smith",
  "startDate": "2024-01-20T00: 00: 00+00: 00",
  "endDate": "2024-01-25T00: 00: 00+00: 00",
  "totalPrice": 2500,
  "currency": "USD",
  "status": "confirmed",
  "numberOfGuests": 2,
  "specialRequests": "Late check-in requested",
  "numberOfNights": 5,
  "confirmedAt": "2024-01-16T14: 00: 00+00: 00",
  "cancelledAt": null,
  "completedAt": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Créer réservation
/api/reservations

Créer une nouvelle réservation pour une propriété.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
propertyId	string	Oui	Property UUID ex. 660e8400-e29b-41d4-a716-446655440001
guestId	string	Oui	Guest user UUID ex. 770e8400-e29b-41d4-a716-446655440002
startDate	string	Oui	Start date (ISO 8601) ex. 2024-01-20T00:00:00+00:00
endDate	string	Oui	End date (ISO 8601) ex. 2024-01-25T00:00:00+00:00
numberOfGuests	integer	Oui	Number of guests ex. 2
specialRequests	string	Non	Special requests or notes
EXEMPLE DE RÉPONSE
JSON
201 Reservation created

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "guestId": "770e8400-e29b-41d4-a716-446655440002",
  "guestName": "John Doe",
  "hostId": "880e8400-e29b-41d4-a716-446655440003",
  "hostName": "Jane Smith",
  "startDate": "2024-01-20T00: 00: 00+00: 00",
  "endDate": "2024-01-25T00: 00: 00+00: 00",
  "totalPrice": 2500,
  "currency": "USD",
  "status": "pending",
  "numberOfGuests": 2,
  "specialRequests": null,
  "numberOfNights": 5,
  "confirmedAt": null,
  "cancelledAt": null,
  "completedAt": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
PUT
Modifier réservation
/api/reservations/{id}

Modifier les détails de la réservation. Uniquement possible pour les réservations en attente.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Reservation UUID
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
startDate	string	Non	New start date (ISO 8601) ex. 2024-01-21T00:00:00+00:00
endDate	string	Non	New end date (ISO 8601) ex. 2024-01-26T00:00:00+00:00
numberOfGuests	integer	Non	Number of guests ex. 3
specialRequests	string	Non	Special requests or notes
EXEMPLE DE RÉPONSE
JSON
200 Reservation updated

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "guestId": "770e8400-e29b-41d4-a716-446655440002",
  "guestName": "John Doe",
  "hostId": "880e8400-e29b-41d4-a716-446655440003",
  "hostName": "Jane Smith",
  "startDate": "2024-01-21T00: 00: 00+00: 00",
  "endDate": "2024-01-26T00: 00: 00+00: 00",
  "totalPrice": 2500,
  "currency": "USD",
  "status": "pending",
  "numberOfGuests": 3,
  "specialRequests": "Early check-in if possible",
  "numberOfNights": 5,
  "confirmedAt": null,
  "cancelledAt": null,
  "completedAt": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
DELETE
Supprimer réservation
/api/reservations/{id}

Supprimer une réservation en attente. Impossible de supprimer les réservations confirmées ou terminées.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Reservation UUID
EXEMPLE DE RÉPONSE
POST
Confirmer réservation
/api/reservations/{id}/confirm

Confirmer une réservation en attente.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Reservation UUID
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
transactionId	string	Non	Optional payment transaction ID
EXEMPLE DE RÉPONSE
JSON
200 Reservation confirmed

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "guestId": "770e8400-e29b-41d4-a716-446655440002",
  "guestName": "John Doe",
  "hostId": "880e8400-e29b-41d4-a716-446655440003",
  "hostName": "Jane Smith",
  "startDate": "2024-01-20T00: 00: 00+00: 00",
  "endDate": "2024-01-25T00: 00: 00+00: 00",
  "totalPrice": 2500,
  "currency": "USD",
  "status": "confirmed",
  "numberOfGuests": 2,
  "specialRequests": null,
  "numberOfNights": 5,
  "confirmedAt": "2024-01-16T14: 00: 00+00: 00",
  "cancelledAt": null,
  "completedAt": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Annuler réservation
/api/reservations/{id}/cancel

Annuler une réservation existante.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Reservation UUID
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
cancellationReason	string	Oui	Reason for cancellation
EXEMPLE DE RÉPONSE
JSON
200 Reservation cancelled

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "guestId": "770e8400-e29b-41d4-a716-446655440002",
  "guestName": "John Doe",
  "hostId": "880e8400-e29b-41d4-a716-446655440003",
  "hostName": "Jane Smith",
  "startDate": "2024-01-20T00: 00: 00+00: 00",
  "endDate": "2024-01-25T00: 00: 00+00: 00",
  "totalPrice": 2500,
  "currency": "USD",
  "status": "cancelled",
  "numberOfGuests": 2,
  "specialRequests": null,
  "numberOfNights": 5,
  "confirmedAt": null,
  "cancelledAt": "2024-01-17T10: 00: 00+00: 00",
  "completedAt": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
GET
Facture réservation
/api/reservations/{id}/invoice

Obtenir la facture d'une réservation.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Reservation UUID
EXEMPLE DE RÉPONSE
JSON
200 Invoice details

Copy
{
  "reservationId": "550e8400-e29b-41d4-a716-446655440000",
  "invoiceNumber": "INV-2024-01-550e8400",
  "amount": 2500,
  "currency": "USD",
  "issueDate": "2024-01-15",
  "pdfUrl": null
}
GET
Info paiement
/api/reservations/{id}/payment

Obtenir les informations de paiement d'une réservation.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Reservation UUID
EXEMPLE DE RÉPONSE
POST
Payer réservation
/api/reservations/{id}/pay

Traiter le paiement d'une réservation.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Reservation UUID
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
paymentMethod	string	Oui	Payment method ex. mobile_money
phoneNumber	string	Non	Phone for mobile money ex. +243812345678
EXEMPLE DE RÉPONSE
POST
Vérifier dispo.
/api/reservations/check-availability

Vérifier si une propriété est disponible pour les dates spécifiées.
Essayer


PUBLIC

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
propertyId	string	Oui	Property UUID ex. 660e8400-e29b-41d4-a716-446655440001
startDate	string	Oui	Start date (YYYY-MM-DD) ex. 2024-01-20
endDate	string	Oui	End date (YYYY-MM-DD) ex. 2024-01-25
EXEMPLE DE RÉPONSE
JSON
200 Availability status

Copy
{
  "available": true,
  "message": "Property is available for the selected dates",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "startDate": "2024-01-20",
  "endDate": "2024-01-25"
}
GET
Calendrier propriété
/api/properties/{id}/calendar

endpointDescriptions.getPropertyCalendar
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Property UUID
startDate	string	Non	Calendar start date (YYYY-MM-DD) ex. 2024-01-01
endDate	string	Non	Calendar end date (YYYY-MM-DD) ex. 2024-12-31
EXEMPLE DE RÉPONSE
JSON
200 Property calendar

Copy
{
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "startDate": "2024-01-01",
  "endDate": "2024-01-31",
  "calendar": [
    {
      "date": "2024-01-01",
      "status": "available",
      "reservationId": null
    },
    {
      "date": "2024-01-02",
      "status": "available",
      "reservationId": null
    },
    {
      "date": "2024-01-20",
      "status": "booked",
      "reservationId": "550e8400-e29b-41d4-a716-446655440000"
    },
    {
      "date": "2024-01-21",
      "status": "booked",
      "reservationId": "550e8400-e29b-41d4-a716-446655440000"
    }
  ]
}

Mes réservations (en tant qu'hôte)
(4 endpoints)
GET
Mes réservations
/api/me/reservations

Obtenir les réservations faites par l'utilisateur actuel.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Page number
status	string	Non	Filter by status (pending, confirmed, cancelled, completed)
EXEMPLE DE RÉPONSE
JSON
200 My property reservations

Copy
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "propertyId": "660e8400-e29b-41d4-a716-446655440001",
      "propertyTitle": "Modern Apartment in Gombe",
      "guestId": "770e8400-e29b-41d4-a716-446655440002",
      "guestName": "John Doe",
      "hostId": "880e8400-e29b-41d4-a716-446655440003",
      "hostName": "Jane Smith",
      "startDate": "2024-01-20T00: 00: 00+00: 00",
      "endDate": "2024-01-25T00: 00: 00+00: 00",
      "totalPrice": 2500,
      "currency": "USD",
      "status": "confirmed",
      "numberOfGuests": 2,
      "specialRequests": null,
      "numberOfNights": 5,
      "confirmedAt": "2024-01-16T14: 00: 00+00: 00",
      "cancelledAt": null,
      "completedAt": null,
      "createdAt": "2024-01-15T10: 30: 00+00: 00"
    }
  ]
}
GET
Réservations entrantes
/api/me/reservations/incoming

Obtenir les réservations à venir pour les propriétés de l'utilisateur.
Essayer


USER

EXEMPLE DE RÉPONSE
GET
Réservations passées
/api/me/reservations/past

Obtenir les réservations passées de l'utilisateur actuel.
Essayer


USER

EXEMPLE DE RÉPONSE
GET
Réservations annulées
/api/me/reservations/cancelled

Obtenir les réservations annulées de l'utilisateur actuel.
Essayer


USER

EXEMPLE DE RÉPONSE

Mes réservations (en tant que client)
(3 endpoints)
GET
Réservations reçues
/api/me/bookings

Obtenir les réservations reçues par le propriétaire.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Page number
EXEMPLE DE RÉPONSE
JSON
200 My bookings

Copy
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "propertyId": "660e8400-e29b-41d4-a716-446655440001",
      "propertyTitle": "Modern Apartment in Gombe",
      "guestId": "770e8400-e29b-41d4-a716-446655440002",
      "guestName": "John Doe",
      "hostId": "880e8400-e29b-41d4-a716-446655440003",
      "hostName": "Jane Smith",
      "startDate": "2024-01-20T00: 00: 00+00: 00",
      "endDate": "2024-01-25T00: 00: 00+00: 00",
      "totalPrice": 2500,
      "currency": "USD",
      "status": "confirmed",
      "numberOfGuests": 2,
      "specialRequests": null,
      "numberOfNights": 5,
      "confirmedAt": "2024-01-16T14: 00: 00+00: 00",
      "cancelledAt": null,
      "completedAt": null,
      "createdAt": "2024-01-15T10: 30: 00+00: 00"
    }
  ]
}
GET
En attente
/api/me/bookings/pending

Obtenir les demandes de réservation en attente.
Essayer


USER

EXEMPLE DE RÉPONSE
GET
Confirmées
/api/me/bookings/confirmed

Obtenir les réservations confirmées.
Essayer


USER

EXEMPLE DE RÉPONSE

Visites de propriétés
(7 endpoints)
GET
Détails visite
/api/visits/{id}

Obtenir les informations détaillées d'une visite spécifique.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Visit UUID
EXEMPLE DE RÉPONSE
JSON
200 Visit details

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "visitorId": "770e8400-e29b-41d4-a716-446655440002",
  "visitorName": "John Doe",
  "scheduledAt": "2024-01-20T14: 00: 00+00: 00",
  "status": "scheduled",
  "notes": "Interested in long-term rental",
  "confirmedAt": null,
  "completedAt": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Planifier visite
/api/visits

Planifier une visite de propriété.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
propertyId	string	Oui	Property UUID ex. 660e8400-e29b-41d4-a716-446655440001
visitorId	string	Oui	Visitor user UUID ex. 770e8400-e29b-41d4-a716-446655440002
scheduledAt	string	Oui	Visit date and time (ISO 8601) ex. 2024-01-20T14:00:00+00:00
notes	string	Non	Additional notes
EXEMPLE DE RÉPONSE
JSON
201 Visit scheduled

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "visitorId": "770e8400-e29b-41d4-a716-446655440002",
  "visitorName": "John Doe",
  "scheduledAt": "2024-01-20T14: 00: 00+00: 00",
  "status": "scheduled",
  "notes": "Interested in long-term rental",
  "confirmedAt": null,
  "completedAt": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
PUT
Modifier visite
/api/visits/{id}

Reprogrammer ou mettre à jour une visite de propriété.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Visit UUID
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
scheduledAt	string	Oui	New date and time (ISO 8601) ex. 2024-01-21T15:00:00+00:00
notes	string	Non	Updated notes
EXEMPLE DE RÉPONSE
JSON
200 Visit updated

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "visitorId": "770e8400-e29b-41d4-a716-446655440002",
  "visitorName": "John Doe",
  "scheduledAt": "2024-01-21T15: 00: 00+00: 00",
  "status": "scheduled",
  "notes": "Rescheduled - Interested in long-term rental",
  "confirmedAt": null,
  "completedAt": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
DELETE
Annuler visite
/api/visits/{id}

Annuler une visite planifiée.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Visit UUID
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
cancellationReason	string	Non	Reason for cancellation
EXEMPLE DE RÉPONSE
POST
Confirmer visite
/api/visits/{id}/confirm

Confirmer une visite planifiée.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Visit UUID
EXEMPLE DE RÉPONSE
JSON
200 Visit confirmed

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "visitorId": "770e8400-e29b-41d4-a716-446655440002",
  "visitorName": "John Doe",
  "scheduledAt": "2024-01-20T14: 00: 00+00: 00",
  "status": "confirmed",
  "notes": "Interested in long-term rental",
  "confirmedAt": "2024-01-16T10: 00: 00+00: 00",
  "completedAt": null,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Terminer visite
/api/visits/{id}/complete

Marquer une visite de propriété comme terminée.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	Visit UUID
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
notes	string	Non	Completion notes or feedback
EXEMPLE DE RÉPONSE
JSON
200 Visit completed

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Modern Apartment in Gombe",
  "visitorId": "770e8400-e29b-41d4-a716-446655440002",
  "visitorName": "John Doe",
  "scheduledAt": "2024-01-20T14: 00: 00+00: 00",
  "status": "completed",
  "notes": "Visit went well, client interested",
  "confirmedAt": "2024-01-16T10: 00: 00+00: 00",
  "completedAt": "2024-01-20T15: 30: 00+00: 00",
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}

Mes visites
(4 endpoints)
GET
Mes visites
/api/me/visits

Obtenir les visites planifiées par l'utilisateur actuel.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
status	string	Non	Filter by status (scheduled, confirmed, completed, cancelled)
EXEMPLE DE RÉPONSE
JSON
200 My scheduled visits

Copy
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "propertyId": "660e8400-e29b-41d4-a716-446655440001",
      "propertyTitle": "Modern Apartment in Gombe",
      "visitorId": "770e8400-e29b-41d4-a716-446655440002",
      "visitorName": "John Doe",
      "scheduledAt": "2024-01-20T14: 00: 00+00: 00",
      "status": "scheduled",
      "notes": "Interested in long-term rental",
      "confirmedAt": null,
      "completedAt": null,
      "createdAt": "2024-01-15T10: 30: 00+00: 00"
    }
  ]
}
GET
Visites à venir
/api/me/visits/upcoming

Obtenir les visites à venir.
Essayer


USER

EXEMPLE DE RÉPONSE
GET
Visites passées
/api/me/visits/past

Obtenir les visites passées.
Essayer


USER

EXEMPLE DE RÉPONSE
GET
Demandes visite
/api/me/visit-requests

Obtenir les demandes de visite pour les propriétés de l'utilisateur.
Essayer


USER

EXEMPLE DE RÉPONSE




API paiements
9 endpoints


Traitez les paiements, gérez les portefeuilles, suivez les transactions et gérez le support multi-devises.

Methodes de paiement supportees
L'API FUTELA utilise FlexPay comme passerelle de paiement principale pour les transactions mobile money.
Operateurs mobile money

M-Pesa

Orange Money

Airtel Money

Portefeuille FUTELA
Statuts des transactions

pending - En attente

processing - Traitement

completed - Complete

failed - Echoue

Devises
(2 endpoints)
GET
Liste devises
/api/currencies

Récupérer toutes les devises supportées.
Essayer


PUBLIC

EXEMPLE DE RÉPONSE
JSON
200 Liste des devises

Copy
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "code": "USD",
      "name": "Dollar americain",
      "symbol": "$",
      "exchangeRate": 1,
      "isActive": true,
      "createdAt": "2024-01-01T00: 00: 00+00: 00",
      "updatedAt": "2024-01-15T10: 00: 00+00: 00"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "code": "CDF",
      "name": "Franc congolais",
      "symbol": "FC",
      "exchangeRate": 2750,
      "isActive": true,
      "createdAt": "2024-01-01T00: 00: 00+00: 00",
      "updatedAt": "2024-01-15T10: 00: 00+00: 00"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "code": "EUR",
      "name": "Euro",
      "symbol": "E",
      "exchangeRate": 0.92,
      "isActive": true,
      "createdAt": "2024-01-01T00: 00: 00+00: 00",
      "updatedAt": "2024-01-15T10: 00: 00+00: 00"
    }
  ]
}
GET
Détails devise
/api/currencies/{code}

Obtenir les informations détaillées d'une devise spécifique.
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
code	string	Oui	Code de la devise (ISO 4217) ex. USD
EXEMPLE DE RÉPONSE
JSON
200 Details de la devise

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "code": "USD",
  "name": "Dollar americain",
  "symbol": "$",
  "exchangeRate": 1,
  "isActive": true,
  "createdAt": "2024-01-01T00: 00: 00+00: 00",
  "updatedAt": "2024-01-15T10: 00: 00+00: 00"
}

Paiements FlexPay
(2 endpoints)
POST
Initier paiement
/api/payments/initiate

Initier une nouvelle transaction de paiement.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
amount	number	Oui	Montant du paiement ex. 500
currency	string	Oui	Code devise (USD, CDF) ex. USD
gateway	string	Oui	Passerelle de paiement (flexpay) ex. flexpay
phoneNumber	string	Oui	Numero de telephone mobile money ex. +243812345678
description	string	Non	Description du paiement
metadata	object	Non	Donnees supplementaires
EXEMPLE DE RÉPONSE
JSON
200 Paiement initie

Copy
{
  "transactionId": "550e8400-e29b-41d4-a716-446655440000",
  "externalId": "FLEXPAY-TXN-123456",
  "amount": 500,
  "currency": "USD",
  "status": "pending",
  "gateway": "flexpay",
  "paymentUrl": "https://payment.flexpay.cd/pay/...",
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Webhook paiement
/api/payments/webhook

Point de terminaison webhook pour les callbacks du fournisseur de paiement.
Essayer


PUBLIC

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
externalId	string	Oui	ID de transaction FlexPay
status	string	Oui	Statut du paiement (completed, failed)
amount	number	Non	Montant confirme
EXEMPLE DE RÉPONSE
JSON
200 Webhook traite

Copy
{
  "success": true,
  "transactionId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "completed"
}

Portefeuille
(4 endpoints)
GET
Mon portefeuille
/api/me/wallet

Obtenir le portefeuille de l'utilisateur actuel.
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 Details du portefeuille

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "userId": "550e8400-e29b-41d4-a716-446655440001",
  "balance": 1250,
  "currency": "USD",
  "isActive": true,
  "lastTransactionAt": "2024-01-15T10: 30: 00+00: 00",
  "createdAt": "2024-01-01T00: 00: 00+00: 00"
}
GET
Solde portefeuille
/api/me/wallet/balance

Obtenir le solde d'un portefeuille.
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 Solde du portefeuille

Copy
{
  "walletId": "550e8400-e29b-41d4-a716-446655440000",
  "balance": 1250,
  "currency": "USD",
  "userId": "550e8400-e29b-41d4-a716-446655440001"
}
POST
Recharger
/api/me/wallet/topup

Recharger un portefeuille.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
amount	number	Oui	Montant a ajouter ex. 100
phoneNumber	string	Oui	Numero mobile money ex. +243812345678
description	string	Non	Description de la recharge
EXEMPLE DE RÉPONSE
JSON
200 Recharge initiee

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "walletId": "550e8400-e29b-41d4-a716-446655440001",
  "type": "deposit",
  "amount": 100,
  "currency": "USD",
  "status": "pending",
  "gateway": "flexpay",
  "paymentUrl": "https://payment.flexpay.cd/pay/...",
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Retirer
/api/me/wallet/withdraw

Retirer des fonds d'un portefeuille.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
amount	number	Oui	Montant a retirer ex. 100
phoneNumber	string	Oui	Numero mobile money de destination ex. +243812345678
description	string	Non	Description du retrait
EXEMPLE DE RÉPONSE
JSON
200 Retrait initie

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "walletId": "550e8400-e29b-41d4-a716-446655440001",
  "type": "withdrawal",
  "amount": 100,
  "currency": "USD",
  "status": "pending",
  "gateway": "flexpay",
  "description": "Retrait vers +243812345678",
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}

Transactions
(1 endpoint)
GET
Mes transactions
/api/me/transactions

Obtenir les transactions de l'utilisateur actuel.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Numero de page
type	string	Non	Filtrer par type (payment, deposit, withdrawal)
startDate	string	Non	Date de debut (YYYY-MM-DD)
endDate	string	Non	Date de fin (YYYY-MM-DD)
EXEMPLE DE RÉPONSE
JSON
200 Liste des transactions

Copy
{
  "transactions": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "walletId": "550e8400-e29b-41d4-a716-446655440001",
      "type": "payment",
      "amount": 500,
      "currency": "USD",
      "status": "completed",
      "gateway": "flexpay",
      "externalId": "FLEXPAY-123",
      "description": "Paiement reservation Appartement Gombe",
      "relatedEntity": "550e8400-e29b-41d4-a716-446655440003",
      "relatedEntityType": "reservation",
      "processedAt": "2024-01-15T10: 31: 00+00: 00",
      "createdAt": "2024-01-15T10: 30: 00+00: 00"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440004",
      "walletId": "550e8400-e29b-41d4-a716-446655440001",
      "type": "deposit",
      "amount": 1000,
      "currency": "USD",
      "status": "completed",
      "gateway": "flexpay",
      "description": "Recharge portefeuille",
      "processedAt": "2024-01-14T09: 00: 00+00: 00",
      "createdAt": "2024-01-14T09: 00: 00+00: 00"
    }
  ],
  "total": 25
}



API messagerie
23 endpoints


Messagerie en temps réel, notifications et formulaires de contact. Propulsé par Mercure pour les mises à jour instantanées.

Mises à jour en temps réel
Les messages et notifications sont livrés en temps réel via Server-Sent Events (SSE) via Mercure. Abonnez-vous au hub Mercure pour recevoir les mises à jour instantanées.
Types de messages
text
image
file
Types de notifications
reservation
payment
message
system

Conversations
(10 endpoints)
GET
Mes conversations
/api/conversations

Obtenir toutes les conversations de l'utilisateur actuel.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Numero de page (pagination)
unreadOnly	boolean	Non	Afficher uniquement les conversations non lues
EXEMPLE DE RÉPONSE
JSON
200 Liste des conversations avec pagination

Copy
{
  "conversations": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "subject": "Question sur Appartement moderne",
      "participants": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440001",
          "name": "Jean Dupont"
        },
        {
          "id": "550e8400-e29b-41d4-a716-446655440002",
          "name": "Marie Kabongo"
        }
      ],
      "participantIds": [ "550e8400-e29b-41d4-a716-446655440001",
        "550e8400-e29b-41d4-a716-446655440002"
      ],
      "propertyId": "550e8400-e29b-41d4-a716-446655440003",
      "propertyTitle": "Appartement moderne a Gombe",
      "lastMessageAt": "2024-01-15T10: 30: 00+00: 00",
      "isArchived": false,
      "createdAt": "2024-01-10T09: 00: 00+00: 00"
    }
  ],
  "total": 10
}
GET
Conversations archivées
/api/conversations/archived

Obtenir la liste des conversations archivées.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Numero de page
EXEMPLE DE RÉPONSE
JSON
200 Liste des conversations archivees

Copy
{
  "conversations": [],
  "total": 0
}
GET
Détails conversation
/api/conversations/{id}

Obtenir les informations détaillées d'une conversation spécifique.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID de la conversation
EXEMPLE DE RÉPONSE
JSON
200 Details de la conversation

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "subject": "Question sur Appartement moderne",
  "participants": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Jean Dupont"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "Marie Kabongo"
    }
  ],
  "propertyId": "550e8400-e29b-41d4-a716-446655440003",
  "propertyTitle": "Appartement moderne a Gombe",
  "lastMessageAt": "2024-01-15T10: 30: 00+00: 00",
  "isArchived": false,
  "createdAt": "2024-01-10T09: 00: 00+00: 00"
}
POST
Créer conversation
/api/conversations

Démarrer une nouvelle conversation.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
subject	string	Oui	Sujet de la conversation ex. Question sur votre propriete
participantIds	array	Oui	Tableau d'UUID des participants (minimum 2) ex. ["uuid1", "uuid2"]
propertyId	string	Non	UUID de la propriete (optionnel)
EXEMPLE DE RÉPONSE
JSON
201 Conversation creee

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "subject": "Question sur votre propriete",
  "participants": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Jean Dupont"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "Marie Kabongo"
    }
  ],
  "isArchived": false,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
DELETE
Supprimer conversation
/api/conversations/{id}

Supprimer une conversation.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID de la conversation
EXEMPLE DE RÉPONSE
GET
Messages de conversation
/api/conversations/{id}/messages

Récupérer tous les messages d'une conversation.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID de la conversation
page	integer	Non	Numero de page
order[createdAt]	string	Non	Ordre de tri (asc/desc)
EXEMPLE DE RÉPONSE
JSON
200 Messages de la conversation

Copy
{
  "messages": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440010",
      "conversationId": "550e8400-e29b-41d4-a716-446655440000",
      "senderId": "550e8400-e29b-41d4-a716-446655440001",
      "senderName": "Jean Dupont",
      "content": "L'appartement est-il toujours disponible ?",
      "type": "text",
      "attachments": [],
      "isRead": true,
      "readAt": "2024-01-15T10: 35: 00+00: 00",
      "createdAt": "2024-01-15T10: 30: 00+00: 00"
    }
  ],
  "total": 1
}
POST
Archiver conversation
/api/conversations/{id}/archive

Archiver une conversation.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID de la conversation
EXEMPLE DE RÉPONSE
JSON
200 Conversation archivee

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "isArchived": true
}
POST
Démarrer conversation avec utilisateur
/api/users/{userId}/conversations

Démarrer ou obtenir une conversation existante avec un utilisateur.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
userId	string	Oui	UUID de l'utilisateur
EXEMPLE DE RÉPONSE
JSON
200 Conversation (nouvelle ou existante)

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "subject": "Conversation directe",
  "participants": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Jean Dupont"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "Marie Kabongo"
    }
  ],
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Démarrer conversation sur propriété
/api/properties/{propertyId}/conversations

Démarrer une conversation avec le propriétaire à propos d'une annonce.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
propertyId	string	Oui	UUID de la propriete
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
message	string	Non	Message initial (optionnel) ex. Bonjour, votre appartement est-il disponible ?
EXEMPLE DE RÉPONSE
JSON
200 Conversation avec le proprietaire

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "subject": "Question sur Appartement moderne",
  "propertyId": "550e8400-e29b-41d4-a716-446655440100",
  "propertyTitle": "Appartement moderne a Gombe",
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Contacter le propriétaire
/api/properties/{propertyId}/contact-owner

Envoyer une demande au propriétaire (public, sans authentification).
Essayer


PUBLIC

PARAMÈTRES URL
Champ	Type	requis	Description
propertyId	string	Oui	UUID de la propriete
CORPS DE LA REQUÊTE
Champ	Type	requis	Description
name	string	Oui	Nom du demandeur ex. Jean Dupont
email	string	Oui	Email du demandeur ex. jean@email.com
phone	string	Non	Telephone du demandeur ex. +243812345678
message	string	Oui	Message pour le proprietaire
EXEMPLE DE RÉPONSE
JSON
200 Demande de contact envoyee

Copy
{
  "success": true,
  "message": "Votre message a ete envoye au proprietaire"
}

Messages
(6 endpoints)
GET
Détails message
/api/messages/{id}

Obtenir les informations détaillées d'un message spécifique.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID du message
EXEMPLE DE RÉPONSE
JSON
200 Details du message

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "conversationId": "550e8400-e29b-41d4-a716-446655440001",
  "senderId": "550e8400-e29b-41d4-a716-446655440002",
  "senderName": "Jean Dupont",
  "content": "L'appartement est-il toujours disponible ?",
  "type": "text",
  "attachments": [],
  "isRead": true,
  "readAt": "2024-01-15T10: 35: 00+00: 00",
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
POST
Envoyer message
/api/messages

Envoyer un message dans une conversation.
Essayer


USER

CORPS DE LA REQUÊTE
Champ	Type	requis	Description
conversationId	string	Oui	UUID de la conversation
senderId	string	Oui	UUID de l'expediteur
content	string	Oui	Contenu du message
attachments	array	Non	Pieces jointes {filename, url, size, mimeType}
EXEMPLE DE RÉPONSE
JSON
201 Message envoye

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "conversationId": "550e8400-e29b-41d4-a716-446655440001",
  "senderId": "550e8400-e29b-41d4-a716-446655440002",
  "senderName": "Jean Dupont",
  "content": "Oui, il est toujours disponible !",
  "type": "text",
  "attachments": [],
  "isRead": false,
  "createdAt": "2024-01-15T10: 40: 00+00: 00"
}
DELETE
Supprimer message
/api/messages/{id}

Supprimer un message.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID du message
EXEMPLE DE RÉPONSE
PUT
Marquer lu
/api/messages/{id}/read

Marquer un message comme lu.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID du message
EXEMPLE DE RÉPONSE
JSON
200 Message marque comme lu

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "isRead": true,
  "readAt": "2024-01-15T10: 35: 00+00: 00"
}
GET
Mes messages
/api/me/messages

Obtenir tous les messages qui me sont envoyés.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Numero de page
EXEMPLE DE RÉPONSE
JSON
200 Liste des messages

Copy
{
  "messages": [],
  "total": 0
}
GET
endpoints.getUnreadMessagesCount
/api/me/messages/unread

endpointDescriptions.getUnreadMessagesCount
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 Compteur de messages non lus

Copy
{
  "count": 5
}

Notifications
(7 endpoints)
GET
Liste notifications
/api/notifications

Obtenir toutes les notifications de l'utilisateur actuel.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
page	integer	Non	Numero de page
type	string	Non	Filtrer par type (reservation, payment, message, system)
EXEMPLE DE RÉPONSE
JSON
200 Liste des notifications

Copy
{
  "notifications": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "userId": "550e8400-e29b-41d4-a716-446655440001",
      "type": "reservation_confirmed",
      "title": "Reservation confirmee",
      "content": "Votre reservation pour Appartement moderne a ete confirmee.",
      "data": {
        "reservationId": "550e8400-e29b-41d4-a716-446655440002"
      },
      "relatedEntityId": "550e8400-e29b-41d4-a716-446655440002",
      "relatedEntityType": "reservation",
      "status": "sent",
      "channel": "web",
      "isRead": false,
      "readAt": null,
      "sentVia": [ "web",
        "email"
      ],
      "createdAt": "2024-01-15T10: 30: 00+00: 00"
    }
  ],
  "total": 25
}
GET
Nombre de non lus
/api/notifications/unread-count

Obtenir le nombre de notifications non lues.
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 Compteur de notifications non lues

Copy
{
  "count": 5
}
GET
Notifications non lues
/api/notifications/unread

Obtenir toutes les notifications non lues.
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 Liste des notifications non lues

Copy
{
  "notifications": [],
  "total": 0
}
PUT
Tout marquer lu
/api/notifications/mark-all-read

Marquer toutes les notifications comme lues.
Essayer


USER

EXEMPLE DE RÉPONSE
JSON
200 Toutes les notifications marquees comme lues

Copy
{
  "markedCount": 15
}
GET
Détails notification
/api/notifications/{id}

Obtenir les informations détaillées d'une notification spécifique.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID de la notification
EXEMPLE DE RÉPONSE
JSON
200 Details de la notification

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "userId": "550e8400-e29b-41d4-a716-446655440001",
  "type": "reservation_confirmed",
  "title": "Reservation confirmee",
  "content": "Votre reservation pour Appartement moderne a ete confirmee.",
  "data": {
    "reservationId": "550e8400-e29b-41d4-a716-446655440002"
  },
  "isRead": false,
  "createdAt": "2024-01-15T10: 30: 00+00: 00"
}
PUT
Marquer notif. lue
/api/notifications/{id}/read

Marquer une notification comme lue.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID de la notification
EXEMPLE DE RÉPONSE
JSON
200 Notification marquee comme lue

Copy
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "isRead": true,
  "readAt": "2024-01-15T10: 35: 00+00: 00"
}
DELETE
Supprimer notif.
/api/notifications/{id}

Supprimer une notification.
Essayer


USER

PARAMÈTRES URL
Champ	Type	requis	Description
id	string	Oui	UUID de la notification
EXEMPLE DE RÉPONSE
