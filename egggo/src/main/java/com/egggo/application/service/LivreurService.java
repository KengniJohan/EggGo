package com.egggo.application.service;

import com.egggo.api.dto.livreur.LivraisonDto;
import com.egggo.api.dto.livreur.LivreurDashboardDto;
import com.egggo.api.dto.livreur.UpdatePositionRequest;
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

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service pour les fonctionnalités des livreurs
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class LivreurService {

    private final LivreurRepository livreurRepository;
    private final LivraisonRepository livraisonRepository;
    private final CommandeRepository commandeRepository;

    /**
     * Récupère le tableau de bord d'un livreur
     */
    @Transactional(readOnly = true)
    public LivreurDashboardDto getDashboard(Long livreurId) {
        Livreur livreur = livreurRepository.findById(livreurId)
                .orElseThrow(() -> new EntityNotFoundException("Livreur non trouvé"));

        // Livraisons actives
        List<Livraison> livraisonsActives = livraisonRepository.findByLivreurIdAndStatutIn(livreurId,
                List.of(StatutLivraison.ASSIGNEE, StatutLivraison.EN_ROUTE_CLIENT, StatutLivraison.ARRIVEE));

        // Statistiques du jour
        LocalDateTime debutJour = LocalDate.now().atStartOfDay();
        LocalDateTime finJour = debutJour.plusDays(1);

        List<Livraison> livraisonsJour = livraisonRepository.findLivraisonsDuJour(debutJour, finJour)
                .stream()
                .filter(l -> l.getLivreur().getId().equals(livreurId))
                .collect(Collectors.toList());

        int livraisonsEffectuees = (int) livraisonsJour.stream()
                .filter(l -> l.getStatut() == StatutLivraison.LIVREE)
                .count();

        double distanceJour = livraisonsJour.stream()
                .filter(l -> l.getDistanceKm() != null)
                .mapToDouble(Livraison::getDistanceKm)
                .sum();

        // Gains (calculés à partir des commandes livrées)
        double gainsJour = livraisonsJour.stream()
                .filter(l -> l.getStatut() == StatutLivraison.LIVREE)
                .mapToDouble(l -> l.getCommande().getFraisLivraison())
                .sum();

        // Livraison en cours
        LivreurDashboardDto.LivraisonEnCoursDto livraisonEnCours = null;
        var enCours = livraisonsActives.stream()
                .filter(l -> l.getStatut() == StatutLivraison.EN_ROUTE_CLIENT)
                .findFirst();

        if (enCours.isPresent()) {
            Livraison l = enCours.get();
            Commande c = l.getCommande();
            livraisonEnCours = LivreurDashboardDto.LivraisonEnCoursDto.builder()
                    .id(l.getId())
                    .commandeRef(c.getReference())
                    .clientNom(c.getClient().getNomComplet())
                    .clientTelephone(c.getClient().getTelephone())
                    .adresse(formatAdresse(c))
                    .latitude(c.getAdresseLivraison().getLatitude())
                    .longitude(c.getAdresseLivraison().getLongitude())
                    .distanceRestante(l.getDistanceKm())
                    .tempsEstime(l.getTempsEstime())
                    .build();
        }

        // Livraisons en attente
        List<LivreurDashboardDto.LivraisonAttenteDto> livraisonsAttente = livraisonsActives.stream()
                .filter(l -> l.getStatut() == StatutLivraison.ASSIGNEE)
                .map(l -> {
                    Commande c = l.getCommande();
                    return LivreurDashboardDto.LivraisonAttenteDto.builder()
                            .id(l.getId())
                            .commandeRef(c.getReference())
                            .clientNom(c.getClient().getNomComplet())
                            .adresse(formatAdresse(c))
                            .distance(l.getDistanceKm())
                            .montant(c.getFraisLivraison())
                            .build();
                })
                .collect(Collectors.toList());

        return LivreurDashboardDto.builder()
                .livreurId(livreurId)
                .nom(livreur.getNomComplet())
                .disponible(livreur.getDisponible())
                .livraisonsJour(livraisonsEffectuees)
                .gainsJour(gainsJour)
                .distanceJour(distanceJour)
                .noteMoyenne(livreur.getNoteMoyenne())
                .livraisonEnCours(livraisonEnCours)
                .livraisonsAttente(livraisonsAttente)
                .build();
    }

    /**
     * Met à jour la position GPS du livreur
     */
    @Transactional
    public void updatePosition(Long livreurId, UpdatePositionRequest request) {
        Livreur livreur = livreurRepository.findById(livreurId)
                .orElseThrow(() -> new EntityNotFoundException("Livreur non trouvé"));

        livreur.mettreAJourPosition(request.getLatitude(), request.getLongitude());
        livreurRepository.save(livreur);

        log.debug("Position mise à jour pour livreur {}: {}, {}", livreurId, request.getLatitude(), request.getLongitude());
    }

    /**
     * Change la disponibilité du livreur
     */
    @Transactional
    public void setDisponible(Long livreurId, boolean disponible) {
        Livreur livreur = livreurRepository.findById(livreurId)
                .orElseThrow(() -> new EntityNotFoundException("Livreur non trouvé"));

        livreur.setDisponible(disponible);
        livreurRepository.save(livreur);

        log.info("Disponibilité mise à jour pour livreur {}: {}", livreurId, disponible);
    }

    /**
     * Récupère les livraisons d'un livreur
     */
    @Transactional(readOnly = true)
    public List<LivraisonDto> getLivraisons(Long livreurId, String statut) {
        List<Livraison> livraisons;
        if (statut != null && !statut.isEmpty()) {
            StatutLivraison statutEnum = StatutLivraison.valueOf(statut.toUpperCase());
            livraisons = livraisonRepository.findByLivreurIdAndStatutIn(livreurId, List.of(statutEnum));
        } else {
            livraisons = livraisonRepository.findByLivreurIdOrderByDateAssignationDesc(livreurId);
        }

        return livraisons.stream()
                .map(this::toLivraisonDto)
                .collect(Collectors.toList());
    }

    /**
     * Accepte une livraison
     */
    @Transactional
    public LivraisonDto accepterLivraison(Long livreurId, Long livraisonId) {
        Livraison livraison = livraisonRepository.findById(livraisonId)
                .orElseThrow(() -> new EntityNotFoundException("Livraison non trouvée"));

        if (!livraison.getLivreur().getId().equals(livreurId)) {
            throw new IllegalArgumentException("Cette livraison n'est pas assignée à ce livreur");
        }

        if (livraison.getStatut() != StatutLivraison.ASSIGNEE) {
            throw new IllegalStateException("Cette livraison ne peut pas être acceptée");
        }

        livraison.setStatut(StatutLivraison.EN_ROUTE_CLIENT);
        livraison.setDateAcceptation(LocalDateTime.now());

        // Mettre à jour le statut de la commande
        Commande commande = livraison.getCommande();
        commande.mettreAJourStatut(StatutCommande.EN_LIVRAISON);
        commandeRepository.save(commande);

        livraison = livraisonRepository.save(livraison);
        log.info("Livraison {} acceptée par livreur {}", livraisonId, livreurId);

        return toLivraisonDto(livraison);
    }

    /**
     * Signale l'arrivée à destination
     */
    @Transactional
    public LivraisonDto signalerArrivee(Long livreurId, Long livraisonId) {
        Livraison livraison = livraisonRepository.findById(livraisonId)
                .orElseThrow(() -> new EntityNotFoundException("Livraison non trouvée"));

        if (!livraison.getLivreur().getId().equals(livreurId)) {
            throw new IllegalArgumentException("Cette livraison n'est pas assignée à ce livreur");
        }

        if (livraison.getStatut() != StatutLivraison.EN_ROUTE_CLIENT) {
            throw new IllegalStateException("Le livreur doit être en route pour signaler son arrivée");
        }

        livraison.setStatut(StatutLivraison.ARRIVEE);
        livraison = livraisonRepository.save(livraison);

        log.info("Livreur {} arrivé pour livraison {}", livreurId, livraisonId);

        return toLivraisonDto(livraison);
    }

    /**
     * Confirme la livraison
     */
    @Transactional
    public LivraisonDto confirmerLivraison(Long livreurId, Long livraisonId, String codeConfirmation, String photoPreuve) {
        Livraison livraison = livraisonRepository.findById(livraisonId)
                .orElseThrow(() -> new EntityNotFoundException("Livraison non trouvée"));

        if (!livraison.getLivreur().getId().equals(livreurId)) {
            throw new IllegalArgumentException("Cette livraison n'est pas assignée à ce livreur");
        }

        if (livraison.getStatut() != StatutLivraison.ARRIVEE && livraison.getStatut() != StatutLivraison.EN_ROUTE_CLIENT) {
            throw new IllegalStateException("Cette livraison ne peut pas être confirmée");
        }

        // TODO: Vérifier le code de confirmation si nécessaire
        livraison.setStatut(StatutLivraison.LIVREE);
        livraison.setDateLivraison(LocalDateTime.now());
        livraison.setPhotoPreuve(photoPreuve);

        // Mettre à jour le statut de la commande
        Commande commande = livraison.getCommande();
        commande.mettreAJourStatut(StatutCommande.LIVREE);
        commande.setDateLivraison(LocalDateTime.now());
        commandeRepository.save(commande);

        // Incrémenter le compteur du livreur
        Livreur livreur = livraison.getLivreur();
        livreur.incrementerLivraisons();
        livreurRepository.save(livreur);

        livraison = livraisonRepository.save(livraison);
        log.info("Livraison {} confirmée par livreur {}", livraisonId, livreurId);

        return toLivraisonDto(livraison);
    }

    /**
     * Signale un problème lors de la livraison
     */
    @Transactional
    public LivraisonDto signalerProbleme(Long livreurId, Long livraisonId, String description) {
        Livraison livraison = livraisonRepository.findById(livraisonId)
                .orElseThrow(() -> new EntityNotFoundException("Livraison non trouvée"));

        if (!livraison.getLivreur().getId().equals(livreurId)) {
            throw new IllegalArgumentException("Cette livraison n'est pas assignée à ce livreur");
        }

        livraison.setStatut(StatutLivraison.ECHOUEE);
        livraison.setNotes(description);

        livraison = livraisonRepository.save(livraison);
        log.warn("Problème signalé pour livraison {} par livreur {}: {}", livraisonId, livreurId, description);

        return toLivraisonDto(livraison);
    }

    /**
     * Récupère l'itinéraire pour une livraison
     */
    @Transactional(readOnly = true)
    public LivraisonDto.ItineraireDto getItineraire(Long livreurId, Long livraisonId) {
        Livraison livraison = livraisonRepository.findById(livraisonId)
                .orElseThrow(() -> new EntityNotFoundException("Livraison non trouvée"));

        if (!livraison.getLivreur().getId().equals(livreurId)) {
            throw new IllegalArgumentException("Cette livraison n'est pas assignée à ce livreur");
        }

        Livreur livreur = livraison.getLivreur();
        Commande commande = livraison.getCommande();

        // Dans une vraie application, on appellerait un service de cartographie (Google Maps, etc.)
        // Pour l'instant, on retourne les coordonnées de départ et d'arrivée
        return LivraisonDto.ItineraireDto.builder()
                .depart(LivraisonDto.ItineraireDto.PointDto.builder()
                        .latitude(livreur.getLatitude())
                        .longitude(livreur.getLongitude())
                        .label("Position actuelle")
                        .build())
                .arrivee(LivraisonDto.ItineraireDto.PointDto.builder()
                        .latitude(commande.getAdresseLivraison().getLatitude())
                        .longitude(commande.getAdresseLivraison().getLongitude())
                        .label(formatAdresse(commande))
                        .build())
                .points(new ArrayList<>()) // Serait rempli par le service de cartographie
                .distanceTotale(livraison.getDistanceKm())
                .dureeEstimee(livraison.getTempsEstime())
                .build();
    }

    // ====================== Méthodes utilitaires ======================

    private String formatAdresse(Commande commande) {
        var adresse = commande.getAdresseLivraison();
        return String.format("%s, %s %s", adresse.getRue(), adresse.getVille(), adresse.getQuartier());
    }

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
