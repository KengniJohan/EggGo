# Description Dynamique - Diagrammes de Cas d'Utilisation

## 1. Introduction

Ce document présente la modélisation dynamique du système EggGo à travers les diagrammes de cas d'utilisation UML. Ces diagrammes décrivent les interactions entre les différents acteurs et le système.

---

## 2. Identification des Acteurs

### 2.1 Acteurs Principaux

| Acteur | Description | Type |
|--------|-------------|------|
| **Client** | Utilisateur final qui commande des œufs | Principal |
| **Livreur** | Personne en charge de la livraison | Principal |
| **Producteur** | Ferme avicole partenaire | Principal |
| **Administrateur** | Gestionnaire de la plateforme | Principal |

### 2.2 Acteurs Secondaires

| Acteur | Description | Type |
|--------|-------------|------|
| **Système de paiement** | MTN MoMo, Orange Money | Secondaire |
| **Système de notification** | Firebase Cloud Messaging | Secondaire |
| **Système de géolocalisation** | Google Maps API | Secondaire |

---

## 3. Diagramme de Cas d'Utilisation Général

```mermaid
graph TB
    subgraph Système EggGo
        UC1[S'inscrire]
        UC2[Se connecter]
        UC3[Gérer son profil]
        UC4[Consulter le catalogue]
        UC5[Passer une commande]
        UC6[Suivre une commande]
        UC7[Effectuer un paiement]
        UC8[Noter et commenter]
        UC9[Gérer les abonnements]
        UC10[Accepter une livraison]
        UC11[Livrer une commande]
        UC12[Mettre à jour le statut]
        UC13[Gérer le stock]
        UC14[Confirmer une commande]
        UC15[Gérer les utilisateurs]
        UC16[Gérer les produits]
        UC17[Consulter les statistiques]
        UC18[Gérer les promotions]
    end

    Client((Client))
    Livreur((Livreur))
    Producteur((Producteur))
    Admin((Administrateur))
    Payment[/Système Paiement/]
    Notif[/Système Notification/]
    Geo[/Système Géolocalisation/]

    Client --> UC1
    Client --> UC2
    Client --> UC3
    Client --> UC4
    Client --> UC5
    Client --> UC6
    Client --> UC7
    Client --> UC8
    Client --> UC9

    Livreur --> UC2
    Livreur --> UC10
    Livreur --> UC11
    Livreur --> UC12

    Producteur --> UC2
    Producteur --> UC13
    Producteur --> UC14

    Admin --> UC2
    Admin --> UC15
    Admin --> UC16
    Admin --> UC17
    Admin --> UC18

    UC5 --> Payment
    UC7 --> Payment
    UC5 --> Notif
    UC6 --> Notif
    UC11 --> Geo
    UC6 --> Geo
```

---

## 4. Cas d'Utilisation Détaillés par Acteur

### 4.1 Cas d'Utilisation - Client

```mermaid
graph LR
    subgraph "Cas d'utilisation Client"
        UC1[S'inscrire]
        UC2[Se connecter]
        UC3[Gérer son profil]
        UC4[Consulter le catalogue]
        UC5[Rechercher des produits]
        UC6[Ajouter au panier]
        UC7[Passer une commande]
        UC8[Choisir le mode de paiement]
        UC9[Effectuer le paiement]
        UC10[Suivre sa commande]
        UC11[Consulter l'historique]
        UC12[Noter le livreur]
        UC13[Noter le produit]
        UC14[Gérer ses adresses]
        UC15[Créer un abonnement]
        UC16[Modifier un abonnement]
        UC17[Annuler un abonnement]
        UC18[Contacter le support]
        UC19[Utiliser un code promo]
    end

    Client((Client))

    Client --> UC1
    Client --> UC2
    Client --> UC3
    Client --> UC4
    Client --> UC5
    Client --> UC6
    Client --> UC7
    Client --> UC8
    Client --> UC9
    Client --> UC10
    Client --> UC11
    Client --> UC12
    Client --> UC13
    Client --> UC14
    Client --> UC15
    Client --> UC16
    Client --> UC17
    Client --> UC18
    Client --> UC19

    UC7 -.->|include| UC8
    UC8 -.->|include| UC9
    UC15 -.->|extend| UC7
    UC19 -.->|extend| UC7
```

### 4.2 Cas d'Utilisation - Livreur

