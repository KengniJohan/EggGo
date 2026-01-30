package com.egggo.api.controller;

import com.egggo.api.dto.common.ApiResponse;
import com.egggo.api.dto.livreur.LivraisonDto;
import com.egggo.api.dto.livreur.LivreurDashboardDto;
import com.egggo.api.dto.livreur.UpdatePositionRequest;
import com.egggo.application.service.LivreurService;
import com.egggo.domain.model.user.Utilisateur;
import com.egggo.domain.repository.UtilisateurRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Contrôleur pour les fonctionnalités livreur
 */
@RestController
@RequestMapping("/v1/livreur")
@RequiredArgsConstructor
@PreAuthorize("hasRole('LIVREUR')")
@Tag(name = "Livreur", description = "APIs pour les livreurs")
public class LivreurController {

    private final LivreurService livreurService;
    private final UtilisateurRepository utilisateurRepository;

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String telephone = authentication.getName();
        Utilisateur utilisateur = utilisateurRepository.findByTelephone(telephone)
                .orElseThrow(() -> new IllegalStateException("Utilisateur non trouvé"));
        return utilisateur.getId();
    }

    // ==================== DASHBOARD ====================

    @GetMapping("/dashboard")
    @Operation(summary = "Dashboard livreur", description = "Récupère les statistiques du livreur")
    public ResponseEntity<ApiResponse<LivreurDashboardDto>> getDashboard() {
        Long livreurId = getCurrentUserId();
        LivreurDashboardDto dashboard = livreurService.getDashboard(livreurId);
        return ResponseEntity.ok(ApiResponse.success(dashboard));
    }

    // ==================== DISPONIBILITÉ ====================

    @PatchMapping("/disponibilite")
    @Operation(summary = "Changer disponibilité", description = "Active/désactive la disponibilité du livreur")
    public ResponseEntity<ApiResponse<Void>> setDisponibilite(@RequestParam boolean disponible) {
        Long livreurId = getCurrentUserId();
        livreurService.setDisponible(livreurId, disponible);
        String message = disponible ? "Vous êtes maintenant disponible" : "Vous êtes hors ligne";
        return ResponseEntity.ok(ApiResponse.success(message));
    }

    // ==================== POSITION GPS ====================

    @PostMapping("/position")
    @Operation(summary = "Mettre à jour position", description = "Met à jour la position GPS du livreur")
    public ResponseEntity<ApiResponse<Void>> updatePosition(
            @Valid @RequestBody UpdatePositionRequest request) {
        Long livreurId = getCurrentUserId();
        livreurService.updatePosition(livreurId, request);
        return ResponseEntity.ok(ApiResponse.success("Position mise à jour"));
    }

    // ==================== LIVRAISONS ====================

    @GetMapping("/livraisons")
    @Operation(summary = "Mes livraisons", description = "Liste les livraisons assignées au livreur")
    public ResponseEntity<ApiResponse<List<LivraisonDto>>> getMesLivraisons(
            @RequestParam(required = false) String statut) {
        Long livreurId = getCurrentUserId();
        List<LivraisonDto> livraisons = livreurService.getLivraisons(livreurId, statut);
        return ResponseEntity.ok(ApiResponse.success(livraisons));
    }

    @PatchMapping("/livraisons/{id}/accepter")
    @Operation(summary = "Accepter livraison", description = "Accepte une livraison assignée")
    public ResponseEntity<ApiResponse<LivraisonDto>> accepterLivraison(@PathVariable Long id) {
        Long livreurId = getCurrentUserId();
        LivraisonDto livraison = livreurService.accepterLivraison(livreurId, id);
        return ResponseEntity.ok(ApiResponse.success("Livraison acceptée", livraison));
    }

    @PatchMapping("/livraisons/{id}/arrivee")
    @Operation(summary = "Signaler arrivée", description = "Signale l'arrivée à destination")
    public ResponseEntity<ApiResponse<LivraisonDto>> signalerArrivee(@PathVariable Long id) {
        Long livreurId = getCurrentUserId();
        LivraisonDto livraison = livreurService.signalerArrivee(livreurId, id);
        return ResponseEntity.ok(ApiResponse.success("Arrivée signalée", livraison));
    }

    @PatchMapping("/livraisons/{id}/confirmer")
    @Operation(summary = "Confirmer livraison", description = "Confirme la livraison au client")
    public ResponseEntity<ApiResponse<LivraisonDto>> confirmerLivraison(
            @PathVariable Long id,
            @RequestParam(required = false) String codeConfirmation,
            @RequestParam(required = false) String photoPreuve) {
        Long livreurId = getCurrentUserId();
        LivraisonDto livraison = livreurService.confirmerLivraison(livreurId, id, codeConfirmation, photoPreuve);
        return ResponseEntity.ok(ApiResponse.success("Livraison effectuée avec succès", livraison));
    }

    @PatchMapping("/livraisons/{id}/probleme")
    @Operation(summary = "Signaler problème", description = "Signale un problème lors de la livraison")
    public ResponseEntity<ApiResponse<LivraisonDto>> signalerProbleme(
            @PathVariable Long id,
            @RequestParam String description) {
        Long livreurId = getCurrentUserId();
        LivraisonDto livraison = livreurService.signalerProbleme(livreurId, id, description);
        return ResponseEntity.ok(ApiResponse.success("Problème signalé", livraison));
    }

    // ==================== ITINÉRAIRE ====================

    @GetMapping("/livraisons/{id}/itineraire")
    @Operation(summary = "Obtenir itinéraire", description = "Récupère l'itinéraire vers la destination")
    public ResponseEntity<ApiResponse<LivraisonDto.ItineraireDto>> getItineraire(@PathVariable Long id) {
        Long livreurId = getCurrentUserId();
        LivraisonDto.ItineraireDto itineraire = livreurService.getItineraire(livreurId, id);
        return ResponseEntity.ok(ApiResponse.success(itineraire));
    }
}
