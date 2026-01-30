package com.egggo.domain.model.product;

/**
 * Énumération des unités de vente des produits
 */
public enum Unite {
    PIECE("Pièce", 1),
    PLATEAU_30("Plateau (30 œufs)", 30),
    CARTON_180("Carton (180 œufs)", 180),
    CARTON_360("Carton (360 œufs)", 360);

    private final String libelle;
    private final int quantite;

    Unite(String libelle, int quantite) {
        this.libelle = libelle;
        this.quantite = quantite;
    }

    public String getLibelle() {
        return libelle;
    }

    public int getQuantite() {
        return quantite;
    }
}
