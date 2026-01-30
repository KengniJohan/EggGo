package com.egggo.domain.repository;

import com.egggo.domain.model.product.Produit;
import com.egggo.domain.model.product.Unite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository pour la gestion des produits
 */
@Repository
public interface ProduitRepository extends JpaRepository<Produit, Long> {

    /**
     * Trouve les produits par catégorie
     */
    List<Produit> findByCategorieIdAndDisponibleTrue(Long categorieId);

    /**
     * Trouve les produits par producteur
     */
    List<Produit> findByProducteurId(Long producteurId);

    /**
     * Trouve les produits disponibles (en stock)
     */
    List<Produit> findByDisponibleTrueAndQuantiteStockGreaterThan(Integer stock);

    /**
     * Trouve les produits par unité
     */
    List<Produit> findByUniteAndDisponibleTrue(Unite unite);

    /**
     * Recherche des produits par nom (contient, ignore case)
     */
    List<Produit> findByNomContainingIgnoreCaseAndDisponibleTrue(String nom);

    /**
     * Recherche des produits par nom ou description
     */
    @Query("SELECT p FROM Produit p WHERE " +
           "p.disponible = true AND " +
           "(LOWER(p.nom) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(p.description) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<Produit> rechercherProduits(@Param("search") String search);

    /**
     * Trouve les produits populaires (les plus commandés)
     */
    @Query("SELECT p, COUNT(lc) as nbCommandes FROM Produit p " +
           "LEFT JOIN LigneCommande lc ON lc.produit = p " +
           "WHERE p.disponible = true " +
           "GROUP BY p ORDER BY nbCommandes DESC")
    List<Object[]> findProduitsPopulaires();

    /**
     * Trouve les produits avec stock faible (quantité < 10)
     */
    @Query("SELECT p FROM Produit p WHERE p.disponible = true AND p.quantiteStock < 10")
    List<Produit> findProduitsStockFaible();
}
