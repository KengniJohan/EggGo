package com.egggo.api.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * DTO pour les statistiques de livraisons
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StatsLivraisonsDto {
    private Integer livraisonsTotales;
    private Integer livraisonsReussies;
    private Integer livraisonsEchouees;
    private Double tauxReussite;
    private Double tempsLivraisonMoyen;
    private Double distanceTotaleParcourue;

    private List<LivraisonJourDto> livraisonsParJour;
    private Map<String, Integer> livraisonsParStatut;
    private List<TopLivreurDto> topLivreurs;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LivraisonJourDto {
        private String date;
        private Integer total;
        private Integer reussies;
        private Double distance;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class TopLivreurDto {
        private Long id;
        private String nom;
        private Integer livraisons;
        private Double noteMoyenne;
        private Double distance;
    }
}
