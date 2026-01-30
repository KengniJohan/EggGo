package com.egggo.api.controller;

import com.egggo.api.dto.common.ApiResponse;
import com.egggo.api.dto.product.CategorieDto;
import com.egggo.application.service.ProduitService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Contrôleur pour les catégories de produits
 */
@RestController
@RequestMapping("/v1/categories")
@RequiredArgsConstructor
@Tag(name = "Catégories", description = "APIs pour la gestion des catégories")
public class CategorieController {

    private final ProduitService produitService;

    @GetMapping
    @Operation(summary = "Liste des catégories", description = "Récupère toutes les catégories actives")
    public ResponseEntity<ApiResponse<List<CategorieDto>>> getAllCategories() {
        List<CategorieDto> categories = produitService.getAllCategories();
        return ResponseEntity.ok(ApiResponse.success(categories));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'une catégorie", description = "Récupère une catégorie par son ID")
    public ResponseEntity<ApiResponse<CategorieDto>> getCategorieById(@PathVariable Long id) {
        CategorieDto categorie = produitService.getCategorieById(id);
        return ResponseEntity.ok(ApiResponse.success(categorie));
    }
}
