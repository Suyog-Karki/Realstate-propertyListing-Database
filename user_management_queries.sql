-- ============================================
-- USER & AUTHENTICATION MANAGEMENT QUERIES
-- ============================================
-- This file contains useful SQL queries for managing users
-- Use these for admin tasks and troubleshooting

-- ============================================
-- VIEW ALL USERS
-- ============================================
SELECT id, name, email, phone, address, role, is_active, created_at, updated_at 
FROM users 
ORDER BY created_at DESC;

-- ============================================
-- VIEW USERS BY ROLE
-- ============================================

-- View all admins
SELECT id, name, email, role, is_active FROM users WHERE role = 'admin';

-- View all sellers
SELECT id, name, email, phone, role, is_active FROM users WHERE role = 'seller' ORDER BY created_at DESC;

-- View all buyers
SELECT id, name, email, phone, role, is_active FROM users WHERE role = 'buyer' ORDER BY created_at DESC;

-- View all agents
SELECT id, name, email, phone, role, is_active FROM users WHERE role = 'agent' ORDER BY created_at DESC;

-- ============================================
-- VIEW ACTIVE & INACTIVE USERS
-- ============================================

-- Active users only
SELECT id, name, email, role, created_at 
FROM users 
WHERE is_active = TRUE 
ORDER BY created_at DESC;

-- Inactive users
SELECT id, name, email, role, created_at 
FROM users 
WHERE is_active = FALSE 
ORDER BY created_at DESC;

-- ============================================
-- VIEW USER STATISTICS
-- ============================================

-- User count by role
SELECT 
    role,
    COUNT(*) as total,
    SUM(IF(is_active = TRUE, 1, 0)) as active,
    SUM(IF(is_active = FALSE, 1, 0)) as inactive
FROM users 
GROUP BY role;

-- Total users
SELECT COUNT(*) as total_users FROM users;

-- Active users
SELECT COUNT(*) as active_users FROM users WHERE is_active = TRUE;

-- ============================================
-- SELLER ACTIVITIES
-- ============================================

-- Sellers with property count
SELECT 
    u.id,
    u.name,
    u.email,
    COUNT(p.id) as total_properties,
    COUNT(DISTINCT l.id) as active_listings
FROM users u
LEFT JOIN properties p ON u.id = p.owner_id
LEFT JOIN listings l ON p.id = l.property_id AND l.status = 'active'
WHERE u.role = 'seller'
GROUP BY u.id, u.name, u.email
ORDER BY active_listings DESC;

-- Listings by specific seller
SELECT u.name as seller, 
       p.type as property_type,
       l.price,
       l.status,
       loc.city,
       loc.area,
       l.created_at
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN users u ON p.owner_id = u.id
WHERE u.id = 1  -- Change 1 to seller's user ID
ORDER BY l.created_at DESC;

-- ============================================
-- BUYER ACTIVITIES
-- ============================================

-- Buyers with favorite count
SELECT 
    u.id,
    u.name,
    u.email,
    COUNT(f.listing_id) as favorites_count,
    COUNT(DISTINCT i.id) as inquiries_sent
FROM users u
LEFT JOIN favorites f ON u.id = f.user_id
LEFT JOIN inquiries i ON u.id = i.user_id
WHERE u.role = 'buyer'
GROUP BY u.id, u.name, u.email
ORDER BY favorites_count DESC;

-- User's favorite properties
SELECT 
    u.name as buyer,
    p.type as property_type,
    l.price,
    loc.city,
    loc.area,
    f.created_at as favorited_at
FROM favorites f
INNER JOIN users u ON f.user_id = u.id
INNER JOIN listings l ON f.listing_id = l.id
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN locations loc ON l.location_id = loc.id
WHERE u.id = 2  -- Change 2 to buyer's user ID
ORDER BY f.created_at DESC;

-- User's inquiries
SELECT 
    u.name as buyer,
    p.type as property_type,
    l.price,
    loc.city,
    i.message,
    i.created_at
FROM inquiries i
INNER JOIN users u ON i.user_id = u.id
INNER JOIN listings l ON i.listing_id = l.id
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN locations loc ON l.location_id = loc.id
WHERE u.id = 2  -- Change 2 to buyer's user ID
ORDER BY i.created_at DESC;

-- ============================================
-- UPDATE USER INFORMATION
-- ============================================

-- Update user phone and address
UPDATE users 
SET phone = '9841234567', 
    address = 'New Address, Kathmandu',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1;

-- Change user role (Admin to Seller)
UPDATE users 
SET role = 'seller',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1;

-- Deactivate user account
UPDATE users 
SET is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1;

-- Reactivate user account
UPDATE users 
SET is_active = TRUE,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1;

-- ============================================
-- DELETE USER (Use with caution)
-- ============================================

-- Delete user and all related data (cascading)
-- This will delete: user, their properties, listings, favorites, inquiries
DELETE FROM users WHERE id = 1;

-- ============================================
-- USER VERIFICATION QUERIES
-- ============================================

-- Check if email exists
SELECT id, name, email, role 
FROM users 
WHERE email = 'admin@propertylisting.com';

