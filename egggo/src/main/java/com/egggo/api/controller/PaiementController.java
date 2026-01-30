package com.egggo.api.controller;

import com.egggo.api.dto.common.ApiResponse;
import com.egggo.api.dto.payment.ConfirmerPaiementRequest;
import com.egggo.api.dto.payment.InitierPaiementRequest;
import com.egggo.api.dto.payment.PaiementResponse;
import com.egggo.application.service.PaiementService;
import com.egggo.domain.model.payment.StatutPaiement;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller pour les paiements mobile money (SIMULATION)
 * 
 * Ce controller simule les interactions avec Orange Money et MTN Mobile Money
 * pour permettre les tests complets sans intégration réelle.
 * 
 * MODES DE SIMULATION pour confirmerPaiement:
 * - codeOtp="1234" ou simulationMode="SUCCESS" : Paiement réussi
 * - codeOtp="0000" ou simulationMode="FAILED"  : Paiement échoué
 * - simulationMode="TIMEOUT" : Délai dépassé
 * - simulationMode="CANCEL"  : Annulation utilisateur
 */
@RestController
@RequestMapping("/v1/paiements")
@RequiredArgsConstructor
@Tag(name = "Paiements", description = "API de paiement mobile money (SIMULATION)")
public class PaiementController {

    private final PaiementService paiementService;

    /**
     * Initie un paiement mobile money
     * Simule l'envoi d'une demande USSD/Push à l'utilisateur
     */
    @PostMapping("/initier")
    @Operation(summary = "Initier un paiement", 
               description = "Démarre un paiement Orange Money ou MTN MoMo. " +
                           "En simulation, un message USSD est généré.")
    public ResponseEntity<ApiResponse<PaiementResponse>> initierPaiement(
            @Valid @RequestBody InitierPaiementRequest request) {
        
        PaiementResponse response = paiementService.initierPaiement(request);
        
        return ResponseEntity.ok(ApiResponse.<PaiementResponse>builder()
                .success(true)
                .message("Paiement initié. " + response.getMessageOperateur())
                .data(response)
                .build());
    }

    /**
     * Confirme un paiement (simulation du callback opérateur)
     * Utilisez différents codes OTP pour simuler différents résultats
     */
    @PostMapping("/confirmer")
    @Operation(summary = "Confirmer un paiement (SIMULATION)", 
               description = "Simule la confirmation du paiement. " +
                           "Codes: 1234=succès, 0000=échec, TIMEOUT=expiré")
    public ResponseEntity<ApiResponse<PaiementResponse>> confirmerPaiement(
            @Valid @RequestBody ConfirmerPaiementRequest request) {
        
        PaiementResponse response = paiementService.confirmerPaiement(request);
        
        String message = switch (response.getStatut()) {
            case REUSSI -> "Paiement confirmé avec succès!";
            case ECHOUE -> "Le paiement a échoué.";
            case EXPIRE -> "Le délai de paiement a expiré.";
            case ANNULE -> "Le paiement a été annulé.";
            default -> "Paiement en cours de traitement.";
        };
        
        return ResponseEntity.ok(ApiResponse.<PaiementResponse>builder()
                .success(response.getStatut() == StatutPaiement.REUSSI)
                .message(message)
                .data(response)
                .build());
    }

    /**
     * Vérifie le statut d'un paiement par son ID
     */
    @GetMapping("/{id}")
    @Operation(summary = "Vérifier le statut d'un paiement")
    public ResponseEntity<ApiResponse<PaiementResponse>> verifierStatut(@PathVariable Long id) {
        PaiementResponse response = paiementService.verifierStatut(id);
        
        return ResponseEntity.ok(ApiResponse.<PaiementResponse>builder()
                .success(true)
                .message("Statut du paiement récupéré")
                .data(response)
                .build());
    }

    /**
     * Vérifie le statut d'un paiement par sa référence
     */
    @GetMapping("/reference/{reference}")
    @Operation(summary = "Vérifier le statut par référence")
    public ResponseEntity<ApiResponse<PaiementResponse>> verifierStatutParReference(
            @PathVariable String reference) {
        
        PaiementResponse response = paiementService.verifierStatutParReference(reference);
        
        return ResponseEntity.ok(ApiResponse.<PaiementResponse>builder()
                .success(true)
                .message("Statut du paiement récupéré")
                .data(response)
                .build());
    }

    /**
     * Récupère l'historique des paiements d'une commande
     */
    @GetMapping("/commande/{commandeId}")
    @Operation(summary = "Historique des paiements d'une commande")
    public ResponseEntity<ApiResponse<List<PaiementResponse>>> getPaiementsCommande(
            @PathVariable Long commandeId) {
        
        List<PaiementResponse> paiements = paiementService.getPaiementsCommande(commandeId);
        
        return ResponseEntity.ok(ApiResponse.<List<PaiementResponse>>builder()
                .success(true)
                .message(paiements.size() + " paiement(s) trouvé(s)")
                .data(paiements)
                .build());
    }

    /**
     * Annule un paiement en attente
     */
    @PostMapping("/{id}/annuler")
    @Operation(summary = "Annuler un paiement en attente")
    public ResponseEntity<ApiResponse<PaiementResponse>> annulerPaiement(@PathVariable Long id) {
        PaiementResponse response = paiementService.annulerPaiement(id);
        
        return ResponseEntity.ok(ApiResponse.<PaiementResponse>builder()
                .success(true)
                .message("Paiement annulé avec succès")
                .data(response)
                .build());
    }

    /**
     * Endpoint d'information sur les modes de simulation
     */
    @GetMapping("/simulation/info")
    @Operation(summary = "Information sur les modes de simulation")
    public ResponseEntity<ApiResponse<SimulationInfo>> getSimulationInfo() {
        SimulationInfo info = new SimulationInfo();
        
        return ResponseEntity.ok(ApiResponse.<SimulationInfo>builder()
                .success(true)
                .message("Modes de simulation disponibles")
                .data(info)
                .build());
    }

    /**
     * DTO pour les informations de simulation
     */
    public static class SimulationInfo {
        public final String description = "API de paiement SIMULÉE pour les tests";
        public final String[] modesDisponibles = {
            "SUCCESS ou 1234 : Paiement réussi",
            "FAILED ou 0000 : Paiement échoué (solde insuffisant)",
            "TIMEOUT ou 9999 : Délai de validation dépassé",
            "CANCEL ou ANNULE : Annulation par l'utilisateur"
        };
        public final String[] operateursSimules = {"ORANGE_MONEY", "MTN_MOMO"};
        public final String formatTelephone = "Cameroun: 6XXXXXXXX (9 chiffres, commence par 6)";
        public final String exempleOrangeMoney = "65X, 69X pour Orange Money";
        public final String exempleMtnMomo = "67X, 68X pour MTN Mobile Money";
    }
}
