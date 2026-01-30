package com.egggo.api.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO pour le dashboard administrateur
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdminDashboardDto {

    private Integer totalClients;
    private Integer totalProducteurs;
    private Integer totalLivreurs;
    private Integer commandesMois;
    private Double chiffreAffairesMois;
    private Integer producteursEnAttente;
    private Integer livreursEnAttente;

    private List<ChartDataDto> commandesChart;
    private List<AlerteDto> alertes;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ChartDataDto {
        private String label;
        private Double valeur;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AlerteDto {
        private String type;
        private String message;
        private LocalDateTime date;
    }
}
