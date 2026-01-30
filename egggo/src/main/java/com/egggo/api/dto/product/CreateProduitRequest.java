package com.egggo.api.dto.product;

import com.egggo.domain.model.product.Unite;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO pour la création d'un produit
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateProduitRequest {

    @NotBlank(message = "Le nom du produit est obligatoire")
    @Size(max = 100, message = "Le nom ne doit pas dépasser 100 caractères")
    private String nom;

    @Size(max = 500, message = "La description ne doit pas dépasser 500 caractères")
    private String description;

    @NotNull(message = "Le prix unitaire est obligatoire")
    @Positive(message = "Le prix doit être positif")
    private Double prixUnitaire;

    @PositiveOrZero(message = "Le prix promotionnel doit être positif ou nul")
    private Double prixPromotionnel;

    @NotNull(message = "L'unité est obligatoire")
    private Unite unite;

    @NotNull(message = "Le stock est obligatoire")
    @PositiveOrZero(message = "Le stock doit être positif ou nul")
    private Integer stockDisponible;

    @PositiveOrZero(message = "Le seuil d'alerte doit être positif ou nul")
    private Integer seuilAlerte;

    private String imageUrl;

    @NotNull(message = "La catégorie est obligatoire")
    private Long categorieId;
}
