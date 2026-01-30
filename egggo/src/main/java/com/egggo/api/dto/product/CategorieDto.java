package com.egggo.api.dto.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO pour les catégories de produits
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategorieDto {

    private Long id;
    private String nom;
    private String description;
    private String icone;
    private Integer ordre;
    private Boolean actif;
}
