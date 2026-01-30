package com.egggo.domain.repository;

import com.egggo.domain.model.product.Categorie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository pour la gestion des catégories de produits
 */
@Repository
public interface CategorieRepository extends JpaRepository<Categorie, Long> {

    /**
     * Trouve une catégorie par son nom
     */
    Optional<Categorie> findByNom(String nom);

    /**
     * Vérifie si une catégorie existe déjà
     */
    boolean existsByNom(String nom);

    /**
     * Trouve les catégories actives
     */
    List<Categorie> findByActifTrue();

    /**
     * Trouve les catégories triées par ordre
     */
    List<Categorie> findByActifTrueOrderByOrdreAsc();
}
