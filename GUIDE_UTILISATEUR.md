# 🥚 EggGo - Guide Utilisateur

## Application de Livraison d'Œufs au Cameroun

---

## Table des Matières

1. [Introduction](#introduction)
2. [Installation et Configuration](#installation-et-configuration)
3. [Guide Client](#guide-client)
4. [Guide Producteur](#guide-producteur)
5. [Guide Livreur](#guide-livreur)
6. [Guide Administrateur](#guide-administrateur)
7. [Paiement Mobile Money](#paiement-mobile-money)
8. [FAQ](#faq)

---

## Introduction

**EggGo** est une application mobile de livraison d'œufs frais qui connecte les producteurs avicoles camerounais directement aux consommateurs. L'application permet de commander des œufs de qualité, livrés rapidement à domicile.

### Acteurs de la Plateforme

| Rôle | Description |
|------|-------------|
| **Client** | Commande des œufs et se fait livrer |
| **Producteur** | Publie ses offres d'œufs et gère ses stocks |
| **Livreur** | Effectue les livraisons avec suivi GPS |
| **Administrateur** | Gère la plateforme et valide les comptes |

---

## Installation et Configuration

### Prérequis

#### Backend (API Spring Boot)
- Java 17+
- Docker (pour PostgreSQL)
- Maven

#### Mobile (Flutter)
- Flutter SDK 3.10+
- Android Studio ou VS Code
- Un appareil Android/iOS ou émulateur

### Démarrage du Backend

```bash
# 1. Démarrer la base de données PostgreSQL
docker run --name egggo-postgres -e POSTGRES_DB=egggo_db -e POSTGRES_USER=egggo -e POSTGRES_PASSWORD=egggo123 -p 5432:5432 -d postgres:15

# 2. Lancer l'API
cd egggo
./mvnw spring-boot:run
```

L'API sera accessible sur `http://localhost:8080/api`

### Démarrage de l'Application Mobile

```bash
cd egggo_mobile

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Configuration de l'IP (pour test sur appareil physique)

Modifiez le fichier `lib/core/constants/api_constants.dart` :

```dart
static const String baseUrl = 'http://VOTRE_IP_WIFI:8080/api';
```

---

## Guide Client

### 1. Inscription

1. Ouvrez l'application EggGo
2. Appuyez sur **"Créer un compte"**
3. Remplissez le formulaire :
   - Nom et Prénom
   - Numéro de téléphone (format: 6XXXXXXXX)
   - Mot de passe (minimum 6 caractères)
4. Appuyez sur **"S'inscrire"**

### 2. Connexion

1. Entrez votre numéro de téléphone
2. Entrez votre mot de passe
3. Appuyez sur **"Se connecter"**

### 3. Parcourir les Produits

L'écran d'accueil affiche :
- **Catégories** : Œufs de poule, Œufs de caille, Plateaux, etc.
- **Produits populaires** : Les meilleures ventes
- **Producteurs proches** : Fermes près de chez vous

### 4. Commander

1. **Sélectionnez un produit** en appuyant dessus
2. **Choisissez la quantité** avec les boutons + et -
3. **Ajoutez au panier** 
4. **Accédez au panier** via l'icône en haut à droite
5. **Validez la commande** :
   - Sélectionnez une adresse de livraison
   - Choisissez le mode de paiement (Mobile Money)
   - Confirmez la commande

### 5. Suivre sa Commande

1. Allez dans **"Mes Commandes"** depuis le menu
2. Visualisez le statut de chaque commande :
   - 🟡 **En attente** : Commande reçue
   - 🔵 **Confirmée** : Préparation en cours
   - 🟠 **En livraison** : Le livreur est en route
   - 🟢 **Livrée** : Commande reçue

### 6. Gérer son Profil

- Modifier ses informations personnelles
- Ajouter/modifier des adresses de livraison
- Consulter l'historique des commandes

---

## Guide Producteur

### 1. Inscription Producteur

1. Créez un compte avec le rôle **"Producteur"**
2. Renseignez les informations de votre ferme :
   - Nom de la ferme
   - Adresse
   - Description
3. **Attendez la validation** par l'administrateur

### 2. Tableau de Bord

Le dashboard producteur affiche :
- 📊 **Chiffre d'affaires du mois**
- 📦 **Commandes en attente**
- 🥚 **Produits en stock**
- ⚠️ **Produits en rupture**
- ⭐ **Note moyenne**

### 3. Gérer les Produits

#### Ajouter un Produit

1. Allez dans **"Mes Produits"**
2. Appuyez sur le bouton **"+"**
3. Remplissez le formulaire :
   - Nom du produit
   - Description
   - Prix unitaire
   - Quantité en stock
   - Catégorie
   - Photo (optionnel)
4. Appuyez sur **"Publier"**

#### Modifier le Stock

1. Sur la liste des produits, appuyez sur l'icône **stock**
2. Entrez la nouvelle quantité
3. Choisissez l'opération :
   - **Ajouter** : Ajout au stock existant
   - **Retirer** : Réduction du stock
   - **Définir** : Remplacer par cette valeur

#### Activer/Désactiver un Produit

- Utilisez le switch pour rendre un produit disponible ou non

### 4. Gérer les Commandes

1. Allez dans **"Commandes Reçues"**
2. Filtrez par statut si nécessaire
3. Pour chaque commande :
   - **Confirmer** : Accepter la commande
   - **Annuler** : Refuser avec motif
   - **Assigner un livreur** : Choisir un livreur

### 5. Livreurs Rattachés

- Visualisez vos livreurs propres
- Consultez les livreurs indépendants disponibles
- Assignez un livreur à une commande confirmée

---

## Guide Livreur

### 1. Inscription Livreur

1. Créez un compte avec le rôle **"Livreur"**
2. Renseignez vos informations :
   - Numéro de pièce d'identité
   - Type de véhicule (Moto, Vélo, Voiture)
   - Numéro de plaque (si applicable)
   - Zone de couverture
3. Choisissez si vous êtes :
   - **Indépendant** : Libre de choisir vos livraisons
   - **Rattaché à un producteur** : Livraisons exclusives
4. **Attendez la validation** par l'administrateur

### 2. Tableau de Bord

Le dashboard livreur affiche :
- 📍 **Statut** : En ligne / Hors ligne
- 🚴 **Livraisons du jour**
- 💰 **Gains du jour**
- 📏 **Distance parcourue**
- ⭐ **Note moyenne**

### 3. Passer En Ligne

1. Activez le switch **"Disponible"** en haut de l'écran
2. Votre position GPS sera partagée
3. Vous recevrez des notifications de nouvelles livraisons

### 4. Gérer les Livraisons

#### Accepter une Livraison

1. Consultez les **"Livraisons en attente"**
2. Visualisez les détails :
   - Adresse de récupération (producteur)
   - Adresse de livraison (client)
   - Distance estimée
   - Gains
3. Appuyez sur **"Accepter"**

#### Effectuer une Livraison

1. **En route vers le producteur** : Récupérez la commande
2. **Confirmation récupération** : Appuyez sur "Commande récupérée"
3. **En route vers le client** : Suivez l'itinéraire
4. **Signaler l'arrivée** : Appuyez sur "Je suis arrivé"
5. **Confirmer la livraison** : 
   - Entrez le code de confirmation du client
   - Prenez une photo preuve (optionnel)
   - Appuyez sur "Livraison effectuée"

### 5. Navigation GPS

- L'application affiche l'itinéraire vers la destination
- Coordonnées GPS du client disponibles
- Bouton pour ouvrir dans Google Maps

### 6. Signaler un Problème

En cas de difficulté :
1. Appuyez sur **"Signaler un problème"**
2. Décrivez la situation
3. L'administrateur sera notifié

---

## Guide Administrateur

### 1. Accès Administrateur

Connectez-vous avec un compte administrateur pour accéder au dashboard admin.

### 2. Tableau de Bord

Vue d'ensemble de la plateforme :
- 👥 **Total Clients**
- 🏭 **Total Producteurs**
- 🚴 **Total Livreurs**
- 📦 **Commandes du mois**
- 💰 **Chiffre d'affaires**

### 3. Validation des Producteurs

1. Allez dans **"Producteurs en attente"**
2. Examinez chaque demande :
   - Informations de la ferme
   - Documents fournis
3. Actions :
   - ✅ **Valider** : Le producteur peut publier des produits
   - ❌ **Refuser** : Indiquez le motif du refus

### 4. Validation des Livreurs

1. Allez dans **"Livreurs en attente"**
2. Vérifiez :
   - Pièce d'identité
   - Type de véhicule
   - Zone de couverture
3. Actions :
   - ✅ **Valider** : Le livreur peut effectuer des livraisons
   - ❌ **Refuser** : Indiquez le motif du refus

### 5. Gestion des Utilisateurs

- Recherchez des utilisateurs par nom ou téléphone
- Activez/désactivez des comptes
- Consultez l'activité de chaque utilisateur

### 6. Statistiques

#### Statistiques de Ventes
- Chiffre d'affaires total
- Nombre de commandes
- Panier moyen
- Top producteurs

#### Statistiques de Livraisons
- Nombre de livraisons
- Taux de réussite
- Temps moyen de livraison
- Top livreurs

---

## Paiement Mobile Money

### Modes de Paiement Supportés

| Opérateur | Service |
|-----------|---------|
| MTN | MTN Mobile Money |
| Orange | Orange Money |

### Processus de Paiement

1. Lors de la validation de commande, sélectionnez **"Mobile Money"**
2. Choisissez votre opérateur (MTN ou Orange)
3. Entrez votre numéro de téléphone Mobile Money
4. Vous recevrez une demande de confirmation sur votre téléphone
5. Validez le paiement avec votre code PIN
6. La commande est confirmée automatiquement

### Simulation (Mode Test)

En mode développement, les paiements sont simulés :
- Le paiement est automatiquement validé après 3 secondes
- Aucun montant réel n'est débité

---

## FAQ

### Questions Générales

**Q: Comment réinitialiser mon mot de passe ?**
> Contactez le support via l'application ou appelez le service client.

**Q: L'application ne se connecte pas au serveur ?**
> Vérifiez votre connexion internet. Si vous êtes en développement, assurez-vous que l'API est démarrée et que l'IP est correcte.

### Questions Client

**Q: Puis-je annuler une commande ?**
> Oui, tant que la commande n'est pas en cours de livraison. Allez dans "Mes Commandes" et appuyez sur "Annuler".

**Q: Comment modifier mon adresse de livraison ?**
> Allez dans "Mon Profil" > "Mes Adresses" et modifiez ou ajoutez une nouvelle adresse.

### Questions Producteur

**Q: Combien de temps pour être validé ?**
> La validation prend généralement 24 à 48 heures ouvrables.

**Q: Comment modifier mes horaires de disponibilité ?**
> Allez dans "Paramètres de la ferme" pour définir vos heures d'ouverture.

### Questions Livreur

**Q: Comment sont calculés mes gains ?**
> Vous recevez les frais de livraison de chaque commande effectuée. Le montant est affiché avant d'accepter une livraison.

**Q: Que faire si le client n'est pas là ?**
> Appelez le client avec le numéro affiché. Si pas de réponse après 10 minutes, signalez un problème.

---

## Support

Pour toute question ou assistance :

- 📧 **Email** : support@egggo.cm
- 📞 **Téléphone** : +237 6XX XXX XXX
- 🕐 **Horaires** : Lun-Sam, 8h-18h

---

## Changelog

### Version 1.0.0 (Janvier 2026)
- 🚀 Lancement initial
- 👤 Gestion multi-rôles (Client, Producteur, Livreur, Admin)
- 🥚 Publication et gestion des produits
- 📦 Système de commandes complet
- 🚴 Suivi GPS des livraisons
- 💳 Paiement Mobile Money (MTN/Orange)
- 📊 Dashboards personnalisés par rôle

---

**© 2026 EggGo - Tous droits réservés**
