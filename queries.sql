-- ============================================
-- Sample Queries - Property Listing Database
-- ============================================
-- Demonstrates various SQL concepts and database operations

-- ============================================
-- 1. BASIC SELECT QUERIES
-- ============================================

-- Get all active listings with their details
SELECT * FROM listings WHERE status = 'active';

-- Get all users who are sellers
SELECT id, name, email FROM users WHERE role = 'seller';

-- Get properties by type
SELECT * FROM properties WHERE type = 'House';

-- ============================================
-- 2. JOIN OPERATIONS
-- ============================================

-- INNER JOIN: Get all listings with property and location details
SELECT 
    l.id AS listing_id,
    p.type AS property_type,
    p.description,
    loc.city,
    loc.area,
    loc.address,
    l.price,
    l.status
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN locations loc ON l.location_id = loc.id;

-- LEFT JOIN: Get all users and their properties (including users with no properties)
SELECT 
    u.name AS owner_name,
    u.email,
    p.type AS property_type,
    p.description
FROM users u
LEFT JOIN properties p ON u.id = p.owner_id
WHERE u.role = 'seller';

-- Multiple JOINS: Get complete listing information
SELECT 
    l.id AS listing_id,
    u.name AS owner_name,
    p.type AS property_type,
    loc.city,
    loc.area,
    l.price,
    l.status,
    COUNT(pi.id) AS image_count
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN users u ON p.owner_id = u.id
INNER JOIN locations loc ON l.location_id = loc.id
LEFT JOIN property_images pi ON l.id = pi.listing_id
GROUP BY l.id, u.name, p.type, loc.city, loc.area, l.price, l.status;

-- ============================================
-- 3. AGGREGATE FUNCTIONS
-- ============================================

-- Count listings by status
SELECT status, COUNT(*) AS count
FROM listings
GROUP BY status;

-- Average, minimum, and maximum property prices
SELECT 
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM listings;

-- Count properties by type
SELECT type, COUNT(*) AS count
FROM properties
GROUP BY type
ORDER BY count DESC;

-- Count listings by city
SELECT 
    loc.city,
    COUNT(l.id) AS listing_count,
    ROUND(AVG(l.price), 2) AS avg_price
FROM locations loc
LEFT JOIN listings l ON loc.id = l.location_id
GROUP BY loc.city
ORDER BY listing_count DESC;

-- ============================================
-- 4. SUBQUERIES
-- ============================================

-- Find users who have made inquiries
SELECT DISTINCT name, email
FROM users
WHERE id IN (SELECT DISTINCT user_id FROM inquiries);

-- Find listings with price above average
SELECT 
    l.id,
    p.type,
    loc.city,
    l.price
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN locations loc ON l.location_id = loc.id
WHERE l.price > (SELECT AVG(price) FROM listings);

-- Find sellers with most properties
SELECT 
    u.name,
    u.email,
    (SELECT COUNT(*) FROM properties p WHERE p.owner_id = u.id) AS property_count
FROM users u
WHERE u.role = 'seller'
HAVING property_count > 0
ORDER BY property_count DESC;

-- ============================================
-- 5. ADVANCED FILTERING (WHERE, HAVING)
-- ============================================

-- Listings in specific price range
SELECT 
    l.id,
    p.type,
    loc.city,
    l.price,
    l.status
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN locations loc ON l.location_id = loc.id
WHERE l.price BETWEEN 500000 AND 1500000
    AND l.status = 'active'
ORDER BY l.price;

-- Cities with more than 1 listing
SELECT 
    loc.city,
    COUNT(l.id) AS listing_count
FROM locations loc
INNER JOIN listings l ON loc.id = l.location_id
GROUP BY loc.city
HAVING COUNT(l.id) > 1;

-- ============================================
-- 6. STRING OPERATIONS
-- ============================================

-- Search properties by description keyword
SELECT 
    id,
    type,
    description
FROM properties
WHERE description LIKE '%bedroom%';

-- Users with email from specific domain
SELECT name, email
FROM users
WHERE email LIKE '%@email.com';

-- Concatenate address details
SELECT 
    id,
    CONCAT(area, ', ', city) AS location_summary,
    address
FROM locations;

-- ============================================
-- 7. DATE/TIME OPERATIONS
-- ============================================

-- Recent listings (last 30 days)
SELECT 
    l.id,
    p.type,
    l.price,
    l.created_at
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
WHERE l.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY l.created_at DESC;

-- Inquiries by month
SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS inquiry_count
FROM inquiries
GROUP BY month
ORDER BY month DESC;

-- ============================================
-- 8. COMPLEX QUERIES WITH MULTIPLE CONCEPTS
-- ============================================

