package com.egggo.api.dto.payment;

import com.egggo.domain.model.order.ModePaiement;
import com.egggo.domain.model.payment.StatutPaiement;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO de réponse pour un paiement
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaiementResponse {

    private Long id;
    private String reference;
    private String transactionId;
    private Double montant;
    private ModePaiement modePaiement;
    private StatutPaiement statut;
    private String numeroTelephone;
    private String messageOperateur;
    private LocalDateTime dateInitiation;
    private LocalDateTime dateConfirmation;
    
    // Informations de la commande
    private Long commandeId;
    private String commandeReference;
}
