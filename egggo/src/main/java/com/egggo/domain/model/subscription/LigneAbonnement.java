package com.egggo.domain.model.subscription;

import com.egggo.domain.model.product.Produit;
import jakarta.persistence.*;
import lombok.*;

/**
 * Entité représentant une ligne d'abonnement
 */
@Entity
@Table(name = "lignes_abonnement")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LigneAbonnement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "abonnement_id", nullable = false)
    private Abonnement abonnement;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "produit_id", nullable = false)
    private Produit produit;

    @Column(nullable = false)
    private Integer quantite;
}
