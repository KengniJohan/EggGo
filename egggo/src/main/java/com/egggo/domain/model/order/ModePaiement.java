package com.egggo.domain.model.order;

/**
 * Énumération des modes de paiement supportés
 */
public enum ModePaiement {
    MTN_MOMO("MTN Mobile Money", "momo"),
    ORANGE_MONEY("Orange Money", "om"),
    CASH_LIVRAISON("Cash à la livraison", "cash"),
    CARTE_BANCAIRE("Carte bancaire", "card");

    private final String libelle;
    private final String code;

    ModePaiement(String libelle, String code) {
        this.libelle = libelle;
        this.code = code;
    }

    public String getLibelle() {
        return libelle;
    }

    public String getCode() {
        return code;
    }

    /**
     * Vérifie si le mode de paiement nécessite un paiement immédiat
     */
    public boolean necessitePaiementImmediat() {
        return this != CASH_LIVRAISON;
    }
}