-- Get most favorited listings
SELECT 
    l.id AS listing_id,
    p.type,
    loc.city,
    l.price,
    COUNT(f.listing_id) AS favorite_count
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN locations loc ON l.location_id = loc.id
LEFT JOIN favorites f ON l.id = f.listing_id
GROUP BY l.id, p.type, loc.city, l.price
ORDER BY favorite_count DESC
LIMIT 5;

-- User engagement report
SELECT 
    u.id,
    u.name,
    u.email,
    u.role,
    COUNT(DISTINCT f.listing_id) AS favorites_count,
    COUNT(DISTINCT i.id) AS inquiries_count
FROM users u
LEFT JOIN favorites f ON u.id = f.user_id
LEFT JOIN inquiries i ON u.id = i.user_id
GROUP BY u.id, u.name, u.email, u.role
HAVING favorites_count > 0 OR inquiries_count > 0
ORDER BY (favorites_count + inquiries_count) DESC;

-- Property listing details with inquiry count
SELECT 
    l.id AS listing_id,
    u.name AS owner_name,
    p.type,
    p.description,
    CONCAT(loc.city, ' - ', loc.area) AS location,
    l.price,
    l.status,
    COUNT(DISTINCT pi.id) AS image_count,
    COUNT(DISTINCT f.user_id) AS favorite_count,
    COUNT(DISTINCT i.id) AS inquiry_count
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN users u ON p.owner_id = u.id
INNER JOIN locations loc ON l.location_id = loc.id
LEFT JOIN property_images pi ON l.id = pi.listing_id
LEFT JOIN favorites f ON l.id = f.listing_id
LEFT JOIN inquiries i ON l.id = i.listing_id
GROUP BY l.id, u.name, p.type, p.description, loc.city, loc.area, l.price, l.status
ORDER BY inquiry_count DESC, favorite_count DESC;

-- ============================================
-- 9. UPDATE OPERATIONS
-- ============================================

-- Update listing status
UPDATE listings 
SET status = 'sold' 
WHERE id = 1;

-- Update property description
UPDATE properties 
SET description = CONCAT(description, ' - Recently renovated')
WHERE id = 1;

-- Increase prices by 5% for active listings in New York
UPDATE listings l
INNER JOIN locations loc ON l.location_id = loc.id
SET l.price = l.price * 1.05
WHERE loc.city = 'New York' AND l.status = 'active';

-- ============================================
-- 10. DELETE OPERATIONS
-- ============================================

-- Delete old inactive listings (commented out for safety)
-- DELETE FROM listings 
-- WHERE status = 'inactive' 
-- AND created_at < DATE_SUB(NOW(), INTERVAL 6 MONTH);

-- Remove favorites for sold listings (commented out for safety)
-- DELETE f FROM favorites f
-- INNER JOIN listings l ON f.listing_id = l.id
-- WHERE l.status = 'sold';

-- ============================================
-- 11. CONDITIONAL LOGIC (CASE)
-- ============================================

-- Categorize properties by price range
SELECT 
    l.id,
    p.type,
    l.price,
    CASE 
        WHEN l.price < 500000 THEN 'Budget'
        WHEN l.price BETWEEN 500000 AND 1000000 THEN 'Mid-Range'
        WHEN l.price BETWEEN 1000001 AND 2000000 THEN 'Luxury'
        ELSE 'Ultra-Luxury'
    END AS price_category
FROM listings l
INNER JOIN properties p ON l.property_id = p.id;

-- User activity level
SELECT 
    u.name,
    COUNT(DISTINCT f.listing_id) AS favorites,
    COUNT(DISTINCT i.id) AS inquiries,
    CASE 
        WHEN COUNT(DISTINCT f.listing_id) + COUNT(DISTINCT i.id) >= 5 THEN 'Highly Active'
        WHEN COUNT(DISTINCT f.listing_id) + COUNT(DISTINCT i.id) >= 2 THEN 'Active'
        ELSE 'Low Activity'
    END AS activity_level
FROM users u
LEFT JOIN favorites f ON u.id = f.user_id
LEFT JOIN inquiries i ON u.id = i.user_id
WHERE u.role IN ('buyer')
GROUP BY u.id, u.name;

-- ============================================
-- 12. SET OPERATIONS (UNION)
-- ============================================

-- Get all users who are either sellers or have made inquiries
SELECT DISTINCT u.id, u.name, u.email, 'Seller' AS category
FROM users u
WHERE u.role = 'seller'
UNION
SELECT DISTINCT u.id, u.name, u.email, 'Has Inquiries' AS category
FROM users u
INNER JOIN inquiries i ON u.id = i.user_id;
