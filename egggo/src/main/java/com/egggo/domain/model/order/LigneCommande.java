package com.egggo.domain.model.order;

import com.egggo.domain.model.product.Produit;
import jakarta.persistence.*;
import lombok.*;

/**
 * Entité représentant une ligne de commande
 */
@Entity
@Table(name = "lignes_commande")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LigneCommande {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "commande_id", nullable = false)
    private Commande commande;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "produit_id", nullable = false)
    private Produit produit;

    @Column(nullable = false)
    private Integer quantite;

    @Column(nullable = false)
    private Double prixUnitaire;

    @Column(nullable = false)
    private Double prixTotal;

    /**
     * Calcule le prix total de la ligne
     */
    @PrePersist
    @PreUpdate
    public void calculerPrixLigne() {
        if (prixUnitaire != null && quantite != null) {
            this.prixTotal = prixUnitaire * quantite;
        }
    }
}
