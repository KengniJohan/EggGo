package com.egggo.domain.model.user;

import com.egggo.domain.model.common.Adresse;
import com.egggo.domain.model.order.Commande;
import com.egggo.domain.model.subscription.Abonnement;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.List;

/**
 * Entité représentant un client de l'application
 * Un client peut passer des commandes et souscrire à des abonnements
 */
@Entity
@Table(name = "clients")
@PrimaryKeyJoinColumn(name = "utilisateur_id")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class Client extends Utilisateur {

    @Builder.Default
    @Column(nullable = false)
    private Integer pointsFidelite = 0;

    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Adresse> adresses = new ArrayList<>();

    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Commande> commandes = new ArrayList<>();

    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Abonnement> abonnements = new ArrayList<>();

    /**
     * Ajoute des points de fidélité
     */
    public void ajouterPoints(int points) {
        this.pointsFidelite += points;
    }

    /**
     * Utilise des points de fidélité
     */
    public boolean utiliserPoints(int points) {
        if (this.pointsFidelite >= points) {
            this.pointsFidelite -= points;
            return true;
        }
        return false;
    }

    /**
     * Retourne l'adresse principale du client
     */
    public Adresse getAdressePrincipale() {
        return adresses.stream()
                .filter(Adresse::getPrincipale)
                .findFirst()
                .orElse(adresses.isEmpty() ? null : adresses.get(0));
    }

    @PrePersist
    public void prePersist() {
        setRole(Role.CLIENT);
    }
}
