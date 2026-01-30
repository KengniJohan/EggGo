import 'package:flutter/foundation.dart';
import '../models/livreur_dashboard.dart';
import '../services/livreur_service.dart';
import '../services/api_service.dart';

/// Provider pour les fonctionnalités livreur
class LivreurProvider extends ChangeNotifier {
  final LivreurService _livreurService;

  LivreurProvider(ApiService apiService)
      : _livreurService = LivreurService(apiService);

  // États
  bool _isLoading = false;
  String? _errorMessage;
  LivreurDashboard? _dashboard;
  List<Livraison> _livraisons = [];
  bool _disponible = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LivreurDashboard? get dashboard => _dashboard;
  List<Livraison> get livraisons => _livraisons;
  bool get disponible => _disponible;

  /// Charge le dashboard
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _livreurService.getDashboard();
      _disponible = _dashboard?.disponible ?? false;
    } catch (e) {
      _errorMessage = e.toString();
      _dashboard = LivreurDashboard.empty();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Change la disponibilité
  Future<bool> setDisponibilite(bool disponible) async {
    try {
      await _livreurService.setDisponibilite(disponible);
      _disponible = disponible;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Met à jour la position GPS
  Future<void> updatePosition(double latitude, double longitude) async {
    try {
      await _livreurService.updatePosition(latitude, longitude);
    } catch (e) {
      // Ignorer silencieusement les erreurs de position
    }
  }

  /// Charge les livraisons
  Future<void> loadLivraisons({String? statut}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _livraisons = await _livreurService.getLivraisons(statut: statut);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Accepte une livraison
  Future<bool> accepterLivraison(int livraisonId) async {
    try {
      final updatedLivraison = await _livreurService.accepterLivraison(livraisonId);
      _updateLivraisonInList(updatedLivraison);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Signale la récupération
  Future<bool> signalerRecuperation(int livraisonId) async {
    try {
      final updatedLivraison = await _livreurService.signalerRecuperation(livraisonId);
      _updateLivraisonInList(updatedLivraison);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Signale l'arrivée
  Future<bool> signalerArrivee(int livraisonId) async {
    try {
      final updatedLivraison = await _livreurService.signalerArrivee(livraisonId);
      _updateLivraisonInList(updatedLivraison);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Confirme la livraison
  Future<bool> confirmerLivraison(
    int livraisonId, {
    String? codeConfirmation,
    String? photoPreuve,
  }) async {
    try {
      final updatedLivraison = await _livreurService.confirmerLivraison(
        livraisonId,
        codeConfirmation: codeConfirmation,
        photoPreuve: photoPreuve,
      );
      _updateLivraisonInList(updatedLivraison);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Signale un problème
  Future<bool> signalerProbleme(int livraisonId, String description) async {
    try {
      final updatedLivraison = await _livreurService.signalerProbleme(livraisonId, description);
      _updateLivraisonInList(updatedLivraison);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateLivraisonInList(Livraison livraison) {
    final index = _livraisons.indexWhere((l) => l.id == livraison.id);
    if (index != -1) {
      _livraisons[index] = livraison;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
