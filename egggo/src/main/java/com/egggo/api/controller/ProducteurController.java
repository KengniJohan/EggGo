package com.egggo.api.controller;

import com.egggo.api.dto.common.ApiResponse;
import com.egggo.api.dto.common.PageResponse;
import com.egggo.api.dto.order.CommandeDto;
import com.egggo.api.dto.product.CreateProduitRequest;
import com.egggo.api.dto.product.ProduitDto;
import com.egggo.api.dto.producteur.UpdateStockRequest;
import com.egggo.api.dto.producteur.ProducteurDashboardDto;
import com.egggo.api.dto.user.LivreurDto;
import com.egggo.application.service.ProducteurService;
import com.egggo.domain.model.user.Utilisateur;
import com.egggo.domain.repository.UtilisateurRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Contrôleur pour les fonctionnalités producteur
 */
@RestController
@RequestMapping("/v1/producteur")
@RequiredArgsConstructor
@PreAuthorize("hasRole('PRODUCTEUR')")
@Tag(name = "Producteur", description = "APIs pour les producteurs")
public class ProducteurController {

    private final ProducteurService producteurService;
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
    @Operation(summary = "Dashboard producteur", description = "Récupère les statistiques du producteur")
    public ResponseEntity<ApiResponse<ProducteurDashboardDto>> getDashboard() {
        Long producteurId = getCurrentUserId();
        ProducteurDashboardDto dashboard = producteurService.getDashboard(producteurId);
        return ResponseEntity.ok(ApiResponse.success(dashboard));
    }

    // ==================== GESTION DES PRODUITS ====================

    @GetMapping("/produits")
    @Operation(summary = "Mes produits", description = "Liste tous les produits du producteur")
    public ResponseEntity<ApiResponse<List<ProduitDto>>> getMesProduits() {
        Long producteurId = getCurrentUserId();
        List<ProduitDto> produits = producteurService.getProduits(producteurId);
        return ResponseEntity.ok(ApiResponse.success(produits));
    }

    @PostMapping("/produits")
    @Operation(summary = "Publier un produit", description = "Crée une nouvelle offre de produit")
    public ResponseEntity<ApiResponse<ProduitDto>> createProduit(
            @Valid @RequestBody CreateProduitRequest request) {
        Long producteurId = getCurrentUserId();
        ProduitDto produit = producteurService.createProduit(producteurId, request);
        return ResponseEntity.ok(ApiResponse.success("Produit publié avec succès", produit));
    }

    @PutMapping("/produits/{id}")
    @Operation(summary = "Modifier un produit", description = "Met à jour un produit existant")
    public ResponseEntity<ApiResponse<ProduitDto>> updateProduit(
            @PathVariable Long id,
            @Valid @RequestBody CreateProduitRequest request) {
        Long producteurId = getCurrentUserId();
        ProduitDto produit = producteurService.updateProduit(producteurId, id, request);
        return ResponseEntity.ok(ApiResponse.success("Produit mis à jour", produit));
    }

    @PatchMapping("/produits/{id}/stock")
    @Operation(summary = "Mettre à jour le stock", description = "Modifie la quantité en stock")
    public ResponseEntity<ApiResponse<ProduitDto>> updateStock(
            @PathVariable Long id,
            @Valid @RequestBody UpdateStockRequest request) {
        Long producteurId = getCurrentUserId();
        ProduitDto produit = producteurService.updateStock(producteurId, id, request);
        return ResponseEntity.ok(ApiResponse.success("Stock mis à jour", produit));
    }

    @PatchMapping("/produits/{id}/disponibilite")
    @Operation(summary = "Activer/Désactiver produit", description = "Change la disponibilité du produit")
    public ResponseEntity<ApiResponse<ProduitDto>> toggleDisponibilite(@PathVariable Long id) {
        Long producteurId = getCurrentUserId();
        ProduitDto produit = producteurService.toggleDisponibilite(producteurId, id);
        return ResponseEntity.ok(ApiResponse.success(produit));
    }

