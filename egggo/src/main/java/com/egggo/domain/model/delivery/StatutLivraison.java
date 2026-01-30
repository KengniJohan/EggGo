package com.egggo.domain.model.delivery;

/**
 * Énumération des statuts de livraison
 */
public enum StatutLivraison {
    ASSIGNEE("Assignée", "La livraison a été assignée à un livreur"),
    ACCEPTEE("Acceptée", "Le livreur a accepté la livraison"),
    EN_ROUTE_PRODUCTEUR("En route vers producteur", "Le livreur se dirige vers le producteur"),
    RECUPEREE("Récupérée", "La commande a été récupérée chez le producteur"),
    EN_ROUTE_CLIENT("En route vers client", "Le livreur se dirige vers le client"),
    ARRIVEE("Arrivée", "Le livreur est arrivé chez le client"),
    LIVREE("Livrée", "La commande a été livrée"),
    ECHOUEE("Échouée", "La livraison a échoué");

    private final String libelle;
    private final String description;

    StatutLivraison(String libelle, String description) {
        this.libelle = libelle;
        this.description = description;
    }

    public String getLibelle() {
        return libelle;
    }

    public String getDescription() {
        return description;
    }
}
