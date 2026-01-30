package com.egggo.api.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * DTO pour les statistiques de ventes
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StatsVentesDto {
    private Double chiffreAffairesTotal;
    private Integer nombreCommandes;
    private Double panierMoyen;
    private Integer nombreClients;
    
    private List<VenteJourDto> ventesParJour;
    private Map<String, Double> ventesParCategorie;
    private List<TopProducteurDto> topProducteurs;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class VenteJourDto {
        private String date;
        private Double montant;
        private Integer commandes;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class TopProducteurDto {
        private Long id;
        private String nomFerme;
        private Double chiffreAffaires;
        private Integer commandes;
    }
}
