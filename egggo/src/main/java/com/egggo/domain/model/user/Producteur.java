package com.egggo.domain.model.user;

import com.egggo.domain.model.order.Commande;
import com.egggo.domain.model.product.Produit;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.List;

/**
 * Entité représentant un producteur/ferme avicole partenaire
 * Un producteur propose des produits et reçoit des commandes
 */
@Entity
@Table(name = "producteurs")
@PrimaryKeyJoinColumn(name = "utilisateur_id")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class Producteur extends Utilisateur {

    @Column(nullable = false, length = 150)
    private String nomFerme;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 255)
    private String adresseFerme;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Column(length = 255)
    private String logoFerme;

    @Builder.Default
    @Column(nullable = false)
    private Boolean certifie = false;

    @Builder.Default
    @Column(nullable = false)
    private Double noteMoyenne = 0.0;

    @Builder.Default
    @Column(nullable = false)
    private Integer nombreVentes = 0;

    @Builder.Default
    @Column(nullable = false)
    private Boolean valide = false; // Validé par l'admin

    @OneToMany(mappedBy = "producteur", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Produit> produits = new ArrayList<>();

    @OneToMany(mappedBy = "producteur", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Commande> commandes = new ArrayList<>();

    /**
     * Livreurs rattachés à ce producteur (livreurs propres)
     */
    @OneToMany(mappedBy = "producteurRattache", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Livreur> livreursRattaches = new ArrayList<>();

    /**
     * Ajoute un produit à la liste du producteur
     */
    public void ajouterProduit(Produit produit) {
        produits.add(produit);
        produit.setProducteur(this);
    }

    /**
     * Retire un produit de la liste
     */
    public void retirerProduit(Produit produit) {
        produits.remove(produit);
        produit.setProducteur(null);
    }

    /**
     * Met à jour la note moyenne après une nouvelle notation
     */
    public void mettreAJourNote(Double nouvelleNote) {
        if (nombreVentes == 0) {
            this.noteMoyenne = nouvelleNote;
        } else {
            this.noteMoyenne = ((noteMoyenne * nombreVentes) + nouvelleNote) / (nombreVentes + 1);
        }
    }

    /**
     * Incrémente le nombre de ventes
     */
    public void incrementerVentes() {
        this.nombreVentes++;
    }

    @PrePersist
    public void prePersist() {
        setRole(Role.PRODUCTEUR);
    }
}
