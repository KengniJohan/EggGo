# Description Statique - Diagramme de Classes

## 1. Introduction

Ce document présente la modélisation statique du système EggGo à travers le diagramme de classes UML. Ce diagramme représente la structure des données et les relations entre les entités du système.

---

## 2. Diagramme de Classes Complet

```mermaid
classDiagram
    %% ===== UTILISATEURS =====
    class Utilisateur {
        <<abstract>>
        +Long id
        +String nom
        +String prenom
        +String telephone
        +String email
        +String motDePasse
        +String photoProfil
        +Boolean actif
        +LocalDateTime dateCreation
        +LocalDateTime dateModification
        +seConnecter()
        +seDeconnecter()
        +modifierProfil()
        +reinitialiserMotDePasse()
    }

    class Client {
        +List~Adresse~ adresses
        +List~Commande~ commandes
        +List~Abonnement~ abonnements
        +Integer pointsFidelite
        +passerCommande()
        +suivreCommande()
        +noterProduit()
        +noterLivreur()
        +gererAbonnement()
    }

    class Livreur {
        +String numeroPieceIdentite
        +String typeVehicule
        +String numeroPlaque
        +Boolean disponible
        +Double latitude
        +Double longitude
        +Double noteMoyenne
        +Integer nombreLivraisons
        +List~Livraison~ livraisons
        +accepterLivraison()
        +refuserLivraison()
        +mettreAJourPosition()
        +confirmerLivraison()
        +signalerProbleme()
    }

    class Producteur {
        +String nomFerme
        +String description
        +String adresseFerme
        +Double latitude
        +Double longitude
        +String logoFerme
        +Boolean certifie
        +Double noteMoyenne
        +List~Produit~ produits
        +List~Commande~ commandes
        +ajouterProduit()
        +modifierStock()
        +confirmerCommande()
        +consulterStatistiques()
    }

    class Administrateur {
        +String role
        +List~String~ permissions
        +gererUtilisateurs()
        +gererProduits()
        +consulterStatistiques()
        +envoyerNotification()
    }

    %% ===== PRODUITS =====
    class Produit {
        +Long id
        +String nom
        +String description
        +String image
        +Double prixUnitaire
        +Integer quantiteStock
        +Unite unite
        +Boolean disponible
        +LocalDateTime dateAjout
        +Categorie categorie
        +Producteur producteur
        +List~Avis~ avis
        +calculerPrixTotal(quantite)
        +verifierDisponibilite(quantite)
        +mettreAJourStock(quantite)
    }

    class Categorie {
        +Long id
        +String nom
        +String description
        +String icone
        +List~Produit~ produits
    }

    class Unite {
        <<enumeration>>
        PIECE
        PLATEAU_30
        CARTON_180
        CARTON_360
    }

    %% ===== COMMANDES =====
    class Commande {
        +Long id
        +String reference
        +Client client
        +Producteur producteur
        +Livreur livreur
        +Adresse adresseLivraison
        +StatutCommande statut
        +Double montantProduits
        +Double fraisLivraison
        +Double montantTotal
        +Double montantRemise
        +ModePaiement modePaiement
        +Boolean paye
        +String creneauLivraison
        +LocalDateTime dateCommande
        +LocalDateTime dateLivraison
        +String notes
        +List~LigneCommande~ lignes
        +Livraison livraison
        +calculerTotal()
        +appliquerPromotion()
        +mettreAJourStatut()
        +annuler()
    }

    class LigneCommande {
        +Long id
        +Produit produit
        +Integer quantite
        +Double prixUnitaire
        +Double prixTotal
        +calculerPrixLigne()
    }

    class StatutCommande {
        <<enumeration>>
        EN_ATTENTE
        CONFIRMEE
        EN_PREPARATION
        PRETE
        EN_LIVRAISON
        LIVREE
        ANNULEE
        REMBOURSEE
    }

    class ModePaiement {
        <<enumeration>>
        MTN_MOMO
        ORANGE_MONEY
        CASH_LIVRAISON
        CARTE_BANCAIRE
    }

    %% ===== LIVRAISONS =====
    class Livraison {
        +Long id
        +Commande commande
        +Livreur livreur
        +StatutLivraison statut
        +LocalDateTime dateAcceptation
        +LocalDateTime dateRecuperation
        +LocalDateTime dateLivraison
        +String codeConfirmation
        +Double distanceKm
        +String notes
        +List~PositionGPS~ historiquePosistions
        +accepter()
        +recuperer()
        +terminer()
        +signaler()
    }

    class StatutLivraison {
        <<enumeration>>
        ASSIGNEE
        ACCEPTEE
        EN_ROUTE_PRODUCTEUR
        RECUPEREE
        EN_ROUTE_CLIENT
        ARRIVEE
        LIVREE
        ECHOUEE
    }

    class PositionGPS {
        +Long id
        +Double latitude
        +Double longitude
        +LocalDateTime timestamp
    }

    %% ===== ADRESSES =====
    class Adresse {
        +Long id
        +String libelle
        +String rue
        +String quartier
        +String ville
        +String description
        +Double latitude
        +Double longitude
        +Boolean principale
        +Client client
    }

    %% ===== ABONNEMENTS =====
    class Abonnement {
        +Long id
        +Client client
        +String nom
        +Frequence frequence
        +Integer jourLivraison
        +Adresse adresseLivraison
        +Boolean actif
        +LocalDate dateDebut
        +LocalDate dateFin
        +List~LigneAbonnement~ lignes
        +activer()
        +desactiver()
        +modifier()
        +genererCommande()
    }

    class LigneAbonnement {
        +Long id
        +Produit produit
        +Integer quantite
    }

    class Frequence {
        <<enumeration>>
        HEBDOMADAIRE
        BI_MENSUELLE
        MENSUELLE
    }

    %% ===== AVIS ET NOTATIONS =====
    class Avis {
        +Long id
        +Client client
        +Integer note
        +String commentaire
        +LocalDateTime dateAvis
        +Boolean valide
    }

    class AvisProduit {
        +Produit produit
    }

    class AvisLivreur {
        +Livreur livreur
        +Commande commande
    }

    class AvisProducteur {
        +Producteur producteur
        +Commande commande
    }

    %% ===== PROMOTIONS =====
    class Promotion {
        +Long id
        +String code
        +String description
        +TypePromotion type
        +Double valeur
        +Double montantMinimum
        +Integer utilisationsMax
        +Integer utilisationsActuelles
        +LocalDate dateDebut
        +LocalDate dateFin
        +Boolean active
        +List~Produit~ produitsEligibles
        +verifierValidite()
        +appliquer()
    }

    class TypePromotion {
        <<enumeration>>
        POURCENTAGE
        MONTANT_FIXE
        LIVRAISON_GRATUITE
    }

    %% ===== PAIEMENTS =====
    class Paiement {
        +Long id
        +Commande commande
        +Double montant
        +ModePaiement mode
        +StatutPaiement statut
        +String referenceExterne
        +LocalDateTime dateInitiation
        +LocalDateTime dateConfirmation
        +initier()
        +confirmer()
        +annuler()
        +rembourser()
    }

    class StatutPaiement {
        <<enumeration>>
        EN_ATTENTE
        EN_COURS
        REUSSI
        ECHOUE
        REMBOURSE
    }

    %% ===== NOTIFICATIONS =====
    class Notification {
        +Long id
        +Utilisateur destinataire
        +String titre
        +String message
        +TypeNotification type
        +Boolean lue
        +LocalDateTime dateEnvoi
        +String donnees
        +envoyer()
        +marquerCommeLue()
    }

    class TypeNotification {
        <<enumeration>>
        COMMANDE
        LIVRAISON
        PROMOTION
        SYSTEME
    }

    %% ===== ZONES DE LIVRAISON =====
    class ZoneLivraison {
        +Long id
        +String nom
        +String ville
        +List~String~ quartiers
        +Double fraisLivraison
        +Integer delaiEstime
        +Boolean active
        +verifierCouverture()
        +calculerFrais()
    }

    %% ===== RELATIONS =====
    Utilisateur <|-- Client
    Utilisateur <|-- Livreur
    Utilisateur <|-- Producteur
    Utilisateur <|-- Administrateur

    Client "1" --> "*" Adresse : possède
    Client "1" --> "*" Commande : passe
    Client "1" --> "*" Abonnement : souscrit
    Client "1" --> "*" Avis : redige

    Producteur "1" --> "*" Produit : propose
    Producteur "1" --> "*" Commande : reçoit

    Produit "*" --> "1" Categorie : appartient
    Produit "1" --> "*" Avis : reçoit

    Commande "1" --> "*" LigneCommande : contient
    Commande "*" --> "1" Adresse : livrée à
    Commande "1" --> "0..1" Livraison : associée
    Commande "1" --> "0..1" Paiement : payée par
    Commande "*" --> "0..1" Promotion : utilise

    LigneCommande "*" --> "1" Produit : concerne

    Livraison "*" --> "1" Livreur : effectuée par
    Livraison "1" --> "*" PositionGPS : tracée

    Abonnement "1" --> "*" LigneAbonnement : contient
    Abonnement "*" --> "1" Adresse : livrée à
    LigneAbonnement "*" --> "1" Produit : concerne

    Avis <|-- AvisProduit
    Avis <|-- AvisLivreur
    Avis <|-- AvisProducteur

    Notification "*" --> "1" Utilisateur : destinée à
```

