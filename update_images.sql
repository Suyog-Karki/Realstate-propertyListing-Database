-- ==================================================
-- Update Property Images with Real URLs
-- ==================================================
-- These images are from public stock photo services (Unsplash, Pexels)
-- showing Nepalese-style houses and properties

TRUNCATE TABLE property_images;

-- Insert images for Kathmandu Apartment (Listing 1)
INSERT INTO property_images (listing_id, image_url) VALUES
(1, 'https://images.unsplash.com/photo-1570129477492-45e003008e0c?w=600&h=400&fit=crop'),
(1, 'https://images.unsplash.com/photo-1560584018-9ffb8a6a4ac5?w=600&h=400&fit=crop'),
(1, 'https://images.unsplash.com/photo-1542896917-0f49a5d8b10e?w=600&h=400&fit=crop');

-- Insert images for Pokhara House (Listing 2)
INSERT INTO property_images (listing_id, image_url) VALUES
(2, 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=600&h=400&fit=crop'),
(2, 'https://images.unsplash.com/photo-1580587771525-78991c1a370d?w=600&h=400&fit=crop'),
(2, 'https://images.unsplash.com/photo-1516455207990-7a41e1d4ffd5?w=600&h=400&fit=crop');

-- Insert images for Lalitpur Condo (Listing 3)
INSERT INTO property_images (listing_id, image_url) VALUES
(3, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop'),
(3, 'https://images.unsplash.com/photo-1576369915855-91271f62f1d4?w=600&h=400&fit=crop');

-- Insert images for Bhaktapur Townhouse (Listing 4)
INSERT INTO property_images (listing_id, image_url) VALUES
(4, 'https://images.unsplash.com/photo-1493857671505-72967e2e2760?w=600&h=400&fit=crop'),
(4, 'https://images.unsplash.com/photo-1570129477492-45e003008e0c?w=600&h=400&fit=crop');

-- Insert images for Janakpur Apartment (Listing 5)
INSERT INTO property_images (listing_id, image_url) VALUES
(5, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=600&h=400&fit=crop');

-- Insert images for Biratnagar House (Listing 6)
INSERT INTO property_images (listing_id, image_url) VALUES
(6, 'https://images.unsplash.com/photo-1579738840235-e5c89f50bc38?w=600&h=400&fit=crop'),
(6, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop'),
(6, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop');

-- Insert images for Dharan Condo (Listing 7)
INSERT INTO property_images (listing_id, image_url) VALUES
(7, 'https://images.unsplash.com/photo-1512207736139-feed7b36ae91?w=600&h=400&fit=crop');

-- Insert images for Bharatpur Apartment (Listing 8)
INSERT INTO property_images (listing_id, image_url) VALUES
(8, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=600&h=400&fit=crop');

-- Insert images for Hetauda House (Listing 9)
INSERT INTO property_images (listing_id, image_url) VALUES
(9, 'https://images.unsplash.com/photo-1570129477492-45e003008e0c?w=600&h=400&fit=crop');

-- Insert images for Gulmi Townhouse (Listing 10)
INSERT INTO property_images (listing_id, image_url) VALUES
(10, 'https://images.unsplash.com/photo-1493857671505-72967e2e2760?w=600&h=400&fit=crop');

-- Verify all images were inserted
SELECT listing_id, COUNT(*) AS image_count FROM property_images GROUP BY listing_id ORDER BY listing_id;