    @DeleteMapping("/produits/{id}")
    @Operation(summary = "Supprimer un produit", description = "Supprime un produit")
    public ResponseEntity<ApiResponse<Void>> deleteProduit(@PathVariable Long id) {
        Long producteurId = getCurrentUserId();
        producteurService.deleteProduit(producteurId, id);
        return ResponseEntity.ok(ApiResponse.success("Produit supprimé"));
    }

    // ==================== GESTION DES COMMANDES ====================

    @GetMapping("/commandes")
    @Operation(summary = "Commandes reçues", description = "Liste les commandes reçues par le producteur")
    public ResponseEntity<ApiResponse<PageResponse<CommandeDto>>> getCommandesRecues(
            @RequestParam(required = false) String statut,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Long producteurId = getCurrentUserId();
        Pageable pageable = PageRequest.of(page, size);
        Page<CommandeDto> commandes = producteurService.getCommandes(producteurId, statut, pageable);
        return ResponseEntity.ok(ApiResponse.success(PageResponse.from(commandes)));
    }

    @PatchMapping("/commandes/{id}/confirmer")
    @Operation(summary = "Confirmer une commande", description = "Confirme la préparation d'une commande")
    public ResponseEntity<ApiResponse<CommandeDto>> confirmerCommande(@PathVariable Long id) {
        Long producteurId = getCurrentUserId();
        CommandeDto commande = producteurService.confirmerCommande(producteurId, id);
        return ResponseEntity.ok(ApiResponse.success("Commande confirmée", commande));
    }

    @PatchMapping("/commandes/{id}/annuler")
    @Operation(summary = "Annuler une commande", description = "Annule une commande")
    public ResponseEntity<ApiResponse<CommandeDto>> annulerCommande(
            @PathVariable Long id,
            @RequestParam String raison) {
        Long producteurId = getCurrentUserId();
        CommandeDto commande = producteurService.annulerCommande(producteurId, id, raison);
        return ResponseEntity.ok(ApiResponse.success("Commande annulée", commande));
    }

    @PatchMapping("/commandes/{id}/prete")
    @Operation(summary = "Marquer commande prête", description = "Marque la commande comme prête à être récupérée par le livreur")
    public ResponseEntity<ApiResponse<CommandeDto>> marquerPrete(@PathVariable Long id) {
        Long producteurId = getCurrentUserId();
        CommandeDto commande = producteurService.marquerPrete(producteurId, id);
        return ResponseEntity.ok(ApiResponse.success("Commande prête", commande));
    }

    // ==================== GESTION DES LIVREURS ====================

    @GetMapping("/livreurs")
    @Operation(summary = "Livreurs rattachés", description = "Liste les livreurs rattachés au producteur")
    public ResponseEntity<ApiResponse<List<LivreurDto>>> getLivreursRattaches() {
        Long producteurId = getCurrentUserId();
        List<LivreurDto> livreurs = producteurService.getLivreursRattaches(producteurId);
        return ResponseEntity.ok(ApiResponse.success(livreurs));
    }

    @GetMapping("/livreurs/independants")
    @Operation(summary = "Livreurs indépendants", description = "Liste les livreurs indépendants disponibles")
    public ResponseEntity<ApiResponse<List<LivreurDto>>> getLivreursIndependants() {
        List<LivreurDto> livreurs = producteurService.getLivreursIndependants();
        return ResponseEntity.ok(ApiResponse.success(livreurs));
    }

    @PostMapping("/commandes/{commandeId}/assigner-livreur/{livreurId}")
    @Operation(summary = "Assigner un livreur", description = "Assigne un livreur à une commande")
    public ResponseEntity<ApiResponse<CommandeDto>> assignerLivreur(
            @PathVariable Long commandeId,
            @PathVariable Long livreurId) {
        Long producteurId = getCurrentUserId();
        CommandeDto commande = producteurService.assignerLivreur(producteurId, commandeId, livreurId);
        return ResponseEntity.ok(ApiResponse.success("Livreur assigné", commande));
    }
}
