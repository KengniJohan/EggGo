import 'dart:io';

/// Constantes de l'API EggGo
class ApiConstants {
  ApiConstants._();

  // Base URL - Détection automatique selon la plateforme
  static String get baseUrl {
    // Adresse IP WiFi de votre machine (à modifier selon votre réseau)
    const String wifiIp = '192.168.1.167';
    const int port = 8080;
    
    // Pour les appareils physiques (Android/iOS), utiliser l'IP WiFi
    // Pour l'émulateur Android, 10.0.2.2 pointe vers localhost
    // Pour le simulateur iOS, localhost fonctionne directement
    
    if (Platform.isAndroid) {
      // Utiliser l'IP WiFi pour appareil physique
      // Décommenter la ligne suivante pour émulateur: return 'http://10.0.2.2:$port/api';
      return 'http://$wifiIp:$port/api';
    } else if (Platform.isIOS) {
      // iOS simulateur peut utiliser localhost, appareil physique utilise WiFi
      return 'http://$wifiIp:$port/api';
    } else {
      // Web, Windows, etc.
      return 'http://localhost:$port/api';
    }
  }
  
  // Pour la production
  // static const String baseUrl = 'https://api.egggo.cm/api';

  // Endpoints Auth
  static const String login = '/v1/auth/login';
  static const String register = '/v1/auth/register';
  static const String profile = '/v1/auth/me';

  // Endpoints Produits
  static const String produits = '/v1/produits';
  static const String categories = '/v1/categories';

  // Endpoints Commandes
  static const String commandes = '/v1/commandes';
  static const String mesCommandes = '/v1/commandes/mes-commandes';

  // Endpoints Paiements
  static const String paiements = '/v1/paiements';
  static const String initierPaiement = '/v1/paiements/initier';
  static const String confirmerPaiement = '/v1/paiements/confirmer';

  // Endpoints Livraisons
  static const String livraisons = '/v1/livraisons';

  // Endpoints Producteur
  static const String producteurDashboard = '/v1/producteur/dashboard';
  static const String producteurProduits = '/v1/producteur/produits';
  static const String producteurCommandes = '/v1/producteur/commandes';
  static const String producteurLivreurs = '/v1/producteur/livreurs';

  // Endpoints Livreur
  static const String livreurDashboard = '/v1/livreur/dashboard';
  static const String livreurDisponibilite = '/v1/livreur/disponibilite';
  static const String livreurPosition = '/v1/livreur/position';
  static const String livreurLivraisons = '/v1/livreur/livraisons';

  // Endpoints Admin
  static const String adminDashboard = '/v1/admin/dashboard';
  static const String adminProducteursEnAttente = '/v1/admin/producteurs/en-attente';
  static const String adminLivreursEnAttente = '/v1/admin/livreurs/en-attente';
  static const String adminValiderProducteur = '/v1/admin/producteurs';
  static const String adminValiderLivreur = '/v1/admin/livreurs';

  // Health
  static const String health = '/health';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
