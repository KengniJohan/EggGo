package com.egggo.api.dto.producteur;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO pour la mise à jour du stock
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateStockRequest {

    private Integer quantite;
    
    private StockOperation operation;

    public enum StockOperation {
        ADD,    // Ajouter au stock
        REMOVE, // Retirer du stock
        SET     // Définir le stock à cette valeur
    }
}
