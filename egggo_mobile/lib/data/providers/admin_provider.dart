import 'package:flutter/foundation.dart';
import '../models/admin_dashboard.dart';
import '../services/admin_service.dart';
import '../services/api_service.dart';

/// Provider pour les fonctionnalités administrateur
class AdminProvider extends ChangeNotifier {
  final AdminService _adminService;

  AdminProvider(ApiService apiService)
      : _adminService = AdminService(apiService);

  // États
  bool _isLoading = false;
  String? _errorMessage;
  AdminDashboard? _dashboard;
  List<ProducteurEnAttente> _producteursEnAttente = [];
  List<LivreurEnAttente> _livreursEnAttente = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdminDashboard? get dashboard => _dashboard;
  List<ProducteurEnAttente> get producteursEnAttente => _producteursEnAttente;
  List<LivreurEnAttente> get livreursEnAttente => _livreursEnAttente;

  /// Charge le dashboard
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _adminService.getDashboard();
    } catch (e) {
      _errorMessage = e.toString();
      _dashboard = AdminDashboard.empty();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge les producteurs en attente
  Future<void> loadProducteursEnAttente() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _producteursEnAttente = await _adminService.getProducteursEnAttente();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge les livreurs en attente
  Future<void> loadLivreursEnAttente() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _livreursEnAttente = await _adminService.getLivreursEnAttente();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge tout
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _adminService.getDashboard().then((d) => _dashboard = d),
        _adminService.getProducteursEnAttente().then((p) => _producteursEnAttente = p),
        _adminService.getLivreursEnAttente().then((l) => _livreursEnAttente = l),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
      _dashboard ??= AdminDashboard.empty();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Valide un producteur
  Future<bool> validerProducteur(int producteurId) async {
    try {
      final success = await _adminService.validerProducteur(producteurId);
      if (success) {
        _producteursEnAttente.removeWhere((p) => p.id == producteurId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Rejette un producteur
  Future<bool> rejeterProducteur(int producteurId, String motif) async {
    try {
      final success = await _adminService.rejeterProducteur(producteurId, motif);
      if (success) {
        _producteursEnAttente.removeWhere((p) => p.id == producteurId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Valide un livreur
  Future<bool> validerLivreur(int livreurId) async {
    try {
      final success = await _adminService.validerLivreur(livreurId);
      if (success) {
        _livreursEnAttente.removeWhere((l) => l.id == livreurId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Rejette un livreur
  Future<bool> rejeterLivreur(int livreurId, String motif) async {
    try {
      final success = await _adminService.rejeterLivreur(livreurId, motif);
      if (success) {
        _livreursEnAttente.removeWhere((l) => l.id == livreurId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
