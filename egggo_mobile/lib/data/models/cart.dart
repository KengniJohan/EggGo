import 'produit.dart';

/// Élément du panier
class CartItem {
  final Produit produit;
  int quantite;

  CartItem({
    required this.produit,
    this.quantite = 1,
  });

  /// Prix total de cet élément
  double get total => produit.prix * quantite;

  /// Prix formaté
  String get totalFormate => '${total.toStringAsFixed(0)} FCFA';

  /// Incrémente la quantité
  void incrementer() {
    if (produit.stockDisponible > quantite) {
      quantite++;
    }
  }

  /// Décrémente la quantité (minimum 1)
  void decrementer() {
    if (quantite > 1) {
      quantite--;
    }
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      produit: Produit.fromJson(json['produit']),
      quantite: json['quantite'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produit': produit.toJson(),
      'quantite': quantite,
    };
  }
}

/// Panier d'achat
class Cart {
  final List<CartItem> items;

  Cart({List<CartItem>? items}) : items = items ?? [];

  /// Nombre total d'articles
  int get nombreArticles => items.fold(0, (sum, item) => sum + item.quantite);

  /// Montant total du panier
  double get total => items.fold(0.0, (sum, item) => sum + item.total);

  /// Total formaté
  String get totalFormate => '${total.toStringAsFixed(0)} FCFA';

  /// Vérifie si le panier est vide
  bool get estVide => items.isEmpty;

  /// Ajoute un produit au panier
  void ajouterProduit(Produit produit, {int quantite = 1}) {
    final existingIndex = items.indexWhere((item) => item.produit.id == produit.id);
    
    if (existingIndex >= 0) {
      items[existingIndex].quantite += quantite;
    } else {
      items.add(CartItem(produit: produit, quantite: quantite));
    }
  }

  /// Retire un produit du panier
  void retirerProduit(int produitId) {
    items.removeWhere((item) => item.produit.id == produitId);
  }

  /// Met à jour la quantité d'un produit
  void mettreAJourQuantite(int produitId, int quantite) {
    final index = items.indexWhere((item) => item.produit.id == produitId);
    if (index >= 0) {
      if (quantite <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantite = quantite;
      }
    }
  }

  /// Vide le panier
  void vider() {
    items.clear();
  }

  /// Récupère l'ID du producteur (tous les produits doivent être du même producteur)
  int? get producteurId {
    if (items.isEmpty) return null;
    return items.first.produit.producteurId;
  }

  /// Convertit en liste de lignes de commande pour l'API
  List<Map<String, dynamic>> toLignesCommande() {
    return items.map((item) => {
      'produitId': item.produit.id,
      'quantite': item.quantite,
    }).toList();
  }
}
