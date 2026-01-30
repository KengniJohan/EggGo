package com.egggo.application.service;

import com.egggo.api.dto.livreur.LivraisonDto;
import com.egggo.domain.model.delivery.Livraison;
import com.egggo.domain.model.delivery.StatutLivraison;
import com.egggo.domain.model.order.Commande;
import com.egggo.domain.model.order.StatutCommande;
import com.egggo.domain.model.user.Livreur;
import com.egggo.domain.repository.CommandeRepository;
import com.egggo.domain.repository.LivraisonRepository;
import com.egggo.domain.repository.LivreurRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Service de gestion des livraisons
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class LivraisonService {

    private final LivraisonRepository livraisonRepository;
    private final CommandeRepository commandeRepository;
    private final LivreurRepository livreurRepository;

    /**
     * Crée une livraison pour une commande
     */
    @Transactional
    public LivraisonDto creerLivraison(Long commandeId, Long livreurId) {
        Commande commande = commandeRepository.findById(commandeId)
                .orElseThrow(() -> new EntityNotFoundException("Commande non trouvée"));

        Livreur livreur = livreurRepository.findById(livreurId)
                .orElseThrow(() -> new EntityNotFoundException("Livreur non trouvé"));

        // Vérifier si une livraison existe déjà
        if (livraisonRepository.findByCommandeId(commandeId).isPresent()) {
            throw new IllegalStateException("Une livraison existe déjà pour cette commande");
        }

        Livraison livraison = Livraison.builder()
                .commande(commande)
                .livreur(livreur)
                .statut(StatutLivraison.ASSIGNEE)
                .dateAssignation(LocalDateTime.now())
                .build();

        // Calculer la distance estimée
        Double distance = calculerDistance(livreur, commande);
        livraison.setDistanceKm(distance);
        livraison.setTempsEstime(estimerTemps(distance));

        // Mettre à jour le statut de la commande
        commande.mettreAJourStatut(StatutCommande.EN_PREPARATION);
        commandeRepository.save(commande);

        livraison = livraisonRepository.save(livraison);
        log.info("Livraison créée: {} pour commande {} avec livreur {}", livraison.getId(), commandeId, livreurId);

        return toLivraisonDto(livraison);
    }

    /**
     * Trouve les livraisons par statut
     */
    @Transactional(readOnly = true)
    public List<Livraison> getLivraisonsParStatut(StatutLivraison statut) {
        return livraisonRepository.findByStatut(statut);
    }

    /**
     * Trouve le meilleur livreur pour une commande
     */
    @Transactional(readOnly = true)
    public Livreur trouverMeilleurLivreur(Commande commande) {
        // Récupérer les livreurs proches
        Double latitudeDestination = commande.getAdresseLivraison().getLatitude();
        Double longitudeDestination = commande.getAdresseLivraison().getLongitude();

        if (latitudeDestination == null || longitudeDestination == null) {
            // Si pas de coordonnées, prendre le premier livreur disponible
            return livreurRepository.findByDisponibleTrueAndActifTrue().stream()
                    .filter(l -> l.getValide())
                    .findFirst()
                    .orElse(null);
        }

        // Chercher les livreurs à proximité (dans un rayon de 10km)
        List<Livreur> livreursProches = livreurRepository.findLivreursProches(
                latitudeDestination, longitudeDestination, 10.0);

        return livreursProches.stream()
                .filter(Livreur::getValide)
                .findFirst()
                .orElse(null);
    }

    /**
     * Calcule la distance entre le livreur et l'adresse de livraison
     */
    private Double calculerDistance(Livreur livreur, Commande commande) {
        if (livreur.getLatitude() == null || livreur.getLongitude() == null) {
            return 5.0; // Distance par défaut
        }

        Double lat1 = livreur.getLatitude();
        Double lon1 = livreur.getLongitude();
        Double lat2 = commande.getAdresseLivraison().getLatitude();
        Double lon2 = commande.getAdresseLivraison().getLongitude();

        if (lat2 == null || lon2 == null) {
            return 5.0; // Distance par défaut
        }

        // Formule de Haversine pour calculer la distance
        double R = 6371; // Rayon de la Terre en km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    /**
     * Estime le temps de livraison en minutes
     */
    private Integer estimerTemps(Double distanceKm) {
        // Estimation: 20 km/h de moyenne en ville
        return (int) Math.ceil((distanceKm / 20.0) * 60);
    }

    /**
     * Convertit une livraison en DTO
     */
    private LivraisonDto toLivraisonDto(Livraison livraison) {
        Commande commande = livraison.getCommande();

        return LivraisonDto.builder()
                .id(livraison.getId())
                .commandeId(commande.getId())
                .commandeRef(commande.getReference())
                .clientNom(commande.getClient().getNomComplet())
                .clientTelephone(commande.getClient().getTelephone())
                .adresse(LivraisonDto.AdresseDto.builder()
                        .rue(commande.getAdresseLivraison().getRue())
                        .quartier(commande.getAdresseLivraison().getQuartier())
                        .ville(commande.getAdresseLivraison().getVille())
                        .latitude(commande.getAdresseLivraison().getLatitude())
                        .longitude(commande.getAdresseLivraison().getLongitude())
                        .indications(commande.getAdresseLivraison().getDescription())
                        .build())
                .statut(livraison.getStatut().name())
                .distance(livraison.getDistanceKm())
                .tempsEstime(livraison.getTempsEstime())
                .montant(commande.getFraisLivraison())
                .dateAssignation(livraison.getDateAssignation())
                .dateAcceptation(livraison.getDateAcceptation())
                .dateLivraison(livraison.getDateLivraison())
                .notes(livraison.getNotes())
                .build();
    }
}
