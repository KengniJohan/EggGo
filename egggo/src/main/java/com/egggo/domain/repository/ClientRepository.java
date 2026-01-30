package com.egggo.domain.repository;

import com.egggo.domain.model.user.Client;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository pour la gestion des clients
 */
@Repository
public interface ClientRepository extends JpaRepository<Client, Long> {

    /**
     * Trouve un client par son numéro de téléphone
     */
    Optional<Client> findByTelephone(String telephone);

    /**
     * Trouve un client par son email
     */
    Optional<Client> findByEmail(String email);

    /**
     * Trouve les clients actifs
     */
    List<Client> findByActifTrue();

    /**
     * Trouve les clients par ville
     */
    @Query("SELECT c FROM Client c JOIN c.adresses a WHERE a.ville = :ville")
    List<Client> findByVille(@Param("ville") String ville);

    /**
     * Trouve les clients ayant des points de fidélité
     */
    List<Client> findByPointsFideliteGreaterThan(Integer points);

    /**
     * Compte le nombre total de clients actifs
     */
    long countByActifTrue();
}
