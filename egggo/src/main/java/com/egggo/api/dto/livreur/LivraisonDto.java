package com.egggo.api.dto.livreur;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO pour une livraison
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LivraisonDto {

    private Long id;
    private Long commandeId;
    private String commandeRef;
    private String clientNom;
    private String clientTelephone;
    private AdresseDto adresse;
    private String statut;
    private Double distance;
    private Integer tempsEstime;
    private Double montant;
    private LocalDateTime dateAssignation;
    private LocalDateTime dateAcceptation;
    private LocalDateTime dateLivraison;
    private String notes;
    private ItineraireDto itineraire;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AdresseDto {
        private String rue;
        private String quartier;
        private String ville;
        private Double latitude;
        private Double longitude;
        private String indications;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ItineraireDto {
        private PointDto depart;
        private PointDto arrivee;
        private List<PointDto> points;
        private Double distanceTotale;
        private Integer dureeEstimee;

        @Data
        @NoArgsConstructor
        @AllArgsConstructor
        @Builder
        public static class PointDto {
            private Double latitude;
            private Double longitude;
            private String label;
        }
    }
}
