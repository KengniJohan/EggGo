package com.egggo.api.controller;

import com.egggo.api.dto.common.ApiResponse;
import com.egggo.api.dto.product.CategorieDto;
import com.egggo.api.dto.product.CreateProduitRequest;
import com.egggo.api.dto.product.ProduitDto;
import com.egggo.application.service.ProduitService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Contrôleur pour les produits
 */
@RestController
@RequestMapping("/v1/produits")
@RequiredArgsConstructor
@Tag(name = "Produits", description = "APIs pour la gestion des produits")
public class ProduitController {

    private final ProduitService produitService;

    @GetMapping("/categories")
    @Operation(summary = "Liste des catégories", description = "Récupère toutes les catégories actives")
    public ResponseEntity<ApiResponse<List<CategorieDto>>> getAllCategories() {
        List<CategorieDto> categories = produitService.getAllCategories();
        return ResponseEntity.ok(ApiResponse.success(categories));
    }

    @GetMapping
    @Operation(summary = "Liste des produits", description = "Récupère tous les produits disponibles")
    public ResponseEntity<ApiResponse<List<ProduitDto>>> getAllProduits() {
        List<ProduitDto> produits = produitService.getAllProduitsDisponibles();
        return ResponseEntity.ok(ApiResponse.success(produits));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'un produit", description = "Récupère un produit par son ID")
    public ResponseEntity<ApiResponse<ProduitDto>> getProduitById(@PathVariable Long id) {
        ProduitDto produit = produitService.getProduitById(id);
        return ResponseEntity.ok(ApiResponse.success(produit));
    }

    @GetMapping("/categorie/{categorieId}")
    @Operation(summary = "Produits par catégorie", description = "Récupère les produits d'une catégorie")
    public ResponseEntity<ApiResponse<List<ProduitDto>>> getProduitsByCategorie(@PathVariable Long categorieId) {
        List<ProduitDto> produits = produitService.getProduitsByCategorie(categorieId);
        return ResponseEntity.ok(ApiResponse.success(produits));
    }

    @GetMapping("/producteur/{producteurId}")
    @Operation(summary = "Produits par producteur", description = "Récupère les produits d'un producteur")
    public ResponseEntity<ApiResponse<List<ProduitDto>>> getProduitsByProducteur(@PathVariable Long producteurId) {
        List<ProduitDto> produits = produitService.getProduitsByProducteur(producteurId);
        return ResponseEntity.ok(ApiResponse.success(produits));
    }

    @GetMapping("/search")
    @Operation(summary = "Recherche de produits", description = "Recherche des produits par mot-clé")
    public ResponseEntity<ApiResponse<List<ProduitDto>>> searchProduits(@RequestParam String q) {
        List<ProduitDto> produits = produitService.rechercherProduits(q);
        return ResponseEntity.ok(ApiResponse.success(produits));
    }

    @PostMapping
    @PreAuthorize("hasRole('PRODUCTEUR')")
    @Operation(summary = "Créer un produit", description = "Crée un nouveau produit (réservé aux producteurs)")
    public ResponseEntity<ApiResponse<ProduitDto>> createProduit(
            @RequestHeader("X-Producteur-Id") Long producteurId,
            @Valid @RequestBody CreateProduitRequest request) {
        ProduitDto produit = produitService.createProduit(producteurId, request);
        return ResponseEntity.ok(ApiResponse.success("Produit créé avec succès", produit));
    }

    @PatchMapping("/{id}/stock")
    @PreAuthorize("hasRole('PRODUCTEUR')")
    @Operation(summary = "Mettre à jour le stock", description = "Met à jour le stock d'un produit")
    public ResponseEntity<ApiResponse<ProduitDto>> updateStock(
            @PathVariable Long id,
            @RequestParam Integer quantite) {
        ProduitDto produit = produitService.updateStock(id, quantite);
        return ResponseEntity.ok(ApiResponse.success("Stock mis à jour", produit));
    }
}
