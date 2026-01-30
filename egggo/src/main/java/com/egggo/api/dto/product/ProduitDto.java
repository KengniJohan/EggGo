package com.egggo.api.dto.product;

import com.egggo.domain.model.product.Unite;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO pour les produits
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProduitDto {

    private Long id;
    private String nom;
    private String description;
    private Double prixUnitaire;
    private Double prixPromotionnel;
    private Unite unite;
    private Integer stockDisponible;
    private String imageUrl;
    private Boolean actif;
    private Boolean disponible;
    
    // Informations sur la catégorie
    private Long categorieId;
    private String categorieNom;
    
    // Informations sur le producteur
    private Long producteurId;
    private String producteurNom;
    private String producteurFerme;
    private Double producteurNote;
}