---

## 3. Description des Classes Principales

### 3.1 Classe Utilisateur (Abstraite)

La classe `Utilisateur` est la classe mère de tous les types d'utilisateurs du système.

| Attribut | Type | Description |
|----------|------|-------------|
| id | Long | Identifiant unique |
| nom | String | Nom de famille |
| prenom | String | Prénom |
| telephone | String | Numéro de téléphone (unique) |
| email | String | Adresse email (optionnel) |
| motDePasse | String | Mot de passe hashé |
| photoProfil | String | URL de la photo |
| actif | Boolean | Compte actif ou désactivé |
| dateCreation | LocalDateTime | Date de création du compte |

### 3.2 Classe Client

Hérite de `Utilisateur`. Représente un client qui commande des œufs.

| Attribut spécifique | Type | Description |
|---------------------|------|-------------|
| adresses | List<Adresse> | Adresses de livraison |
| commandes | List<Commande> | Historique des commandes |
| abonnements | List<Abonnement> | Abonnements actifs |
| pointsFidelite | Integer | Points de fidélité cumulés |

### 3.3 Classe Livreur

Hérite de `Utilisateur`. Représente un livreur partenaire.

| Attribut spécifique | Type | Description |
|---------------------|------|-------------|
| numeroPieceIdentite | String | CNI ou passeport |
| typeVehicule | String | Moto, vélo, voiture |
| numeroPlaque | String | Immatriculation |
| disponible | Boolean | Disponibilité actuelle |
| latitude/longitude | Double | Position GPS actuelle |
| noteMoyenne | Double | Note moyenne reçue |
| nombreLivraisons | Integer | Total livraisons effectuées |

