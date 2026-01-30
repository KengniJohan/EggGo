import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

/// États d'authentification
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Provider pour l'authentification
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider(ApiService apiService) 
      : _authService = AuthService(apiService);

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  /// Initialise l'état d'authentification au démarrage
  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.initialize();
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        try {
          _user = await _authService.getProfile();
          _status = AuthStatus.authenticated;
        } catch (e) {
          // Token invalide ou API inaccessible, déconnecter
          await _authService.logout();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }

  /// Connexion (utilise le téléphone comme identifiant)
  Future<bool> login(String telephone, String motDePasse) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(telephone, motDePasse);
      _user = response.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Inscription
  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
    String role = 'CLIENT',
    // Champs spécifiques producteur
    String? nomFerme,
    String? localisation,
    String? description,
    // Champs spécifiques livreur
    String? typeVehicule,
    String? numeroPermis,
    String? zoneCouverture,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        motDePasse: motDePasse,
        role: role,
        nomFerme: nomFerme,
        localisation: localisation,
        description: description,
        typeVehicule: typeVehicule,
        numeroPermis: numeroPermis,
        zoneCouverture: zoneCouverture,
      );
      _user = response.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Rafraîchit le profil utilisateur
  Future<void> refreshProfile() async {
    try {
      _user = await _authService.getProfile();
      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  /// Efface l'erreur
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
