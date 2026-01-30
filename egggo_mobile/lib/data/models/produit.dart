/// Modèle Catégorie de produit
class Categorie {
  final int id;
  final String nom;
  final String? description;
  final String? imageUrl;
  final bool actif;

  Categorie({
    required this.id,
    required this.nom,
    this.description,
    this.imageUrl,
    this.actif = true,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      actif: json['actif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'imageUrl': imageUrl,
      'actif': actif,
    };
  }
}

/// Modèle Produit (œufs)
class Produit {
  final int id;
  final String nom;
  final String? description;
  final double prix;
  final String unite;
  final int quantiteMinimale;
  final int stockDisponible;
  final String? imageUrl;
  final bool disponible;
  final Categorie? categorie;
  final int? producteurId;
  final String? producteurNom;

  Produit({
    required this.id,
    required this.nom,
    this.description,
    required this.prix,
    this.unite = 'plateau',
    this.quantiteMinimale = 1,
    this.stockDisponible = 0,
    this.imageUrl,
    this.disponible = true,
    this.categorie,
    this.producteurId,
    this.producteurNom,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'],
      prix: (json['prixUnitaire'] ?? json['prix'] ?? 0).toDouble(),
      unite: json['unite'] ?? 'plateau',
      quantiteMinimale: json['quantiteMinimale'] ?? 1,
      stockDisponible: json['quantiteStock'] ?? json['stockDisponible'] ?? 0,
      imageUrl: json['imageUrl'],
      disponible: json['disponible'] ?? json['actif'] ?? true,
      categorie: json['categorie'] != null 
          ? Categorie.fromJson(json['categorie']) 
          : null,
      producteurId: json['producteurId'],
      producteurNom: json['producteurNom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'unite': unite,
      'quantiteMinimale': quantiteMinimale,
      'stockDisponible': stockDisponible,
      'imageUrl': imageUrl,
      'disponible': disponible,
      'categorieId': categorie?.id,
    };
  }

  /// Prix formaté avec devise
  String get prixFormate => '${prix.toStringAsFixed(0)} FCFA';

  /// Vérifie si le produit est en stock
  bool get enStock => stockDisponible > 0 && disponible;
}
