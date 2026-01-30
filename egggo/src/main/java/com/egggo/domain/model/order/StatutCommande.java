package com.egggo.domain.model.order;

/**
 * Énumération des statuts de commande
 */
public enum StatutCommande {
    EN_ATTENTE("En attente", "La commande est en attente de confirmation"),
    CONFIRMEE("Confirmée", "La commande a été confirmée par le producteur"),
    EN_PREPARATION("En préparation", "La commande est en cours de préparation"),
    PRETE("Prête", "La commande est prête pour récupération"),
    EN_LIVRAISON("En livraison", "La commande est en cours de livraison"),
    LIVREE("Livrée", "La commande a été livrée"),
    ANNULEE("Annulée", "La commande a été annulée"),
    REMBOURSEE("Remboursée", "La commande a été remboursée");

    private final String libelle;
    private final String description;

    StatutCommande(String libelle, String description) {
        this.libelle = libelle;
        this.description = description;
    }

    public String getLibelle() {
        return libelle;
    }

    public String getDescription() {
        return description;
    }

    /**
     * Vérifie si le statut peut passer au statut suivant
     */
    public boolean peutPasserA(StatutCommande nouveauStatut) {
        return switch (this) {
            case EN_ATTENTE -> nouveauStatut == CONFIRMEE || nouveauStatut == ANNULEE;
            case CONFIRMEE -> nouveauStatut == EN_PREPARATION || nouveauStatut == ANNULEE;
            case EN_PREPARATION -> nouveauStatut == PRETE || nouveauStatut == ANNULEE;
            case PRETE -> nouveauStatut == EN_LIVRAISON || nouveauStatut == ANNULEE;
            case EN_LIVRAISON -> nouveauStatut == LIVREE || nouveauStatut == ANNULEE;
            case LIVREE -> nouveauStatut == REMBOURSEE;
            case ANNULEE, REMBOURSEE -> false;
        };
    }
}
