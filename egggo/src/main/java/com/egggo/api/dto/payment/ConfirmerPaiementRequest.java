package com.egggo.api.dto.payment;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO pour confirmer un paiement (simulation du callback opérateur)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConfirmerPaiementRequest {

    @NotNull(message = "L'ID du paiement est requis")
    private Long paiementId;

    @NotBlank(message = "Le code OTP est requis (simulation)")
    private String codeOtp;

    /**
     * Pour la simulation:
     * - "SUCCESS" ou "1234" : paiement réussi
     * - "FAILED" ou "0000" : paiement échoué
     * - "TIMEOUT" : délai dépassé
     * - Autre : paiement en attente
     */
    private String simulationMode;
}
