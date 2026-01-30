package com.egggo.domain.model.payment;

/**
 * Énumération des statuts de paiement
 */
public enum StatutPaiement {
    EN_ATTENTE("En attente", "Le paiement est en attente de traitement"),
    EN_COURS("En cours", "Le paiement est en cours de traitement"),
    REUSSI("Réussi", "Le paiement a été effectué avec succès"),
    ECHOUE("Échoué", "Le paiement a échoué"),
    EXPIRE("Expiré", "Le délai de paiement a expiré"),
    ANNULE("Annulé", "Le paiement a été annulé"),
    REMBOURSE("Remboursé", "Le paiement a été remboursé");

    private final String libelle;
    private final String description;

    StatutPaiement(String libelle, String description) {
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
     * Vérifie si le paiement est terminé (succès ou échec)
     */
    public boolean estTermine() {
        return this == REUSSI || this == ECHOUE || this == REMBOURSE;
    }
}
