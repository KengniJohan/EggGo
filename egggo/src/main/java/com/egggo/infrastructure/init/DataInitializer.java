package com.egggo.infrastructure.init;

import com.egggo.domain.model.product.Categorie;
import com.egggo.domain.model.product.Produit;
import com.egggo.domain.model.product.Unite;
import com.egggo.domain.model.user.Producteur;
import com.egggo.domain.model.user.Role;
import com.egggo.domain.repository.CategorieRepository;
import com.egggo.domain.repository.ProducteurRepository;
import com.egggo.domain.repository.ProduitRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Initialise les données de démonstration au démarrage
 * Active uniquement en profil "dev"
 */
@Component
@Profile("dev")
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final CategorieRepository categorieRepository;
    private final ProducteurRepository producteurRepository;
    private final ProduitRepository produitRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        if (categorieRepository.count() > 0) {
            log.info("Données déjà initialisées, skip...");
            return;
        }

        log.info("Initialisation des données de démonstration...");

        // Créer les catégories
        Categorie oeufsConsommation = categorieRepository.save(Categorie.builder()
                .nom("Œufs de consommation")
                .description("Œufs frais pour la consommation quotidienne")
                .icone("🥚")
                .ordre(1)
                .build());

        Categorie oeufsIncubation = categorieRepository.save(Categorie.builder()
                .nom("Œufs à couver")
                .description("Œufs fertilisés pour l'incubation")
                .icone("🐣")
                .ordre(2)
                .build());

        Categorie oeufsSpeciaux = categorieRepository.save(Categorie.builder()
                .nom("Œufs spéciaux")
                .description("Œufs bio, plein air, enrichis")
                .icone("✨")
                .ordre(3)
                .build());

        log.info("Catégories créées: 3");

        // Créer un producteur de démonstration
        Producteur producteur = producteurRepository.save(Producteur.builder()
                .nom("NGUEMA")
                .prenom("Jean-Pierre")
                .telephone("690123456")
                .email("ferme.nguema@egggo.cm")
                .motDePasse(passwordEncoder.encode("password123"))
                .role(Role.PRODUCTEUR)
                .nomFerme("Ferme Avicole NGUEMA")
                .adresseFerme("Yaoundé - Nsimalen")
                .description("Ferme familiale spécialisée dans l'élevage de poules pondeuses depuis 15 ans")
                .latitude(3.8480)
                .longitude(11.5021)
                .certifie(true)
                .valide(true)
                .nombreVentes(150)
                .noteMoyenne(4.5)
                .build());

        log.info("Producteur de démonstration créé: {}", producteur.getNomFerme());

        // Créer des produits
        produitRepository.save(Produit.builder()
                .nom("Œufs frais - Plateau de 30")
                .description("Plateau de 30 œufs frais de ferme, calibre moyen")
                .prixUnitaire(2500.0)
                .unite(Unite.PLATEAU_30)
                .quantiteStock(100)
                .categorie(oeufsConsommation)
                .producteur(producteur)
                .build());

        produitRepository.save(Produit.builder()
                .nom("Œufs frais - Pièce")
                .description("Œuf frais de ferme à l'unité")
                .prixUnitaire(100.0)
                .unite(Unite.PIECE)
                .quantiteStock(500)
                .categorie(oeufsConsommation)
                .producteur(producteur)
                .build());

        produitRepository.save(Produit.builder()
                .nom("Œufs à couver - Plateau")
                .description("Œufs fertilisés pour incubation, race locale améliorée")
                .prixUnitaire(5000.0)
                .unite(Unite.PLATEAU_30)
                .quantiteStock(30)
                .categorie(oeufsIncubation)
                .producteur(producteur)
                .build());

        produitRepository.save(Produit.builder()
                .nom("Œufs bio plein air")
                .description("Œufs de poules élevées en plein air, alimentation 100% bio")
                .prixUnitaire(4000.0)
                .unite(Unite.PLATEAU_30)
                .quantiteStock(50)
                .categorie(oeufsSpeciaux)
                .producteur(producteur)
                .build());

        produitRepository.save(Produit.builder()
                .nom("Carton 180 œufs")
                .description("Carton de 180 œufs (6 plateaux) - Idéal pour les professionnels")
                .prixUnitaire(14000.0)
                .unite(Unite.CARTON_180)
                .quantiteStock(20)
                .categorie(oeufsConsommation)
                .producteur(producteur)
                .build());

        log.info("Produits de démonstration créés: 5");
        log.info("Initialisation terminée avec succès!");
    }
}
