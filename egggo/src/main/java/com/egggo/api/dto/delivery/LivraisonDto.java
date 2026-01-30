package com.egggo.api.dto.delivery;

import com.egggo.domain.model.delivery.StatutLivraison;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO pour les livraisons
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LivraisonDto {

    private Long id;
    private Long commandeId;
    private String commandeReference;
    private StatutLivraison statut;
    private String codeConfirmation;
    private Double distanceKm;
    private String notes;

    // Informations client
    private String clientNom;
    private String clientTelephone;
    private AdresseDto adresseLivraison;

    // Informations producteur
    private String producteurNom;
    private String producteurTelephone;
    private AdresseDto adresseRecuperation;

    // Informations livreur
    private Long livreurId;
    private String livreurNom;
    private Double livreurLatitude;
    private Double livreurLongitude;

    // Dates
    private LocalDateTime dateAssignation;
    private LocalDateTime dateAcceptation;
    private LocalDateTime dateRecuperation;
    private LocalDateTime dateLivraison;

    // Montants
    private Double montantCommande;
    private Double fraisLivraison;
    private Double gainLivreur;

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
        private String instructions;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ItineraireDto {
        private Double originLatitude;
        private Double originLongitude;
        private Double destinationLatitude;
        private Double destinationLongitude;
        private Double distanceKm;
        private Integer dureeMinutes;
        private String polyline;
    }
}
