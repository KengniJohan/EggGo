package com.egggo.domain.repository;

import com.egggo.domain.model.user.Producteur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository pour la gestion des producteurs
 */
@Repository
public interface ProducteurRepository extends JpaRepository<Producteur, Long> {

    /**
     * Trouve un producteur par son numéro de téléphone
     */
    Optional<Producteur> findByTelephone(String telephone);

    /**
     * Trouve les producteurs actifs
     */
    List<Producteur> findByActifTrue();

    /**
     * Trouve les producteurs certifiés et actifs
     */
    List<Producteur> findByCertifieTrueAndActifTrue();

    /**
     * Trouve les producteurs par adresse de ferme (contient)
     */
    List<Producteur> findByAdresseFermeContainingIgnoreCase(String adresse);

    /**
     * Trouve les producteurs proches d'une position GPS
     */
    @Query("SELECT p FROM Producteur p WHERE " +
           "p.actif = true AND p.certifie = true AND " +
           "p.latitude IS NOT NULL AND p.longitude IS NOT NULL AND " +
           "(6371 * acos(cos(radians(:latitude)) * cos(radians(p.latitude)) * " +
           "cos(radians(p.longitude) - radians(:longitude)) + " +
           "sin(radians(:latitude)) * sin(radians(p.latitude)))) < :rayonKm " +
           "ORDER BY (6371 * acos(cos(radians(:latitude)) * cos(radians(p.latitude)) * " +
           "cos(radians(p.longitude) - radians(:longitude)) + " +
           "sin(radians(:latitude)) * sin(radians(p.latitude))))")
    List<Producteur> findProducteursProches(@Param("latitude") Double latitude,
                                             @Param("longitude") Double longitude,
                                             @Param("rayonKm") Double rayonKm);

    /**
     * Trouve les producteurs les mieux notés
     */
    @Query("SELECT p FROM Producteur p WHERE p.actif = true AND p.certifie = true ORDER BY p.noteMoyenne DESC")
    List<Producteur> findMeilleursProducteurs();

    /**
     * Recherche des producteurs par nom ou ferme
     */
    @Query("SELECT p FROM Producteur p WHERE " +
           "LOWER(p.nom) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(p.nomFerme) LIKE LOWER(CONCAT('%', :search, '%'))")
    List<Producteur> rechercherProducteurs(@Param("search") String search);
}
