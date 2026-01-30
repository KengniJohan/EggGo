package com.egggo.api.dto.order;

import com.egggo.domain.model.order.ModePaiement;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO pour la création d'une commande
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateCommandeRequest {

    // Soit adresseId pour une adresse existante, soit nouvelleAdresse pour en créer une
    private Long adresseId;
    
    @Valid
    private AdresseRequest nouvelleAdresse;

    @NotNull(message = "Le producteur est obligatoire")
    private Long producteurId;

    @NotNull(message = "Le mode de paiement est obligatoire")
    private ModePaiement modePaiement;

    private String creneauLivraison;
    
    private String notes;

    @NotEmpty(message = "La commande doit contenir au moins un produit")
    @Valid
    private List<LigneCommandeRequest> lignes;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LigneCommandeRequest {
        
        @NotNull(message = "Le produit est obligatoire")
        private Long produitId;

        @NotNull(message = "La quantité est obligatoire")
        @Positive(message = "La quantité doit être positive")
        private Integer quantite;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AdresseRequest {
        private String libelle;
        private String rue;
        @NotNull(message = "Le quartier est obligatoire")
        private String quartier;
        @NotNull(message = "La ville est obligatoire")
        private String ville;
        private String description;
        private Double latitude;
        private Double longitude;
    }
}
