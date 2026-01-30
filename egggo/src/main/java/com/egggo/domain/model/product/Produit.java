package com.egggo.domain.model.product;

import com.egggo.domain.model.user.Producteur;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

/**
 * Entité représentant un produit (type d'œuf) disponible à la vente
 */
@Entity
@Table(name = "produits")
@EntityListeners(AuditingEntityListener.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Produit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String nom;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 255)
    private String image;

    @Column(nullable = false)
    private Double prixUnitaire;

    @Column(nullable = false)
    @Builder.Default
    private Integer quantiteStock = 0;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Unite unite;

    @Column(nullable = false)
    @Builder.Default
    private Boolean disponible = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categorie_id", nullable = false)
    private Categorie categorie;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "producteur_id", nullable = false)
    private Producteur producteur;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @LastModifiedDate
    @Column(nullable = false)
    private LocalDateTime dateModification;

    /**
     * Calcule le prix total pour une quantité donnée
     */
    public Double calculerPrixTotal(int quantite) {
        return prixUnitaire * quantite;
    }

    /**
     * Vérifie si la quantité demandée est disponible
     */
    public boolean verifierDisponibilite(int quantiteDemandee) {
        return disponible && quantiteStock >= quantiteDemandee;
    }

    /**
     * Met à jour le stock après une vente
     */
    public boolean decrementerStock(int quantite) {
        if (quantiteStock >= quantite) {
            quantiteStock -= quantite;
            if (quantiteStock == 0) {
                disponible = false;
            }
            return true;
        }
        return false;
    }

    /**
     * Réapprovisionne le stock
     */
    public void incrementerStock(int quantite) {
        quantiteStock += quantite;
        if (quantiteStock > 0) {
            disponible = true;
        }
    }
}
