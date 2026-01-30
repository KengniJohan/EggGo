import 'package:flutter/foundation.dart';
import '../models/produit.dart';
import '../services/produit_service.dart';
import '../services/api_service.dart';

/// Provider pour les produits
class ProduitProvider extends ChangeNotifier {
  final ProduitService _produitService;

  List<Produit> _produits = [];
  List<Categorie> _categories = [];
  Produit? _selectedProduit;
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedCategorieId;

  ProduitProvider(ApiService apiService) 
      : _produitService = ProduitService(apiService);

  // Getters
  List<Produit> get produits => _produits;
  List<Categorie> get categories => _categories;
  Produit? get selectedProduit => _selectedProduit;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedCategorieId => _selectedCategorieId;

  /// Produits filtrés par catégorie
  List<Produit> get produitsFiltres {
    if (_selectedCategorieId == null) {
      return _produits;
    }
    return _produits.where((p) => p.categorie?.id == _selectedCategorieId).toList();
  }

  /// Charge les produits
  Future<void> chargerProduits({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && _produits.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _produits = await _produitService.getProduits(disponible: true);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les catégories
  Future<void> chargerCategories({bool refresh = false}) async {
    if (!refresh && _categories.isNotEmpty) return;

    try {
      _categories = await _produitService.getCategories();
      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  /// Charge les données initiales
  Future<void> chargerDonnees({bool refresh = false}) async {
    await Future.wait([
      chargerProduits(refresh: refresh),
      chargerCategories(refresh: refresh),
    ]);
  }

  /// Sélectionne une catégorie
  void selectionnerCategorie(int? categorieId) {
    _selectedCategorieId = categorieId;
    notifyListeners();
  }

  /// Charge un produit par son ID
  Future<Produit?> chargerProduitById(int id) async {
    try {
      _selectedProduit = await _produitService.getProduitById(id);
      notifyListeners();
      return _selectedProduit;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Recherche de produits
  Future<List<Produit>> rechercher(String query) async {
    if (query.isEmpty) {
      return _produits;
    }
    
    // Recherche locale d'abord
    final local = _produits.where((p) => 
        p.nom.toLowerCase().contains(query.toLowerCase()) ||
        (p.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
    
    if (local.isNotEmpty) {
      return local;
    }

    // Sinon recherche API
    try {
      return await _produitService.rechercher(query);
    } catch (e) {
      return [];
    }
  }

  /// Efface l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
