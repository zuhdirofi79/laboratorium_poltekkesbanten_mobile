-- ============================================
-- API Tokens Table Migration
-- ============================================
-- Purpose: Store API tokens for mobile app authentication
-- This table is NEW and does NOT interfere with existing web system
-- 
-- Location: api/database/migrations/create_api_tokens_table.sql
-- 
-- IMPORTANT: Run this SQL in your cPanel MySQL or phpMyAdmin
-- ============================================

CREATE TABLE IF NOT EXISTS `api_tokens` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `user_id` (`user_id`),
  KEY `expires_at` (`expires_at`),
  CONSTRAINT `api_tokens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Why this table is safe:
-- 1. It's a NEW table, doesn't modify existing tables
-- 2. Foreign key references users.id (read-only for API)
-- 3. ON DELETE CASCADE ensures cleanup if user is deleted
-- 4. Token hash is unique to prevent duplicates
-- 5. Expires_at allows automatic token expiration
-- ============================================
