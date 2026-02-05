/// Statuts de commande
enum StatutCommande {
  enAttente('EN_ATTENTE', 'En attente'),
  confirmee('CONFIRMEE', 'Confirmée'),
  enPreparation('EN_PREPARATION', 'En préparation'),
  prete('PRETE', 'Prête'),
  enLivraison('EN_LIVRAISON', 'En livraison'),
  livree('LIVREE', 'Livrée'),
  annulee('ANNULEE', 'Annulée');

  final String code;
  final String libelle;

  const StatutCommande(this.code, this.libelle);

  static StatutCommande fromCode(String code) {
    return StatutCommande.values.firstWhere(
      (s) => s.code == code,
      orElse: () => StatutCommande.enAttente,
    );
  }
}

/// Modes de paiement
enum ModePaiement {
  orangeMoney('ORANGE_MONEY', 'Orange Money'),
  mtnMomo('MTN_MOMO', 'MTN Mobile Money'),
  cashLivraison('CASH_LIVRAISON', 'Cash à la livraison');

  final String code;
  final String libelle;

  const ModePaiement(this.code, this.libelle);

  static ModePaiement fromCode(String code) {
    return ModePaiement.values.firstWhere(
      (m) => m.code == code,
      orElse: () => ModePaiement.cashLivraison,
    );
  }
}

/// Ligne de commande
class LigneCommande {
  final int id;
  final int produitId;
  final String produitNom;
  final int quantite;
  final double prixUnitaire;
  final double sousTotal;

  LigneCommande({
    required this.id,
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.prixUnitaire,
    required this.sousTotal,
  });

  factory LigneCommande.fromJson(Map<String, dynamic> json) {
    return LigneCommande(
      id: json['id'] ?? 0,
      produitId: json['produitId'] ?? 0,
      produitNom: json['produitNom'] ?? '',
      quantite: json['quantite'] ?? 0,
      prixUnitaire: (json['prixUnitaire'] ?? 0).toDouble(),
      sousTotal: (json['sousTotal'] ?? 0).toDouble(),
    );
  }
}

/// Adresse de livraison
class Adresse {
  final int? id;
  final String rue;
  final String quartier;
  final String ville;
  final String? codePostal;
  final String? complement;
  final double? latitude;
  final double? longitude;

  Adresse({
    this.id,
    required this.rue,
    required this.quartier,
    required this.ville,
    this.codePostal,
    this.complement,
    this.latitude,
    this.longitude,
  });

  String get adresseComplete => '$rue, $quartier, $ville';

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      id: json['id'],
      rue: json['rue'] ?? '',
      quartier: json['quartier'] ?? '',
      ville: json['ville'] ?? 'Douala',
      codePostal: json['codePostal'],
      complement: json['complement'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rue': rue,
      'quartier': quartier,
      'ville': ville,
      'codePostal': codePostal,
      'complement': complement,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Modèle Commande
class Commande {
  final int id;
  final String reference;
  final StatutCommande statut;
  final double montantTotal;
  final double? fraisLivraison;
  final bool paye;
  final ModePaiement? modePaiement;
  final String? notes;
  final DateTime dateCreation;
  final DateTime? dateLivraisonSouhaitee;
  final List<LigneCommande> lignes;
  final Adresse? adresseLivraison;

  Commande({
    required this.id,
    required this.reference,
    required this.statut,
    required this.montantTotal,
    this.fraisLivraison,
    this.paye = false,
    this.modePaiement,
    this.notes,
    required this.dateCreation,
    this.dateLivraisonSouhaitee,
    this.lignes = const [],
    this.adresseLivraison,
  });

  /// Montant formaté
  String get montantFormate => '${montantTotal.toStringAsFixed(0)} FCFA';

  /// Sous-total (total - frais de livraison)
  double get sousTotal => montantTotal - (fraisLivraison ?? 0);

  /// Date formatée
  String get dateFormatee {
    return '${dateCreation.day}/${dateCreation.month}/${dateCreation.year}';
  }

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? '',
      statut: StatutCommande.fromCode(json['statut'] ?? 'EN_ATTENTE'),
      montantTotal: (json['montantTotal'] ?? 0).toDouble(),
      fraisLivraison: json['fraisLivraison']?.toDouble(),
      paye: json['paye'] ?? false,
      modePaiement: json['modePaiement'] != null 
          ? ModePaiement.fromCode(json['modePaiement']) 
          : null,
      notes: json['notes'],
      dateCreation: json['dateCreation'] != null 
          ? DateTime.parse(json['dateCreation']) 
          : DateTime.now(),
      dateLivraisonSouhaitee: json['dateLivraisonSouhaitee'] != null 
          ? DateTime.parse(json['dateLivraisonSouhaitee']) 
          : null,
      lignes: (json['lignes'] as List<dynamic>?)
          ?.map((l) => LigneCommande.fromJson(l))
          .toList() ?? [],
      adresseLivraison: json['adresseLivraison'] != null 
          ? Adresse.fromJson(json['adresseLivraison']) 
          : null,
    );
  }
}
