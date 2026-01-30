/// Statuts de paiement
enum StatutPaiement {
  enAttente('EN_ATTENTE', 'En attente'),
  enCours('EN_COURS', 'En cours'),
  reussi('REUSSI', 'Réussi'),
  echoue('ECHOUE', 'Échoué'),
  expire('EXPIRE', 'Expiré'),
  annule('ANNULE', 'Annulé'),
  rembourse('REMBOURSE', 'Remboursé');

  final String code;
  final String libelle;

  const StatutPaiement(this.code, this.libelle);

  static StatutPaiement fromCode(String code) {
    return StatutPaiement.values.firstWhere(
      (s) => s.code == code,
      orElse: () => StatutPaiement.enAttente,
    );
  }

  bool get estTermine => this == reussi || this == echoue || this == annule || this == expire;
  bool get estReussi => this == reussi;
}

/// Modèle Paiement Mobile Money
class Paiement {
  final int id;
  final String reference;
  final String? transactionId;
  final double montant;
  final String modePaiement;
  final StatutPaiement statut;
  final String? numeroTelephone;
  final String? messageOperateur;
  final DateTime? dateInitiation;
  final DateTime? dateConfirmation;
  final int? commandeId;
  final String? commandeReference;

  Paiement({
    required this.id,
    required this.reference,
    this.transactionId,
    required this.montant,
    required this.modePaiement,
    required this.statut,
    this.numeroTelephone,
    this.messageOperateur,
    this.dateInitiation,
    this.dateConfirmation,
    this.commandeId,
    this.commandeReference,
  });

  /// Montant formaté
  String get montantFormate => '${montant.toStringAsFixed(0)} FCFA';

  /// Vérifie si c'est Orange Money
  bool get estOrangeMoney => modePaiement == 'ORANGE_MONEY';

  /// Vérifie si c'est MTN MoMo
  bool get estMtnMomo => modePaiement == 'MTN_MOMO';

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? '',
      transactionId: json['transactionId'],
      montant: (json['montant'] ?? 0).toDouble(),
      modePaiement: json['modePaiement'] ?? '',
      statut: StatutPaiement.fromCode(json['statut'] ?? 'EN_ATTENTE'),
      numeroTelephone: json['numeroTelephone'],
      messageOperateur: json['messageOperateur'],
      dateInitiation: json['dateInitiation'] != null 
          ? DateTime.parse(json['dateInitiation']) 
          : null,
      dateConfirmation: json['dateConfirmation'] != null 
          ? DateTime.parse(json['dateConfirmation']) 
          : null,
      commandeId: json['commandeId'],
      commandeReference: json['commandeReference'],
    );
  }
}

/// Requête d'initiation de paiement
class InitierPaiementRequest {
  final int commandeId;
  final String modePaiement;
  final String numeroTelephone;
  final double montant;

  InitierPaiementRequest({
    required this.commandeId,
    required this.modePaiement,
    required this.numeroTelephone,
    required this.montant,
  });

  Map<String, dynamic> toJson() {
    return {
      'commandeId': commandeId,
      'modePaiement': modePaiement,
      'numeroTelephone': numeroTelephone,
      'montant': montant,
    };
  }
}

/// Requête de confirmation de paiement
class ConfirmerPaiementRequest {
  final int paiementId;
  final String codeOtp;
  final String? simulationMode;

  ConfirmerPaiementRequest({
    required this.paiementId,
    required this.codeOtp,
    this.simulationMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'paiementId': paiementId,
      'codeOtp': codeOtp,
      if (simulationMode != null) 'simulationMode': simulationMode,
    };
  }
}
