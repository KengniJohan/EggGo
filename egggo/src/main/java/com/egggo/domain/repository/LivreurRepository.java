package com.egggo.domain.repository;

import com.egggo.domain.model.user.Livreur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository pour la gestion des livreurs
 */
@Repository
public interface LivreurRepository extends JpaRepository<Livreur, Long> {

    /**
     * Trouve un livreur par son numéro de téléphone
     */
    Optional<Livreur> findByTelephone(String telephone);

    /**
     * Trouve les livreurs disponibles
     */
    List<Livreur> findByDisponibleTrueAndActifTrue();

    /**
     * Trouve les livreurs proches d'une position GPS (dans un rayon donné en km)
     */
    @Query("SELECT l FROM Livreur l WHERE " +
           "l.disponible = true AND l.actif = true AND " +
           "l.latitude IS NOT NULL AND l.longitude IS NOT NULL AND " +
           "(6371 * acos(cos(radians(:latitude)) * cos(radians(l.latitude)) * " +
           "cos(radians(l.longitude) - radians(:longitude)) + " +
           "sin(radians(:latitude)) * sin(radians(l.latitude)))) < :rayonKm " +
           "ORDER BY (6371 * acos(cos(radians(:latitude)) * cos(radians(l.latitude)) * " +
           "cos(radians(l.longitude) - radians(:longitude)) + " +
           "sin(radians(:latitude)) * sin(radians(l.latitude))))")
    List<Livreur> findLivreursProches(@Param("latitude") Double latitude,
                                       @Param("longitude") Double longitude,
                                       @Param("rayonKm") Double rayonKm);

    /**
     * Compte le nombre de livreurs disponibles
     */
    long countByDisponibleTrueAndActifTrue();

    /**
     * Trouve les livreurs avec la meilleure note
     */
    @Query("SELECT l FROM Livreur l WHERE l.actif = true ORDER BY l.noteMoyenne DESC")
    List<Livreur> findMeilleursLivreurs();
}
