package com.egggo.api.controller;

import com.egggo.api.dto.auth.AuthResponse;
import com.egggo.api.dto.auth.LoginRequest;
import com.egggo.api.dto.auth.RegisterRequest;
import com.egggo.api.dto.common.ApiResponse;
import com.egggo.application.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Contrôleur pour l'authentification
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentification", description = "APIs pour la connexion et l'inscription")
public class AuthController {

    private final AuthService authService;

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
    public ResponseEntity<ApiResponse<String>> me() {
        // Cette méthode sera implémentée avec la récupération du contexte de sécurité
        return ResponseEntity.ok(ApiResponse.success("Utilisateur connecté"));
    }
}