```mermaid
graph LR
    subgraph "Cas d'utilisation Livreur"
        UC1[S'inscrire comme livreur]
        UC2[Se connecter]
        UC3[Consulter les livraisons disponibles]
        UC4[Accepter une livraison]
        UC5[Refuser une livraison]
        UC6[Récupérer la commande]
        UC7[Naviguer vers le client]
        UC8[Confirmer la livraison]
        UC9[Signaler un problème]
        UC10[Consulter ses gains]
        UC11[Gérer sa disponibilité]
        UC12[Mettre à jour sa position]
        UC13[Consulter son historique]
        UC14[Recevoir des notifications]
    end

    Livreur((Livreur))

    Livreur --> UC1
    Livreur --> UC2
    Livreur --> UC3
    Livreur --> UC4
    Livreur --> UC5
    Livreur --> UC6
    Livreur --> UC7
    Livreur --> UC8
    Livreur --> UC9
    Livreur --> UC10
    Livreur --> UC11
    Livreur --> UC12
    Livreur --> UC13
    Livreur --> UC14

    UC4 -.->|include| UC6
    UC6 -.->|include| UC7
    UC7 -.->|include| UC8
```

### 4.3 Cas d'Utilisation - Producteur

```mermaid
graph LR
    subgraph "Cas d'utilisation Producteur"
        UC1[S'inscrire comme producteur]
        UC2[Se connecter]
        UC3[Gérer son profil ferme]
        UC4[Ajouter des produits]
        UC5[Modifier les prix]
        UC6[Gérer le stock]
        UC7[Consulter les commandes]
        UC8[Confirmer une commande]
        UC9[Préparer une commande]
        UC10[Signaler indisponibilité]
        UC11[Consulter les statistiques]
        UC12[Consulter les revenus]
        UC13[Gérer les promotions]
        UC14[Recevoir des notifications]
    end

    Producteur((Producteur))

    Producteur --> UC1
    Producteur --> UC2
    Producteur --> UC3
    Producteur --> UC4
    Producteur --> UC5
    Producteur --> UC6
    Producteur --> UC7
    Producteur --> UC8
    Producteur --> UC9
    Producteur --> UC10
    Producteur --> UC11
    Producteur --> UC12
    Producteur --> UC13
    Producteur --> UC14

    UC8 -.->|include| UC9
```

### 4.4 Cas d'Utilisation - Administrateur

```mermaid
graph LR
    subgraph "Cas d'utilisation Administrateur"
        UC1[Se connecter]
        UC2[Gérer les clients]
        UC3[Gérer les livreurs]
        UC4[Gérer les producteurs]
        UC5[Valider les inscriptions]
        UC6[Gérer les produits]
        UC7[Gérer les catégories]
        UC8[Consulter toutes les commandes]
        UC9[Résoudre les litiges]
        UC10[Gérer les promotions]
        UC11[Configurer les tarifs]
        UC12[Consulter les statistiques]
        UC13[Générer des rapports]
        UC14[Envoyer des notifications]
        UC15[Gérer les zones de livraison]
        UC16[Configurer le système]
    end

    Admin((Administrateur))

    Admin --> UC1
    Admin --> UC2
    Admin --> UC3
    Admin --> UC4
    Admin --> UC5
    Admin --> UC6
    Admin --> UC7
    Admin --> UC8
    Admin --> UC9
    Admin --> UC10
    Admin --> UC11
    Admin --> UC12
    Admin --> UC13
    Admin --> UC14
    Admin --> UC15
    Admin --> UC16
```

---

## 5. Description Textuelle des Cas d'Utilisation Principaux

### 5.1 UC: Passer une commande

| Élément | Description |
|---------|-------------|
| **Nom** | Passer une commande |
| **Acteur principal** | Client |
| **Préconditions** | Le client est connecté et a des produits dans son panier |
| **Postconditions** | La commande est enregistrée et le producteur est notifié |
| **Scénario principal** | 1. Le client accède à son panier<br>2. Le client vérifie les produits<br>3. Le client sélectionne une adresse de livraison<br>4. Le client choisit un créneau de livraison<br>5. Le client sélectionne un mode de paiement<br>6. Le système calcule le total<br>7. Le client valide la commande<br>8. Le système enregistre la commande<br>9. Le système envoie une notification au producteur |
| **Scénarios alternatifs** | 4a. Le client ajoute une nouvelle adresse<br>7a. Le paiement échoue → retour à l'étape 5 |
| **Extensions** | Utiliser un code promo, Planifier un abonnement |

### 5.2 UC: Livrer une commande

