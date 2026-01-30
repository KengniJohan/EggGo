package com.egggo.api.controller;

import com.egggo.api.dto.common.ApiResponse;
import com.egggo.api.dto.common.PageResponse;
import com.egggo.api.dto.order.CommandeDto;
import com.egggo.api.dto.order.CreateCommandeRequest;
import com.egggo.application.service.CommandeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Contrôleur pour les commandes
 */
@RestController
@RequestMapping("/api/v1/commandes")
@RequiredArgsConstructor
@Tag(name = "Commandes", description = "APIs pour la gestion des commandes")
public class CommandeController {

    private final CommandeService commandeService;

    @PostMapping
    @PreAuthorize("hasRole('CLIENT')")
    @Operation(summary = "Créer une commande", description = "Crée une nouvelle commande (réservé aux clients)")
    public ResponseEntity<ApiResponse<CommandeDto>> createCommande(
            @RequestHeader("X-Client-Id") Long clientId,
            @Valid @RequestBody CreateCommandeRequest request) {
        CommandeDto commande = commandeService.createCommande(clientId, request);
        return ResponseEntity.ok(ApiResponse.success("Commande créée avec succès", commande));
    }

    @GetMapping("/client")
    @PreAuthorize("hasRole('CLIENT')")
    @Operation(summary = "Mes commandes", description = "Récupère les commandes du client connecté")
    public ResponseEntity<ApiResponse<PageResponse<CommandeDto>>> getCommandesClient(
            @RequestHeader("X-Client-Id") Long clientId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<CommandeDto> commandes = commandeService.getCommandesClient(clientId, pageable);
        return ResponseEntity.ok(ApiResponse.success(PageResponse.from(commandes)));
    }

    @GetMapping("/producteur")
    @PreAuthorize("hasRole('PRODUCTEUR')")
    @Operation(summary = "Commandes reçues", description = "Récupère les commandes reçues par le producteur")
    public ResponseEntity<ApiResponse<PageResponse<CommandeDto>>> getCommandesProducteur(
            @RequestHeader("X-Producteur-Id") Long producteurId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<CommandeDto> commandes = commandeService.getCommandesProducteur(producteurId, pageable);
        return ResponseEntity.ok(ApiResponse.success(PageResponse.from(commandes)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'une commande", description = "Récupère une commande par son ID")
    public ResponseEntity<ApiResponse<CommandeDto>> getCommandeById(@PathVariable Long id) {
        CommandeDto commande = commandeService.getCommandeById(id);
        return ResponseEntity.ok(ApiResponse.success(commande));
    }

    @GetMapping("/reference/{reference}")
    @Operation(summary = "Commande par référence", description = "Récupère une commande par sa référence")
    public ResponseEntity<ApiResponse<CommandeDto>> getCommandeByReference(@PathVariable String reference) {
        CommandeDto commande = commandeService.getCommandeByReference(reference);
        return ResponseEntity.ok(ApiResponse.success(commande));
    }

    @PatchMapping("/{id}/confirmer")
    @PreAuthorize("hasRole('PRODUCTEUR')")
    @Operation(summary = "Confirmer une commande", description = "Confirme une commande (réservé aux producteurs)")
    public ResponseEntity<ApiResponse<CommandeDto>> confirmerCommande(@PathVariable Long id) {
        CommandeDto commande = commandeService.confirmerCommande(id);
        return ResponseEntity.ok(ApiResponse.success("Commande confirmée", commande));
    }

    @PatchMapping("/{id}/annuler")
    @Operation(summary = "Annuler une commande", description = "Annule une commande")
    public ResponseEntity<ApiResponse<CommandeDto>> annulerCommande(
            @PathVariable Long id,
            @RequestParam String raison) {
        CommandeDto commande = commandeService.annulerCommande(id, raison);
        return ResponseEntity.ok(ApiResponse.success("Commande annulée", commande));
    }
}
