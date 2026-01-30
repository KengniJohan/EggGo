package com.egggo.api.dto.user;

import com.egggo.domain.model.user.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO pour les utilisateurs
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UtilisateurDto {
    private Long id;
    private String nom;
    private String prenom;
    private String telephone;
    private String email;
    private Role role;
    private Boolean actif;
    private String photoProfil;
    private LocalDateTime dateCreation;
}