### 3.4 Classe Producteur

Hérite de `Utilisateur`. Représente une ferme avicole partenaire.

| Attribut spécifique | Type | Description |
|---------------------|------|-------------|
| nomFerme | String | Nom commercial de la ferme |
| description | String | Description de la ferme |
| adresseFerme | String | Adresse physique |
| latitude/longitude | Double | Coordonnées GPS |
| logoFerme | String | URL du logo |
| certifie | Boolean | Certification qualité |
| noteMoyenne | Double | Note moyenne reçue |

### 3.5 Classe Produit

Représente un produit (type d'œuf) disponible à la vente.

| Attribut | Type | Description |
|----------|------|-------------|
| id | Long | Identifiant unique |
| nom | String | Nom du produit |
| description | String | Description détaillée |
| image | String | URL de l'image |
| prixUnitaire | Double | Prix par unité |
| quantiteStock | Integer | Stock disponible |
| unite | Unite | Unité de vente (pièce, plateau, carton) |
| disponible | Boolean | Disponibilité |
| categorie | Categorie | Catégorie du produit |
| producteur | Producteur | Ferme productrice |

### 3.6 Classe Commande

Représente une commande passée par un client.

| Attribut | Type | Description |
|----------|------|-------------|
| id | Long | Identifiant unique |
| reference | String | Référence unique (ex: EGG-2026-001234) |
| client | Client | Client ayant passé la commande |
| producteur | Producteur | Ferme concernée |
| livreur | Livreur | Livreur assigné |
| adresseLivraison | Adresse | Adresse de livraison |
| statut | StatutCommande | État actuel |
| montantProduits | Double | Sous-total produits |
| fraisLivraison | Double | Frais de livraison |
| montantTotal | Double | Total à payer |
| modePaiement | ModePaiement | Mode de paiement choisi |
| paye | Boolean | Paiement effectué |
| creneauLivraison | String | Créneau demandé |
| lignes | List<LigneCommande> | Détail des produits |

### 3.7 Classe Livraison

Représente le processus de livraison d'une commande.

| Attribut | Type | Description |
|----------|------|-------------|
| id | Long | Identifiant unique |
| commande | Commande | Commande associée |
| livreur | Livreur | Livreur en charge |
| statut | StatutLivraison | État de la livraison |
| codeConfirmation | String | Code à 4 chiffres pour confirmation |
| distanceKm | Double | Distance calculée |
| historiquePositions | List<PositionGPS> | Suivi GPS |

### 3.8 Classe Abonnement

Représente un abonnement récurrent pour des livraisons automatiques.

| Attribut | Type | Description |
|----------|------|-------------|
| id | Long | Identifiant unique |
| client | Client | Client abonné |
| nom | String | Nom de l'abonnement |
| frequence | Frequence | Fréquence de livraison |
| jourLivraison | Integer | Jour préféré (1-7) |
| adresseLivraison | Adresse | Adresse de livraison |
| actif | Boolean | Abonnement actif |
| lignes | List<LigneAbonnement> | Produits de l'abonnement |

---

## 4. Relations entre Classes

### 4.1 Héritage

```
Utilisateur (abstraite)
    ├── Client
    ├── Livreur
    ├── Producteur
    └── Administrateur

Avis (abstraite)
    ├── AvisProduit
    ├── AvisLivreur
    └── AvisProducteur
```

### 4.2 Associations principales

| Classe source | Classe cible | Cardinalité | Description |
|---------------|--------------|-------------|-------------|
| Client | Adresse | 1..* | Un client a plusieurs adresses |
| Client | Commande | 0..* | Un client peut avoir plusieurs commandes |
| Producteur | Produit | 1..* | Un producteur propose plusieurs produits |
| Commande | LigneCommande | 1..* | Une commande contient plusieurs lignes |
| Commande | Livraison | 1..0..1 | Une commande a au plus une livraison |
| Livraison | PositionGPS | 1..* | Une livraison a plusieurs positions |

---

## 5. Dictionnaire de Données

### 5.1 Énumérations

#### StatutCommande
| Valeur | Description |
|--------|-------------|
| EN_ATTENTE | Commande créée, en attente de confirmation |
| CONFIRMEE | Confirmée par le producteur |
| EN_PREPARATION | En cours de préparation |
| PRETE | Prête pour récupération |
| EN_LIVRAISON | En cours de livraison |
| LIVREE | Livrée avec succès |
| ANNULEE | Annulée |
| REMBOURSEE | Remboursée |

#### ModePaiement
| Valeur | Description |
|--------|-------------|
| MTN_MOMO | MTN Mobile Money |
| ORANGE_MONEY | Orange Money |
| CASH_LIVRAISON | Espèces à la livraison |
| CARTE_BANCAIRE | Carte bancaire (Visa/Mastercard) |

#### Unite
| Valeur | Quantité | Description |
|--------|----------|-------------|
| PIECE | 1 | Œuf à l'unité |
| PLATEAU_30 | 30 | Plateau standard |
| CARTON_180 | 180 | Carton de 6 plateaux |
| CARTON_360 | 360 | Carton de 12 plateaux |

#### Frequence
| Valeur | Description |
|--------|-------------|
| HEBDOMADAIRE | Chaque semaine |
| BI_MENSUELLE | Deux fois par mois |
| MENSUELLE | Une fois par mois |

---

## 6. Contraintes d'Intégrité

### 6.1 Contraintes de clé

- `Utilisateur.telephone` : Unique
- `Utilisateur.email` : Unique (si renseigné)
- `Commande.reference` : Unique
- `Promotion.code` : Unique

### 6.2 Contraintes métier

1. Un `Client` doit avoir au moins une `Adresse` pour passer commande
2. Un `Livreur` ne peut avoir qu'une seule `Livraison` en cours (statut != LIVREE)
3. Une `Commande` ne peut être assignée à un `Livreur` que si `statut` = PRETE
4. Le `stock` d'un `Produit` ne peut pas être négatif
5. Une `Promotion` ne peut être utilisée que si `utilisationsActuelles` < `utilisationsMax`

### 6.3 Règles de gestion

| Règle | Description |
|-------|-------------|
| RG1 | Les frais de livraison sont calculés en fonction de la `ZoneLivraison` |
| RG2 | Une commande annulée après paiement génère un remboursement |
| RG3 | Un livreur avec une note < 3.0 est automatiquement désactivé |
| RG4 | Les abonnements génèrent des commandes automatiques |
| RG5 | Les points de fidélité = 1 point pour 1000 FCFA dépensés |

---

## 7. Conclusion

Ce diagramme de classes constitue le modèle de données central du système EggGo. Il servira de base pour :
- La création des entités JPA (Spring Boot)
- La conception de la base de données
- La création des modèles Dart (Flutter)
- L'implémentation des règles métier

---

*Document rédigé le 30 janvier 2026 - Projet EggGo*
