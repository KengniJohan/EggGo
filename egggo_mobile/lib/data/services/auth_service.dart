import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Service d'authentification
class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Connexion utilisateur (utilise le téléphone comme identifiant)
  Future<AuthResponse> login(String telephone, String motDePasse) async {
    final response = await _apiService.post(
      ApiConstants.login,
      body: {
        'telephone': telephone,
        'motDePasse': motDePasse,
      },
    );

    final authResponse = AuthResponse.fromJson(response['data'] ?? response);
    
    // Sauvegarder le token
    await _saveToken(authResponse.token);
    _apiService.setAuthToken(authResponse.token);

    return authResponse;
  }

  /// Inscription utilisateur
  Future<AuthResponse> register({
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
    final Map<String, dynamic> body = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'motDePasse': motDePasse,
      'role': role,
    };

    // Ajouter les champs spécifiques selon le rôle
    if (role == 'PRODUCTEUR') {
      if (nomFerme != null) body['nomFerme'] = nomFerme;
      if (localisation != null) body['localisation'] = localisation;
      if (description != null) body['description'] = description;
    } else if (role == 'LIVREUR') {
      if (typeVehicule != null) body['typeVehicule'] = typeVehicule;
      if (numeroPermis != null) body['numeroPermis'] = numeroPermis;
      if (zoneCouverture != null) body['zoneCouverture'] = zoneCouverture;
    }

    final response = await _apiService.post(
      ApiConstants.register,
      body: body,
    );

    final authResponse = AuthResponse.fromJson(response['data'] ?? response);
    
    // Sauvegarder le token
    await _saveToken(authResponse.token);
    _apiService.setAuthToken(authResponse.token);

    return authResponse;
  }

  /// Récupère le profil de l'utilisateur connecté
  Future<User> getProfile() async {
    final response = await _apiService.get(ApiConstants.profile);
    return User.fromJson(response['data'] ?? response);
  }

  /// Déconnexion
  Future<void> logout() async {
    await _removeToken();
    _apiService.setAuthToken(null);
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Récupère le token stocké
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// Sauvegarde le token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  /// Supprime le token
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  /// Initialise le service avec le token stocké
  Future<void> initialize() async {
    final token = await getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }
}
