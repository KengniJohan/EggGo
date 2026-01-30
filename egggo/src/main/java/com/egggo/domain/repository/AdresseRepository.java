package com.egggo.domain.repository;

import com.egggo.domain.model.common.Adresse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository pour la gestion des adresses
 */
@Repository
public interface AdresseRepository extends JpaRepository<Adresse, Long> {

    /**
     * Trouve les adresses d'un client
     */
    List<Adresse> findByClientId(Long clientId);

    /**
     * Trouve les adresses par ville
     */
    List<Adresse> findByVille(String ville);

    /**
     * Trouve les adresses par quartier
     */
    List<Adresse> findByQuartier(String quartier);

    /**
     * Trouve l'adresse principale d'un client
     */
    List<Adresse> findByClientIdAndPrincipaleTrue(Long clientId);
}
