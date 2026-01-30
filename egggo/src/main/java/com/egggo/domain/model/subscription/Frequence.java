package com.egggo.domain.model.subscription;

/**
 * Énumération des fréquences d'abonnement
 */
public enum Frequence {
    HEBDOMADAIRE("Hebdomadaire", 7),
    BI_MENSUELLE("Bi-mensuelle", 14),
    MENSUELLE("Mensuelle", 30);

    private final String libelle;
    private final int joursIntervalle;

    Frequence(String libelle, int joursIntervalle) {
        this.libelle = libelle;
        this.joursIntervalle = joursIntervalle;
    }

    public String getLibelle() {
        return libelle;
    }

    public int getJoursIntervalle() {
        return joursIntervalle;
    }
}
