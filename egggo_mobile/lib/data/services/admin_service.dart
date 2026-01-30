import '../../core/constants/api_constants.dart';
import '../models/admin_dashboard.dart';
import 'api_service.dart';

/// Service pour les fonctionnalités administrateur
class AdminService {
  final ApiService _apiService;

  AdminService(this._apiService);

  /// Récupère le dashboard admin
  Future<AdminDashboard> getDashboard() async {
    try {
      final response = await _apiService.get(ApiConstants.adminDashboard);
      return AdminDashboard.fromJson(response['data'] ?? response);
    } catch (e) {
      return AdminDashboard.empty();
    }
  }

  /// Récupère les producteurs en attente de validation
  Future<List<ProducteurEnAttente>> getProducteursEnAttente() async {
    final response = await _apiService.get(ApiConstants.adminProducteursEnAttente);
    final data = response['data'] ?? response;
    if (data is List) {
      return data.map((e) => ProducteurEnAttente.fromJson(e)).toList();
    }
    return [];
  }

  /// Récupère les livreurs en attente de validation
  Future<List<LivreurEnAttente>> getLivreursEnAttente() async {
    final response = await _apiService.get(ApiConstants.adminLivreursEnAttente);
    final data = response['data'] ?? response;
    if (data is List) {
      return data.map((e) => LivreurEnAttente.fromJson(e)).toList();
    }
    return [];
  }

  /// Valide un producteur
  Future<bool> validerProducteur(int producteurId) async {
    try {
      await _apiService.patch(
        '${ApiConstants.adminProducteursEnAttente}/$producteurId/valider',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Rejette un producteur
  Future<bool> rejeterProducteur(int producteurId, String motif) async {
    try {
      await _apiService.patch(
        '${ApiConstants.adminProducteursEnAttente}/$producteurId/rejeter',
        body: {'motif': motif},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valide un livreur
  Future<bool> validerLivreur(int livreurId) async {
    try {
      await _apiService.patch(
        '${ApiConstants.adminLivreursEnAttente}/$livreurId/valider',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Rejette un livreur
  Future<bool> rejeterLivreur(int livreurId, String motif) async {
    try {
      await _apiService.patch(
        '${ApiConstants.adminLivreursEnAttente}/$livreurId/rejeter',
        body: {'motif': motif},
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
