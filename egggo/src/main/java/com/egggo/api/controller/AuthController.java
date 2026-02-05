package com.egggo.api.controller;

import com.egggo.api.dto.auth.AuthResponse;
import com.egggo.api.dto.auth.LoginRequest;
import com.egggo.api.dto.auth.RegisterRequest;
import com.egggo.api.dto.common.ApiResponse;
import com.egggo.application.service.AuthService;
import com.egggo.domain.model.user.Utilisateur;
import com.egggo.domain.repository.UtilisateurRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

/**
 * Contrôleur pour l'authentification
 */
@RestController
@RequestMapping("/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentification", description = "APIs pour la connexion et l'inscription")
public class AuthController {

    private final AuthService authService;
    private final UtilisateurRepository utilisateurRepository;

    @PostMapping("/login")
    @Operation(summary = "Connexion", description = "Authentifie un utilisateur et retourne un token JWT")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Connexion réussie", response));
    }

    @PostMapping("/register")
    @Operation(summary = "Inscription", description = "Inscrit un nouvel utilisateur (client, livreur ou producteur)")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(ApiResponse.success("Inscription réussie", response));
    }

    @GetMapping("/me")
    @Operation(summary = "Profil utilisateur", description = "Récupère les informations de l'utilisateur connecté")
    public ResponseEntity<ApiResponse<AuthResponse.UserInfo>> me() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String telephone = authentication.getName();
        
        Utilisateur utilisateur = utilisateurRepository.findByTelephone(telephone)
                .orElseThrow(() -> new IllegalStateException("Utilisateur non trouvé"));
        
        AuthResponse.UserInfo userInfo = AuthResponse.UserInfo.builder()
                .id(utilisateur.getId())
                .nom(utilisateur.getNom())
                .prenom(utilisateur.getPrenom())
                .telephone(utilisateur.getTelephone())
                .email(utilisateur.getEmail())
                .photoProfil(utilisateur.getPhotoProfil())
                .role(utilisateur.getRole())
                .build();
        
        return ResponseEntity.ok(ApiResponse.success(userInfo));
    }
}
