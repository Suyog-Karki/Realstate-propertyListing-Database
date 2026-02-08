-- ============================================
-- Triggers and Additional Constraints
-- ============================================
-- Demonstrates triggers for business logic and data integrity

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger 1: Log property updates (requires audit table)
DROP TABLE IF EXISTS property_audit_log;
CREATE TABLE property_audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    action VARCHAR(20) NOT NULL,
    old_description TEXT,
    new_description TEXT,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_property_id (property_id),
    INDEX idx_changed_at (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TRIGGER IF EXISTS property_update_audit;
DELIMITER //
CREATE TRIGGER property_update_audit
AFTER UPDATE ON properties
FOR EACH ROW
BEGIN
    IF OLD.description != NEW.description THEN
        INSERT INTO property_audit_log (
            property_id, 
            action, 
            old_description, 
            new_description,
            changed_by
        )
        VALUES (
            NEW.id, 
            'UPDATE', 
            OLD.description, 
            NEW.description,
            USER()
        );
    END IF;
END //
DELIMITER ;

-- Trigger 2: Auto-update listing status when property is sold
DROP TRIGGER IF EXISTS check_listing_status_before_favorite;
DELIMITER //
CREATE TRIGGER check_listing_status_before_favorite
BEFORE INSERT ON favorites
FOR EACH ROW
BEGIN
    DECLARE listing_status VARCHAR(20);
    
    SELECT status INTO listing_status
    FROM listings
    WHERE id = NEW.listing_id;
    
    IF listing_status != 'active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot favorite a non-active listing';
    END IF;
END //
DELIMITER ;

-- Trigger 3: Prevent deletion of users with active listings
DROP TRIGGER IF EXISTS prevent_user_deletion_with_active_listings;
DELIMITER //
CREATE TRIGGER prevent_user_deletion_with_active_listings
BEFORE DELETE ON users
FOR EACH ROW
BEGIN
    DECLARE active_listing_count INT;
    
    SELECT COUNT(*) INTO active_listing_count
    FROM properties p
    INNER JOIN listings l ON p.id = l.property_id
    WHERE p.owner_id = OLD.id AND l.status = 'active';
    
    IF active_listing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete user with active listings';
    END IF;
END //
DELIMITER ;

-- Trigger 4: Timestamp update tracking
DROP TABLE IF EXISTS listing_status_history;
CREATE TABLE listing_status_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    listing_id INT NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    INDEX idx_listing_id (listing_id),
    INDEX idx_changed_at (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TRIGGER IF EXISTS track_listing_status_changes;
DELIMITER //
CREATE TRIGGER track_listing_status_changes
AFTER UPDATE ON listings
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO listing_status_history (
            listing_id,
            old_status,
            new_status
        )
        VALUES (
            NEW.id,
            OLD.status,
            NEW.status
        );
    END IF;
END //
DELIMITER ;

-- Trigger 5: Validate price on listing insert/update
DROP TRIGGER IF EXISTS validate_listing_price_insert;
DELIMITER //
CREATE TRIGGER validate_listing_price_insert
BEFORE INSERT ON listings
FOR EACH ROW
BEGIN
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Listing price must be greater than 0';
    END IF;
    
    IF NEW.price > 100000000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Listing price exceeds maximum allowed value';
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS validate_listing_price_update;
DELIMITER //
CREATE TRIGGER validate_listing_price_update
BEFORE UPDATE ON listings
FOR EACH ROW
BEGIN
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Listing price must be greater than 0';
    END IF;
    
    IF NEW.price > 100000000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Listing price exceeds maximum allowed value';
    END IF;
END //
DELIMITER ;

-- Trigger 6: Auto-remove favorites when listing is sold
DROP TRIGGER IF EXISTS auto_remove_favorites_on_sold;
DELIMITER //
CREATE TRIGGER auto_remove_favorites_on_sold
AFTER UPDATE ON listings
FOR EACH ROW
BEGIN
    IF NEW.status = 'sold' AND OLD.status != 'sold' THEN
        -- Note: In practice, you might want to keep favorites for reference
        -- This trigger is for demonstration purposes
        DELETE FROM favorites WHERE listing_id = NEW.id;
    END IF;
END //
DELIMITER ;

-- ============================================
-- ADDITIONAL CONSTRAINTS AND CHECKS
-- ============================================

-- Add check constraints (MySQL 8.0.16+)
-- Note: These can also be added in the main schema file

-- Ensure non-empty strings
ALTER TABLE users 
ADD CONSTRAINT chk_user_name_not_empty 
CHECK (CHAR_LENGTH(TRIM(name)) > 0);

ALTER TABLE users 
ADD CONSTRAINT chk_user_email_format 
CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$');

-- Ensure valid property types
ALTER TABLE properties 
ADD CONSTRAINT chk_property_type_valid 
CHECK (type IN ('Apartment', 'House', 'Condo', 'Townhouse', 'Studio', 'Villa', 'Penthouse'));

-- ============================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================
-- Note: Many indexes are already created in schema.sql
-- These are additional indexes for specific query patterns

-- Composite index for price range queries with status
CREATE INDEX idx_listings_status_price ON listings(status, price);

-- Full-text index for property descriptions (if supported)
-- ALTER TABLE properties ADD FULLTEXT idx_description_fulltext (description);

-- Index for location-based searches
CREATE INDEX idx_locations_city_area ON locations(city, area);

-- Index for date-based queries
CREATE INDEX idx_inquiries_created_user ON inquiries(created_at, user_id);
CREATE INDEX idx_favorites_created_user ON favorites(created_at, user_id);

-- ============================================
-- DEMONSTRATION QUERIES
-- ============================================

-- Test trigger 1: Update a property description
-- UPDATE properties SET description = 'Updated luxury apartment' WHERE id = 1;
-- SELECT * FROM property_audit_log;

-- Test trigger 2: Try to favorite a sold listing (should fail)
-- UPDATE listings SET status = 'sold' WHERE id = 1;
-- INSERT INTO favorites (user_id, listing_id) VALUES (5, 1);

-- Test trigger 4: Change listing status
-- UPDATE listings SET status = 'pending' WHERE id = 2;
-- SELECT * FROM listing_status_history;

-- Test trigger 5: Try to insert invalid price (should fail)
-- INSERT INTO listings (property_id, location_id, price, status) 
-- VALUES (1, 1, -1000, 'active');

-- View audit logs
-- SELECT * FROM property_audit_log ORDER BY changed_at DESC;
-- SELECT * FROM listing_status_history ORDER BY changed_at DESC;
