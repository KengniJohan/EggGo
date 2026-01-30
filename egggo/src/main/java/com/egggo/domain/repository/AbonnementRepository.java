package com.egggo.domain.repository;

import com.egggo.domain.model.subscription.Abonnement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/**
 * Repository pour la gestion des abonnements
 */
@Repository
public interface AbonnementRepository extends JpaRepository<Abonnement, Long> {

    /**
     * Trouve les abonnements d'un client
     */
    List<Abonnement> findByClientIdOrderByDateCreationDesc(Long clientId);

    /**
     * Trouve les abonnements actifs d'un client
     */
    List<Abonnement> findByClientIdAndActifTrue(Long clientId);

    /**
     * Trouve les abonnements à livrer à une date donnée
     */
    @Query("SELECT a FROM Abonnement a WHERE a.actif = true AND a.prochaineLivraison = :date")
    List<Abonnement> findAbonnementsALivrer(@Param("date") LocalDate date);

    /**
     * Trouve tous les abonnements actifs
     */
    List<Abonnement> findByActifTrue();

    /**
     * Compte les abonnements actifs
     */
    long countByActifTrue();
}
