package com.egggo.api.dto.user;

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
    private Boolean valide;
    private Double noteMoyenne;
    private Integer nombreLivraisons;

    // Rattachement
    private Boolean independant;
    private String producteurRattacheNom;
    private String zoneCouverture;

    // Statistiques du jour
    private Integer livraisonsAujourdhui;
    private Integer livraisonsEnCours;
    private Double gainsAujourdhui;
    private Double distanceParcourue;

    // Statistiques globales
    private Integer livraisonsSemaine;
    private Integer livraisonsMois;
    private Double gainsSemaine;
    private Double gainsMois;

    // Livraison en cours
    private LivraisonEnCoursDto livraisonEnCours;

    // Livraisons en attente
    private List<LivraisonAttenteDto> livraisonsEnAttente;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LivraisonEnCoursDto {
        private Long id;
        private String commandeReference;
        private String clientNom;
        private String adresse;
        private Double latitude;
        private Double longitude;
        private Double distanceRestante;
        private String statut;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LivraisonAttenteDto {
        private Long id;
        private String commandeReference;
        private String producteurNom;
        private String adresseRecuperation;
        private String clientNom;
        private String adresseLivraison;
        private Double distanceEstimee;
        private Double gainEstime;
    }
}
