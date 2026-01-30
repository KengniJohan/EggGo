package com.egggo.api.controller;

import com.egggo.api.dto.admin.AdminDashboardDto;
import com.egggo.api.dto.common.ApiResponse;
import com.egggo.api.dto.common.PageResponse;
import com.egggo.api.dto.user.*;
import com.egggo.application.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Contrôleur pour les fonctionnalités administrateur
 */
@RestController
@RequestMapping("/v1/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "Administration", description = "APIs pour l'administration")
public class AdminController {

    private final AdminService adminService;

    // ==================== DASHBOARD ====================

    @GetMapping("/dashboard")
    @Operation(summary = "Dashboard admin", description = "Récupère les statistiques globales")
    public ResponseEntity<ApiResponse<AdminDashboardDto>> getDashboard() {
        AdminDashboardDto dashboard = adminService.getDashboard();
        return ResponseEntity.ok(ApiResponse.success(dashboard));
    }

    // ==================== GESTION DES UTILISATEURS ====================

    @GetMapping("/utilisateurs")
    @Operation(summary = "Liste utilisateurs", description = "Liste tous les utilisateurs avec filtres")
    public ResponseEntity<ApiResponse<PageResponse<UtilisateurDto>>> getUtilisateurs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String role) {
        Pageable pageable = PageRequest.of(page, size);
        Page<UtilisateurDto> utilisateurs = adminService.getUtilisateurs(role, pageable);
        return ResponseEntity.ok(ApiResponse.success(PageResponse.from(utilisateurs)));
    }

    @GetMapping("/utilisateurs/{id}")
    @Operation(summary = "Détail utilisateur", description = "Récupère les détails d'un utilisateur")
    public ResponseEntity<ApiResponse<UtilisateurDto>> getUtilisateur(@PathVariable Long id) {
        UtilisateurDto utilisateur = adminService.getUtilisateurById(id);
        return ResponseEntity.ok(ApiResponse.success(utilisateur));
    }

    @PatchMapping("/utilisateurs/{id}/activer")
    @Operation(summary = "Activer/Désactiver utilisateur", description = "Change l'état d'activation")
    public ResponseEntity<ApiResponse<UtilisateurDto>> toggleActivation(@PathVariable Long id) {
        UtilisateurDto utilisateur = adminService.toggleUtilisateurActif(id);
        return ResponseEntity.ok(ApiResponse.success(utilisateur));
    }

    // ==================== VALIDATION PRODUCTEURS ====================

    @GetMapping("/producteurs/en-attente")
    @Operation(summary = "Producteurs en attente", description = "Liste les producteurs en attente de validation")
    public ResponseEntity<ApiResponse<List<ProducteurDto>>> getProducteursEnAttente() {
        List<ProducteurDto> producteurs = adminService.getProducteursEnAttente();
        return ResponseEntity.ok(ApiResponse.success(producteurs));
    }

    @PatchMapping("/producteurs/{id}/valider")
    @Operation(summary = "Valider producteur", description = "Valide un producteur")
    public ResponseEntity<ApiResponse<ProducteurDto>> validerProducteur(@PathVariable Long id) {
        ProducteurDto producteur = adminService.validerProducteur(id);
        return ResponseEntity.ok(ApiResponse.success("Producteur validé", producteur));
    }

    @PatchMapping("/producteurs/{id}/refuser")
    @Operation(summary = "Refuser producteur", description = "Refuse un producteur avec motif")
    public ResponseEntity<ApiResponse<Void>> refuserProducteur(
            @PathVariable Long id,
            @RequestParam String motif) {
        adminService.refuserProducteur(id, motif);
        return ResponseEntity.ok(ApiResponse.success("Producteur refusé"));
    }

    // ==================== VALIDATION LIVREURS ====================

    @GetMapping("/livreurs/en-attente")
    @Operation(summary = "Livreurs en attente", description = "Liste les livreurs en attente de validation")
    public ResponseEntity<ApiResponse<List<LivreurDto>>> getLivreursEnAttente() {
        List<LivreurDto> livreurs = adminService.getLivreursEnAttente();
        return ResponseEntity.ok(ApiResponse.success(livreurs));
    }

    @PatchMapping("/livreurs/{id}/valider")
    @Operation(summary = "Valider livreur", description = "Valide un livreur")
    public ResponseEntity<ApiResponse<LivreurDto>> validerLivreur(@PathVariable Long id) {
        LivreurDto livreur = adminService.validerLivreur(id);
        return ResponseEntity.ok(ApiResponse.success("Livreur validé", livreur));
    }

    @PatchMapping("/livreurs/{id}/refuser")
    @Operation(summary = "Refuser livreur", description = "Refuse un livreur avec motif")
    public ResponseEntity<ApiResponse<Void>> refuserLivreur(
            @PathVariable Long id,
            @RequestParam String motif) {
        adminService.refuserLivreur(id, motif);
        return ResponseEntity.ok(ApiResponse.success("Livreur refusé"));
    }

    // ==================== STATISTIQUES ====================

    @GetMapping("/stats/ventes")
    @Operation(summary = "Statistiques ventes", description = "Récupère les statistiques de ventes")
    public ResponseEntity<ApiResponse<StatsVentesDto>> getStatsVentes(
            @RequestParam(required = false) String periode) {
        StatsVentesDto stats = adminService.getStatsVentes(periode);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    @GetMapping("/stats/livraisons")
    @Operation(summary = "Statistiques livraisons", description = "Récupère les statistiques de livraisons")
    public ResponseEntity<ApiResponse<StatsLivraisonsDto>> getStatsLivraisons(
            @RequestParam(required = false) String periode) {
        StatsLivraisonsDto stats = adminService.getStatsLivraisons(periode);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
}
