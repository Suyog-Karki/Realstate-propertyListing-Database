-- ============================================
-- Advanced Concepts - Transactions & Indexing
-- ============================================
-- Demonstrates transaction management and index optimization

-- ============================================
-- TRANSACTION EXAMPLES
-- ============================================

-- Transaction 1: Create a complete listing (property + listing)
DELIMITER //
DROP PROCEDURE IF EXISTS create_complete_listing//
CREATE PROCEDURE create_complete_listing(
    IN p_owner_id INT,
    IN p_property_type VARCHAR(50),
    IN p_description TEXT,
    IN p_city VARCHAR(100),
    IN p_area VARCHAR(100),
    IN p_address TEXT,
    IN p_price DECIMAL(15,2),
    OUT p_listing_id INT
)
BEGIN
    DECLARE v_property_id INT;
    DECLARE v_location_id INT;
    DECLARE v_listing_id INT;
    
    -- Handle errors
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_listing_id = -1;
        SELECT 'Transaction failed! Rolling back changes.' AS Error;
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Check if location exists, if not create it
    SELECT id INTO v_location_id
    FROM locations
    WHERE city = p_city AND area = p_area AND address = p_address
    LIMIT 1;
    
    IF v_location_id IS NULL THEN
        INSERT INTO locations (city, area, address)
        VALUES (p_city, p_area, p_address);
        SET v_location_id = LAST_INSERT_ID();
    END IF;
    
    -- Create property
    INSERT INTO properties (owner_id, type, description)
    VALUES (p_owner_id, p_property_type, p_description);
    SET v_property_id = LAST_INSERT_ID();
    
    -- Create listing
    INSERT INTO listings (property_id, location_id, price, status)
    VALUES (v_property_id, v_location_id, p_price, 'active');
    SET v_listing_id = LAST_INSERT_ID();
    
    -- Commit transaction
    COMMIT;
    
    SET p_listing_id = v_listing_id;
    SELECT 'Listing created successfully!' AS Success, v_listing_id AS listing_id;
END//
DELIMITER ;

-- Transaction 2: Transfer property ownership
DELIMITER //
DROP PROCEDURE IF EXISTS transfer_property_ownership//
CREATE PROCEDURE transfer_property_ownership(
    IN p_property_id INT,
    IN p_new_owner_id INT,
    IN p_update_price DECIMAL(15,2)
)
BEGIN
    DECLARE v_old_owner_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transfer failed! Transaction rolled back.' AS Error;
    END;
    
    START TRANSACTION;
    
    -- Get old owner
    SELECT owner_id INTO v_old_owner_id
    FROM properties
    WHERE id = p_property_id;
    
    -- Update property owner
    UPDATE properties
    SET owner_id = p_new_owner_id
    WHERE id = p_property_id;
    
    -- Update all active listings for this property to sold
    UPDATE listings
    SET status = 'sold'
    WHERE property_id = p_property_id AND status = 'active';
    
    -- Create new listing with new price
    INSERT INTO listings (property_id, location_id, price, status)
    SELECT p_property_id, location_id, p_update_price, 'active'
    FROM listings
    WHERE property_id = p_property_id
    LIMIT 1;
    
    COMMIT;
    
    SELECT 'Property transferred successfully!' AS Success,
           v_old_owner_id AS old_owner,
           p_new_owner_id AS new_owner;
END//
DELIMITER ;

-- Transaction 3: Batch update listing prices
DELIMITER //
DROP PROCEDURE IF EXISTS batch_update_prices//
CREATE PROCEDURE batch_update_prices(
    IN p_city VARCHAR(100),
    IN p_increase_percentage DECIMAL(5,2)
)
BEGIN
    DECLARE v_affected_rows INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Price update failed! Transaction rolled back.' AS Error;
    END;
    
    START TRANSACTION;
    
    -- Update prices for all active listings in specified city
    UPDATE listings l
    INNER JOIN locations loc ON l.location_id = loc.id
    SET l.price = l.price * (1 + p_increase_percentage / 100)
    WHERE loc.city = p_city AND l.status = 'active';
    
    SET v_affected_rows = ROW_COUNT();
    
    COMMIT;
    
    SELECT CONCAT('Successfully updated ', v_affected_rows, ' listings in ', p_city) AS Success;
