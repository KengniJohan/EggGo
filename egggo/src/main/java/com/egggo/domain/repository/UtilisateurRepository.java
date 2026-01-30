package com.egggo.domain.repository;

import com.egggo.domain.model.user.Role;
import com.egggo.domain.model.user.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository pour la gestion des utilisateurs
 */
@Repository
public interface UtilisateurRepository extends JpaRepository<Utilisateur, Long> {

    /**
     * Trouve un utilisateur par son numéro de téléphone
     */
    Optional<Utilisateur> findByTelephone(String telephone);

    /**
     * Vérifie si un numéro de téléphone existe déjà
     */
    boolean existsByTelephone(String telephone);

    /**
     * Vérifie si un email existe déjà
     */
    boolean existsByEmail(String email);

    /**
     * Trouve tous les utilisateurs ayant un rôle spécifique
     */
    List<Utilisateur> findByRole(Role role);

    /**
     * Trouve les utilisateurs actifs par rôle
     */
    List<Utilisateur> findByRoleAndActifTrue(Role role);

    /**
     * Recherche des utilisateurs par nom ou téléphone
     */
    @Query("SELECT u FROM Utilisateur u WHERE " +
           "LOWER(u.nom) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.prenom) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "u.telephone LIKE CONCAT('%', :search, '%')")
    List<Utilisateur> rechercherParNomOuTelephone(@Param("search") String search);
}
