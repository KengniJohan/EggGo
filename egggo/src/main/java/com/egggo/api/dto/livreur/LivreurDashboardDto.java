package com.egggo.api.dto.livreur;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO pour le dashboard livreur
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LivreurDashboardDto {

    private Long livreurId;
    private String nom;
    private Boolean disponible;
    private Integer livraisonsJour;
    private Double gainsJour;
    private Double distanceJour;
    private Double noteMoyenne;

    private LivraisonEnCoursDto livraisonEnCours;
    private List<LivraisonAttenteDto> livraisonsAttente;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LivraisonEnCoursDto {
        private Long id;
        private String commandeRef;
        private String clientNom;
        private String clientTelephone;
        private String adresse;
        private Double latitude;
        private Double longitude;
        private Double distanceRestante;
        private Integer tempsEstime;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LivraisonAttenteDto {
        private Long id;
        private String commandeRef;
        private String clientNom;
        private String adresse;
        private Double distance;
        private Double montant;
    }
}
