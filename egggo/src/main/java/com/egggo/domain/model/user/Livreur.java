package com.egggo.domain.model.user;

import com.egggo.domain.model.delivery.Livraison;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.List;

/**
 * Entité représentant un livreur partenaire
 * Un livreur effectue les livraisons des commandes
 */
@Entity
@Table(name = "livreurs")
@PrimaryKeyJoinColumn(name = "utilisateur_id")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class Livreur extends Utilisateur {

    @Column(nullable = false, length = 50)
    private String numeroPieceIdentite;

    @Column(length = 30)
    private String typeVehicule; // MOTO, VELO, VOITURE

    @Column(length = 20)
    private String numeroPlaque;

    @Builder.Default
    @Column(nullable = false)
    private Boolean disponible = true;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Builder.Default
    @Column(nullable = false)
    private Double noteMoyenne = 0.0;

    @Builder.Default
    @Column(nullable = false)
    private Integer nombreLivraisons = 0;

    @Builder.Default
    @Column(nullable = false)
    private Boolean valide = false; // Validé par l'admin

    /**
     * Producteur auquel le livreur est rattaché (null = livreur indépendant)
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "producteur_id")
    private Producteur producteurRattache;

    /**
     * Indique si le livreur est indépendant ou rattaché à un producteur
     */
    @Builder.Default
    @Column(nullable = false)
    private Boolean independant = true;

    /**
     * Zone de couverture du livreur (ex: "Douala", "Yaoundé")
     */
    @Column(length = 100)
    private String zoneCouverture;

    @OneToMany(mappedBy = "livreur", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Livraison> livraisons = new ArrayList<>();

    /**
     * Met à jour la position GPS du livreur
     */
    public void mettreAJourPosition(Double latitude, Double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }

    /**
     * Met à jour la note moyenne après une nouvelle notation
     */
    public void mettreAJourNote(Double nouvelleNote) {
        if (nombreLivraisons == 0) {
            this.noteMoyenne = nouvelleNote;
        } else {
            this.noteMoyenne = ((noteMoyenne * nombreLivraisons) + nouvelleNote) / (nombreLivraisons + 1);
        }
    }

    /**
     * Incrémente le nombre de livraisons effectuées
     */
    public void incrementerLivraisons() {
        this.nombreLivraisons++;
    }

    @PrePersist
    public void prePersist() {
        setRole(Role.LIVREUR);
    }
}
