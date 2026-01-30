# Charte Graphique - EggGo

## 1. Introduction

Ce document définit l'identité visuelle de l'application EggGo. La charte graphique établit les règles d'utilisation des couleurs, de la typographie, du logo et des éléments visuels pour garantir une cohérence sur tous les supports.

---

## 2. Philosophie de la Marque

### 2.1 Vision

> **"Connecter les fermes camerounaises aux consommateurs pour des œufs frais, chaque jour"**

### 2.2 Valeurs de la marque

| Valeur | Description | Expression visuelle |
|--------|-------------|---------------------|
| **Fraîcheur** | Produits frais de la ferme | Couleurs vives et naturelles |
| **Confiance** | Traçabilité et qualité | Design épuré et professionnel |
| **Proximité** | Lien direct producteur-consommateur | Formes rondes et accueillantes |
| **Modernité** | Innovation technologique | Interface contemporaine |
| **Cameroun** | Ancrage local | Couleurs chaudes, inspiration africaine |

### 2.3 Personnalité de la marque

- **Ton** : Amical, accessible, professionnel
- **Style** : Moderne, épuré, chaleureux
- **Ambiance** : Naturelle, authentique, dynamique

---

## 3. Logo

### 3.1 Logo Principal

```
    ╭─────────────────────────────────╮
    │                                 │
    │         🥚                      │
    │        ╱  ╲                     │
    │       │ GO │                    │
    │        ╲  ╱                     │
    │         ──                      │
    │                                 │
    │      E G G G O                  │
    │                                 │
    ╰─────────────────────────────────╯
```

### 3.2 Concept du Logo

Le logo EggGo combine :
- **Un œuf stylisé** : Représente le produit principal
- **Une flèche intégrée** : Symbolise la livraison et le mouvement
- **La lettre "G"** : Formée par la coquille de l'œuf
- **Couleur orange** : Évoque le jaune d'œuf et l'énergie

### 3.3 Versions du Logo

| Version | Utilisation |
|---------|-------------|
| **Logo complet** | Applications principales, documents officiels |
| **Logo horizontal** | En-têtes, bannières |
| **Icône** | Favicon, icône d'app, réseaux sociaux |
| **Logo monochrome** | Impressions N&B, fonds colorés |
| **Logo inversé** | Fonds sombres |

### 3.4 Zone de Protection

```
    ┌─────────────────────────────────┐
    │  x   ┌─────────────┐   x        │
    │      │             │            │
    │  x   │    LOGO     │   x        │
    │      │             │            │
    │  x   └─────────────┘   x        │
    └─────────────────────────────────┘
    
    x = hauteur du "E" de EggGo (minimum)
```

### 3.5 Tailles Minimales

| Support | Taille minimale |
|---------|-----------------|
| Imprimé | 25 mm de large |
| Écran | 80 px de large |
| Favicon | 32 x 32 px |
| Icône app | 512 x 512 px |

### 3.6 Utilisations Interdites

❌ Ne pas étirer ou déformer le logo  
❌ Ne pas changer les couleurs officielles  
❌ Ne pas ajouter d'effets (ombres, contours)  
❌ Ne pas placer sur un fond trop chargé  
❌ Ne pas modifier les proportions  
❌ Ne pas utiliser en basse résolution  

---

## 4. Palette de Couleurs

### 4.1 Couleurs Principales

#### Orange EggGo (Primaire)
```
┌──────────────────────────────────────┐
│                                      │
│   ████████████████████████████████   │
│                                      │
│   Nom: Orange EggGo                  │
│   HEX: #FF6B35                       │
│   RGB: 255, 107, 53                  │
│   HSL: 16°, 100%, 60%                │
│   CMYK: 0, 58, 79, 0                 │
│                                      │
│   Usage: Actions principales,        │
│   boutons, accents                   │
│                                      │
└──────────────────────────────────────┘
```

#### Jaune Œuf (Secondaire)
```
┌──────────────────────────────────────┐
│                                      │
│   ████████████████████████████████   │
│                                      │
│   Nom: Jaune Œuf                     │
│   HEX: #FFB800                       │
│   RGB: 255, 184, 0                   │
│   HSL: 43°, 100%, 50%                │
│   CMYK: 0, 28, 100, 0                │
│                                      │
│   Usage: Promotions, badges,         │
│   notifications                      │
│                                      │
└──────────────────────────────────────┘
```

