import 'package:flutter/foundation.dart';
import '../models/produit.dart';
import '../models/commande.dart';
import '../models/producteur_dashboard.dart';
import '../services/producteur_service.dart';
import '../services/api_service.dart';

/// Provider pour les fonctionnalités producteur
class ProducteurProvider extends ChangeNotifier {
  final ProducteurService _producteurService;

  ProducteurProvider(ApiService apiService)
      : _producteurService = ProducteurService(apiService);

  // États
  bool _isLoading = false;
  String? _errorMessage;
  ProducteurDashboard? _dashboard;
  List<Produit> _produits = [];
  List<Commande> _commandes = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProducteurDashboard? get dashboard => _dashboard;
  List<Produit> get produits => _produits;
  List<Commande> get commandes => _commandes;

  /// Charge le dashboard
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _producteurService.getDashboard();
    } catch (e) {
      _errorMessage = e.toString();
      _dashboard = ProducteurDashboard.empty();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge les produits
  Future<void> loadProduits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _produits = await _producteurService.getProduits();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crée un produit
  Future<bool> createProduit({
    required String nom,
    required String description,
    required double prix,
    required int quantiteStock,
    required int categorieId,
    String? imageUrl,
    String? unite,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final produit = await _producteurService.createProduit(
        nom: nom,
        description: description,
        prix: prix,
        quantiteStock: quantiteStock,
        categorieId: categorieId,
        imageUrl: imageUrl,
        unite: unite,
      );
      _produits.insert(0, produit);
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

  /// Met à jour le stock d'un produit
  Future<bool> updateStock(int produitId, int quantite, String operation) async {
    try {
      final updatedProduit = await _producteurService.updateStock(
        produitId,
        UpdateStockRequest(quantite: quantite, operation: operation),
      );
      
      // Mettre à jour le produit dans la liste
      final index = _produits.indexWhere((p) => p.id == produitId);
      if (index != -1) {
        _produits[index] = updatedProduit;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Active/désactive un produit
  Future<bool> toggleDisponibilite(int produitId) async {
    try {
      final updatedProduit = await _producteurService.toggleDisponibilite(produitId);
      
      final index = _produits.indexWhere((p) => p.id == produitId);
      if (index != -1) {
        _produits[index] = updatedProduit;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Supprime un produit
  Future<bool> deleteProduit(int produitId) async {
    try {
      await _producteurService.deleteProduit(produitId);
      _produits.removeWhere((p) => p.id == produitId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Charge les commandes
  Future<void> loadCommandes({String? statut}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _commandes = await _producteurService.getCommandes(statut: statut);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Confirme une commande
  Future<bool> confirmerCommande(int commandeId) async {
    try {
      final updatedCommande = await _producteurService.confirmerCommande(commandeId);
      
      final index = _commandes.indexWhere((c) => c.id == commandeId);
      if (index != -1) {
        _commandes[index] = updatedCommande;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Annule une commande
  Future<bool> annulerCommande(int commandeId, String motif) async {
    try {
      final updatedCommande = await _producteurService.annulerCommande(commandeId, motif);
      
      final index = _commandes.indexWhere((c) => c.id == commandeId);
      if (index != -1) {
        _commandes[index] = updatedCommande;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Assigne un livreur à une commande
  Future<bool> assignerLivreur(int commandeId, int livreurId) async {
    try {
      final updatedCommande = await _producteurService.assignerLivreur(commandeId, livreurId);
      
      final index = _commandes.indexWhere((c) => c.id == commandeId);
      if (index != -1) {
        _commandes[index] = updatedCommande;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Marque une commande comme prête
  Future<bool> marquerPrete(int commandeId) async {
    try {
      final updatedCommande = await _producteurService.marquerPrete(commandeId);
      
      final index = _commandes.indexWhere((c) => c.id == commandeId);
      if (index != -1) {
        _commandes[index] = updatedCommande;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Récupère les livreurs disponibles
  Future<List<Map<String, dynamic>>> getLivreursDisponibles() async {
    try {
      return await _producteurService.getLivreursDisponibles();
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
