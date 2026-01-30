package com.egggo.application.service;

import com.egggo.api.dto.order.CommandeDto;
import com.egggo.api.dto.product.ProduitDto;
import com.egggo.api.dto.producteur.ProducteurDashboardDto;
import com.egggo.api.dto.product.CreateProduitRequest;
import com.egggo.api.dto.producteur.UpdateStockRequest;
import com.egggo.api.dto.user.LivreurDto;
import com.egggo.domain.model.order.Commande;
import com.egggo.domain.model.order.LigneCommande;
import com.egggo.domain.model.order.StatutCommande;
import com.egggo.domain.model.product.Produit;
import com.egggo.domain.model.user.Livreur;
import com.egggo.domain.model.user.Producteur;
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
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service pour les fonctionnalités des producteurs
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ProducteurService {

    private final ProducteurRepository producteurRepository;
    private final ProduitRepository produitRepository;
    private final CommandeRepository commandeRepository;
    private final LivreurRepository livreurRepository;
    private final CategorieRepository categorieRepository;

    /**
     * Récupère le tableau de bord d'un producteur
     */
    @Transactional(readOnly = true)
    public ProducteurDashboardDto getDashboard(Long producteurId) {
        Producteur producteur = producteurRepository.findById(producteurId)
                .orElseThrow(() -> new EntityNotFoundException("Producteur non trouvé"));

        LocalDateTime debutJour = LocalDate.now().atStartOfDay();
        LocalDateTime debutMois = LocalDate.now().withDayOfMonth(1).atStartOfDay();

        // Statistiques
        List<Commande> commandesMois = commandeRepository.findByProducteurIdAndDateCommandeAfter(producteurId, debutMois);
        List<Commande> commandesEnAttente = commandeRepository.findByProducteurIdAndStatut(producteurId, StatutCommande.EN_ATTENTE);
        List<Produit> produits = produitRepository.findByProducteurId(producteurId);

        double chiffreAffairesMois = commandesMois.stream()
                .filter(c -> c.getStatut() != StatutCommande.ANNULEE)
                .mapToDouble(Commande::getMontantTotal)
                .sum();

        int produitsEnStock = (int) produits.stream()
                .filter(p -> p.getQuantiteStock() > 0)
                .count();

        int produitsEnRupture = (int) produits.stream()
                .filter(p -> p.getQuantiteStock() <= 0)
                .count();

        // Commandes récentes
        List<ProducteurDashboardDto.CommandeResumeDto> commandesRecentes = commandeRepository
                .findByProducteurIdOrderByDateCommandeDesc(producteurId, Pageable.ofSize(5))
                .stream()
                .map(c -> ProducteurDashboardDto.CommandeResumeDto.builder()
                        .id(c.getId())
                        .reference(c.getReference())
                        .clientNom(c.getClient().getNomComplet())
                        .montant(c.getMontantTotal())
                        .statut(c.getStatut().name())
                        .date(c.getDateCommande())
                        .build())
                .collect(Collectors.toList());

        // Produits du producteur
        List<ProducteurDashboardDto.ProduitResumeDto> produitsList = produits.stream()
                .map(p -> ProducteurDashboardDto.ProduitResumeDto.builder()
                        .id(p.getId())
                        .nom(p.getNom())
                        .prix(p.getPrixUnitaire())
                        .stock(p.getQuantiteStock())
                        .disponible(p.getDisponible())
                        .build())
                .collect(Collectors.toList());

        return ProducteurDashboardDto.builder()
                .producteurId(producteurId)
                .nomFerme(producteur.getNomFerme())
                .chiffreAffairesMois(chiffreAffairesMois)
                .commandesEnAttente(commandesEnAttente.size())
                .produitsEnStock(produitsEnStock)
                .produitsEnRupture(produitsEnRupture)
                .noteMoyenne(producteur.getNoteMoyenne())
                .commandesRecentes(commandesRecentes)
                .produits(produitsList)
                .build();
    }

    /**
     * Récupère les produits d'un producteur
     */
    @Transactional(readOnly = true)
    public List<ProduitDto> getProduits(Long producteurId) {
        return produitRepository.findByProducteurId(producteurId)
                .stream()
                .map(this::toProduitDto)
                .collect(Collectors.toList());
    }

    /**
     * Crée un nouveau produit pour un producteur
     */
    @Transactional
    public ProduitDto createProduit(Long producteurId, CreateProduitRequest request) {
        Producteur producteur = producteurRepository.findById(producteurId)
                .orElseThrow(() -> new EntityNotFoundException("Producteur non trouvé"));

        var categorie = categorieRepository.findById(request.getCategorieId())
                .orElseThrow(() -> new EntityNotFoundException("Catégorie non trouvée"));

        Produit produit = Produit.builder()
                .nom(request.getNom())
                .description(request.getDescription())
                .prixUnitaire(request.getPrixUnitaire())
                .unite(request.getUnite())
                .quantiteStock(request.getStockDisponible() != null ? request.getStockDisponible() : 0)
                .image(request.getImageUrl())
                .categorie(categorie)
                .producteur(producteur)
                .disponible(true)
                .build();

        produit = produitRepository.save(produit);
        log.info("Produit créé: {} par producteur {}", produit.getNom(), producteurId);

        return toProduitDto(produit);
    }

    /**
     * Met à jour un produit existant
     */
    @Transactional
    public ProduitDto updateProduit(Long producteurId, Long produitId, CreateProduitRequest request) {
        Produit produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new EntityNotFoundException("Produit non trouvé"));

        if (!produit.getProducteur().getId().equals(producteurId)) {
            throw new IllegalArgumentException("Ce produit n'appartient pas à ce producteur");
        }

        if (request.getNom() != null) produit.setNom(request.getNom());
        if (request.getDescription() != null) produit.setDescription(request.getDescription());
        if (request.getPrixUnitaire() != null) produit.setPrixUnitaire(request.getPrixUnitaire());
        if (request.getUnite() != null) produit.setUnite(request.getUnite());
        if (request.getStockDisponible() != null) produit.setQuantiteStock(request.getStockDisponible());
        if (request.getImageUrl() != null) produit.setImage(request.getImageUrl());

        if (request.getCategorieId() != null) {
            var categorie = categorieRepository.findById(request.getCategorieId())
                    .orElseThrow(() -> new EntityNotFoundException("Catégorie non trouvée"));
            produit.setCategorie(categorie);
        }

        produit = produitRepository.save(produit);
        log.info("Produit mis à jour: {}", produit.getNom());

        return toProduitDto(produit);
    }

    /**
     * Met à jour le stock d'un produit
     */
    @Transactional
    public ProduitDto updateStock(Long producteurId, Long produitId, UpdateStockRequest request) {
        Produit produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new EntityNotFoundException("Produit non trouvé"));

        if (!produit.getProducteur().getId().equals(producteurId)) {
            throw new IllegalArgumentException("Ce produit n'appartient pas à ce producteur");
        }

        int nouveauStock;
        switch (request.getOperation()) {
            case ADD:
                nouveauStock = produit.getQuantiteStock() + request.getQuantite();
                break;
            case REMOVE:
                nouveauStock = Math.max(0, produit.getQuantiteStock() - request.getQuantite());
                break;
            case SET:
            default:
                nouveauStock = request.getQuantite();
                break;
        }

        produit.setQuantiteStock(nouveauStock);
        produit.setDisponible(nouveauStock > 0);
        produit = produitRepository.save(produit);

        log.info("Stock mis à jour pour produit {}: {}", produitId, nouveauStock);

        return toProduitDto(produit);
    }

    /**
     * Active/désactive la disponibilité d'un produit
     */
    @Transactional
    public ProduitDto toggleDisponibilite(Long producteurId, Long produitId) {
        Produit produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new EntityNotFoundException("Produit non trouvé"));

        if (!produit.getProducteur().getId().equals(producteurId)) {
            throw new IllegalArgumentException("Ce produit n'appartient pas à ce producteur");
        }

        produit.setDisponible(!produit.getDisponible());
        produit = produitRepository.save(produit);

        return toProduitDto(produit);
    }

    /**
     * Supprime un produit
     */
    @Transactional
    public void deleteProduit(Long producteurId, Long produitId) {
        Produit produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new EntityNotFoundException("Produit non trouvé"));

        if (!produit.getProducteur().getId().equals(producteurId)) {
            throw new IllegalArgumentException("Ce produit n'appartient pas à ce producteur");
        }

        produitRepository.delete(produit);
        log.info("Produit supprimé: {}", produitId);
    }

    /**
     * Récupère les commandes d'un producteur
     */
    @Transactional(readOnly = true)
    public Page<CommandeDto> getCommandes(Long producteurId, String statut, Pageable pageable) {
        Page<Commande> commandes;
        if (statut != null && !statut.isEmpty()) {
            StatutCommande statutEnum = StatutCommande.valueOf(statut.toUpperCase());
            commandes = commandeRepository.findByProducteurIdAndStatutOrderByDateCommandeDesc(producteurId, statutEnum, pageable);
        } else {
            commandes = commandeRepository.findByProducteurIdOrderByDateCommandeDesc(producteurId, pageable);
        }

        return commandes.map(this::toCommandeDto);
    }

    /**
     * Confirme une commande
     */
    @Transactional
    public CommandeDto confirmerCommande(Long producteurId, Long commandeId) {
        Commande commande = commandeRepository.findById(commandeId)
                .orElseThrow(() -> new EntityNotFoundException("Commande non trouvée"));

        if (!commande.getProducteur().getId().equals(producteurId)) {
            throw new IllegalArgumentException("Cette commande n'appartient pas à ce producteur");
        }

        if (!commande.mettreAJourStatut(StatutCommande.CONFIRMEE)) {
            throw new IllegalStateException("Impossible de confirmer cette commande");
        }

        commande = commandeRepository.save(commande);
        log.info("Commande confirmée: {} par producteur {}", commande.getReference(), producteurId);

        return toCommandeDto(commande);
    }

    /**
     * Annule une commande
     */
    @Transactional
    public CommandeDto annulerCommande(Long producteurId, Long commandeId, String raison) {
        Commande commande = commandeRepository.findById(commandeId)
                .orElseThrow(() -> new EntityNotFoundException("Commande non trouvée"));

        if (!commande.getProducteur().getId().equals(producteurId)) {
            throw new IllegalArgumentException("Cette commande n'appartient pas à ce producteur");
        }

        if (!commande.peutEtreAnnulee()) {
            throw new IllegalStateException("Cette commande ne peut plus être annulée");
        }

        commande.setStatut(StatutCommande.ANNULEE);
        commande.setNotes(raison);

        // Restaurer le stock
        for (LigneCommande ligne : commande.getLignes()) {
            Produit produit = ligne.getProduit();
            produit.incrementerStock(ligne.getQuantite());
            produitRepository.save(produit);
        }

        commande = commandeRepository.save(commande);
        log.info("Commande annulée: {} par producteur {} - Raison: {}", commande.getReference(), producteurId, raison);

        return toCommandeDto(commande);
    }

    /**
     * Récupère les livreurs rattachés au producteur
     */
    @Transactional(readOnly = true)
    public List<LivreurDto> getLivreursRattaches(Long producteurId) {
        Producteur producteur = producteurRepository.findById(producteurId)
                .orElseThrow(() -> new EntityNotFoundException("Producteur non trouvé"));

        return producteur.getLivreursRattaches().stream()
                .map(this::toLivreurDto)
                .collect(Collectors.toList());
    }

    /**
     * Récupère les livreurs indépendants disponibles
     */
    @Transactional(readOnly = true)
    public List<LivreurDto> getLivreursIndependants() {
        return livreurRepository.findByDisponibleTrueAndActifTrue().stream()
                .filter(Livreur::getIndependant)
                .map(this::toLivreurDto)
                .collect(Collectors.toList());
    }

    /**
     * Assigne un livreur à une commande
     */
    @Transactional
    public CommandeDto assignerLivreur(Long producteurId, Long commandeId, Long livreurId) {
        Commande commande = commandeRepository.findById(commandeId)
                .orElseThrow(() -> new EntityNotFoundException("Commande non trouvée"));

        if (!commande.getProducteur().getId().equals(producteurId)) {
            throw new IllegalArgumentException("Cette commande n'appartient pas à ce producteur");
        }

        Livreur livreur = livreurRepository.findById(livreurId)
                .orElseThrow(() -> new EntityNotFoundException("Livreur non trouvé"));

        // La création de la livraison sera gérée par LivraisonService
        commande.mettreAJourStatut(StatutCommande.EN_PREPARATION);
        commande = commandeRepository.save(commande);

        log.info("Livreur {} assigné à la commande {}", livreurId, commandeId);

        return toCommandeDto(commande);
    }

    // ====================== Méthodes de conversion ======================

    private ProduitDto toProduitDto(Produit produit) {
        return ProduitDto.builder()
                .id(produit.getId())
                .nom(produit.getNom())
                .description(produit.getDescription())
                .prixUnitaire(produit.getPrixUnitaire())
                .unite(produit.getUnite())
                .stockDisponible(produit.getQuantiteStock())
                .imageUrl(produit.getImage())
                .actif(produit.getDisponible())
                .disponible(produit.verifierDisponibilite(1))
                .categorieId(produit.getCategorie().getId())
                .categorieNom(produit.getCategorie().getNom())
                .producteurId(produit.getProducteur().getId())
                .producteurNom(produit.getProducteur().getNomComplet())
                .producteurFerme(produit.getProducteur().getNomFerme())
                .producteurNote(produit.getProducteur().getNoteMoyenne())
                .build();
    }

    private CommandeDto toCommandeDto(Commande commande) {
        return CommandeDto.builder()
                .id(commande.getId())
                .reference(commande.getReference())
                .statut(commande.getStatut())
                .modePaiement(commande.getModePaiement())
                .montantProduits(commande.getMontantProduits())
                .fraisLivraison(commande.getFraisLivraison())
                .montantRemise(commande.getMontantRemise())
                .montantTotal(commande.getMontantTotal())
                .paye(commande.getPaye())
                .creneauLivraison(commande.getCreneauLivraison())
                .notes(commande.getNotes())
                .dateCommande(commande.getDateCommande())
                .dateLivraison(commande.getDateLivraison())
                .clientId(commande.getClient().getId())
                .clientNom(commande.getClient().getNomComplet())
                .clientTelephone(commande.getClient().getTelephone())
                .producteurId(commande.getProducteur().getId())
                .producteurNom(commande.getProducteur().getNomComplet())
                .producteurFerme(commande.getProducteur().getNomFerme())
                .build();
    }

    private LivreurDto toLivreurDto(Livreur livreur) {
        return LivreurDto.builder()
                .id(livreur.getId())
                .nom(livreur.getNom())
                .prenom(livreur.getPrenom())
                .telephone(livreur.getTelephone())
                .typeVehicule(livreur.getTypeVehicule())
                .numeroPlaque(livreur.getNumeroPlaque())
                .disponible(livreur.getDisponible())
                .latitude(livreur.getLatitude())
                .longitude(livreur.getLongitude())
                .noteMoyenne(livreur.getNoteMoyenne())
                .nombreLivraisons(livreur.getNombreLivraisons())
                .valide(livreur.getValide())
                .independant(livreur.getIndependant())
                .producteurRattacheNom(livreur.getProducteurRattache() != null ?
                        livreur.getProducteurRattache().getNomFerme() : null)
                .producteurRattacheId(livreur.getProducteurRattache() != null ?
                        livreur.getProducteurRattache().getId() : null)
                .zoneCouverture(livreur.getZoneCouverture())
                .dateCreation(livreur.getDateCreation())
                .build();
    }
}
