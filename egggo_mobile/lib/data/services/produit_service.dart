import '../../core/constants/api_constants.dart';
import '../models/produit.dart';
import 'api_service.dart';

/// Service pour les produits
class ProduitService {
  final ApiService _apiService;

  ProduitService(this._apiService);

  /// Récupère tous les produits
  Future<List<Produit>> getProduits({
    int? categorieId,
    bool? disponible,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };

    if (categorieId != null) {
      queryParams['categorieId'] = categorieId;
    }
    if (disponible != null) {
      queryParams['disponible'] = disponible;
    }

    final response = await _apiService.get(
      ApiConstants.produits,
      queryParams: queryParams,
    );

    final data = response['data'];
    if (data is List) {
      return data.map((json) => Produit.fromJson(json)).toList();
    } else if (data != null && data['content'] is List) {
      // Format paginé
      return (data['content'] as List)
          .map((json) => Produit.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Récupère un produit par son ID
  Future<Produit> getProduitById(int id) async {
    final response = await _apiService.get('${ApiConstants.produits}/$id');
    return Produit.fromJson(response['data'] ?? response);
  }

  /// Récupère les produits par catégorie
  Future<List<Produit>> getProduitsByCategorie(int categorieId) async {
    return getProduits(categorieId: categorieId);
  }

  /// Recherche de produits
  Future<List<Produit>> rechercher(String query) async {
    final response = await _apiService.get(
      '${ApiConstants.produits}/recherche',
      queryParams: {'q': query},
    );

    final data = response['data'];
    if (data is List) {
      return data.map((json) => Produit.fromJson(json)).toList();
    }
    return [];
  }

  /// Récupère toutes les catégories
  Future<List<Categorie>> getCategories() async {
    final response = await _apiService.get(ApiConstants.categories);
    
    final data = response['data'];
    if (data is List) {
      return data.map((json) => Categorie.fromJson(json)).toList();
    }
    return [];
  }
}
