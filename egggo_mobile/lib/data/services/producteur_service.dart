import '../../core/constants/api_constants.dart';
import '../models/produit.dart';
import '../models/commande.dart';
import '../models/producteur_dashboard.dart';
import 'api_service.dart';

/// Service pour les fonctionnalités producteur
class ProducteurService {
  final ApiService _apiService;

  ProducteurService(this._apiService);

  String _mapUniteToApi(String? unite) {
    final value = (unite ?? '').trim().toLowerCase();
    switch (value) {
      case 'pièce':
      case 'piece':
        return 'PIECE';
      case 'plateau':
      case 'alvéole':
      case 'alveole':
        return 'PLATEAU_30';
      case 'carton':
        return 'CARTON_180';
      default:
        // Valeur déjà au format API ?
        return unite ?? 'PLATEAU_30';
    }
  }

  /// Récupère le dashboard producteur
  Future<ProducteurDashboard> getDashboard() async {
    try {
      final response = await _apiService.get(ApiConstants.producteurDashboard);
      return ProducteurDashboard.fromJson(response['data'] ?? response);
    } catch (e) {
      // Retourner un dashboard vide en cas d'erreur
      return ProducteurDashboard.empty();
    }
  }

  /// Récupère les produits du producteur
  Future<List<Produit>> getProduits() async {
    final response = await _apiService.get(ApiConstants.producteurProduits);
    final data = response['data'] ?? response;
    if (data is List) {
      return data.map((e) => Produit.fromJson(e)).toList();
    }
    return [];
  }

  /// Crée un nouveau produit
  Future<Produit> createProduit({
    required String nom,
    required String description,
    required double prix,
    required int quantiteStock,
    required int categorieId,
    String? imageUrl,
    String? unite,
  }) async {
    final response = await _apiService.post(
      ApiConstants.producteurProduits,
      body: {
        'nom': nom,
        'description': description,
        'prixUnitaire': prix,
        'stockDisponible': quantiteStock,
        'categorieId': categorieId,
        'imageUrl': imageUrl,
        'unite': _mapUniteToApi(unite),
      },
    );
    return Produit.fromJson(response['data'] ?? response);
  }

  /// Met à jour un produit
  Future<Produit> updateProduit(int id, {
    String? nom,
    String? description,
    double? prix,
    int? quantiteStock,
    int? categorieId,
    String? imageUrl,
    String? unite,
  }) async {
    final body = <String, dynamic>{};
    if (nom != null) body['nom'] = nom;
    if (description != null) body['description'] = description;
    if (prix != null) body['prixUnitaire'] = prix;
    if (quantiteStock != null) body['stockDisponible'] = quantiteStock;
    if (categorieId != null) body['categorieId'] = categorieId;
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    if (unite != null) body['unite'] = _mapUniteToApi(unite);

    final response = await _apiService.put(
      '${ApiConstants.producteurProduits}/$id',
      body: body,
    );
    return Produit.fromJson(response['data'] ?? response);
  }

  /// Met à jour le stock d'un produit
  Future<Produit> updateStock(int produitId, UpdateStockRequest request) async {
    final response = await _apiService.patch(
      '${ApiConstants.producteurProduits}/$produitId/stock',
      body: request.toJson(),
    );
    return Produit.fromJson(response['data'] ?? response);
  }

  /// Active/désactive la disponibilité d'un produit
  Future<Produit> toggleDisponibilite(int produitId) async {
    final response = await _apiService.patch(
      '${ApiConstants.producteurProduits}/$produitId/disponibilite',
    );
    return Produit.fromJson(response['data'] ?? response);
  }

  /// Supprime un produit
  Future<void> deleteProduit(int produitId) async {
    await _apiService.delete('${ApiConstants.producteurProduits}/$produitId');
  }

  /// Récupère les commandes reçues
  Future<List<Commande>> getCommandes({String? statut, int page = 0, int size = 20}) async {
    String url = ApiConstants.producteurCommandes;
    final params = <String>[];
    if (statut != null) params.add('statut=$statut');
    params.add('page=$page');
    params.add('size=$size');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await _apiService.get(url);
    final data = response['data'];
    if (data != null && data['content'] is List) {
      return (data['content'] as List).map((e) => Commande.fromJson(e)).toList();
    }
    return [];
  }

  /// Confirme une commande
  Future<Commande> confirmerCommande(int commandeId) async {
    final response = await _apiService.patch(
      '${ApiConstants.producteurCommandes}/$commandeId/confirmer',
    );
    return Commande.fromJson(response['data'] ?? response);
  }

  /// Annule une commande
  Future<Commande> annulerCommande(int commandeId, String motif) async {
    final response = await _apiService.patch(
      '${ApiConstants.producteurCommandes}/$commandeId/annuler?raison=${Uri.encodeComponent(motif)}',
    );
    return Commande.fromJson(response['data'] ?? response);
  }

  /// Assigne un livreur à une commande
  Future<Commande> assignerLivreur(int commandeId, int livreurId) async {
    final response = await _apiService.post(
      '${ApiConstants.producteurCommandes}/$commandeId/assigner-livreur/$livreurId',
      body: {},
    );
    return Commande.fromJson(response['data'] ?? response);
  }

  /// Marque une commande comme prête (le livreur peut venir la récupérer)
  Future<Commande> marquerPrete(int commandeId) async {
    final response = await _apiService.patch(
      '${ApiConstants.producteurCommandes}/$commandeId/prete',
    );
    return Commande.fromJson(response['data'] ?? response);
  }

  /// Récupère les livreurs disponibles
  Future<List<Map<String, dynamic>>> getLivreursDisponibles() async {
    final response = await _apiService.get(ApiConstants.producteurLivreurs);
    final data = response['data'] ?? [];
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
}
