package com.egggo.application.service;

import com.egggo.api.dto.product.CategorieDto;
import com.egggo.api.dto.product.CreateProduitRequest;
import com.egggo.api.dto.product.ProduitDto;
import com.egggo.domain.model.product.Categorie;
import com.egggo.domain.model.product.Produit;
import com.egggo.domain.model.user.Producteur;
import com.egggo.domain.repository.CategorieRepository;
import com.egggo.domain.repository.ProducteurRepository;
import com.egggo.domain.repository.ProduitRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service de gestion des produits
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ProduitService {

    private final ProduitRepository produitRepository;
    private final CategorieRepository categorieRepository;
    private final ProducteurRepository producteurRepository;

    /**
     * Récupère toutes les catégories actives
     */
    @Transactional(readOnly = true)
    public List<CategorieDto> getAllCategories() {
        return categorieRepository.findByActifTrueOrderByOrdreAsc()
                .stream()
                .map(this::toCategorieDto)
                .collect(Collectors.toList());
    }

    /**
     * Récupère une catégorie par son ID
     */
    @Transactional(readOnly = true)
    public CategorieDto getCategorieById(Long id) {
        Categorie categorie = categorieRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Catégorie non trouvée avec l'ID: " + id));
        return toCategorieDto(categorie);
    }

    /**
     * Récupère les produits par catégorie
     */
    @Transactional(readOnly = true)
    public List<ProduitDto> getProduitsByCategorie(Long categorieId) {
        return produitRepository.findByCategorieIdAndDisponibleTrue(categorieId)
                .stream()
                .map(this::toProduitDto)
                .collect(Collectors.toList());
    }

    /**
     * Récupère les produits d'un producteur
     */
    @Transactional(readOnly = true)
    public List<ProduitDto> getProduitsByProducteur(Long producteurId) {
        return produitRepository.findByProducteurId(producteurId)
                .stream()
                .map(this::toProduitDto)
                .collect(Collectors.toList());
    }

    /**
     * Récupère tous les produits disponibles
     */
    @Transactional(readOnly = true)
    public List<ProduitDto> getAllProduitsDisponibles() {
        return produitRepository.findByDisponibleTrueAndQuantiteStockGreaterThan(0)
                .stream()
                .map(this::toProduitDto)
                .collect(Collectors.toList());
    }

    /**
     * Récupère un produit par son ID
     */
    @Transactional(readOnly = true)
    public ProduitDto getProduitById(Long id) {
        Produit produit = produitRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Produit non trouvé"));
        return toProduitDto(produit);
    }

    /**
     * Recherche des produits par mot-clé
     */
    @Transactional(readOnly = true)
    public List<ProduitDto> rechercherProduits(String search) {
        return produitRepository.findByNomContainingIgnoreCaseAndDisponibleTrue(search)
                .stream()
                .map(this::toProduitDto)
                .collect(Collectors.toList());
    }

    /**
     * Crée un nouveau produit (pour les producteurs)
     */
    @Transactional
    public ProduitDto createProduit(Long producteurId, CreateProduitRequest request) {
        Producteur producteur = producteurRepository.findById(producteurId)
                .orElseThrow(() -> new EntityNotFoundException("Producteur non trouvé"));

        Categorie categorie = categorieRepository.findById(request.getCategorieId())
                .orElseThrow(() -> new EntityNotFoundException("Catégorie non trouvée"));

        Produit produit = Produit.builder()
                .nom(request.getNom())
                .description(request.getDescription())
                .prixUnitaire(request.getPrixUnitaire())
                .unite(request.getUnite())
                .quantiteStock(request.getStockDisponible() != null ? request.getStockDisponible() : 0)
                .image(request.getImageUrl())
                .categorie(categorie)
                .producteur(producteur)
                .disponible(true)
                .build();

        produit = produitRepository.save(produit);
        log.info("Produit créé: {} par producteur {}", produit.getNom(), producteurId);

        return toProduitDto(produit);
    }

    /**
     * Met à jour le stock d'un produit
     */
    @Transactional
    public ProduitDto updateStock(Long produitId, Integer quantite) {
        Produit produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new EntityNotFoundException("Produit non trouvé"));

        produit.setQuantiteStock(quantite);
        if (quantite > 0) {
            produit.setDisponible(true);
        }
        produit = produitRepository.save(produit);

        log.info("Stock mis à jour pour produit {}: {}", produitId, quantite);

        return toProduitDto(produit);
    }

    /**
     * Convertit une entité Categorie en DTO
     */
    private CategorieDto toCategorieDto(Categorie categorie) {
        return CategorieDto.builder()
                .id(categorie.getId())
                .nom(categorie.getNom())
                .description(categorie.getDescription())
                .icone(categorie.getIcone())
                .ordre(categorie.getOrdre())
                .actif(categorie.getActif())
                .build();
    }

    /**
     * Convertit une entité Produit en DTO
     */
    private ProduitDto toProduitDto(Produit produit) {
        return ProduitDto.builder()
                .id(produit.getId())
                .nom(produit.getNom())
                .description(produit.getDescription())
                .prixUnitaire(produit.getPrixUnitaire())
                .prixPromotionnel(null) // Pas de prix promotionnel dans l'entité actuelle
                .unite(produit.getUnite())
                .stockDisponible(produit.getQuantiteStock())
                .imageUrl(produit.getImage())
                .actif(produit.getDisponible())
                .disponible(produit.verifierDisponibilite(1))
                .categorieId(produit.getCategorie().getId())
                .categorieNom(produit.getCategorie().getNom())
                .producteurId(produit.getProducteur().getId())
                .producteurNom(produit.getProducteur().getNom() + " " + produit.getProducteur().getPrenom())
                .producteurFerme(produit.getProducteur().getNomFerme())
                .producteurNote(produit.getProducteur().getNoteMoyenne())
                .build();
    }
}
