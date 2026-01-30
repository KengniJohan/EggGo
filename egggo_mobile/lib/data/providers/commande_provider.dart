import 'package:flutter/foundation.dart';
import '../models/commande.dart';
import '../models/cart.dart';
import '../services/commande_service.dart';
import '../services/api_service.dart';

/// Provider pour les commandes
class CommandeProvider extends ChangeNotifier {
  final CommandeService _commandeService;

  List<Commande> _commandes = [];
  Commande? _commandeEnCours;
  bool _isLoading = false;
  String? _errorMessage;

  CommandeProvider(ApiService apiService) 
      : _commandeService = CommandeService(apiService);

  // Getters
  List<Commande> get commandes => _commandes;
  Commande? get commandeEnCours => _commandeEnCours;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Commandes en cours (non livrées/annulées)
  List<Commande> get commandesEnCours {
    return _commandes.where((c) => 
        c.statut != StatutCommande.livree && 
        c.statut != StatutCommande.annulee
    ).toList();
  }

  /// Historique des commandes (livrées/annulées)
  List<Commande> get historiqueCommandes {
    return _commandes.where((c) => 
        c.statut == StatutCommande.livree || 
        c.statut == StatutCommande.annulee
    ).toList();
  }

  /// Charge les commandes de l'utilisateur
  Future<void> chargerCommandes({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && _commandes.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _commandes = await _commandeService.getMesCommandes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée une nouvelle commande
  Future<Commande?> creerCommande({
    required Cart cart,
    int? adresseId,
    Adresse? nouvelleAdresse,
    required ModePaiement modePaiement,
    String? notes,
    String? creneauLivraison,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final commande = await _commandeService.creerCommande(
        cart: cart,
        adresseId: adresseId,
        nouvelleAdresse: nouvelleAdresse,
        modePaiement: modePaiement,
        notes: notes,
        creneauLivraison: creneauLivraison,
      );
      
      _commandeEnCours = commande;
      _commandes.insert(0, commande);
      _isLoading = false;
      notifyListeners();
      return commande;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Charge une commande par son ID
  Future<Commande?> chargerCommande(int id) async {
    try {
      _commandeEnCours = await _commandeService.getCommandeById(id);
      
      // Mettre à jour la liste
      final index = _commandes.indexWhere((c) => c.id == id);
      if (index >= 0) {
        _commandes[index] = _commandeEnCours!;
      }
      
      notifyListeners();
      return _commandeEnCours;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Annule une commande
  Future<bool> annulerCommande(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final commande = await _commandeService.annulerCommande(id);
      
      // Mettre à jour la liste
      final index = _commandes.indexWhere((c) => c.id == id);
      if (index >= 0) {
        _commandes[index] = commande;
      }
      
      if (_commandeEnCours?.id == id) {
        _commandeEnCours = commande;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Calcule les frais de livraison
  Future<double> calculerFraisLivraison(Adresse adresse) async {
    return _commandeService.calculerFraisLivraison(adresse);
  }

  /// Efface l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Définit la commande en cours
  void setCommandeEnCours(Commande? commande) {
    _commandeEnCours = commande;
    notifyListeners();
  }
}
