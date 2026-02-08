-- ============================================
-- Views and Stored Procedures
-- ============================================
-- Advanced database concepts demonstration

-- ============================================
-- VIEWS
-- ============================================

-- View 1: Active Listings Overview
DROP VIEW IF EXISTS active_listings_view;
CREATE VIEW active_listings_view AS
SELECT 
    l.id AS listing_id,
    u.name AS owner_name,
    u.email AS owner_email,
    p.type AS property_type,
    p.description,
    loc.city,
    loc.area,
    loc.address,
    l.price,
    l.created_at
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN users u ON p.owner_id = u.id
INNER JOIN locations loc ON l.location_id = loc.id
WHERE l.status = 'active';

-- View 2: User Favorites with Details
DROP VIEW IF EXISTS user_favorites_view;
CREATE VIEW user_favorites_view AS
SELECT 
    u.id AS user_id,
    u.name AS user_name,
    u.email,
    l.id AS listing_id,
    p.type AS property_type,
    loc.city,
    l.price,
    f.created_at AS favorited_at
FROM favorites f
INNER JOIN users u ON f.user_id = u.id
INNER JOIN listings l ON f.listing_id = l.id
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN locations loc ON l.location_id = loc.id;

-- View 3: Listing Statistics
DROP VIEW IF EXISTS listing_statistics_view;
CREATE VIEW listing_statistics_view AS
SELECT 
    l.id AS listing_id,
    p.type AS property_type,
    loc.city,
    l.price,
    l.status,
    COUNT(DISTINCT pi.id) AS image_count,
    COUNT(DISTINCT f.user_id) AS favorite_count,
    COUNT(DISTINCT i.id) AS inquiry_count
FROM listings l
INNER JOIN properties p ON l.property_id = p.id
INNER JOIN locations loc ON l.location_id = loc.id
LEFT JOIN property_images pi ON l.id = pi.listing_id
LEFT JOIN favorites f ON l.id = f.listing_id
LEFT JOIN inquiries i ON l.id = i.listing_id
GROUP BY l.id, p.type, loc.city, l.price, l.status;

-- View 4: Seller Performance
DROP VIEW IF EXISTS seller_performance_view;
CREATE VIEW seller_performance_view AS
SELECT 
    u.id AS seller_id,
    u.name AS seller_name,
    u.email,
    COUNT(DISTINCT p.id) AS total_properties,
    COUNT(DISTINCT l.id) AS total_listings,
    COUNT(DISTINCT CASE WHEN l.status = 'active' THEN l.id END) AS active_listings,
    COUNT(DISTINCT CASE WHEN l.status = 'sold' THEN l.id END) AS sold_listings,
    ROUND(AVG(l.price), 2) AS avg_listing_price,
    COUNT(DISTINCT i.id) AS total_inquiries
FROM users u
LEFT JOIN properties p ON u.id = p.owner_id
LEFT JOIN listings l ON p.id = l.property_id
LEFT JOIN inquiries i ON l.id = i.listing_id
WHERE u.role = 'seller'
GROUP BY u.id, u.name, u.email;

-- View 5: City Market Overview
DROP VIEW IF EXISTS city_market_view;
CREATE VIEW city_market_view AS
SELECT 
    loc.city,
    COUNT(DISTINCT l.id) AS total_listings,
    COUNT(DISTINCT CASE WHEN l.status = 'active' THEN l.id END) AS active_listings,
    COUNT(DISTINCT CASE WHEN l.status = 'sold' THEN l.id END) AS sold_listings,
    ROUND(MIN(l.price), 2) AS min_price,
    ROUND(MAX(l.price), 2) AS max_price,
    ROUND(AVG(l.price), 2) AS avg_price,
    COUNT(DISTINCT p.id) AS unique_properties
FROM locations loc
LEFT JOIN listings l ON loc.id = l.location_id
LEFT JOIN properties p ON l.property_id = p.id
GROUP BY loc.city;

-- Usage examples for views:
-- SELECT * FROM active_listings_view;
-- SELECT * FROM user_favorites_view WHERE user_name = 'Emma Johnson';
-- SELECT * FROM listing_statistics_view ORDER BY inquiry_count DESC;
-- SELECT * FROM seller_performance_view ORDER BY total_listings DESC;
-- SELECT * FROM city_market_view ORDER BY avg_price DESC;

-- ============================================
-- STORED PROCEDURES
-- ============================================

-- Procedure 1: Get Listings by Price Range
DROP PROCEDURE IF EXISTS get_listings_by_price_range;
DELIMITER //
CREATE PROCEDURE get_listings_by_price_range(
    IN min_price DECIMAL(15,2),
    IN max_price DECIMAL(15,2)
)
BEGIN
    SELECT 
        l.id AS listing_id,
        p.type AS property_type,
        loc.city,
        loc.area,
        l.price,
        l.status
    FROM listings l
    INNER JOIN properties p ON l.property_id = p.id
    INNER JOIN locations loc ON l.location_id = loc.id
    WHERE l.price BETWEEN min_price AND max_price
    ORDER BY l.price;
END //
DELIMITER ;

-- Procedure 2: Add to Favorites
DROP PROCEDURE IF EXISTS add_to_favorites;
DELIMITER //
CREATE PROCEDURE add_to_favorites(
    IN p_user_id INT,
    IN p_listing_id INT
)
BEGIN
    DECLARE listing_exists INT;
    DECLARE favorite_exists INT;
    
    -- Check if listing exists and is active
    SELECT COUNT(*) INTO listing_exists
    FROM listings
    WHERE id = p_listing_id AND status = 'active';
    
    IF listing_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Listing does not exist or is not active';
    END IF;
    
    -- Check if already favorited
    SELECT COUNT(*) INTO favorite_exists
    FROM favorites
    WHERE user_id = p_user_id AND listing_id = p_listing_id;
    
    IF favorite_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Listing already in favorites';
    END IF;
    
    -- Add to favorites
    INSERT INTO favorites (user_id, listing_id)
    VALUES (p_user_id, p_listing_id);
    
    SELECT 'Listing added to favorites successfully' AS message;
