import '../../core/constants/api_constants.dart';
import '../models/paiement.dart';
import 'api_service.dart';

/// Service de paiement Mobile Money (simulé)
class PaiementService {
  final ApiService _apiService;

  PaiementService(this._apiService);

  /// Initie un paiement mobile money
  Future<Paiement> initierPaiement(InitierPaiementRequest request) async {
    final response = await _apiService.post(
      ApiConstants.initierPaiement,
      body: request.toJson(),
    );
    return Paiement.fromJson(response['data'] ?? response);
  }

  /// Confirme un paiement avec le code OTP
  /// 
  /// Codes de simulation:
  /// - 1234, SUCCESS, OK → Paiement réussi
  /// - 0000, FAILED, ECHEC → Paiement échoué
  /// - 9999, TIMEOUT → Paiement expiré
  /// - ANNULE, CANCEL → Paiement annulé
  Future<Paiement> confirmerPaiement(ConfirmerPaiementRequest request) async {
    final response = await _apiService.post(
      ApiConstants.confirmerPaiement,
      body: request.toJson(),
    );
    return Paiement.fromJson(response['data'] ?? response);
  }

  /// Vérifie le statut d'un paiement
  Future<Paiement> verifierStatut(int paiementId) async {
    final response = await _apiService.get(
      '${ApiConstants.paiements}/$paiementId',
    );
    return Paiement.fromJson(response['data'] ?? response);
  }

  /// Vérifie le statut par référence
  Future<Paiement> verifierStatutParReference(String reference) async {
    final response = await _apiService.get(
      '${ApiConstants.paiements}/reference/$reference',
    );
    return Paiement.fromJson(response['data'] ?? response);
  }

  /// Récupère les paiements d'une commande
  Future<List<Paiement>> getPaiementsCommande(int commandeId) async {
    final response = await _apiService.get(
      '${ApiConstants.paiements}/commande/$commandeId',
    );
    
    final data = response['data'];
    if (data is List) {
      return data.map((json) => Paiement.fromJson(json)).toList();
    }
    return [];
  }

  /// Annule un paiement en attente
  Future<Paiement> annulerPaiement(int paiementId) async {
    final response = await _apiService.post(
      '${ApiConstants.paiements}/$paiementId/annuler',
    );
    return Paiement.fromJson(response['data'] ?? response);
  }

  /// Valide un numéro de téléphone camerounais
  bool validerNumeroTelephone(String numero) {
    // Format: 6XXXXXXXX (9 chiffres commençant par 6)
    final regex = RegExp(r'^6[0-9]{8}$');
    return regex.hasMatch(numero.replaceAll(RegExp(r'\s+'), ''));
  }

  /// Formate un numéro de téléphone
  String formaterNumero(String numero) {
    final clean = numero.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('237')) {
      return clean.substring(3);
    }
    return clean;
  }

  /// Détermine l'opérateur à partir du numéro
  String? detecterOperateur(String numero) {
    final clean = formaterNumero(numero);
    if (clean.length != 9) return null;
    
    final prefix = clean.substring(0, 2);
    
    // Orange: 69, 65, 66
    if (['69', '65', '66'].contains(prefix)) {
      return 'ORANGE_MONEY';
    }
    
    // MTN: 67, 68, 65 (certains)
    if (['67', '68'].contains(prefix)) {
      return 'MTN_MOMO';
    }
    
    return null;
  }
}
