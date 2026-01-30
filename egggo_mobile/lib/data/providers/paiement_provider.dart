import 'package:flutter/foundation.dart';
import '../models/paiement.dart';
import '../services/paiement_service.dart';
import '../services/api_service.dart';

/// États du paiement
enum PaiementEtat {
  initial,
  initiation,
  attenteConfirmation,
  confirmation,
  succes,
  echec,
  expire,
  annule,
}

/// Provider pour les paiements Mobile Money
class PaiementProvider extends ChangeNotifier {
  final PaiementService _paiementService;

  PaiementEtat _etat = PaiementEtat.initial;
  Paiement? _paiementEnCours;
  String? _errorMessage;
  String? _messageOperateur;

  PaiementProvider(ApiService apiService) 
      : _paiementService = PaiementService(apiService);

  // Getters
  PaiementEtat get etat => _etat;
  Paiement? get paiementEnCours => _paiementEnCours;
  String? get errorMessage => _errorMessage;
  String? get messageOperateur => _messageOperateur;
  
  bool get isLoading => 
      _etat == PaiementEtat.initiation || 
      _etat == PaiementEtat.confirmation;

  /// Initie un paiement Mobile Money
  Future<bool> initierPaiement({
    required int commandeId,
    required String modePaiement,
    required String numeroTelephone,
    required double montant,
  }) async {
    _etat = PaiementEtat.initiation;
    _errorMessage = null;
    _messageOperateur = null;
    notifyListeners();

    try {
      final request = InitierPaiementRequest(
        commandeId: commandeId,
        modePaiement: modePaiement,
        numeroTelephone: numeroTelephone,
        montant: montant,
      );

      _paiementEnCours = await _paiementService.initierPaiement(request);
      _messageOperateur = _paiementEnCours?.messageOperateur;
      _etat = PaiementEtat.attenteConfirmation;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _etat = PaiementEtat.echec;
      notifyListeners();
      return false;
    }
  }

  /// Confirme un paiement avec le code OTP
  /// 
  /// Pour la simulation:
  /// - 1234 = Succès
  /// - 0000 = Échec
  /// - 9999 = Timeout
  /// - ANNULE = Annulé
  Future<bool> confirmerPaiement(String codeOtp, {String? simulationMode}) async {
    if (_paiementEnCours == null) {
      _errorMessage = 'Aucun paiement en cours';
      return false;
    }

    _etat = PaiementEtat.confirmation;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = ConfirmerPaiementRequest(
        paiementId: _paiementEnCours!.id,
        codeOtp: codeOtp,
        simulationMode: simulationMode,
      );

      _paiementEnCours = await _paiementService.confirmerPaiement(request);
      _messageOperateur = _paiementEnCours?.messageOperateur;

      // Déterminer l'état final
      switch (_paiementEnCours?.statut) {
        case StatutPaiement.reussi:
          _etat = PaiementEtat.succes;
          break;
        case StatutPaiement.echoue:
          _etat = PaiementEtat.echec;
          break;
        case StatutPaiement.expire:
          _etat = PaiementEtat.expire;
          break;
        case StatutPaiement.annule:
          _etat = PaiementEtat.annule;
          break;
        default:
          _etat = PaiementEtat.attenteConfirmation;
      }

      notifyListeners();
      return _etat == PaiementEtat.succes;
    } catch (e) {
      _errorMessage = e.toString();
      _etat = PaiementEtat.echec;
      notifyListeners();
      return false;
    }
  }

  /// Vérifie le statut du paiement en cours
  Future<void> verifierStatut() async {
    if (_paiementEnCours == null) return;

    try {
      _paiementEnCours = await _paiementService.verifierStatut(_paiementEnCours!.id);
      
      if (_paiementEnCours?.statut.estReussi == true) {
        _etat = PaiementEtat.succes;
      } else if (_paiementEnCours?.statut.estTermine == true) {
        _etat = PaiementEtat.echec;
      }
      
      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  /// Annule le paiement en cours
  Future<bool> annulerPaiement() async {
    if (_paiementEnCours == null) return false;

    try {
      _paiementEnCours = await _paiementService.annulerPaiement(_paiementEnCours!.id);
      _etat = PaiementEtat.annule;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Valide un numéro de téléphone
  bool validerNumero(String numero) {
    return _paiementService.validerNumeroTelephone(numero);
  }

  /// Détecte l'opérateur à partir du numéro
  String? detecterOperateur(String numero) {
    return _paiementService.detecterOperateur(numero);
  }

  /// Réinitialise l'état
  void reset() {
    _etat = PaiementEtat.initial;
    _paiementEnCours = null;
    _errorMessage = null;
    _messageOperateur = null;
    notifyListeners();
  }

  /// Efface l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
