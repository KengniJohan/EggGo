package com.egggo.api.dto.producteur;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
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
    private Double chiffreAffairesMois;

    // Statistiques
    private Integer commandesEnAttente;
    private Integer produitsEnStock;
    private Integer produitsEnRupture;

    // Dernières commandes
    private List<CommandeResumeDto> commandesRecentes;

    // Produits
    private List<ProduitResumeDto> produits;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CommandeResumeDto {
        private Long id;
        private String reference;
        private String clientNom;
        private Double montant;
        private String statut;
        private LocalDateTime date;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ProduitResumeDto {
        private Long id;
        private String nom;
        private Double prix;
        private Integer stock;
        private Boolean disponible;
    }
}
