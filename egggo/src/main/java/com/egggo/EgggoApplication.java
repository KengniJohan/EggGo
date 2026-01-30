package com.egggo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * Application principale EggGo API
 * API REST pour l'application de livraison d'œufs au Cameroun
 * 
 * @author EggGo Team
 * @version 1.0.0
 */
@SpringBootApplication
@EnableJpaAuditing
public class EgggoApplication {

    public static void main(String[] args) {
        SpringApplication.run(EgggoApplication.class, args);
    }

}
