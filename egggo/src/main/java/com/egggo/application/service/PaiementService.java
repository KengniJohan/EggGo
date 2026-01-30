package com.egggo.application.service;

import com.egggo.api.dto.payment.ConfirmerPaiementRequest;
import com.egggo.api.dto.payment.InitierPaiementRequest;
import com.egggo.api.dto.payment.PaiementResponse;
import com.egggo.domain.model.order.Commande;
import com.egggo.domain.model.order.ModePaiement;
import com.egggo.domain.model.order.StatutCommande;
import com.egggo.domain.model.payment.Paiement;
import com.egggo.domain.model.payment.StatutPaiement;
import com.egggo.domain.repository.CommandeRepository;
import com.egggo.domain.repository.PaiementRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Service de paiement mobile money SIMULÉ
 * Simule les interactions avec Orange Money et MTN Mobile Money
 * pour permettre les tests sans intégration réelle
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PaiementService {

    private final PaiementRepository paiementRepository;
    private final CommandeRepository commandeRepository;
    
    private final Random random = new Random();

    /**
     * Initie un paiement mobile money (SIMULATION)
     * Simule l'envoi d'une demande de paiement vers l'opérateur
     */
    @Transactional
    public PaiementResponse initierPaiement(InitierPaiementRequest request) {
        log.info("🔄 [SIMULATION] Initiation paiement {} pour commande {}", 
                request.getModePaiement(), request.getCommandeId());

        // Vérifier la commande
        Commande commande = commandeRepository.findById(request.getCommandeId())
                .orElseThrow(() -> new EntityNotFoundException("Commande non trouvée"));

        // Vérifier que la commande n'est pas déjà payée
        if (commande.getPaye()) {
            throw new IllegalStateException("Cette commande est déjà payée");
        }

        // Vérifier le montant
        if (!commande.getMontantTotal().equals(request.getMontant())) {
            throw new IllegalArgumentException("Le montant ne correspond pas au total de la commande");
        }

        // Générer une référence unique
        String reference = genererReference(request.getModePaiement());
        String transactionId = genererTransactionId(request.getModePaiement());

        // Créer le paiement en base
        Paiement paiement = Paiement.builder()
                .reference(reference)
                .transactionId(transactionId)
                .montant(request.getMontant())
                .modePaiement(request.getModePaiement())
                .statut(StatutPaiement.EN_ATTENTE)
                .numeroTelephone(request.getNumeroTelephone())
                .commande(commande)
                .build();

        paiement = paiementRepository.save(paiement);

        // Simuler le message de l'opérateur
        String messageOperateur = simulerMessageOperateur(request.getModePaiement(), request.getMontant());

        log.info("✅ [SIMULATION] Paiement initié: {} - Transaction: {}", reference, transactionId);
        log.info("📱 [SIMULATION] Message envoyé au {}: {}", request.getNumeroTelephone(), messageOperateur);

        return toPaiementResponse(paiement, messageOperateur);
    }

    /**
     * Confirme un paiement (SIMULATION du callback opérateur)
     * Utilise le code OTP pour simuler différents scénarios
     */
    @Transactional
    public PaiementResponse confirmerPaiement(ConfirmerPaiementRequest request) {
        log.info("🔄 [SIMULATION] Confirmation paiement ID: {}", request.getPaiementId());

        Paiement paiement = paiementRepository.findById(request.getPaiementId())
                .orElseThrow(() -> new EntityNotFoundException("Paiement non trouvé"));

        if (paiement.getStatut() != StatutPaiement.EN_ATTENTE) {
            throw new IllegalStateException("Ce paiement n'est plus en attente");
        }

        String messageOperateur;
        StatutPaiement nouveauStatut;

        // Déterminer le résultat de la simulation
        String mode = request.getSimulationMode() != null ? 
                request.getSimulationMode().toUpperCase() : request.getCodeOtp();

        switch (mode) {
            case "SUCCESS", "1234", "OK" -> {
                nouveauStatut = StatutPaiement.REUSSI;
                messageOperateur = simulerMessageSucces(paiement);
                
                // Mettre à jour la commande
                Commande commande = paiement.getCommande();
                commande.setPaye(true);
                commande.setStatut(StatutCommande.CONFIRMEE);
                commandeRepository.save(commande);
                
                log.info("✅ [SIMULATION] Paiement RÉUSSI: {}", paiement.getReference());
            }
            case "FAILED", "0000", "ECHEC" -> {
                nouveauStatut = StatutPaiement.ECHOUE;
                messageOperateur = simulerMessageEchec(paiement);
                log.warn("❌ [SIMULATION] Paiement ÉCHOUÉ: {}", paiement.getReference());
            }
            case "TIMEOUT", "9999" -> {
                nouveauStatut = StatutPaiement.EXPIRE;
                messageOperateur = "Délai de validation dépassé. Transaction annulée.";
                log.warn("⏰ [SIMULATION] Paiement EXPIRÉ: {}", paiement.getReference());
            }
            case "CANCEL", "ANNULE" -> {
                nouveauStatut = StatutPaiement.ANNULE;
                messageOperateur = "Transaction annulée par l'utilisateur.";
                log.info("🚫 [SIMULATION] Paiement ANNULÉ: {}", paiement.getReference());
            }
            default -> {
                // Code OTP invalide ou en attente
                messageOperateur = "Code OTP invalide. Veuillez réessayer.";
                log.info("⏳ [SIMULATION] Code OTP invalide, paiement toujours en attente");
                return toPaiementResponse(paiement, messageOperateur);
            }
        }

        paiement.setStatut(nouveauStatut);
        paiement.setDatePaiement(LocalDateTime.now());
        paiement = paiementRepository.save(paiement);

        return toPaiementResponse(paiement, messageOperateur);
    }

    /**
     * Vérifie le statut d'un paiement
     */
    @Transactional(readOnly = true)
    public PaiementResponse verifierStatut(Long paiementId) {
        Paiement paiement = paiementRepository.findById(paiementId)
                .orElseThrow(() -> new EntityNotFoundException("Paiement non trouvé"));
        
        return toPaiementResponse(paiement, null);
    }

    /**
     * Vérifie le statut par référence
     */
    @Transactional(readOnly = true)
    public PaiementResponse verifierStatutParReference(String reference) {
        Paiement paiement = paiementRepository.findByReference(reference)
                .orElseThrow(() -> new EntityNotFoundException("Paiement non trouvé"));
        
        return toPaiementResponse(paiement, null);
    }

    /**
     * Récupère l'historique des paiements d'une commande
     */
    @Transactional(readOnly = true)
    public List<PaiementResponse> getPaiementsCommande(Long commandeId) {
        return paiementRepository.findByCommandeId(commandeId)
                .stream()
                .map(p -> toPaiementResponse(p, null))
                .collect(Collectors.toList());
    }

    /**
     * Annule un paiement en attente
     */
    @Transactional
    public PaiementResponse annulerPaiement(Long paiementId) {
        Paiement paiement = paiementRepository.findById(paiementId)
                .orElseThrow(() -> new EntityNotFoundException("Paiement non trouvé"));

        if (paiement.getStatut() != StatutPaiement.EN_ATTENTE) {
            throw new IllegalStateException("Seuls les paiements en attente peuvent être annulés");
        }

        paiement.setStatut(StatutPaiement.ANNULE);
        paiement.setDatePaiement(LocalDateTime.now());
        paiement = paiementRepository.save(paiement);

        log.info("🚫 [SIMULATION] Paiement annulé: {}", paiement.getReference());

        return toPaiementResponse(paiement, "Paiement annulé avec succès");
    }

    // ==================== MÉTHODES DE SIMULATION ====================

    /**
     * Génère une référence de paiement unique
     */
    private String genererReference(ModePaiement mode) {
        String prefix = switch (mode) {
            case ORANGE_MONEY -> "OM";
            case MTN_MOMO -> "MOMO";
            case CASH_LIVRAISON -> "CASH";
            default -> "PAY";
        };
        return prefix + "-" + System.currentTimeMillis() + "-" + random.nextInt(1000);
    }

    /**
     * Génère un ID de transaction simulé (format opérateur)
     */
    private String genererTransactionId(ModePaiement mode) {
        return switch (mode) {
            case ORANGE_MONEY -> "CM.OM." + UUID.randomUUID().toString().substring(0, 12).toUpperCase();
            case MTN_MOMO -> "MOMO" + System.currentTimeMillis() + random.nextInt(10000);
            default -> UUID.randomUUID().toString();
        };
    }

    /**
     * Simule le message USSD/Push envoyé par l'opérateur
     */
    private String simulerMessageOperateur(ModePaiement mode, Double montant) {
        return switch (mode) {
            case ORANGE_MONEY -> String.format(
                    "Orange Money: Vous avez reçu une demande de paiement de %.0f FCFA " +
                    "pour EggGo. Tapez votre code secret pour valider.", montant);
            case MTN_MOMO -> String.format(
                    "MTN MoMo: Confirmez le paiement de %.0f FCFA vers EggGo. " +
                    "Entrez votre PIN pour autoriser.", montant);
            default -> "Paiement en attente de validation";
        };
    }

    /**
     * Simule le message de confirmation de succès
     */
    private String simulerMessageSucces(Paiement paiement) {
        return switch (paiement.getModePaiement()) {
            case ORANGE_MONEY -> String.format(
                    "Orange Money: Transaction réussie! %.0f FCFA envoyés à EggGo. " +
                    "Ref: %s. Merci!", paiement.getMontant(), paiement.getTransactionId());
            case MTN_MOMO -> String.format(
                    "MTN MoMo: Paiement de %.0f FCFA confirmé. " +
                    "ID: %s. Votre commande est en cours de traitement.", 
                    paiement.getMontant(), paiement.getTransactionId());
            default -> "Paiement confirmé avec succès";
        };
    }

    /**
     * Simule le message d'échec
     */
    private String simulerMessageEchec(Paiement paiement) {
        return switch (paiement.getModePaiement()) {
            case ORANGE_MONEY -> "Orange Money: Transaction échouée. Solde insuffisant ou code incorrect.";
            case MTN_MOMO -> "MTN MoMo: Paiement refusé. Vérifiez votre solde et réessayez.";
            default -> "Paiement échoué";
        };
    }

    /**
     * Convertit un Paiement en PaiementResponse
     */
    private PaiementResponse toPaiementResponse(Paiement paiement, String messageOperateur) {
        return PaiementResponse.builder()
                .id(paiement.getId())
                .reference(paiement.getReference())
                .transactionId(paiement.getTransactionId())
                .montant(paiement.getMontant())
                .modePaiement(paiement.getModePaiement())
                .statut(paiement.getStatut())
                .numeroTelephone(paiement.getNumeroTelephone())
                .messageOperateur(messageOperateur)
                .dateInitiation(paiement.getDateCreation())
                .dateConfirmation(paiement.getDatePaiement())
                .commandeId(paiement.getCommande().getId())
                .commandeReference(paiement.getCommande().getReference())
                .build();
    }
}
