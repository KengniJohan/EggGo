package com.egggo.api.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO pour les livreurs
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LivreurDto {
    private Long id;
    private String nom;
    private String prenom;
    private String telephone;
    private String email;
    private String typeVehicule;
    private String numeroPlaque;
    private Boolean disponible;
    private Double latitude;
    private Double longitude;
    private Double noteMoyenne;
    private Integer nombreLivraisons;
    private Boolean valide;
    private Boolean independant;
    private String producteurRattacheNom;
    private Long producteurRattacheId;
    private String zoneCouverture;
    private LocalDateTime dateCreation;
}
