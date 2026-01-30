import '../../core/constants/api_constants.dart';
import '../models/livreur_dashboard.dart';
import 'api_service.dart';

/// Service pour les fonctionnalités livreur
class LivreurService {
  final ApiService _apiService;

  LivreurService(this._apiService);

  /// Récupère le dashboard livreur
  Future<LivreurDashboard> getDashboard() async {
    try {
      final response = await _apiService.get(ApiConstants.livreurDashboard);
      return LivreurDashboard.fromJson(response['data'] ?? response);
    } catch (e) {
      return LivreurDashboard.empty();
    }
  }

  /// Met à jour la disponibilité du livreur
  Future<void> setDisponibilite(bool disponible) async {
    await _apiService.patch(
      '${ApiConstants.livreurDisponibilite}?disponible=$disponible',
    );
  }

  /// Met à jour la position GPS du livreur
  Future<void> updatePosition(double latitude, double longitude) async {
    await _apiService.post(
      ApiConstants.livreurPosition,
      body: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  /// Récupère les livraisons du livreur
  Future<List<Livraison>> getLivraisons({String? statut}) async {
    String url = ApiConstants.livreurLivraisons;
    if (statut != null) url += '?statut=$statut';

    final response = await _apiService.get(url);
    final data = response['data'] ?? response;
    if (data is List) {
      return data.map((e) => Livraison.fromJson(e)).toList();
    }
    return [];
  }

  /// Accepte une livraison
  Future<Livraison> accepterLivraison(int livraisonId) async {
    final response = await _apiService.patch(
      '${ApiConstants.livreurLivraisons}/$livraisonId/accepter',
    );
    return Livraison.fromJson(response['data'] ?? response);
  }

  /// Signale la récupération de la commande chez le producteur
  Future<Livraison> signalerRecuperation(int livraisonId) async {
    final response = await _apiService.patch(
      '${ApiConstants.livreurLivraisons}/$livraisonId/recuperer',
    );
    return Livraison.fromJson(response['data'] ?? response);
  }

  /// Signale l'arrivée à destination
  Future<Livraison> signalerArrivee(int livraisonId) async {
    final response = await _apiService.patch(
      '${ApiConstants.livreurLivraisons}/$livraisonId/arrivee',
    );
    return Livraison.fromJson(response['data'] ?? response);
  }

  /// Confirme la livraison
  Future<Livraison> confirmerLivraison(
    int livraisonId, {
    String? codeConfirmation,
    String? photoPreuve,
  }) async {
    String url = '${ApiConstants.livreurLivraisons}/$livraisonId/confirmer';
    final params = <String>[];
    if (codeConfirmation != null) params.add('codeConfirmation=$codeConfirmation');
    if (photoPreuve != null) params.add('photoPreuve=$photoPreuve');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await _apiService.patch(url);
    return Livraison.fromJson(response['data'] ?? response);
  }

  /// Signale un problème lors de la livraison
  Future<Livraison> signalerProbleme(int livraisonId, String description) async {
    final response = await _apiService.patch(
      '${ApiConstants.livreurLivraisons}/$livraisonId/probleme?description=$description',
    );
    return Livraison.fromJson(response['data'] ?? response);
  }
}