| Élément | Description |
|---------|-------------|
| **Nom** | Livrer une commande |
| **Acteur principal** | Livreur |
| **Préconditions** | Le livreur a accepté la livraison, la commande est prête |
| **Postconditions** | La commande est livrée et le client est satisfait |
| **Scénario principal** | 1. Le livreur reçoit la notification de commande prête<br>2. Le livreur se rend chez le producteur<br>3. Le livreur récupère la commande<br>4. Le livreur confirme la récupération<br>5. Le système active la navigation GPS<br>6. Le livreur se rend chez le client<br>7. Le livreur remet la commande<br>8. Le client confirme la réception<br>9. Le système clôture la livraison |
| **Scénarios alternatifs** | 7a. Client absent → Tentative de contact<br>7b. Produits endommagés → Signalement problème |

### 5.3 UC: Gérer le stock

| Élément | Description |
|---------|-------------|
| **Nom** | Gérer le stock |
| **Acteur principal** | Producteur |
| **Préconditions** | Le producteur est connecté |
| **Postconditions** | Le stock est mis à jour dans le système |
| **Scénario principal** | 1. Le producteur accède à la gestion de stock<br>2. Le producteur sélectionne un produit<br>3. Le producteur modifie la quantité disponible<br>4. Le système met à jour le stock<br>5. Le système actualise le catalogue |
| **Scénarios alternatifs** | 3a. Stock épuisé → Produit masqué du catalogue |

---

## 6. Diagramme de Séquence - Processus de Commande

```mermaid
sequenceDiagram
    participant C as Client
    participant App as Application Mobile
    participant API as API Backend
    participant DB as Base de données
    participant P as Producteur
    participant L as Livreur
    participant Pay as Système Paiement
    participant Notif as Notifications

    C->>App: Consulter catalogue
    App->>API: GET /produits
    API->>DB: Query produits
    DB-->>API: Liste produits
    API-->>App: JSON produits
    App-->>C: Afficher catalogue

    C->>App: Ajouter au panier
    App->>App: Mise à jour panier local

    C->>App: Valider commande
    App->>API: POST /commandes
    API->>DB: Créer commande
    API->>Pay: Initier paiement
    Pay-->>API: Confirmation paiement
    API->>DB: Mettre à jour statut
    API->>Notif: Envoyer notification
    Notif-->>P: Nouvelle commande
    API-->>App: Commande confirmée
    App-->>C: Afficher confirmation

    P->>App: Confirmer commande
    App->>API: PUT /commandes/{id}/confirmer
    API->>DB: Mettre à jour statut
    API->>Notif: Notifier livreurs
    Notif-->>L: Livraison disponible

    L->>App: Accepter livraison
    App->>API: PUT /livraisons/{id}/accepter
    API->>DB: Assigner livreur
    API->>Notif: Notifier client
    Notif-->>C: Livreur assigné

    L->>App: Confirmer livraison
    App->>API: PUT /livraisons/{id}/terminer
    API->>DB: Clôturer commande
    API->>Notif: Notifier tous
    Notif-->>C: Commande livrée
    Notif-->>P: Livraison confirmée
```

---

## 7. Diagramme d'Activité - Flux de Commande

```mermaid
graph TD
    A[Début] --> B[Client consulte catalogue]
    B --> C[Client ajoute produits au panier]
    C --> D{Panier vide?}
    D -->|Oui| B
    D -->|Non| E[Client valide panier]
    E --> F[Sélection adresse livraison]
    F --> G[Choix créneau livraison]
    G --> H[Sélection mode paiement]
    H --> I{Type paiement}
    I -->|Mobile Money| J[Redirection MoMo/OM]
    I -->|Cash| K[Confirmation cash]
    J --> L{Paiement réussi?}
    L -->|Non| H
    L -->|Oui| M[Commande enregistrée]
    K --> M
    M --> N[Notification producteur]
    N --> O{Producteur confirme?}
    O -->|Non| P[Annulation + Remboursement]
    O -->|Oui| Q[Préparation commande]
    Q --> R[Notification livreurs]
    R --> S{Livreur accepte?}
    S -->|Timeout| R
    S -->|Oui| T[Récupération commande]
    T --> U[Livraison en cours]
    U --> V[Arrivée chez client]
    V --> W{Client disponible?}
    W -->|Non| X[Tentative contact]
    X --> W
    W -->|Oui| Y[Remise commande]
    Y --> Z[Confirmation livraison]
    Z --> AA[Notation et commentaire]
    AA --> AB[Fin]
    P --> AB
```

---

## 8. Conclusion

Cette modélisation dynamique couvre l'ensemble des interactions du système EggGo. Les diagrammes présentés serviront de base pour :
- Le développement des fonctionnalités
- La rédaction des spécifications techniques
- Les tests fonctionnels
- La documentation utilisateur

---

*Document rédigé le 30 janvier 2026 - Projet EggGo*