-- Find user by name
SELECT id, name, email, role, phone, address 
FROM users 
WHERE name LIKE '%admin%'  -- Search for name containing 'admin'
ORDER BY name;

-- Get user with all details
SELECT 
    u.*,
    COUNT(DISTINCT p.id) as properties_owned,
    COUNT(DISTINCT l.id) as listings_active,
    COUNT(DISTINCT f.user_id) as favorites_count,
    COUNT(DISTINCT i.id) as inquiries_sent
FROM users u
LEFT JOIN properties p ON u.id = p.owner_id
LEFT JOIN listings l ON p.id = l.property_id AND l.status = 'active'
LEFT JOIN favorites f ON u.id = f.user_id
LEFT JOIN inquiries i ON u.id = i.user_id
WHERE u.id = 1  -- Change ID to check specific user
GROUP BY u.id;

-- ============================================
-- PASSWORD VERIFICATION (for debugging)
-- ============================================

-- View password hash (for verification only)
SELECT id, name, email, password, role 
FROM users 
WHERE email = 'admin@propertylisting.com';

-- NOTE: Password is bcrypt hashed and cannot be reversed
-- If user forgets password, admin should reset it using backend API

-- ============================================
-- RECENT ACTIVITIES
-- ============================================

-- Users joined in last 7 days
SELECT id, name, email, role, created_at 
FROM users 
WHERE created_at >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 7 DAY)
ORDER BY created_at DESC;

-- Recent inquiries received
SELECT 
    u.name as inquirer,
    seller.name as seller,
    p.type as property,
    loc.city,
    i.message,
    i.created_at
FROM inquiries i
INNER JOIN users u ON i.user_id = u.id
INNER JOIN listings l ON i.listing_id = l.id
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN users seller ON p.owner_id = seller.id
INNER JOIN locations loc ON l.location_id = loc.id
WHERE i.created_at >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 7 DAY)
ORDER BY i.created_at DESC;

-- Recent favorites
SELECT 
    u.name as user,
    p.type as property_type,
    l.price,
    loc.city,
    f.created_at
FROM favorites f
INNER JOIN users u ON f.user_id = u.id
INNER JOIN listings l ON f.listing_id = l.id
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN locations loc ON l.location_id = loc.id
WHERE f.created_at >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 7 DAY)
ORDER BY f.created_at DESC;

-- ============================================
-- CONTACT INFORMATION
-- ============================================

-- Get seller contact info
SELECT 
    u.id,
    u.name as seller_name,
    u.email as seller_email,
    u.phone as seller_phone,
    u.address,
    COUNT(DISTINCT l.id) as active_listings
FROM users u
LEFT JOIN properties p ON u.id = p.owner_id
LEFT JOIN listings l ON p.id = l.property_id AND l.status = 'active'
WHERE u.role = 'seller'
GROUP BY u.id, u.name, u.email, u.phone, u.address
ORDER BY active_listings DESC;

-- Get admin contact info (if needed for support)
SELECT 
    id,
    name,
    email,
    phone,
    address
FROM users 
WHERE role = 'admin'
ORDER BY created_at;

-- ============================================
-- USEFUL ADMIN TASKS
-- ============================================

-- Count inquiries per seller
SELECT 
    seller.name as seller,
    COUNT(i.id) as total_inquiries
FROM inquiries i
INNER JOIN listings l ON i.listing_id = l.id
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN users seller ON p.owner_id = seller.id
GROUP BY seller.id, seller.name
ORDER BY total_inquiries DESC;

-- Most favorited properties
SELECT 
    p.type as property_type,
    l.price,
    loc.city,
    u.name as seller,
    COUNT(f.user_id) as favorite_count
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN users u ON p.owner_id = u.id
INNER JOIN locations loc ON l.location_id = loc.id
LEFT JOIN favorites f ON l.id = f.listing_id
WHERE l.status = 'active'
GROUP BY l.id, p.type, l.price, loc.city, u.name
ORDER BY favorite_count DESC
LIMIT 10;

-- Generate user report
SELECT 
    u.id,
    u.name,
    u.email,
    u.role,
    u.is_active,
    u.phone,
    u.address,
    u.created_at,
    u.updated_at,
    COUNT(DISTINCT CASE WHEN p.owner_id = u.id THEN p.id END) as properties,
    COUNT(DISTINCT CASE WHEN f.user_id = u.id THEN f.listing_id END) as favorites,
    COUNT(DISTINCT CASE WHEN i.user_id = u.id THEN i.id END) as inquiries_sent
FROM users u
LEFT JOIN properties p ON u.id = p.owner_id
LEFT JOIN favorites f ON u.id = f.user_id
LEFT JOIN inquiries i ON u.id = i.user_id
GROUP BY u.id, u.name, u.email, u.role, u.is_active, u.phone, u.address, u.created_at, u.updated_at
ORDER BY u.created_at DESC;

-- ============================================
-- NOTE: Use these queries with phpMyAdmin or MySQL CLI
-- Example:
-- mysql -u root -p'password' property_listing_db < user_management_queries.sql
-- Or copy-paste individual queries into MySQL client
-- ============================================
