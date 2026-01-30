package com.egggo.api.dto.payment;

import com.egggo.domain.model.order.ModePaiement;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO pour initier un paiement mobile money
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InitierPaiementRequest {

    @NotNull(message = "L'ID de la commande est requis")
    private Long commandeId;

    @NotNull(message = "Le mode de paiement est requis")
    private ModePaiement modePaiement;

    @NotBlank(message = "Le numéro de téléphone est requis")
    @Pattern(regexp = "^(6[5-9][0-9]{7})$", message = "Numéro de téléphone camerounais invalide")
    private String numeroTelephone;

    @NotNull(message = "Le montant est requis")
    @Positive(message = "Le montant doit être positif")
    private Double montant;
}
