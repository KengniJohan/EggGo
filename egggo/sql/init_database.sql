-- ============================================
-- Script d'initialisation de la base de données EggGo
-- ============================================
-- 
-- Exécutez ce script avec un utilisateur PostgreSQL ayant les droits de création de base de données
-- psql -U postgres -f init_database.sql
-- Ou via pgAdmin

-- Créer la base de données
CREATE DATABASE egggo_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'French_France.1252'
    LC_CTYPE = 'French_France.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Se connecter à la base de données
\c egggo_db

-- Commentaire sur la base de données
COMMENT ON DATABASE egggo_db IS 'Base de données pour l''application EggGo - Livraison d''oeufs au Cameroun';

-- ============================================
-- Les tables seront créées automatiquement par Hibernate (ddl-auto=update)
-- ============================================
