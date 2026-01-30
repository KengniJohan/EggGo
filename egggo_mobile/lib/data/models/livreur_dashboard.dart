/// Modèle pour le dashboard livreur
class LivreurDashboard {
  final bool disponible;
  final int livraisonsJour;
  final double gainsJour;
  final double distanceJour;
  final double noteMoyenne;
  final int nombreAvis;
  final int livraisonsEnAttente;
  final int livraisonsEnCours;
  final int totalLivraisons;
  final LivraisonEnCours? livraisonEnCours;
  final List<LivraisonAttente> livraisonsEnAttenteList;

  LivreurDashboard({
    required this.disponible,
    required this.livraisonsJour,
    required this.gainsJour,
    required this.distanceJour,
    required this.noteMoyenne,
    required this.nombreAvis,
    required this.livraisonsEnAttente,
    required this.livraisonsEnCours,
    required this.totalLivraisons,
    this.livraisonEnCours,
    required this.livraisonsEnAttenteList,
  });

  factory LivreurDashboard.fromJson(Map<String, dynamic> json) {
    return LivreurDashboard(
      disponible: json['disponible'] ?? false,
      livraisonsJour: json['livraisonsJour'] ?? 0,
      gainsJour: (json['gainsJour'] ?? 0).toDouble(),
      distanceJour: (json['distanceJour'] ?? 0).toDouble(),
      noteMoyenne: (json['noteMoyenne'] ?? 0).toDouble(),
      nombreAvis: json['nombreAvis'] ?? 0,
      livraisonsEnAttente: json['livraisonsEnAttente'] ?? 0,
      livraisonsEnCours: json['livraisonsEnCours'] ?? 0,
      totalLivraisons: json['totalLivraisons'] ?? 0,
      livraisonEnCours: json['livraisonEnCours'] != null
          ? LivraisonEnCours.fromJson(json['livraisonEnCours'])
          : null,
      livraisonsEnAttenteList: (json['livraisonsEnAttenteList'] as List<dynamic>?)
              ?.map((e) => LivraisonAttente.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory LivreurDashboard.empty() {
    return LivreurDashboard(
      disponible: false,
      livraisonsJour: 0,
      gainsJour: 0,
      distanceJour: 0,
      noteMoyenne: 4.5,
      nombreAvis: 0,
      livraisonsEnAttente: 0,
      livraisonsEnCours: 0,
      totalLivraisons: 0,
      livraisonEnCours: null,
      livraisonsEnAttenteList: [],
    );
  }
}

/// Livraison en cours
class LivraisonEnCours {
  final int id;
  final String reference;
  final String clientNom;
  final String clientTelephone;
  final String adresseLivraison;
  final double? clientLatitude;
  final double? clientLongitude;
  final String statut;
  final double fraisLivraison;

  LivraisonEnCours({
    required this.id,
    required this.reference,
    required this.clientNom,
    required this.clientTelephone,
    required this.adresseLivraison,
    this.clientLatitude,
    this.clientLongitude,
    required this.statut,
    required this.fraisLivraison,
  });

  factory LivraisonEnCours.fromJson(Map<String, dynamic> json) {
    return LivraisonEnCours(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? '',
      clientNom: json['clientNom'] ?? '',
      clientTelephone: json['clientTelephone'] ?? '',
      adresseLivraison: json['adresseLivraison'] ?? '',
      clientLatitude: json['clientLatitude']?.toDouble(),
      clientLongitude: json['clientLongitude']?.toDouble(),
      statut: json['statut'] ?? '',
      fraisLivraison: (json['fraisLivraison'] ?? 0).toDouble(),
    );
  }
}

/// Livraison en attente
class LivraisonAttente {
  final int id;
  final String reference;
  final String adresseRecuperation;
  final String adresseLivraison;
  final double? distance;
  final double fraisLivraison;
  final DateTime dateAssignation;

  LivraisonAttente({
    required this.id,
    required this.reference,
    required this.adresseRecuperation,
    required this.adresseLivraison,
    this.distance,
    required this.fraisLivraison,
    required this.dateAssignation,
  });

  factory LivraisonAttente.fromJson(Map<String, dynamic> json) {
    return LivraisonAttente(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? '',
      adresseRecuperation: json['adresseRecuperation'] ?? '',
      adresseLivraison: json['adresseLivraison'] ?? '',
      distance: json['distance']?.toDouble(),
      fraisLivraison: (json['fraisLivraison'] ?? 0).toDouble(),
      dateAssignation: json['dateAssignation'] != null
          ? DateTime.parse(json['dateAssignation'])
          : DateTime.now(),
    );
  }
}

/// Livraison complète
class Livraison {
  final int id;
  final String reference;
  final String clientNom;
  final String clientTelephone;
  final String adresseRecuperation;
  final String adresseLivraison;
  final double? clientLatitude;
  final double? clientLongitude;
  final String statut;
  final double fraisLivraison;
  final DateTime dateCreation;
  final DateTime? dateLivraison;
  final String? codeConfirmation;
  final String? photoPreuve;
  final String? problemeDescription;

  Livraison({
    required this.id,
    required this.reference,
    required this.clientNom,
    required this.clientTelephone,
    required this.adresseRecuperation,
    required this.adresseLivraison,
    this.clientLatitude,
    this.clientLongitude,
    required this.statut,
    required this.fraisLivraison,
    required this.dateCreation,
    this.dateLivraison,
    this.codeConfirmation,
    this.photoPreuve,
    this.problemeDescription,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? '',
      clientNom: json['clientNom'] ?? '',
      clientTelephone: json['clientTelephone'] ?? '',
      adresseRecuperation: json['adresseRecuperation'] ?? '',
      adresseLivraison: json['adresseLivraison'] ?? '',
      clientLatitude: json['clientLatitude']?.toDouble(),
      clientLongitude: json['clientLongitude']?.toDouble(),
      statut: json['statut'] ?? '',
      fraisLivraison: (json['fraisLivraison'] ?? 0).toDouble(),
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
      dateLivraison: json['dateLivraison'] != null
          ? DateTime.parse(json['dateLivraison'])
          : null,
      codeConfirmation: json['codeConfirmation'],
      photoPreuve: json['photoPreuve'],
      problemeDescription: json['problemeDescription'],
    );
  }
}
