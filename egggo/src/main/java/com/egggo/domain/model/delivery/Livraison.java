package com.egggo.domain.model.delivery;

import com.egggo.domain.model.order.Commande;
import com.egggo.domain.model.user.Livreur;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Entité représentant une livraison de commande
 */
@Entity
@Table(name = "livraisons")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Livraison {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "commande_id", nullable = false)
    private Commande commande;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "livreur_id", nullable = false)
    private Livreur livreur;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default
    private StatutLivraison statut = StatutLivraison.ASSIGNEE;

    @Column(length = 6)
    private String codeConfirmation; // Code à 4-6 chiffres

    @Column
    private Double distanceKm;

    @Column
    private Integer tempsEstime; // Temps estimé en minutes

    @Column(length = 500)
    private String photoPreuve; // URL de la photo preuve de livraison

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column
    private LocalDateTime dateAssignation;

    @Column
    private LocalDateTime dateAcceptation;

    @Column
    private LocalDateTime dateRecuperation;

    @Column
    private LocalDateTime dateLivraison;

    @OneToMany(mappedBy = "livraison", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<PositionGPS> historiquePositions = new ArrayList<>();

    /**
     * Génère un code de confirmation aléatoire
     */
    @PrePersist
    public void prePersist() {
        if (codeConfirmation == null) {
            Random random = new Random();
            codeConfirmation = String.format("%04d", random.nextInt(10000));
        }
        if (dateAssignation == null) {
            dateAssignation = LocalDateTime.now();
        }
    }

    /**
     * Accepte la livraison
     */
    public void accepter() {
        this.statut = StatutLivraison.ACCEPTEE;
        this.dateAcceptation = LocalDateTime.now();
    }

    /**
     * Confirme la récupération de la commande
     */
    public void confirmerRecuperation() {
        this.statut = StatutLivraison.RECUPEREE;
        this.dateRecuperation = LocalDateTime.now();
    }

    /**
     * Termine la livraison
     */
    public void terminer() {
        this.statut = StatutLivraison.LIVREE;
        this.dateLivraison = LocalDateTime.now();
    }

    /**
     * Marque la livraison comme échouée
     */
    public void echouer(String raison) {
        this.statut = StatutLivraison.ECHOUEE;
        this.notes = raison;
    }

    /**
     * Ajoute une position GPS à l'historique
     */
    public void ajouterPosition(Double latitude, Double longitude) {
        PositionGPS position = PositionGPS.builder()
                .livraison(this)
                .latitude(latitude)
                .longitude(longitude)
                .timestamp(LocalDateTime.now())
                .build();
        historiquePositions.add(position);
    }

    /**
     * Vérifie le code de confirmation
     */
    public boolean verifierCode(String code) {
        return codeConfirmation != null && codeConfirmation.equals(code);
    }
}