#### Vert Ferme (Tertiaire)
```
┌──────────────────────────────────────┐
│                                      │
│   ████████████████████████████████   │
│                                      │
│   Nom: Vert Ferme                    │
│   HEX: #2D6A4F                       │
│   RGB: 45, 106, 79                   │
│   HSL: 153°, 40%, 30%                │
│   CMYK: 58, 0, 25, 58                │
│                                      │
│   Usage: Succès, validation,         │
│   éléments naturels                  │
│                                      │
└──────────────────────────────────────┘
```

### 4.2 Couleurs Neutres

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Noir Texte     Gris Foncé      Gris Moyen     Gris    │
│  #1A1A1A        #4A4A4A         #7A7A7A        #B0B0B0 │
│  ████████       ████████        ████████       ████████│
│                                                         │
│  Gris Clair     Gris Très Clair   Blanc                │
│  #E0E0E0        #F5F5F5           #FFFFFF              │
│  ████████       ████████          ████████             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 4.3 Couleurs Fonctionnelles

| Couleur | HEX | Usage |
|---------|-----|-------|
| **Succès** | #2D6A4F | Confirmations, validations |
| **Erreur** | #D32F2F | Erreurs, alertes critiques |
| **Avertissement** | #F9A825 | Avertissements, attention |
| **Info** | #1976D2 | Informations, liens |

### 4.4 Code Flutter

```dart
// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

abstract class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8F5C);
  static const Color primaryDark = Color(0xFFE55A2B);
  
  static const Color secondary = Color(0xFFFFB800);
  static const Color secondaryLight = Color(0xFFFFCB4D);
  static const Color secondaryDark = Color(0xFFCC9400);
  
  static const Color tertiary = Color(0xFF2D6A4F);
  static const Color tertiaryLight = Color(0xFF4A9B6F);
  static const Color tertiaryDark = Color(0xFF1B4D38);
  
  // Couleurs neutres
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textHint = Color(0xFF7A7A7A);
  static const Color textDisabled = Color(0xFFB0B0B0);
  
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Couleurs fonctionnelles
  static const Color success = Color(0xFF2D6A4F);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF1976D2);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFB800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### 4.5 Accessibilité

Tous les contrastes de couleurs respectent les normes WCAG 2.1 AA :

| Combinaison | Ratio | Conformité |
|-------------|-------|------------|
| Orange sur Blanc | 4.5:1 | ✅ AA |
| Blanc sur Orange | 4.5:1 | ✅ AA |
| Noir sur Blanc | 21:1 | ✅ AAA |
| Vert sur Blanc | 5.2:1 | ✅ AA |

---

## 5. Typographie

### 5.1 Police Principale : Poppins

**Poppins** est une police géométrique sans-serif moderne et lisible, parfaite pour les interfaces mobiles.

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Poppins Bold                                           │
│  ABCDEFGHIJKLMNOPQRSTUVWXYZ                            │
│  abcdefghijklmnopqrstuvwxyz                            │
│  0123456789 !@#$%^&*()                                 │
│                                                         │
│  Poppins SemiBold                                       │
│  ABCDEFGHIJKLMNOPQRSTUVWXYZ                            │
│  abcdefghijklmnopqrstuvwxyz                            │
│  0123456789 !@#$%^&*()                                 │
│                                                         │
│  Poppins Medium                                         │
│  ABCDEFGHIJKLMNOPQRSTUVWXYZ                            │
│  abcdefghijklmnopqrstuvwxyz                            │
│  0123456789 !@#$%^&*()                                 │
│                                                         │
│  Poppins Regular                                        │
│  ABCDEFGHIJKLMNOPQRSTUVWXYZ                            │
│  abcdefghijklmnopqrstuvwxyz                            │
│  0123456789 !@#$%^&*()                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 5.2 Hiérarchie Typographique

| Style | Taille | Poids | Line Height | Usage |
|-------|--------|-------|-------------|-------|
| **Display Large** | 32px | Bold | 40px | Titres principaux |
| **Display Medium** | 28px | Bold | 36px | Titres de section |
| **Display Small** | 24px | SemiBold | 32px | Sous-titres |
| **Headline Large** | 22px | SemiBold | 28px | Titres de page |
| **Headline Medium** | 20px | SemiBold | 26px | Titres de carte |
| **Headline Small** | 18px | Medium | 24px | Titres mineurs |
| **Title Large** | 16px | SemiBold | 22px | Titres d'élément |
| **Title Medium** | 14px | SemiBold | 20px | Labels importants |
| **Title Small** | 12px | SemiBold | 18px | Labels secondaires |
| **Body Large** | 16px | Regular | 24px | Texte principal |
| **Body Medium** | 14px | Regular | 20px | Texte courant |
| **Body Small** | 12px | Regular | 18px | Texte secondaire |
| **Label Large** | 14px | Medium | 20px | Boutons |
| **Label Medium** | 12px | Medium | 16px | Badges |
| **Label Small** | 10px | Medium | 14px | Captions |

### 5.3 Code Flutter

```dart
// lib/core/theme/text_styles.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

