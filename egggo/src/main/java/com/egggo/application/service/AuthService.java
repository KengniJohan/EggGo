package com.egggo.application.service;

import com.egggo.api.dto.auth.AuthResponse;
import com.egggo.api.dto.auth.LoginRequest;
import com.egggo.api.dto.auth.RegisterRequest;
import com.egggo.domain.model.user.*;
import com.egggo.domain.repository.ClientRepository;
import com.egggo.domain.repository.LivreurRepository;
import com.egggo.domain.repository.ProducteurRepository;
import com.egggo.domain.repository.UtilisateurRepository;
import com.egggo.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Service d'authentification
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UtilisateurRepository utilisateurRepository;
    private final ClientRepository clientRepository;
    private final LivreurRepository livreurRepository;
    private final ProducteurRepository producteurRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    /**
     * Authentifie un utilisateur et retourne un token JWT
     */
    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        log.info("Tentative de connexion pour: {}", request.getTelephone());

        Utilisateur utilisateur = utilisateurRepository.findByTelephone(request.getTelephone())
                .orElseThrow(() -> new BadCredentialsException("Identifiants invalides"));

        if (!passwordEncoder.matches(request.getMotDePasse(), utilisateur.getMotDePasse())) {
            throw new BadCredentialsException("Identifiants invalides");
        }

        if (!utilisateur.getActif()) {
            throw new BadCredentialsException("Compte désactivé");
        }

        String token = jwtTokenProvider.generateToken(utilisateur.getTelephone(), utilisateur.getRole().name());

        log.info("Connexion réussie pour: {}", request.getTelephone());

        return buildAuthResponse(utilisateur, token);
    }

    /**
     * Inscrit un nouvel utilisateur
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        log.info("Tentative d'inscription: {} - {}", request.getTelephone(), request.getRole());

        // Vérifier si le téléphone existe déjà
        if (utilisateurRepository.existsByTelephone(request.getTelephone())) {
            throw new IllegalArgumentException("Ce numéro de téléphone est déjà utilisé");
        }

        // Vérifier si l'email existe déjà (si fourni)
        if (request.getEmail() != null && utilisateurRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Cet email est déjà utilisé");
        }

        Utilisateur utilisateur;
        String encodedPassword = passwordEncoder.encode(request.getMotDePasse());

        switch (request.getRole()) {
            case CLIENT -> {
                Client client = Client.builder()
                        .nom(request.getNom())
                        .prenom(request.getPrenom())
                        .telephone(request.getTelephone())
                        .email(request.getEmail())
                        .motDePasse(encodedPassword)
                        .role(Role.CLIENT)
                        .pointsFidelite(0)
                        .build();
                utilisateur = clientRepository.save(client);
            }
            case LIVREUR -> {
                Livreur livreur = Livreur.builder()
                        .nom(request.getNom())
                        .prenom(request.getPrenom())
                        .telephone(request.getTelephone())
                        .email(request.getEmail())
                        .motDePasse(encodedPassword)
                        .role(Role.LIVREUR)
                        .typeVehicule(request.getTypeVehicule())
                        .numeroPieceIdentite(request.getNumeroPermis() != null ? request.getNumeroPermis() : "")
                        .disponible(false)
                        .nombreLivraisons(0)
                        .build();
                utilisateur = livreurRepository.save(livreur);
            }
            case PRODUCTEUR -> {
                Producteur producteur = Producteur.builder()
                        .nom(request.getNom())
                        .prenom(request.getPrenom())
                        .telephone(request.getTelephone())
                        .email(request.getEmail())
                        .motDePasse(encodedPassword)
                        .role(Role.PRODUCTEUR)
                        .nomFerme(request.getNomFerme())
                        .adresseFerme(request.getLocalisation() != null ? request.getLocalisation() : "")
                        .description(request.getDescription())
                        .certifie(false)
                        .valide(false)
                        .nombreVentes(0)
                        .build();
                utilisateur = producteurRepository.save(producteur);
            }
            default -> throw new IllegalArgumentException("Rôle non supporté pour l'inscription");
        }

        String token = jwtTokenProvider.generateToken(utilisateur.getTelephone(), utilisateur.getRole().name());

        log.info("Inscription réussie pour: {}", request.getTelephone());

        return buildAuthResponse(utilisateur, token);
    }

    /**
     * Construit la réponse d'authentification
     */
    private AuthResponse buildAuthResponse(Utilisateur utilisateur, String token) {
        return AuthResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .expiresIn(86400000L) // 24 heures en millisecondes
                .user(AuthResponse.UserInfo.builder()
                        .id(utilisateur.getId())
                        .nom(utilisateur.getNom())
                        .prenom(utilisateur.getPrenom())
                        .telephone(utilisateur.getTelephone())
                        .email(utilisateur.getEmail())
                        .photoProfil(utilisateur.getPhotoProfil())
                        .role(utilisateur.getRole())
                        .build())
                .build();
    }
}
