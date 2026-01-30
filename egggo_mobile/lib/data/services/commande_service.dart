import '../../core/constants/api_constants.dart';
import '../models/commande.dart';
import '../models/cart.dart';
import 'api_service.dart';

/// Service pour les commandes
class CommandeService {
  final ApiService _apiService;

  CommandeService(this._apiService);

  /// Crée une nouvelle commande
  Future<Commande> creerCommande({
    required Cart cart,
    int? adresseId,
    Adresse? nouvelleAdresse,
    required ModePaiement modePaiement,
    String? notes,
    String? creneauLivraison,
  }) async {
    // Récupérer le producteurId depuis le panier
    final producteurId = cart.producteurId;
    if (producteurId == null) {
      throw Exception('Impossible de déterminer le producteur');
    }

    final body = <String, dynamic>{
      'producteurId': producteurId,
      'modePaiement': modePaiement.code,
      'lignes': cart.toLignesCommande(),
    };
    
    // Soit adresseId existante, soit nouvelle adresse
    if (adresseId != null) {
      body['adresseId'] = adresseId;
    } else if (nouvelleAdresse != null) {
      body['nouvelleAdresse'] = {
        'quartier': nouvelleAdresse.quartier,
        'ville': nouvelleAdresse.ville,
        'rue': nouvelleAdresse.rue,
        'description': nouvelleAdresse.complement,
        'latitude': nouvelleAdresse.latitude,
        'longitude': nouvelleAdresse.longitude,
      };
    } else {
      throw Exception('Une adresse de livraison est requise');
    }
    
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    if (creneauLivraison != null) body['creneauLivraison'] = creneauLivraison;

    final response = await _apiService.post(ApiConstants.commandes, body: body);
    return Commande.fromJson(response['data'] ?? response);
  }

  /// Récupère les commandes de l'utilisateur
  Future<List<Commande>> getMesCommandes({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiService.get(
      '${ApiConstants.commandes}/mes-commandes',
      queryParams: {'page': page, 'size': size},
    );

    final data = response['data'];
    if (data is List) {
      return data.map((json) => Commande.fromJson(json)).toList();
    } else if (data != null && data['content'] is List) {
      return (data['content'] as List)
          .map((json) => Commande.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Récupère une commande par son ID
  Future<Commande> getCommandeById(int id) async {
    final response = await _apiService.get('${ApiConstants.commandes}/$id');
    return Commande.fromJson(response['data'] ?? response);
  }

  /// Récupère une commande par sa référence
  Future<Commande> getCommandeByReference(String reference) async {
    final response = await _apiService.get(
      '${ApiConstants.commandes}/reference/$reference',
    );
    return Commande.fromJson(response['data'] ?? response);
  }

  /// Annule une commande
  Future<Commande> annulerCommande(int id) async {
    final response = await _apiService.put(
      '${ApiConstants.commandes}/$id/annuler',
    );
    return Commande.fromJson(response['data'] ?? response);
  }

  /// Calcule les frais de livraison (estimation)
  Future<double> calculerFraisLivraison(Adresse adresse) async {
    // Pour l'instant, frais fixes basés sur la ville
    switch (adresse.ville.toLowerCase()) {
      case 'douala':
        return 500;
      case 'yaoundé':
      case 'yaounde':
        return 500;
      default:
        return 1000;
    }
  }
}
