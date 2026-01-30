package com.egggo.application.service;

import com.egggo.api.dto.admin.AdminDashboardDto;
import com.egggo.api.dto.user.*;
import com.egggo.domain.model.order.Commande;
import com.egggo.domain.model.order.StatutCommande;
import com.egggo.domain.model.user.*;
import com.egggo.domain.repository.*;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Service pour les fonctionnalités d'administration
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AdminService {

    private final UtilisateurRepository utilisateurRepository;
    private final ProducteurRepository producteurRepository;
    private final LivreurRepository livreurRepository;
    private final ClientRepository clientRepository;
    private final CommandeRepository commandeRepository;
    private final LivraisonRepository livraisonRepository;

    /**
     * Récupère le tableau de bord administrateur
     */
    @Transactional(readOnly = true)
    public AdminDashboardDto getDashboard() {
        LocalDateTime debutMois = LocalDate.now().withDayOfMonth(1).atStartOfDay();
        LocalDateTime debut7Jours = LocalDate.now().minusDays(7).atStartOfDay();

        // Compteurs globaux
        long totalClients = clientRepository.count();
        long totalProducteurs = producteurRepository.count();
        long totalLivreurs = livreurRepository.count();
        long commandesMois = commandeRepository.countByDateCommandeAfter(debutMois);

        // Producteurs en attente de validation
        long producteursEnAttente = producteurRepository.findAll().stream()
                .filter(p -> !p.getValide())
                .count();

        // Livreurs en attente de validation
        long livreursEnAttente = livreurRepository.findAll().stream()
                .filter(l -> !l.getValide())
                .count();

        // Chiffre d'affaires du mois
        double chiffreAffairesMois = commandeRepository.findByDateCommandeAfter(debutMois).stream()
                .filter(c -> c.getStatut() != StatutCommande.ANNULEE)
                .mapToDouble(Commande::getMontantTotal)
                .sum();

        // Données pour le graphique des 7 derniers jours
        List<AdminDashboardDto.ChartDataDto> commandesChart = genererDonneesGraphique7Jours();

        // Alertes système
        List<AdminDashboardDto.AlerteDto> alertes = genererAlertes(producteursEnAttente, livreursEnAttente);

        return AdminDashboardDto.builder()
                .totalClients((int) totalClients)
                .totalProducteurs((int) totalProducteurs)
                .totalLivreurs((int) totalLivreurs)
                .commandesMois((int) commandesMois)
                .chiffreAffairesMois(chiffreAffairesMois)
                .producteursEnAttente((int) producteursEnAttente)
                .livreursEnAttente((int) livreursEnAttente)
                .commandesChart(commandesChart)
                .alertes(alertes)
                .build();
    }

    /**
     * Récupère tous les utilisateurs paginés
     */
    @Transactional(readOnly = true)
    public Page<UtilisateurDto> getUtilisateurs(String role, Pageable pageable) {
        Page<Utilisateur> utilisateurs;
        if (role != null && !role.isEmpty()) {
            Role roleEnum = Role.valueOf(role.toUpperCase());
            utilisateurs = utilisateurRepository.findByRole(roleEnum, pageable);
        } else {
            utilisateurs = utilisateurRepository.findAll(pageable);
        }

        return utilisateurs.map(this::toUtilisateurDto);
    }

    /**
     * Récupère un utilisateur par son ID
     */
    @Transactional(readOnly = true)
    public UtilisateurDto getUtilisateurById(Long id) {
        Utilisateur utilisateur = utilisateurRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Utilisateur non trouvé"));
        return toUtilisateurDto(utilisateur);
    }

    /**
     * Active/désactive un utilisateur
     */
    @Transactional
    public UtilisateurDto toggleUtilisateurActif(Long id) {
        Utilisateur utilisateur = utilisateurRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Utilisateur non trouvé"));

        utilisateur.setActif(!utilisateur.getActif());
        utilisateur = utilisateurRepository.save(utilisateur);

        log.info("Utilisateur {} {} par admin", id, utilisateur.getActif() ? "activé" : "désactivé");

        return toUtilisateurDto(utilisateur);
    }

    /**
     * Récupère les producteurs en attente de validation
     */
    @Transactional(readOnly = true)
    public List<ProducteurDto> getProducteursEnAttente() {
        return producteurRepository.findAll().stream()
                .filter(p -> !p.getValide())
                .map(this::toProducteurDto)
                .collect(Collectors.toList());
    }

    /**
     * Valide un producteur
     */
    @Transactional
    public ProducteurDto validerProducteur(Long id) {
        Producteur producteur = producteurRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Producteur non trouvé"));

        producteur.setValide(true);
        producteur = producteurRepository.save(producteur);

        log.info("Producteur {} validé par admin", id);

        return toProducteurDto(producteur);
    }

    /**
     * Refuse un producteur
     */
    @Transactional
    public void refuserProducteur(Long id, String raison) {
        Producteur producteur = producteurRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Producteur non trouvé"));

        producteur.setActif(false);
        producteurRepository.save(producteur);

        log.info("Producteur {} refusé par admin - Raison: {}", id, raison);
    }

    /**
     * Récupère les livreurs en attente de validation
     */
    @Transactional(readOnly = true)
    public List<LivreurDto> getLivreursEnAttente() {
        return livreurRepository.findAll().stream()
                .filter(l -> !l.getValide())
                .map(this::toLivreurDto)
                .collect(Collectors.toList());
    }

    /**
     * Valide un livreur
     */
    @Transactional
    public LivreurDto validerLivreur(Long id) {
        Livreur livreur = livreurRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Livreur non trouvé"));

        livreur.setValide(true);
        livreur = livreurRepository.save(livreur);

        log.info("Livreur {} validé par admin", id);

        return toLivreurDto(livreur);
    }

    /**
     * Refuse un livreur
     */
    @Transactional
    public void refuserLivreur(Long id, String raison) {
        Livreur livreur = livreurRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Livreur non trouvé"));

        livreur.setActif(false);
        livreurRepository.save(livreur);

        log.info("Livreur {} refusé par admin - Raison: {}", id, raison);
    }

    /**
     * Récupère les statistiques de ventes
     */
    @Transactional(readOnly = true)
    public StatsVentesDto getStatsVentes(String periode) {
        LocalDateTime debut = getDebutPeriode(periode);

        List<Commande> commandes = commandeRepository.findByDateCommandeAfter(debut);
        List<Commande> commandesPayees = commandes.stream()
                .filter(c -> c.getStatut() != StatutCommande.ANNULEE)
                .collect(Collectors.toList());

        double chiffreAffaires = commandesPayees.stream()
                .mapToDouble(Commande::getMontantTotal)
                .sum();

        double panierMoyen = commandesPayees.isEmpty() ? 0 :
                chiffreAffaires / commandesPayees.size();

        // Statistiques par jour
        Map<String, List<Commande>> parJour = commandesPayees.stream()
                .collect(Collectors.groupingBy(c ->
                        c.getDateCommande().toLocalDate().format(DateTimeFormatter.ISO_DATE)));

        List<StatsVentesDto.VenteJourDto> ventesParJour = parJour.entrySet().stream()
                .map(e -> StatsVentesDto.VenteJourDto.builder()
                        .date(e.getKey())
                        .montant(e.getValue().stream().mapToDouble(Commande::getMontantTotal).sum())
                        .commandes(e.getValue().size())
                        .build())
                .sorted((a, b) -> a.getDate().compareTo(b.getDate()))
                .collect(Collectors.toList());

        // Top producteurs
        Map<Producteur, Double> chiffreParProducteur = commandesPayees.stream()
                .collect(Collectors.groupingBy(
                        Commande::getProducteur,
                        Collectors.summingDouble(Commande::getMontantTotal)));

        List<StatsVentesDto.TopProducteurDto> topProducteurs = chiffreParProducteur.entrySet().stream()
                .map(e -> StatsVentesDto.TopProducteurDto.builder()
                        .id(e.getKey().getId())
                        .nomFerme(e.getKey().getNomFerme())
                        .chiffreAffaires(e.getValue())
                        .commandes((int) commandesPayees.stream()
                                .filter(c -> c.getProducteur().equals(e.getKey()))
                                .count())
                        .build())
                .sorted((a, b) -> b.getChiffreAffaires().compareTo(a.getChiffreAffaires()))
                .limit(5)
                .collect(Collectors.toList());

        return StatsVentesDto.builder()
                .chiffreAffairesTotal(chiffreAffaires)
                .nombreCommandes(commandesPayees.size())
                .panierMoyen(panierMoyen)
                .nombreClients((int) commandesPayees.stream()
                        .map(c -> c.getClient().getId())
                        .distinct()
                        .count())
                .ventesParJour(ventesParJour)
                .topProducteurs(topProducteurs)
                .build();
    }

    /**
     * Récupère les statistiques de livraisons
     */
    @Transactional(readOnly = true)
    public StatsLivraisonsDto getStatsLivraisons(String periode) {
        LocalDateTime debut = getDebutPeriode(periode);

        var livraisons = livraisonRepository.findAll().stream()
                .filter(l -> l.getDateAssignation().isAfter(debut))
                .collect(Collectors.toList());

        int reussies = (int) livraisons.stream()
                .filter(l -> l.getStatut() == com.egggo.domain.model.delivery.StatutLivraison.LIVREE)
                .count();

        int echouees = (int) livraisons.stream()
                .filter(l -> l.getStatut() == com.egggo.domain.model.delivery.StatutLivraison.ECHOUEE)
                .count();

        double tauxReussite = livraisons.isEmpty() ? 100.0 :
                (reussies * 100.0) / livraisons.size();

        double distanceTotale = livraisons.stream()
                .filter(l -> l.getDistanceKm() != null)
                .mapToDouble(l -> l.getDistanceKm())
                .sum();

        return StatsLivraisonsDto.builder()
                .livraisonsTotales(livraisons.size())
                .livraisonsReussies(reussies)
                .livraisonsEchouees(echouees)
                .tauxReussite(tauxReussite)
                .distanceTotaleParcourue(distanceTotale)
                .build();
    }

    // ====================== Méthodes utilitaires ======================

    private LocalDateTime getDebutPeriode(String periode) {
        if (periode == null) periode = "mois";

        return switch (periode.toLowerCase()) {
            case "jour" -> LocalDate.now().atStartOfDay();
            case "semaine" -> LocalDate.now().minusWeeks(1).atStartOfDay();
            case "annee" -> LocalDate.now().withDayOfYear(1).atStartOfDay();
            default -> LocalDate.now().withDayOfMonth(1).atStartOfDay(); // mois
        };
    }

    private List<AdminDashboardDto.ChartDataDto> genererDonneesGraphique7Jours() {
        List<AdminDashboardDto.ChartDataDto> data = new ArrayList<>();
        LocalDate aujourdhui = LocalDate.now();

        for (int i = 6; i >= 0; i--) {
            LocalDate date = aujourdhui.minusDays(i);
            LocalDateTime debut = date.atStartOfDay();
            LocalDateTime fin = date.plusDays(1).atStartOfDay();

            long nombreCommandes = commandeRepository.findByDateCommandeAfter(debut).stream()
                    .filter(c -> c.getDateCommande().isBefore(fin))
                    .count();

            data.add(AdminDashboardDto.ChartDataDto.builder()
                    .label(date.format(DateTimeFormatter.ofPattern("dd/MM")))
                    .valeur((double) nombreCommandes)
                    .build());
        }

        return data;
    }

    private List<AdminDashboardDto.AlerteDto> genererAlertes(long producteursEnAttente, long livreursEnAttente) {
        List<AdminDashboardDto.AlerteDto> alertes = new ArrayList<>();

        if (producteursEnAttente > 0) {
            alertes.add(AdminDashboardDto.AlerteDto.builder()
                    .type("warning")
                    .message(producteursEnAttente + " producteur(s) en attente de validation")
                    .date(LocalDateTime.now())
                    .build());
        }

        if (livreursEnAttente > 0) {
            alertes.add(AdminDashboardDto.AlerteDto.builder()
                    .type("warning")
                    .message(livreursEnAttente + " livreur(s) en attente de validation")
                    .date(LocalDateTime.now())
                    .build());
        }

        return alertes;
    }

    private UtilisateurDto toUtilisateurDto(Utilisateur u) {
        return UtilisateurDto.builder()
                .id(u.getId())
                .nom(u.getNom())
                .prenom(u.getPrenom())
                .telephone(u.getTelephone())
                .email(u.getEmail())
                .role(u.getRole())
                .actif(u.getActif())
                .photoProfil(u.getPhotoProfil())
                .dateCreation(u.getDateCreation())
                .build();
    }

    private ProducteurDto toProducteurDto(Producteur p) {
        return ProducteurDto.builder()
                .id(p.getId())
                .nom(p.getNom())
                .prenom(p.getPrenom())
                .telephone(p.getTelephone())
                .email(p.getEmail())
                .nomFerme(p.getNomFerme())
                .description(p.getDescription())
                .adresseFerme(p.getAdresseFerme())
                .latitude(p.getLatitude())
                .longitude(p.getLongitude())
                .logoFerme(p.getLogoFerme())
                .certifie(p.getCertifie())
                .valide(p.getValide())
                .noteMoyenne(p.getNoteMoyenne())
                .nombreVentes(p.getNombreVentes())
                .nombreProduits(p.getProduits().size())
                .dateCreation(p.getDateCreation())
                .build();
    }

    private LivreurDto toLivreurDto(Livreur l) {
        return LivreurDto.builder()
                .id(l.getId())
                .nom(l.getNom())
                .prenom(l.getPrenom())
                .telephone(l.getTelephone())
                .email(l.getEmail())
                .typeVehicule(l.getTypeVehicule())
                .numeroPlaque(l.getNumeroPlaque())
                .disponible(l.getDisponible())
                .latitude(l.getLatitude())
                .longitude(l.getLongitude())
                .noteMoyenne(l.getNoteMoyenne())
                .nombreLivraisons(l.getNombreLivraisons())
                .valide(l.getValide())
                .independant(l.getIndependant())
                .producteurRattacheNom(l.getProducteurRattache() != null ?
                        l.getProducteurRattache().getNomFerme() : null)
                .producteurRattacheId(l.getProducteurRattache() != null ?
                        l.getProducteurRattache().getId() : null)
                .zoneCouverture(l.getZoneCouverture())
                .dateCreation(l.getDateCreation())
                .build();
    }
}