END//
DELIMITER ;

-- ============================================
-- INDEX OPTIMIZATION EXAMPLES
-- ============================================

-- Show current indexes
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS COLUMNS,
    INDEX_TYPE,
    NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'property_listing_db'
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY TABLE_NAME, INDEX_NAME;

-- ============================================
-- QUERY OPTIMIZATION EXAMPLES
-- ============================================

-- Example 1: Before optimization (without proper index)
-- This query might be slow on large datasets
EXPLAIN SELECT * FROM listings 
WHERE price > 500000 AND status = 'active';

-- After creating composite index (already in schema.sql):
-- CREATE INDEX idx_listings_status_price ON listings(status, price);
-- The same query will be much faster

-- Example 2: Subquery optimization
-- Inefficient subquery
EXPLAIN SELECT * FROM users u
WHERE u.id IN (
    SELECT DISTINCT user_id FROM favorites
);

-- More efficient with JOIN
EXPLAIN SELECT DISTINCT u.* FROM users u
INNER JOIN favorites f ON u.id = f.user_id;

-- ============================================
-- PERFORMANCE ANALYSIS
-- ============================================

-- Analyze table to update statistics
ANALYZE TABLE listings;
ANALYZE TABLE properties;
ANALYZE TABLE users;

-- Check table statistics
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH,
    INDEX_LENGTH,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) AS data_size_mb,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS index_size_mb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'property_listing_db'
ORDER BY DATA_LENGTH DESC;

-- ============================================
-- LOCKING EXAMPLES (for demonstration)
-- ============================================

-- Read lock (shared lock)
-- LOCK TABLES listings READ;
-- SELECT * FROM listings WHERE id = 1;
-- UNLOCK TABLES;

-- Write lock (exclusive lock)
-- LOCK TABLES listings WRITE;
-- UPDATE listings SET price = 900000 WHERE id = 1;
-- UNLOCK TABLES;

-- ============================================
-- USAGE EXAMPLES
-- ============================================

-- Example 1: Create complete listing
/*
CALL create_complete_listing(
    1,                                      -- owner_id
    'Apartment',                            -- property_type
    'Beautiful 3-bedroom apartment',        -- description
    'Boston',                               -- city
    'Beacon Hill',                          -- area
    '123 Charles Street',                   -- address
    1200000.00,                            -- price
    @new_listing_id                        -- output parameter
);
SELECT @new_listing_id;
*/

-- Example 2: Transfer property
/*
CALL transfer_property_ownership(
    1,              -- property_id
    4,              -- new_owner_id
    950000.00       -- new_price
);
*/

-- Example 3: Batch price update
/*
CALL batch_update_prices('New York', 5.0);  -- Increase by 5%
*/

-- ============================================
-- ACID PROPERTIES DEMONSTRATION
-- ============================================

/*
ACID Properties in our transactions:

1. ATOMICITY: All operations succeed or all fail
   - See create_complete_listing procedure
   - If any step fails, entire transaction rolls back

2. CONSISTENCY: Database maintains valid state
   - Foreign key constraints ensure referential integrity
   - Check constraints validate data before insertion

3. ISOLATION: Concurrent transactions don't interfere
   - MySQL default isolation level: REPEATABLE READ
   - Can be changed with SET TRANSACTION ISOLATION LEVEL

4. DURABILITY: Committed data persists
   - Once COMMIT succeeds, data is permanently stored
   - Survives system crashes
*/

-- Show current isolation level
SELECT @@transaction_isolation;

-- ============================================
-- DEADLOCK PREVENTION TIPS
-- ============================================

/*
Best practices to avoid deadlocks:

1. Access tables in consistent order
2. Keep transactions short
3. Use appropriate isolation levels
4. Acquire locks in the same order
5. Use indexes to reduce lock scope
6. Consider using row-level locking

Example of potential deadlock scenario:
Transaction A: Lock listings, then properties
Transaction B: Lock properties, then listings
(Can create circular wait)

Solution: Both should lock in same order
*/
