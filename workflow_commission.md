 Voici le workflow complet du système de commissions dans Futela, basé sur le code actuel :                                                                                                                         
                                                            
  Vue d'ensemble — Les acteurs                                                                                                                                                                                       
                                                                                                                                                                                                                     
  Propriétaire (landlord)  →  délègue sa propriété à un  →  Commissionnaire                                                                                                                                          
                                                                    ↓                                                                                                                                                
                                                           gère les visites                                                                                                                                          
                                                                    ↓                                                                                                                                                
  Visiteur (visitor)  →  réserve et paie une visite  →  Commission générée                                                                                                                                           
                                                                    ↓                                                                                                                                                
                                                           Code OTP au visiteur                                                                                                                                      
                                                                    ↓                                                                                                                                                
                              Commissionnaire saisit le code  →  Commission vérifiée
                                                                    ↓                                                                                                                                                
                                                           Solde crédité au wallet
                                                                    ↓                                                                                                                                                
                              Commissionnaire demande un retrait  →  Admin approuve
                                                                    ↓                                                                                                                                                
                                                            Mobile Money
                                                                                                                                                                                                                     
  Phase 1 — La délégation (point de départ)                                                                                                                                                                          
  
  Avant qu'un commissionnaire puisse toucher quoi que ce soit, le propriétaire doit déléguer sa propriété via PropertyDelegation :                                                                                   
                                                            
  - Route : POST /api/properties/{id}/delegate                                                                                                                                                                       
  - Paramètres : commissionnaireId + commissionRate (optionnel, défaut 5%)
  - Résultat : l'entité PropertyDelegation lie la propriété à un commissionnaire avec un taux de commission fixé                                                                                                     
                                                                                                                                                                                                                     
  C'est le commissionnaire désigné qui gère les visites de cette propriété (il les voit dans son dashboard, peut les planifier, etc.). Il n'y a pas de notion d'"accepter une visite" — dès que le visiteur paie une 
  visite sur une propriété déléguée, la commission est automatiquement attribuée au commissionnaire de la délégation.                                                                                                
                                                                                                                                                                                                                     
  Phase 2 — Le paiement déclenche la commission (automatique)                                                                                                                                                        
  
  Fichier clé : ConfirmPaymentUseCase.php:84-130                                                                                                                                                                     
                                                            
  Quand le webhook FlexPay confirme le paiement d'une visite :                                                                                                                                                       
                                                            
  1. La transaction est marquée completed                                                                                                                                                                            
  2. La visite est marquée paid                             
  3. Auto-création de la commission si la propriété a une délégation active :                                                                                                                                        
  commissionAmount = transaction.amount × commissionRate / 100                                                                                                                                                       
  platformFee     = transaction.amount − commissionAmount                                                                                                                                                            
  3. Exemple : visite payée 10$, taux 5% → commissionnaire touche 0.50$, plateforme garde 9.50$                                                                                                                      
  4. Un code OTP à 6 chiffres est généré (Commission::generateVerificationCode())                                                                                                                                    
  5. Le statut passe à code_sent                                                                                                                                                                                     
  6. Le code est envoyé au visiteur (pas au commissionnaire) — il apparaît dans son popup via GET /api/me/verification-codes + Mercure SSE sur le topic /api/users/{userId}/commission-code                          
                                                                                                                                                                                                                     
  Pourquoi au visiteur et pas au commissionnaire ? C'est le cœur du système anti-fraude : le commissionnaire doit physiquement rencontrer le visiteur pour recevoir le code de sa part. Sans cette preuve, il ne     
  touche rien.                                                                                                                                                                                                       
                                                                                                                                                                                                                     
  Phase 3 — La vérification (preuve de la visite réelle)    

  Fichier clé : VerifyCommissionCodeUseCase.php                                                                                                                                                                      
  
  Le commissionnaire rencontre le visiteur pour la visite réelle. Le visiteur lui montre le code OTP sur son écran. Deux chemins possibles :                                                                         
                                                            
  A — Le commissionnaire connaît la commission :                                                                                                                                                                     
  - Route : POST /api/commissionnaire/commissions/{id}/verify avec {"code": "358615"}
                                                                                                                                                                                                                     
  B — Le commissionnaire ne sait pas laquelle (cas fréquent) :
  - Route : POST /api/commissionnaire/commissions/find-by-phone avec {"phone": "0812345678"}                                                                                                                         
  - Le backend normalise le téléphone et retrouve la commission en attente liée à ce visiteur                                                                                                                        
  - Puis il vérifie avec le code                                                                                                                                                                                     
                                                                                                                                                                                                                     
  Contrôles de sécurité (code lignes 42-62) :               
  - isLocked() → après 5 tentatives échouées, la commission est verrouillée définitivement                                                                                                                           
  - isCodeExpired() → le code expire après 24 heures                                                                                                                                                                 
  - verifyCode() → compare le code avec le hash bcrypt stocké ; incrémente failedAttempts si mauvais                                                                                                                 
  - Vérification que le commissionnaire qui tente est bien celui assigné à la commission                                                                                                                             
                                                                                                                                                                                                                     
  Si tout passe → statut verified, verifiedAt est rempli, événement CommissionVerifiedEvent dispatché → notification Mercure vers le visiteur ET l'admin. À partir de ce moment, le montant entre dans le solde du   
  commissionnaire.                                                                                                                                                                                                   
                                                                                                                                                                                                                     
  Phase 4 — Le calcul du wallet                                                                                                                                                                                      
                                                            
  Fichier clé : GetCommissionnaireWalletUseCase.php                                                                                                                                                                  
                                                            
  totalEarnings       = Σ commissions vérifiées (status = verified)                                                                                                                                                  
  pendingCommissions  = Σ commissions non vérifiées (pending + code_sent)
  totalWithdrawn      = Σ retraits terminés (status = completed)                                                                                                                                                     
  pendingWithdrawals  = Σ retraits en cours (pending + approved + processing)                                                                                                                                        
                                                                                                                                                                                                                     
  walletBalance = totalEarnings − totalWithdrawn − pendingWithdrawals                                                                                                                                                
                                                                                                                                                                                                                     
  Le walletBalance est le montant réellement retirable à l'instant T. Les retraits en cours sont soustraits pour empêcher un double-retrait tant qu'un retrait précédent n'est pas résolu.                           
                                                            
  Phase 5 — Le retrait                                                                                                                                                                                               
                                                            
  Fichier clé : RequestWithdrawalUseCase.php                                                                                                                                                                         
                                                            
  1. Le commissionnaire demande un retrait via POST /api/commissionnaire/withdrawals avec {"amount": 5.0, "phoneNumber": "0812345678"}                                                                               
  2. Le backend recalcule le solde disponible (même formule que le wallet) pour éviter les conditions de course
  3. Si amount > available → DomainException("Solde insuffisant")                                                                                                                                                    
  4. Normalisation du numéro : 0812... → +243812...                                                                                                                                                                  
  5. Création d'un Withdrawal avec statut pending                                                                                                                                                                    
  6. L'admin reçoit une notification via Mercure (topic admin)                                                                                                                                                       
                                                                                                                                                                                                                     
  L'admin approuve via POST /api/admin/withdrawals/{id}/approve :                                                                                                                                                    
                                                                                                                                                                                                                     
  Fichier clé : ApproveWithdrawalUseCase.php:36-39                                                                                                                                                                   
                                                            
  $withdrawal->approve($admin);       // pending → approved                                                                                                                                                          
  $withdrawal->markAsCompleted();     // approved → completed (directement)
                                                                                                                                                                                                                     
  ⚠️  Important — statut actuel MVP : le commentaire ligne 37 dit explicitement "MVP : marquer comme terminé directement (pas de FlexPay payout)". Autrement dit, le paiement Mobile Money n'est PAS encore automatisé
   — l'admin doit manuellement envoyer l'argent au commissionnaire, puis cliquer "Approuver" qui marque simplement l'opération comme terminée dans le système. L'intégration FlexPay payout est à faire dans une     
  phase ultérieure.                                                                                                                                                                                                  
                                                            
  L'admin peut aussi rejeter avec POST /api/admin/withdrawals/{id}/reject + {"reason": "..."} → le montant retourne dans le walletBalance.                                                                           
   
  Statuts récapitulatifs                                                                                                                                                                                             
                                                            
  Commission :                                                                                                                                                                                                       
                                                            
  ┌───────────┬─────────────────────────────────────────────────────────┐
  │  Statut   │                      Signification                      │                                                                                                                                            
  ├───────────┼─────────────────────────────────────────────────────────┤
  │ pending   │ Créée, code pas encore généré                           │                                                                                                                                            
  ├───────────┼─────────────────────────────────────────────────────────┤
  │ code_sent │ Code OTP envoyé au visiteur, en attente de vérification │
  ├───────────┼─────────────────────────────────────────────────────────┤                                                                                                                                            
  │ verified  │ ✅ Commissionnaire a saisi le bon code, montant crédité │
  ├───────────┼─────────────────────────────────────────────────────────┤                                                                                                                                            
  │ expired   │ Code non utilisé dans les 24h                           │
  ├───────────┼─────────────────────────────────────────────────────────┤                                                                                                                                            
  │ locked    │ 5 tentatives échouées — verrouillée définitivement      │
  ├───────────┼─────────────────────────────────────────────────────────┤                                                                                                                                            
  │ cancelled │ Annulée par l'admin                                     │
  └───────────┴─────────────────────────────────────────────────────────┘                                                                                                                                            
                                                            
  Withdrawal :                                                                                                                                                                                                       
   
  ┌────────────┬─────────────────────────────────────────────┐                                                                                                                                                       
  │   Statut   │                Signification                │
  ├────────────┼─────────────────────────────────────────────┤
  │ pending    │ Demande créée, en attente admin             │
  ├────────────┼─────────────────────────────────────────────┤
  │ approved   │ Admin a validé                              │                                                                                                                                                       
  ├────────────┼─────────────────────────────────────────────┤
  │ processing │ En cours de traitement (non utilisé en MVP) │                                                                                                                                                       
  ├────────────┼─────────────────────────────────────────────┤                                                                                                                                                       
  │ completed  │ ✅ Terminé, argent transféré                │
  ├────────────┼─────────────────────────────────────────────┤                                                                                                                                                       
  │ rejected   │ Refusé par l'admin                          │
  ├────────────┼─────────────────────────────────────────────┤                                                                                                                                                       
  │ failed     │ Échec technique                             │
  └────────────┴─────────────────────────────────────────────┘                                                                                                                                                       
   
  Points d'attention                                                                                                                                                                                                 
                                                            
  1. Le commissionnaire n'a pas de rôle actif dans le déclenchement — tout part du paiement du visiteur. Il ne peut pas "accepter" une visite au sens strict ; la délégation suffit à lui attribuer les commissions. 
  2. Le code OTP est la preuve de visite physique — sans rencontre réelle, pas de vérification possible, donc pas de paiement.
  3. Le wallet balance est recalculé à chaque requête — pas de colonne balance stockée, tout est dérivé des commissions + retraits. C'est plus lent mais garantit la cohérence.                                      
  4. Multi-devise — chaque commission porte la devise de sa transaction source (USD ou CDF). Le wallet actuel retourne currency: 'USD' en dur (GetCommissionnaireWalletUseCase.php:67) — c'est un bug potentiel si un
   commissionnaire a des commissions en CDF et USD mélangées. À surveiller.                                                                                                                                          
  5. Le payout Mobile Money est manuel — l'admin doit envoyer l'argent lui-même puis marquer "approuvé". Pas d'intégration FlexPay sortante pour l'instant.                                                          
                                                                                                                                                                                                                     
  Si tu veux, je peux détailler un point spécifique, ou on peut travailler sur le bug multi-devise du wallet (point 4) qui me semble important pour ta vraie exploitation.