END //
DELIMITER ;

-- Procedure 3: Create New Inquiry
DROP PROCEDURE IF EXISTS create_inquiry;
DELIMITER //
CREATE PROCEDURE create_inquiry(
    IN p_user_id INT,
    IN p_listing_id INT,
    IN p_message TEXT
)
BEGIN
    DECLARE listing_active INT;
    
    -- Check if listing is active
    SELECT COUNT(*) INTO listing_active
    FROM listings
    WHERE id = p_listing_id AND status = 'active';
    
    IF listing_active = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Listing is not available for inquiries';
    END IF;
    
    -- Insert inquiry
    INSERT INTO inquiries (user_id, listing_id, message)
    VALUES (p_user_id, p_listing_id, p_message);
    
    SELECT LAST_INSERT_ID() AS inquiry_id, 
           'Inquiry created successfully' AS message;
END //
DELIMITER ;

-- Procedure 4: Update Listing Status
DROP PROCEDURE IF EXISTS update_listing_status;
DELIMITER //
CREATE PROCEDURE update_listing_status(
    IN p_listing_id INT,
    IN p_new_status VARCHAR(20)
)
BEGIN
    DECLARE listing_exists INT;
    
    -- Validate status
    IF p_new_status NOT IN ('active', 'sold', 'pending', 'inactive') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid status value';
    END IF;
    
    -- Check if listing exists
    SELECT COUNT(*) INTO listing_exists
    FROM listings
    WHERE id = p_listing_id;
    
    IF listing_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Listing does not exist';
    END IF;
    
    -- Update status
    UPDATE listings
    SET status = p_new_status
    WHERE id = p_listing_id;
    
    SELECT 'Listing status updated successfully' AS message;
END //
DELIMITER ;

-- Procedure 5: Get User Activity Report
DROP PROCEDURE IF EXISTS get_user_activity_report;
DELIMITER //
CREATE PROCEDURE get_user_activity_report(
    IN p_user_id INT
)
BEGIN
    SELECT 
        u.id,
        u.name,
        u.email,
        u.role,
        (SELECT COUNT(*) FROM favorites WHERE user_id = p_user_id) AS total_favorites,
        (SELECT COUNT(*) FROM inquiries WHERE user_id = p_user_id) AS total_inquiries,
        (SELECT COUNT(*) FROM properties WHERE owner_id = p_user_id) AS total_properties,
        u.created_at AS member_since
    FROM users u
    WHERE u.id = p_user_id;
    
    -- Recent favorites
    SELECT 
        'Recent Favorites' AS report_section,
        l.id AS listing_id,
        p.type AS property_type,
        loc.city,
        l.price,
        f.created_at
    FROM favorites f
    INNER JOIN listings l ON f.listing_id = l.id
    INNER JOIN properties p ON l.property_id = p.id
    INNER JOIN locations loc ON l.location_id = loc.id
    WHERE f.user_id = p_user_id
    ORDER BY f.created_at DESC
    LIMIT 5;
    
    -- Recent inquiries
    SELECT 
        'Recent Inquiries' AS report_section,
        i.id AS inquiry_id,
        l.id AS listing_id,
        p.type AS property_type,
        SUBSTRING(i.message, 1, 50) AS message_preview,
        i.created_at
    FROM inquiries i
    INNER JOIN listings l ON i.listing_id = l.id
    INNER JOIN properties p ON l.property_id = p.id
    WHERE i.user_id = p_user_id
    ORDER BY i.created_at DESC
    LIMIT 5;
END //
DELIMITER ;

-- Procedure 6: Search Listings
DROP PROCEDURE IF EXISTS search_listings;
DELIMITER //
CREATE PROCEDURE search_listings(
    IN p_city VARCHAR(100),
    IN p_property_type VARCHAR(50),
    IN p_min_price DECIMAL(15,2),
    IN p_max_price DECIMAL(15,2)
)
BEGIN
    SELECT 
        l.id AS listing_id,
        p.type AS property_type,
        p.description,
        loc.city,
        loc.area,
        loc.address,
        l.price,
        l.status,
        COUNT(DISTINCT pi.id) AS image_count
    FROM listings l
    INNER JOIN properties p ON l.property_id = p.id
    INNER JOIN locations loc ON l.location_id = loc.id
    LEFT JOIN property_images pi ON l.id = pi.listing_id
    WHERE 
        (p_city IS NULL OR loc.city = p_city)
        AND (p_property_type IS NULL OR p.type = p_property_type)
        AND (p_min_price IS NULL OR l.price >= p_min_price)
        AND (p_max_price IS NULL OR l.price <= p_max_price)
        AND l.status = 'active'
    GROUP BY l.id, p.type, p.description, loc.city, loc.area, loc.address, l.price, l.status
    ORDER BY l.price;
END //
DELIMITER ;

-- ============================================
-- Usage Examples for Stored Procedures:
-- ============================================

-- CALL get_listings_by_price_range(500000, 1000000);
-- CALL add_to_favorites(2, 1);
-- CALL create_inquiry(2, 1, 'I am interested in scheduling a viewing.');
-- CALL update_listing_status(1, 'sold');
-- CALL get_user_activity_report(2);
-- CALL search_listings('New York', 'Apartment', 500000, 1000000);
-- CALL search_listings(NULL, 'House', NULL, NULL); -- Search all houses
