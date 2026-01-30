/// Modèle pour le dashboard producteur
class ProducteurDashboard {
  final double chiffreAffairesMois;
  final double chiffreAffairesJour;
  final int commandesEnAttente;
  final int commandesConfirmees;
  final int commandesEnLivraison;
  final int totalCommandes;
  final int produitsEnStock;
  final int produitsEnRupture;
  final double noteMoyenne;
  final int nombreAvis;
  final List<CommandeRecente> dernieresCommandes;

  ProducteurDashboard({
    required this.chiffreAffairesMois,
    required this.chiffreAffairesJour,
    required this.commandesEnAttente,
    required this.commandesConfirmees,
    required this.commandesEnLivraison,
    required this.totalCommandes,
    required this.produitsEnStock,
    required this.produitsEnRupture,
    required this.noteMoyenne,
    required this.nombreAvis,
    required this.dernieresCommandes,
  });

  factory ProducteurDashboard.fromJson(Map<String, dynamic> json) {
    return ProducteurDashboard(
      chiffreAffairesMois: (json['chiffreAffairesMois'] ?? 0).toDouble(),
      chiffreAffairesJour: (json['chiffreAffairesJour'] ?? 0).toDouble(),
      commandesEnAttente: json['commandesEnAttente'] ?? 0,
      commandesConfirmees: json['commandesConfirmees'] ?? 0,
      commandesEnLivraison: json['commandesEnLivraison'] ?? 0,
      totalCommandes: json['totalCommandes'] ?? 0,
      produitsEnStock: json['produitsEnStock'] ?? 0,
      produitsEnRupture: json['produitsEnRupture'] ?? 0,
      noteMoyenne: (json['noteMoyenne'] ?? 0).toDouble(),
      nombreAvis: json['nombreAvis'] ?? 0,
      dernieresCommandes: (json['dernieresCommandes'] as List<dynamic>?)
              ?.map((e) => CommandeRecente.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory ProducteurDashboard.empty() {
    return ProducteurDashboard(
      chiffreAffairesMois: 0,
      chiffreAffairesJour: 0,
      commandesEnAttente: 0,
      commandesConfirmees: 0,
      commandesEnLivraison: 0,
      totalCommandes: 0,
      produitsEnStock: 0,
      produitsEnRupture: 0,
      noteMoyenne: 0,
      nombreAvis: 0,
      dernieresCommandes: [],
    );
  }
}

/// Commande récente pour le dashboard
class CommandeRecente {
  final int id;
  final String reference;
  final String clientNom;
  final double montant;
  final String statut;
  final DateTime dateCommande;

  CommandeRecente({
    required this.id,
    required this.reference,
    required this.clientNom,
    required this.montant,
    required this.statut,
    required this.dateCommande,
  });

  factory CommandeRecente.fromJson(Map<String, dynamic> json) {
    return CommandeRecente(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? '',
      clientNom: json['clientNom'] ?? '',
      montant: (json['montant'] ?? 0).toDouble(),
      statut: json['statut'] ?? 'EN_ATTENTE',
      dateCommande: json['dateCommande'] != null
          ? DateTime.parse(json['dateCommande'])
          : DateTime.now(),
    );
  }
}

/// Requête de mise à jour du stock
class UpdateStockRequest {
  final int quantite;
  final String operation; // AJOUTER, RETIRER, DEFINIR

  UpdateStockRequest({
    required this.quantite,
    required this.operation,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantite': quantite,
      'operation': operation,
    };
  }
}
