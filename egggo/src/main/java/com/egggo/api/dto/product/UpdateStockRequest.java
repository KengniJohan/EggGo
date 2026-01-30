package com.egggo.api.dto.product;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * DTO pour la mise à jour du stock
 */
@Data
public class UpdateStockRequest {

    @NotNull(message = "La quantité est obligatoire")
    @Min(value = 0, message = "La quantité doit être positive")
    private Integer quantite;

    /**
     * Type d'opération: ADD (ajouter), SET (définir), REMOVE (retirer)
     */
    private String operation = "SET";
}
