-- ============================================
-- Setup Script - Property Listing Database
-- ============================================
-- Run this single file to set up the complete database

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS property_listing_db;
USE property_listing_db;

-- Inform user
SELECT 'Setting up Property Listing Database...' AS Status;
SELECT 'Step 1: Creating database schema...' AS Status;

-- ============================================
-- EXECUTE SCHEMA CREATION
-- ============================================
SOURCE schema.sql;

SELECT 'Step 2: Loading sample data...' AS Status;

-- ============================================
-- EXECUTE SAMPLE DATA
-- ============================================
SOURCE sample_data.sql;

SELECT 'Step 3: Creating views and stored procedures...' AS Status;

-- ============================================
-- EXECUTE VIEWS AND PROCEDURES
-- ============================================
SOURCE views_procedures.sql;

SELECT 'Step 4: Creating triggers and constraints...' AS Status;

-- ============================================
-- EXECUTE TRIGGERS
-- ============================================
SOURCE triggers_constraints.sql;

-- ============================================
-- VERIFICATION AND SUMMARY
-- ============================================

SELECT 'Setup Complete! Database Summary:' AS Status;

-- Table counts
SELECT 'Table' AS Type, 'users' AS Name, COUNT(*) AS Count FROM users
UNION ALL
SELECT 'Table', 'locations', COUNT(*) FROM locations
UNION ALL
SELECT 'Table', 'properties', COUNT(*) FROM properties
UNION ALL
SELECT 'Table', 'listings', COUNT(*) FROM listings
UNION ALL
SELECT 'Table', 'favorites', COUNT(*) FROM favorites
UNION ALL
SELECT 'Table', 'inquiries', COUNT(*) FROM inquiries
UNION ALL
SELECT 'Table', 'property_images', COUNT(*) FROM property_images;

-- View counts
SELECT 'Views Created' AS Type, COUNT(*) AS Count
FROM information_schema.views
WHERE table_schema = 'property_listing_db';

-- Procedure counts
SELECT 'Stored Procedures' AS Type, COUNT(*) AS Count
FROM information_schema.routines
WHERE routine_schema = 'property_listing_db' 
AND routine_type = 'PROCEDURE';

-- Trigger counts
SELECT 'Triggers' AS Type, COUNT(*) AS Count
FROM information_schema.triggers
WHERE trigger_schema = 'property_listing_db';

SELECT '✓ Database is ready to use!' AS Status;
SELECT 'You can now run queries from queries.sql or test the stored procedures' AS NextSteps;
