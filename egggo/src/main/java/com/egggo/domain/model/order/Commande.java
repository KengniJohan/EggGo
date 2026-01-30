package com.egggo.domain.model.order;

import com.egggo.domain.model.common.Adresse;
import com.egggo.domain.model.delivery.Livraison;
import com.egggo.domain.model.user.Client;
import com.egggo.domain.model.user.Producteur;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Entité représentant une commande passée par un client
 */
@Entity
@Table(name = "commandes")
@EntityListeners(AuditingEntityListener.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Commande {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String reference;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    private Client client;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "producteur_id", nullable = false)
    private Producteur producteur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "adresse_id", nullable = false)
    private Adresse adresseLivraison;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private StatutCommande statut = StatutCommande.EN_ATTENTE;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ModePaiement modePaiement;

    @Column(nullable = false)
    @Builder.Default
    private Double montantProduits = 0.0;

    @Column(nullable = false)
    @Builder.Default
    private Double fraisLivraison = 0.0;

    @Column
    @Builder.Default
    private Double montantRemise = 0.0;

    @Column(nullable = false)
    @Builder.Default
    private Double montantTotal = 0.0;

    @Column(nullable = false)
    @Builder.Default
    private Boolean paye = false;

    @Column(length = 50)
    private String creneauLivraison; // Ex: "10h-12h", "14h-16h"

    @Column(columnDefinition = "TEXT")
    private String notes;

    @OneToMany(mappedBy = "commande", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<LigneCommande> lignes = new ArrayList<>();

    @OneToOne(mappedBy = "commande", cascade = CascadeType.ALL)
    private Livraison livraison;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCommande;

    @LastModifiedDate
    @Column(nullable = false)
    private LocalDateTime dateModification;

    @Column
    private LocalDateTime dateLivraison;

    /**
     * Génère une référence unique pour la commande
     */
    @PrePersist
    public void prePersist() {
        if (reference == null) {
            String uuid = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            reference = "EGG-" + java.time.Year.now().getValue() + "-" + uuid;
        }
    }

    /**
     * Ajoute une ligne à la commande
     */
    public void ajouterLigne(LigneCommande ligne) {
        lignes.add(ligne);
        ligne.setCommande(this);
        calculerTotal();
    }

    /**
     * Retire une ligne de la commande
     */
    public void retirerLigne(LigneCommande ligne) {
        lignes.remove(ligne);
        ligne.setCommande(null);
        calculerTotal();
    }

    /**
     * Calcule le montant total de la commande
     */
    public void calculerTotal() {
        this.montantProduits = lignes.stream()
                .mapToDouble(LigneCommande::getPrixTotal)
                .sum();
        this.montantTotal = montantProduits + fraisLivraison - (montantRemise != null ? montantRemise : 0);
    }

    /**
     * Applique une remise à la commande
     */
    public void appliquerRemise(Double remise) {
        this.montantRemise = remise;
        calculerTotal();
    }

    /**
     * Met à jour le statut de la commande
     */
    public boolean mettreAJourStatut(StatutCommande nouveauStatut) {
        if (statut.peutPasserA(nouveauStatut)) {
            this.statut = nouveauStatut;
            if (nouveauStatut == StatutCommande.LIVREE) {
                this.dateLivraison = LocalDateTime.now();
            }
            return true;
        }
        return false;
    }

    /**
     * Vérifie si la commande peut être annulée
     */
    public boolean peutEtreAnnulee() {
        return statut == StatutCommande.EN_ATTENTE || 
               statut == StatutCommande.CONFIRMEE;
    }
}
