package com.egggo.domain.repository;

import com.egggo.domain.model.payment.Paiement;
import com.egggo.domain.model.payment.StatutPaiement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Repository pour la gestion des paiements
 */
@Repository
public interface PaiementRepository extends JpaRepository<Paiement, Long> {

    /**
     * Trouve un paiement par sa référence
     */
    Optional<Paiement> findByReference(String reference);

    /**
     * Trouve un paiement par son ID de transaction
     */
    Optional<Paiement> findByTransactionId(String transactionId);

    /**
     * Trouve les paiements d'une commande
     */
    List<Paiement> findByCommandeIdOrderByDateCreationDesc(Long commandeId);

    /**
     * Trouve les paiements d'une commande (alias)
     */
    default List<Paiement> findByCommandeId(Long commandeId) {
        return findByCommandeIdOrderByDateCreationDesc(commandeId);
    }

    /**
     * Trouve les paiements par statut
     */
    List<Paiement> findByStatut(StatutPaiement statut);

    /**
     * Trouve les paiements en attente depuis plus de X minutes
     */
    @Query("SELECT p FROM Paiement p WHERE p.statut = 'EN_ATTENTE' AND p.dateCreation < :limite")
    List<Paiement> findPaiementsEnAttenteExpires(@Param("limite") LocalDateTime limite);

    /**
     * Calcule le montant total des paiements réussis sur une période
     */
    @Query("SELECT SUM(p.montant) FROM Paiement p WHERE p.statut = 'REUSSI' " +
           "AND p.datePaiement >= :debut AND p.datePaiement < :fin")
    Double calculerMontantTotal(@Param("debut") LocalDateTime debut, @Param("fin") LocalDateTime fin);
}
