package com.egggo.domain.repository;

import com.egggo.domain.model.order.Commande;
import com.egggo.domain.model.order.StatutCommande;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Repository pour la gestion des commandes
 */
@Repository
public interface CommandeRepository extends JpaRepository<Commande, Long> {

    /**
     * Trouve une commande par sa référence
     */
    Optional<Commande> findByReference(String reference);

    /**
     * Trouve les commandes d'un client
     */
    Page<Commande> findByClientIdOrderByDateCommandeDesc(Long clientId, Pageable pageable);

    /**
     * Trouve les commandes d'un producteur
     */
    Page<Commande> findByProducteurIdOrderByDateCommandeDesc(Long producteurId, Pageable pageable);

    /**
     * Trouve les commandes par statut
     */
    List<Commande> findByStatut(StatutCommande statut);

    /**
     * Trouve les commandes en attente pour un producteur
     */
    List<Commande> findByProducteurIdAndStatut(Long producteurId, StatutCommande statut);

    /**
     * Trouve les commandes du jour pour un producteur
     */
    @Query("SELECT c FROM Commande c WHERE c.producteur.id = :producteurId " +
           "AND c.dateCommande >= :debut AND c.dateCommande < :fin")
    List<Commande> findCommandesDuJour(@Param("producteurId") Long producteurId,
                                        @Param("debut") LocalDateTime debut,
                                        @Param("fin") LocalDateTime fin);

    /**
     * Compte les commandes par statut
     */
    long countByStatut(StatutCommande statut);

    /**
     * Calcule le chiffre d'affaires d'un producteur
     */
    @Query("SELECT SUM(c.montantTotal) FROM Commande c WHERE c.producteur.id = :producteurId " +
           "AND c.statut = 'LIVREE' AND c.dateCommande >= :debut")
    Double calculerChiffreAffaires(@Param("producteurId") Long producteurId,
                                    @Param("debut") LocalDateTime debut);

    /**
     * Trouve les commandes non payées
     */
    List<Commande> findByPayeFalseAndStatutNot(StatutCommande statut);

    /**
     * Trouve les commandes d'un producteur avec un statut spécifique (paginé)
     */
    Page<Commande> findByProducteurIdAndStatutOrderByDateCommandeDesc(Long producteurId, StatutCommande statut, Pageable pageable);

    /**
     * Trouve les commandes après une date
     */
    List<Commande> findByDateCommandeAfter(LocalDateTime date);

    /**
     * Compte les commandes après une date
     */
    long countByDateCommandeAfter(LocalDateTime date);

    /**
     * Trouve les commandes d'un producteur après une date
     */
    List<Commande> findByProducteurIdAndDateCommandeAfter(Long producteurId, LocalDateTime date);
}
