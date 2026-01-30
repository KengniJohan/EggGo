package com.egggo.api.dto.livreur;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO pour la mise à jour de la position GPS
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdatePositionRequest {

    private Double latitude;
    private Double longitude;
}
