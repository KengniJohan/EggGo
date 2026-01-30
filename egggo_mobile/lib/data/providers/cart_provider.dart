import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/produit.dart';

/// Provider pour le panier d'achat
class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();

  // Getters
  Cart get cart => _cart;
  List<CartItem> get items => _cart.items;
  int get nombreArticles => _cart.nombreArticles;
  double get total => _cart.total;
  String get totalFormate => _cart.totalFormate;
  bool get estVide => _cart.estVide;

  /// Ajoute un produit au panier
  void ajouterProduit(Produit produit, {int quantite = 1}) {
    _cart.ajouterProduit(produit, quantite: quantite);
    notifyListeners();
  }

  /// Retire un produit du panier
  void retirerProduit(int produitId) {
    _cart.retirerProduit(produitId);
    notifyListeners();
  }

  /// Met à jour la quantité d'un produit
  void mettreAJourQuantite(int produitId, int quantite) {
    _cart.mettreAJourQuantite(produitId, quantite);
    notifyListeners();
  }

  /// Incrémente la quantité d'un produit
  void incrementer(int produitId) {
    final index = _cart.items.indexWhere((item) => item.produit.id == produitId);
    if (index >= 0) {
      _cart.items[index].incrementer();
      notifyListeners();
    }
  }

  /// Décrémente la quantité d'un produit
  void decrementer(int produitId) {
    final index = _cart.items.indexWhere((item) => item.produit.id == produitId);
    if (index >= 0) {
      _cart.items[index].decrementer();
      notifyListeners();
    }
  }

  /// Vide le panier
  void vider() {
    _cart.vider();
    notifyListeners();
  }

  /// Vérifie si un produit est dans le panier
  bool contientProduit(int produitId) {
    return _cart.items.any((item) => item.produit.id == produitId);
  }

  /// Récupère la quantité d'un produit dans le panier
  int getQuantite(int produitId) {
    final item = _cart.items.firstWhere(
      (item) => item.produit.id == produitId,
      orElse: () => CartItem(produit: Produit(id: 0, nom: '', prix: 0), quantite: 0),
    );
    return item.quantite;
  }
}
