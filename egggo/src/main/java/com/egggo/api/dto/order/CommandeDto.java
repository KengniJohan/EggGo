package com.egggo.api.dto.order;

import com.egggo.domain.model.order.ModePaiement;
import com.egggo.domain.model.order.StatutCommande;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO pour les commandes
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CommandeDto {

    private Long id;
    private String reference;
    private StatutCommande statut;
    private ModePaiement modePaiement;
    private Double montantProduits;
    private Double fraisLivraison;
    private Double montantRemise;
    private Double montantTotal;
    private Boolean paye;
    private String creneauLivraison;
    private String notes;
    private LocalDateTime dateCommande;
    private LocalDateTime dateLivraison;

    // Informations client
    private Long clientId;
    private String clientNom;
    private String clientTelephone;

    // Informations producteur
    private Long producteurId;
    private String producteurNom;
    private String producteurFerme;

    // Adresse de livraison
    private AdresseDto adresse;

    // Lignes de commande
    private List<LigneCommandeDto> lignes;

    // Informations livraison (si assignée)
    private LivraisonDto livraison;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AdresseDto {
        private Long id;
        private String nom;
        private String quartier;
        private String ville;
        private String adresseComplete;
        private String indications;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LigneCommandeDto {
        private Long id;
        private Long produitId;
        private String produitNom;
        private String produitUnite;
        private Integer quantite;
        private Double prixUnitaire;
        private Double prixTotal;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LivraisonDto {
        private Long id;
        private String statut;
        private String livreurNom;
        private String livreurTelephone;
        private String codeConfirmation;
    }
}
