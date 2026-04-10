# Bugfix Requirements Document

## Introduction

L'endpoint d'authentification Apple Sign-In `/api/auth/apple` présente un problème de validation des tokens Apple. L'application mobile envoie correctement les données avec les bons noms de champs, mais le backend retourne "Jeton Apple invalide" (401).

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN l'application mobile envoie une requête POST à `/api/auth/apple` avec des credentials Apple valides (incluant un token Apple JWT valide) THEN le système retourne une erreur 401 "Jeton Apple invalide"

1.2 WHEN le backend reçoit un token Apple avec une signature valide, audience correcte (`com.naara.futela`), et émetteur correct (`https://appleid.apple.com`) THEN le système rejette incorrectement le token

### Expected Behavior (Correct)

2.1 WHEN l'application mobile envoie une requête POST à `/api/auth/apple` avec un token Apple valide THEN le système SHALL valider correctement le token en utilisant les clés publiques d'Apple

2.2 WHEN le token Apple contient l'audience `com.naara.futela` et l'émetteur `https://appleid.apple.com` THEN le système SHALL accepter le token comme valide

2.3 WHEN la validation réussit THEN le système SHALL créer ou connecter l'utilisateur et retourner un JWT token d'authentification

### Token Apple Validation Requirements

3.1 Le backend SHALL récupérer les clés publiques d'Apple depuis `https://appleid.apple.com/auth/keys`

3.2 Le backend SHALL utiliser la clé correspondant au `kid` du token pour valider la signature

3.3 Le backend SHALL vérifier que :
   - `iss` = `https://appleid.apple.com`
   - `aud` = `com.naara.futela`
   - `exp` > temps actuel (token non expiré)

3.4 Le backend SHALL gérer les emails de relais privé Apple (`is_private_email: true`)

### Unchanged Behavior (Regression Prevention)

4.1 WHEN d'autres endpoints protégés sont appelés sans JWT token THEN le système SHALL CONTINUE TO retourner une erreur 401

4.2 WHEN l'endpoint `/api/auth/apple` reçoit des credentials Apple réellement invalides THEN le système SHALL CONTINUE TO retourner une erreur d'authentification appropriée

4.3 WHEN l'authentification Apple réussit THEN le système SHALL CONTINUE TO générer et retourner un JWT token valide pour les requêtes ultérieures

## Mobile App Status ✅

L'application mobile fonctionne correctement et envoie :
- `idToken` : Token JWT Apple valide
- `authorizationCode` : Code d'autorisation Apple
- `userIdentifier` : Identifiant utilisateur Apple

## Backend Requirements

Le backend doit implémenter la validation correcte des tokens Apple selon les spécifications d'Apple :

1. **Récupération des clés publiques** depuis l'endpoint Apple
2. **Validation de la signature JWT** avec la clé appropriée
3. **Vérification des claims** (iss, aud, exp)
4. **Gestion des emails privés** Apple

Voir `APPLE_SIGNIN_TOKEN_VALIDATION_DEBUG.md` pour les détails techniques complets.