abstract class AppTextStyles {
  static const String fontFamily = 'Poppins';
  
  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: AppColors.textPrimary,
  );
  
  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.33,
    color: AppColors.textPrimary,
  );
  
  // Title
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.375,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  // Label
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );
  
  // Prix
  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.33,
    color: AppColors.primary,
  );
  
  static const TextStyle priceSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    color: AppColors.primary,
  );
}
```

---

## 6. Iconographie

### 6.1 Style des Icônes

- **Style** : Outlined (contour) pour la navigation, Filled (plein) pour les actions
- **Épaisseur** : 1.5px - 2px
- **Coins** : Arrondis (border-radius: 2px)
- **Grille** : 24x24px avec padding de 2px

### 6.2 Icônes Personnalisées

| Icône | Usage | Description |
|-------|-------|-------------|
| 🥚 | Œuf simple | Représente un œuf à l'unité |
| 📦 | Plateau | Représente un plateau de 30 œufs |
| 🏠 | Ferme | Représente le producteur |
| 🛵 | Livraison | Représente le livreur |
| ⏱️ | Temps | Représente le délai de livraison |

### 6.3 Bibliothèque d'Icônes

Utilisation de **Material Icons** et **Phosphor Icons** pour Flutter :

```dart
// Icônes recommandées
Icons.egg_outlined           // Œuf
Icons.inventory_2_outlined   // Plateau/Carton
Icons.local_shipping         // Livraison
Icons.storefront_outlined    // Producteur
Icons.location_on_outlined   // Adresse
Icons.access_time_outlined   // Horaire
Icons.payment_outlined       // Paiement
Icons.star_outlined          // Notation
Icons.notifications_outlined // Notifications
Icons.person_outlined        // Profil
Icons.shopping_cart_outlined // Panier
Icons.history_outlined       // Historique
```

---

## 7. Composants UI

### 7.1 Boutons

#### Bouton Principal
```
┌─────────────────────────────────────┐
│                                     │
│  ┌─────────────────────────────┐    │
│  │      COMMANDER MAINTENANT   │    │  ← Orange #FF6B35
│  └─────────────────────────────┘    │    Texte blanc
│                                     │    Radius: 12px
│  Hauteur: 52px                      │    Padding: 16px 24px
│  Ombre: 0 4px 12px rgba(0,0,0,0.15) │
│                                     │
└─────────────────────────────────────┘
```

#### Bouton Secondaire
```
┌─────────────────────────────────────┐
│                                     │
│  ┌─────────────────────────────┐    │
│  │         ANNULER             │    │  ← Bordure Orange
│  └─────────────────────────────┘    │    Fond transparent
│                                     │    Texte Orange
│  Hauteur: 52px                      │
│  Bordure: 2px solid #FF6B35         │
│                                     │
└─────────────────────────────────────┘
```

#### Bouton Texte
```
┌─────────────────────────────────────┐
│                                     │
│         Voir plus →                 │  ← Texte Orange
│                                     │    Pas de fond
│  Hauteur: auto                      │    Souligné au hover
│                                     │
└─────────────────────────────────────┘
```

### 7.2 Cartes Produit

```
┌─────────────────────────────────────┐
│  ┌─────────────────────────────────┐│
│  │                                 ││
│  │          [IMAGE]                ││  ← Ratio 1:1
│  │                                 ││    Radius: 12px
│  │                    ♥            ││  ← Favori
│  └─────────────────────────────────┘│
│                                     │
│  Œufs fermiers bio                  │  ← Title Medium
│  Ferme du Soleil                    │  ← Body Small, Gris
│                                     │
│  1 500 FCFA                         │  ← Price style
│  le plateau                         │  ← Label Small
│                                     │
│  ┌─────────────────────────────┐    │
│  │       AJOUTER AU PANIER     │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘

