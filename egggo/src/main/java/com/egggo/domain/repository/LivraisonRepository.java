package com.egggo.domain.repository;

import com.egggo.domain.model.delivery.Livraison;
import com.egggo.domain.model.delivery.StatutLivraison;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Repository pour la gestion des livraisons
 */
@Repository
public interface LivraisonRepository extends JpaRepository<Livraison, Long> {

    /**
     * Trouve une livraison par commande
     */
    Optional<Livraison> findByCommandeId(Long commandeId);

    /**
     * Trouve les livraisons d'un livreur
     */
    List<Livraison> findByLivreurIdOrderByDateAssignationDesc(Long livreurId);

    /**
     * Trouve les livraisons actives d'un livreur
     */
    List<Livraison> findByLivreurIdAndStatutIn(Long livreurId, List<StatutLivraison> statuts);

    /**
     * Trouve les livraisons par statut
     */
    List<Livraison> findByStatut(StatutLivraison statut);

    /**
     * Compte les livraisons effectuées par un livreur
     */
    long countByLivreurIdAndStatut(Long livreurId, StatutLivraison statut);

    /**
     * Trouve les livraisons du jour
     */
    @Query("SELECT l FROM Livraison l WHERE l.dateAssignation >= :debut AND l.dateAssignation < :fin")
    List<Livraison> findLivraisonsDuJour(@Param("debut") LocalDateTime debut,
                                          @Param("fin") LocalDateTime fin);

    /**
     * Calcule le temps moyen de livraison pour un livreur
     */
    @Query("SELECT AVG(TIMESTAMPDIFF(MINUTE, l.dateAcceptation, l.dateLivraison)) " +
           "FROM Livraison l WHERE l.livreur.id = :livreurId AND l.statut = 'LIVREE'")
    Double calculerTempsMoyenLivraison(@Param("livreurId") Long livreurId);
}
