package com.egggo.domain.model.subscription;

import com.egggo.domain.model.common.Adresse;
import com.egggo.domain.model.user.Client;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Entité représentant un abonnement de livraison récurrente
 */
@Entity
@Table(name = "abonnements")
@EntityListeners(AuditingEntityListener.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Abonnement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String nom;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    private Client client;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Frequence frequence;

    @Column(nullable = false)
    private Integer jourLivraison; // 1-7 pour lundi-dimanche

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "adresse_id", nullable = false)
    private Adresse adresseLivraison;

    @Column(nullable = false)
    @Builder.Default
    private Boolean actif = true;

    @Column(nullable = false)
    private LocalDate dateDebut;

    @Column
    private LocalDate dateFin;

    @Column
    private LocalDate prochaineLivraison;

    @OneToMany(mappedBy = "abonnement", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<LigneAbonnement> lignes = new ArrayList<>();

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    /**
     * Ajoute une ligne à l'abonnement
     */
    public void ajouterLigne(LigneAbonnement ligne) {
        lignes.add(ligne);
        ligne.setAbonnement(this);
    }

    /**
     * Calcule le montant total de l'abonnement
     */
    public Double calculerMontantTotal() {
        return lignes.stream()
                .mapToDouble(ligne -> ligne.getProduit().getPrixUnitaire() * ligne.getQuantite())
                .sum();
    }

    /**
     * Calcule la prochaine date de livraison
     */
    public LocalDate calculerProchaineLivraison() {
        LocalDate today = LocalDate.now();
        if (prochaineLivraison == null || prochaineLivraison.isBefore(today)) {
            return today.plusDays(frequence.getJoursIntervalle());
        }
        return prochaineLivraison.plusDays(frequence.getJoursIntervalle());
    }

    /**
     * Active l'abonnement
     */
    public void activer() {
        this.actif = true;
        this.prochaineLivraison = calculerProchaineLivraison();
    }

    /**
     * Désactive l'abonnement
     */
    public void desactiver() {
        this.actif = false;
    }
}
