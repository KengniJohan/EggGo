package com.egggo.application.service;

import com.egggo.api.dto.order.CommandeDto;
import com.egggo.api.dto.order.CreateCommandeRequest;
import com.egggo.domain.model.common.Adresse;
import com.egggo.domain.model.order.*;
import com.egggo.domain.model.product.Produit;
import com.egggo.domain.model.user.Client;
import com.egggo.domain.model.user.Producteur;
import com.egggo.domain.repository.*;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service de gestion des commandes
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CommandeService {

    private final CommandeRepository commandeRepository;
    private final ClientRepository clientRepository;
    private final ProducteurRepository producteurRepository;
    private final ProduitRepository produitRepository;
    private final AdresseRepository adresseRepository;

    /**
     * Crée une nouvelle commande
     */
    @Transactional
    public CommandeDto createCommande(Long clientId, CreateCommandeRequest request) {
        Client client = clientRepository.findById(clientId)
                .orElseThrow(() -> new EntityNotFoundException("Client non trouvé"));

        Producteur producteur = producteurRepository.findById(request.getProducteurId())
                .orElseThrow(() -> new EntityNotFoundException("Producteur non trouvé"));

        Adresse adresse = adresseRepository.findById(request.getAdresseId())
                .orElseThrow(() -> new EntityNotFoundException("Adresse non trouvée"));

        // Créer la commande
        Commande commande = Commande.builder()
                .client(client)
                .producteur(producteur)
                .adresseLivraison(adresse)
                .modePaiement(request.getModePaiement())
                .creneauLivraison(request.getCreneauLivraison())
                .notes(request.getNotes())
                .fraisLivraison(500.0) // Frais de livraison par défaut
                .build();

        // Ajouter les lignes de commande
        for (CreateCommandeRequest.LigneCommandeRequest ligneRequest : request.getLignes()) {
            Produit produit = produitRepository.findById(ligneRequest.getProduitId())
                    .orElseThrow(() -> new EntityNotFoundException("Produit non trouvé: " + ligneRequest.getProduitId()));

            if (produit.getQuantiteStock() < ligneRequest.getQuantite()) {
                throw new IllegalArgumentException("Stock insuffisant pour le produit: " + produit.getNom());
            }

            LigneCommande ligne = LigneCommande.builder()
                    .produit(produit)
                    .quantite(ligneRequest.getQuantite())
                    .prixUnitaire(produit.getPrixUnitaire())
                    .build();

            commande.ajouterLigne(ligne);

            // Décrémenter le stock
            produit.decrementerStock(ligneRequest.getQuantite());
            produitRepository.save(produit);
        }

        commande = commandeRepository.save(commande);
        log.info("Commande créée: {} par client {}", commande.getReference(), clientId);

        return toCommandeDto(commande);
    }

    /**
     * Récupère les commandes d'un client
     */
    @Transactional(readOnly = true)
    public Page<CommandeDto> getCommandesClient(Long clientId, Pageable pageable) {
        return commandeRepository.findByClientIdOrderByDateCommandeDesc(clientId, pageable)
                .map(this::toCommandeDto);
    }

    /**
     * Récupère les commandes d'un producteur
     */
    @Transactional(readOnly = true)
    public Page<CommandeDto> getCommandesProducteur(Long producteurId, Pageable pageable) {
        return commandeRepository.findByProducteurIdOrderByDateCommandeDesc(producteurId, pageable)
                .map(this::toCommandeDto);
    }

    /**
     * Récupère une commande par son ID
     */
    @Transactional(readOnly = true)
    public CommandeDto getCommandeById(Long id) {
        Commande commande = commandeRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Commande non trouvée"));
        return toCommandeDto(commande);
    }

    /**
     * Récupère une commande par sa référence
     */
    @Transactional(readOnly = true)
    public CommandeDto getCommandeByReference(String reference) {
        Commande commande = commandeRepository.findByReference(reference)
                .orElseThrow(() -> new EntityNotFoundException("Commande non trouvée"));
        return toCommandeDto(commande);
    }

    /**
     * Confirme une commande (par le producteur)
     */
    @Transactional
    public CommandeDto confirmerCommande(Long commandeId) {
        Commande commande = commandeRepository.findById(commandeId)
                .orElseThrow(() -> new EntityNotFoundException("Commande non trouvée"));

        if (!commande.mettreAJourStatut(StatutCommande.CONFIRMEE)) {
            throw new IllegalStateException("Impossible de confirmer cette commande");
        }

        commande = commandeRepository.save(commande);
        log.info("Commande confirmée: {}", commande.getReference());

        return toCommandeDto(commande);
    }

    /**
     * Annule une commande
     */
    @Transactional
    public CommandeDto annulerCommande(Long commandeId, String raison) {
        Commande commande = commandeRepository.findById(commandeId)
                .orElseThrow(() -> new EntityNotFoundException("Commande non trouvée"));

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
        log.info("Commande annulée: {} - Raison: {}", commande.getReference(), raison);

        return toCommandeDto(commande);
    }

    /**
     * Convertit une entité Commande en DTO
     */
    private CommandeDto toCommandeDto(Commande commande) {
        CommandeDto.CommandeDtoBuilder builder = CommandeDto.builder()
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
                .producteurFerme(commande.getProducteur().getNomFerme());

        // Adresse
        Adresse adresse = commande.getAdresseLivraison();
        builder.adresse(CommandeDto.AdresseDto.builder()
                .id(adresse.getId())
                .nom(adresse.getLibelle())
                .quartier(adresse.getQuartier())
                .ville(adresse.getVille())
                .adresseComplete(adresse.getAdresseComplete())
                .indications(adresse.getDescription())
                .build());

        // Lignes de commande
        List<CommandeDto.LigneCommandeDto> lignes = commande.getLignes().stream()
                .map(ligne -> CommandeDto.LigneCommandeDto.builder()
                        .id(ligne.getId())
                        .produitId(ligne.getProduit().getId())
                        .produitNom(ligne.getProduit().getNom())
                        .produitUnite(ligne.getProduit().getUnite().name())
                        .quantite(ligne.getQuantite())
                        .prixUnitaire(ligne.getPrixUnitaire())
                        .prixTotal(ligne.getPrixTotal())
                        .build())
                .collect(Collectors.toList());
        builder.lignes(lignes);

        // Livraison (si assignée)
        if (commande.getLivraison() != null) {
            builder.livraison(CommandeDto.LivraisonDto.builder()
                    .id(commande.getLivraison().getId())
                    .statut(commande.getLivraison().getStatut().getLibelle())
                    .livreurNom(commande.getLivraison().getLivreur().getNomComplet())
                    .livreurTelephone(commande.getLivraison().getLivreur().getTelephone())
                    .codeConfirmation(commande.getLivraison().getCodeConfirmation())
                    .build());
        }

        return builder.build();
    }
}
