package com.egggo.api.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * DTO pour le dashboard administrateur
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdminDashboardDto {

    // Statistiques utilisateurs
    private Integer totalUtilisateurs;
    private Integer totalClients;
    private Integer totalProducteurs;
    private Integer totalLivreurs;
    private Integer producteursEnAttente;
    private Integer livreursEnAttente;

    // Statistiques commandes
    private Integer commandesAujourdhui;
    private Integer commandesEnCours;
    private Integer commandesLivrees;
    private Integer commandesAnnulees;

    // Statistiques financières
    private Double chiffreAffairesJour;
    private Double chiffreAffairesSemaine;
    private Double chiffreAffairesMois;
    private Double commissionsTotales;

    // Graphiques
    private List<ChartDataDto> evolutionVentes;
    private List<ChartDataDto> evolutionInscriptions;
    private Map<String, Integer> repartitionCommandes;

    // Alertes
    private List<AlerteDto> alertes;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ChartDataDto {
        private String label;
        private Double value;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AlerteDto {
        private String type; // WARNING, ERROR, INFO
        private String message;
        private String date;
    }
}
