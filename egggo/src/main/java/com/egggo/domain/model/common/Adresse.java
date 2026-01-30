package com.egggo.domain.model.common;

import com.egggo.domain.model.user.Client;
import jakarta.persistence.*;
import lombok.*;

/**
 * Entité représentant une adresse de livraison
 */
@Entity
@Table(name = "adresses")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Adresse {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String libelle; // Ex: "Maison", "Bureau"

    @Column(length = 255)
    private String rue;

    @Column(nullable = false, length = 100)
    private String quartier;

    @Column(nullable = false, length = 100)
    private String ville;

    @Column(columnDefinition = "TEXT")
    private String description; // Indications supplémentaires

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Column(nullable = false)
    @Builder.Default
    private Boolean principale = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    private Client client;

    /**
     * Retourne l'adresse formatée
     */
    public String getAdresseComplete() {
        StringBuilder sb = new StringBuilder();
        if (rue != null && !rue.isEmpty()) {
            sb.append(rue).append(", ");
        }
        sb.append(quartier).append(", ").append(ville);
        return sb.toString();
    }
}
