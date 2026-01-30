package com.egggo.domain.model.payment;

import com.egggo.domain.model.order.Commande;
import com.egggo.domain.model.order.ModePaiement;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Entité représentant un paiement pour une commande
 */
@Entity
@Table(name = "paiements")
@EntityListeners(AuditingEntityListener.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Paiement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String reference;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "commande_id", nullable = false)
    private Commande commande;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ModePaiement modePaiement;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private StatutPaiement statut = StatutPaiement.EN_ATTENTE;

    @Column(nullable = false)
    private Double montant;

    @Column(length = 100)
    private String transactionId; // ID de transaction du fournisseur (MTN, Orange, etc.)

    @Column(length = 15)
    private String numeroTelephone; // Numéro utilisé pour le paiement mobile

    @Column(columnDefinition = "TEXT")
    private String messageErreur;

    @Column(columnDefinition = "TEXT")
    private String metadata; // JSON pour stocker les détails de réponse du fournisseur

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @Column
    private LocalDateTime datePaiement;

    /**
     * Génère une référence unique pour le paiement
     */
    @PrePersist
    public void prePersist() {
        if (reference == null) {
            String uuid = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            reference = "PAY-" + System.currentTimeMillis() + "-" + uuid;
        }
    }

    /**
     * Marque le paiement comme réussi
     */
    public void marquerReussi(String transactionId) {
        this.statut = StatutPaiement.REUSSI;
        this.transactionId = transactionId;
        this.datePaiement = LocalDateTime.now();
    }

    /**
     * Marque le paiement comme échoué
     */
    public void marquerEchoue(String messageErreur) {
        this.statut = StatutPaiement.ECHOUE;
        this.messageErreur = messageErreur;
    }

    /**
     * Marque le paiement comme remboursé
     */
    public void rembourser() {
        this.statut = StatutPaiement.REMBOURSE;
    }
}
