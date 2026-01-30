import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Réponse générique de l'API
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJson != null 
          ? fromJson(json['data']) 
          : json['data'],
      errors: json['errors'],
    );
  }
}

/// Service HTTP de base pour les appels API
class ApiService {
  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Définit le token d'authentification
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Headers par défaut
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
      }

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: $e');
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: $e');
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .put(uri, headers: _headers, body: jsonEncode(body))
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: $e');
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: $e');
    }
  }

  /// PATCH request
  Future<dynamic> patch(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .patch(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: $e');
    }
  }

  /// Gère la réponse HTTP
  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Gestion des erreurs
    String message = 'Erreur inconnue';
    if (body != null && body is Map) {
      message = body['message'] ?? body['error'] ?? message;
    }

    switch (response.statusCode) {
      case 400:
        throw ApiException('Requête invalide: $message', statusCode: 400, data: body);
      case 401:
        throw ApiException('Non autorisé. Veuillez vous reconnecter.', statusCode: 401);
      case 403:
        throw ApiException('Accès refusé', statusCode: 403);
      case 404:
        throw ApiException('Ressource non trouvée', statusCode: 404);
      case 422:
        throw ApiException('Données invalides: $message', statusCode: 422, data: body);
      case 500:
        throw ApiException('Erreur serveur. Réessayez plus tard.', statusCode: 500);
      default:
        throw ApiException(message, statusCode: response.statusCode, data: body);
    }
  }

  /// Ferme le client HTTP
  void dispose() {
    _client.close();
  }
}
