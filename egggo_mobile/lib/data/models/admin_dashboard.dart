/// Modèle pour le dashboard administrateur
class AdminDashboard {
  final int totalClients;
  final int totalProducteurs;
  final int totalLivreurs;
  final int totalCommandes;
  final double chiffreAffairesMois;
  final double chiffreAffairesJour;
  final int commandesEnCours;
  final int producteursEnAttente;
  final int livreursEnAttente;
  final double variationCA; // % vs mois précédent

  AdminDashboard({
    required this.totalClients,
    required this.totalProducteurs,
    required this.totalLivreurs,
    required this.totalCommandes,
    required this.chiffreAffairesMois,
    required this.chiffreAffairesJour,
    required this.commandesEnCours,
    required this.producteursEnAttente,
    required this.livreursEnAttente,
    this.variationCA = 0,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      totalClients: json['totalClients'] ?? 0,
      totalProducteurs: json['totalProducteurs'] ?? 0,
      totalLivreurs: json['totalLivreurs'] ?? 0,
      totalCommandes: json['totalCommandes'] ?? 0,
      chiffreAffairesMois: (json['chiffreAffairesMois'] ?? 0).toDouble(),
      chiffreAffairesJour: (json['chiffreAffairesJour'] ?? 0).toDouble(),
      commandesEnCours: json['commandesEnCours'] ?? 0,
      producteursEnAttente: json['producteursEnAttente'] ?? 0,
      livreursEnAttente: json['livreursEnAttente'] ?? 0,
      variationCA: (json['variationCA'] ?? 0).toDouble(),
    );
  }

  factory AdminDashboard.empty() {
    return AdminDashboard(
      totalClients: 0,
      totalProducteurs: 0,
      totalLivreurs: 0,
      totalCommandes: 0,
      chiffreAffairesMois: 0,
      chiffreAffairesJour: 0,
      commandesEnCours: 0,
      producteursEnAttente: 0,
      livreursEnAttente: 0,
    );
  }
}

/// Producteur en attente de validation
class ProducteurEnAttente {
  final int id;
  final String nom;
  final String email;
  final String? telephone;
  final String? nomFerme;
  final String? localisation;
  final String? description;
  final DateTime dateInscription;

  ProducteurEnAttente({
    required this.id,
    required this.nom,
    required this.email,
    this.telephone,
    this.nomFerme,
    this.localisation,
    this.description,
    required this.dateInscription,
  });

  factory ProducteurEnAttente.fromJson(Map<String, dynamic> json) {
    return ProducteurEnAttente(
      id: json['id'] ?? 0,
      nom: json['utilisateur']?['nom'] ?? json['nom'] ?? '',
      email: json['utilisateur']?['email'] ?? json['email'] ?? '',
      telephone: json['utilisateur']?['telephone'] ?? json['telephone'],
      nomFerme: json['nomFerme'],
      localisation: json['localisation'],
      description: json['description'],
      dateInscription: json['dateInscription'] != null
          ? DateTime.parse(json['dateInscription'])
          : DateTime.now(),
    );
  }
}

/// Livreur en attente de validation
class LivreurEnAttente {
  final int id;
  final String nom;
  final String email;
  final String? telephone;
  final String? typeVehicule;
  final String? numeroPermis;
  final String? zoneCouverture;
  final DateTime dateInscription;

  LivreurEnAttente({
    required this.id,
    required this.nom,
    required this.email,
    this.telephone,
    this.typeVehicule,
    this.numeroPermis,
    this.zoneCouverture,
    required this.dateInscription,
  });

  factory LivreurEnAttente.fromJson(Map<String, dynamic> json) {
    return LivreurEnAttente(
      id: json['id'] ?? 0,
      nom: json['utilisateur']?['nom'] ?? json['nom'] ?? '',
      email: json['utilisateur']?['email'] ?? json['email'] ?? '',
      telephone: json['utilisateur']?['telephone'] ?? json['telephone'],
      typeVehicule: json['typeVehicule'],
      numeroPermis: json['numeroPermis'],
      zoneCouverture: json['zoneCouverture'],
      dateInscription: json['dateInscription'] != null
          ? DateTime.parse(json['dateInscription'])
          : DateTime.now(),
    );
  }
}
