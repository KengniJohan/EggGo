package com.egggo.api.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur pour les vérifications de santé de l'API
 */
@RestController
@RequestMapping("/api/v1")
@Tag(name = "Health", description = "APIs pour la vérification de l'état de l'application")
public class HealthController {

    @GetMapping("/health")
    @Operation(summary = "Health Check", description = "Vérifie que l'API est opérationnelle")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("application", "EggGo API");
        response.put("version", "1.0.0");
        response.put("timestamp", LocalDateTime.now());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/")
    @Operation(summary = "Welcome", description = "Page d'accueil de l'API")
    public ResponseEntity<Map<String, Object>> welcome() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Bienvenue sur l'API EggGo - Livraison d'oeufs au Cameroun");
        response.put("documentation", "/swagger-ui.html");
        response.put("version", "1.0.0");
        return ResponseEntity.ok(response);
    }
}