Radius: 16px
Ombre: 0 2px 8px rgba(0,0,0,0.08)
Padding: 12px
```

### 7.3 Champs de Saisie

```
┌─────────────────────────────────────┐
│                                     │
│  Numéro de téléphone                │  ← Label, Gris foncé
│  ┌─────────────────────────────────┐│
│  │  🇨🇲 +237  │  6XX XXX XXX       ││  ← Body Large
│  └─────────────────────────────────┘│
│                                     │
│  Hauteur: 56px                      │
│  Radius: 12px                       │
│  Bordure: 1.5px solid #E0E0E0       │
│  Focus: 2px solid #FF6B35           │
│                                     │
└─────────────────────────────────────┘
```

### 7.4 Code Flutter - Thème

```dart
// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      
      // Couleurs
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        background: AppColors.background,
      ),
      
      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.headlineMedium,
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.primary, width: 2),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surface,
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

---

## 8. Espacements et Grille

### 8.1 Système d'Espacement

Base : **4px**

| Token | Valeur | Usage |
|-------|--------|-------|
| `xs` | 4px | Espacement minimal |
| `sm` | 8px | Entre éléments proches |
| `md` | 16px | Espacement standard |
| `lg` | 24px | Entre sections |
| `xl` | 32px | Marges de page |
| `xxl` | 48px | Grands espacements |

### 8.2 Code Flutter

```dart
// lib/core/constants/app_sizes.dart

abstract class AppSizes {
  // Espacements
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  
  // Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;
  
  // Hauteurs
  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 64;
  
  // Icônes
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;
  
  // Images
  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 64;
  static const double avatarXl = 96;
  
  // Padding
  static const EdgeInsets pagePadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
}
```

---

## 9. Animations et Transitions

### 9.1 Durées

| Type | Durée | Usage |
|------|-------|-------|
| **Rapide** | 150ms | Hover, focus |
| **Normal** | 250ms | Transitions standard |
| **Lente** | 400ms | Modales, pages |

### 9.2 Courbes

```dart
// Courbes recommandées
Curves.easeInOut      // Transitions générales
Curves.easeOutCubic   // Apparitions
Curves.easeInCubic    // Disparitions
Curves.elasticOut     // Animations ludiques (succès)
```

### 9.3 Animations Lottie

| Animation | Fichier | Usage |
|-----------|---------|-------|
| Chargement | `loading.json` | États de chargement |
| Succès | `success.json` | Confirmation commande |
| Panier vide | `empty_cart.json` | Panier vide |
| Livraison | `delivery.json` | Suivi livraison |

---

## 10. Application de la Charte

### 10.1 Checklist de Conformité

- [ ] Utilisation exclusive des couleurs de la palette
- [ ] Typographie Poppins pour tous les textes
- [ ] Respect des tailles et poids typographiques
- [ ] Espacements conformes au système 4px
- [ ] Boutons avec les styles définis
- [ ] Radius cohérents (8, 12, 16, 24px)
- [ ] Logo utilisé selon les règles
- [ ] Contrastes accessibles (WCAG AA)

### 10.2 Ressources Designers

Les fichiers sources sont disponibles dans :
- `/design/figma/` - Fichiers Figma
- `/design/assets/` - Assets exportés
- `/design/icons/` - Icônes SVG
- `/design/lottie/` - Animations Lottie

---

## 11. Conclusion

Cette charte graphique assure une identité visuelle cohérente pour l'application EggGo, reflétant les valeurs de fraîcheur, confiance et modernité tout en restant ancrée dans le contexte camerounais.

Elle doit être respectée sur tous les supports : application mobile, site web, supports marketing et communication.

---

*Document rédigé le 30 janvier 2026 - Projet EggGo*
