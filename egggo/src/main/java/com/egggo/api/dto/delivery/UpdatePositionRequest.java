package com.egggo.api.dto.delivery;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * DTO pour la mise à jour de la position GPS
 */
@Data
public class UpdatePositionRequest {

    @NotNull(message = "La latitude est obligatoire")
    private Double latitude;

    @NotNull(message = "La longitude est obligatoire")
    private Double longitude;
}
