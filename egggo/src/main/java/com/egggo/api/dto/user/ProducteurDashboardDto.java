package com.egggo.api.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO pour le dashboard producteur
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProducteurDashboardDto {

    private Long producteurId;
    private String nomFerme;
    private Boolean valide;
    private Boolean certifie;
    private Double noteMoyenne;

    // Statistiques produits
    private Integer totalProduits;
    private Integer produitsDisponibles;
    private Integer produitsEnRupture;

    // Statistiques commandes
    private Integer commandesEnAttente;
    private Integer commandesEnCours;
    private Integer commandesLivrees;
    private Integer commandesAujourdhui;

    // Statistiques financières
    private Double chiffreAffairesJour;
    private Double chiffreAffairesSemaine;
    private Double chiffreAffairesMois;

    // Dernières commandes
    private List<CommandeResumeDto> dernieresCommandes;

    // Produits les plus vendus
    private List<ProduitResumeDto> produitsPopulaires;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CommandeResumeDto {
        private Long id;
        private String reference;
        private String clientNom;
        private Double montantTotal;
        private String statut;
        private String dateCommande;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ProduitResumeDto {
        private Long id;
        private String nom;
        private Integer quantiteVendue;
        private Integer quantiteStock;
        private Double chiffreAffaires;
    }
}
