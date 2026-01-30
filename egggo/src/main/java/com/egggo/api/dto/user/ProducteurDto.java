package com.egggo.api.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO pour les producteurs
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProducteurDto {
    private Long id;
    private String nom;
    private String prenom;
    private String telephone;
    private String email;
    private String nomFerme;
    private String description;
    private String adresseFerme;
    private Double latitude;
    private Double longitude;
    private String logoFerme;
    private Boolean certifie;
    private Boolean valide;
    private Double noteMoyenne;
    private Integer nombreVentes;
    private Integer nombreProduits;
    private LocalDateTime dateCreation;
}
