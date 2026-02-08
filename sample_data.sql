-- ============================================
-- Sample Data for Property Listing Database - Nepal
-- ============================================
-- This file contains sample data to populate the database
-- Currency: Nepalese Rupee (NPR)
-- Locations: Nepal
-- Users are already loaded from auth_setup.sql

-- Insert Locations
INSERT INTO locations (city, area, address) VALUES
('Kathmandu', 'Thamel', '123 Durbar Marg, Apt 5B'),
('Pokhara', 'Lakeside', '456 Phewa Lake Road'),
('Lalitpur', 'Patan', '789 Mangal Bazaar, Suite 12'),
('Bhaktapur', 'Durbar Square', '321 Tachupal Tole'),
('Janakpur', 'Ram Navami Road', '654 Janaki Mandir Area'),
('Biratnagar', 'Main Road', '987 Commercial Area'),
('Dharan', 'Bazaar Area', '147 Hospital Road'),
('Bharatpur', 'City Center', '258 Narayanghat Road'),
('Hetauda', 'Main Bazaar', '369 Industrial Area'),
('Gulmi', 'Ridi Area', '741 District Center'),
('Kathmandu', 'Bhaktapur', '852 Changunarayan'),
('Pokhara', 'Damauli', '963 Siddhartha Highway');

-- Insert Properties
-- Using seller IDs: 2=Raj Kumar, 3=Neeta Verma, 4=Jennifer Malla
INSERT INTO properties (owner_id, type, description) VALUES
(2, 'Apartment', 'Modern 2-bedroom apartment with city views'),
(4, 'House', 'Luxury 4-bedroom house with pool'),
(3, 'Condo', 'Cozy 1-bedroom condo near public transit'),
(2, 'Townhouse', '3-bedroom townhouse with garage'),
(4, 'Apartment', 'Studio apartment in downtown area'),
(3, 'House', 'Spacious 5-bedroom family home'),
(2, 'Condo', '2-bedroom condo with mountain views'),
(4, 'Apartment', 'Penthouse apartment with rooftop access'),
(3, 'House', 'Victorian-style 3-bedroom house'),
(2, 'Townhouse', '2-bedroom townhouse with backyard');

-- Insert Listings
INSERT INTO listings (property_id, location_id, price, status) VALUES
(1, 1, 11050000.00, 'active'),
(2, 2, 32500000.00, 'active'),
(3, 3, 5525000.00, 'active'),
(4, 4, 15600000.00, 'pending'),
(5, 5, 4875000.00, 'active'),
(6, 6, 23400000.00, 'active'),
(7, 7, 12350000.00, 'sold'),
(8, 8, 19500000.00, 'active'),
(9, 9, 9425000.00, 'active'),
(10, 10, 11375000.00, 'inactive');

-- Insert Favorites
-- Using buyer IDs: 5=Priya Sharma, 6=Vijay Singh, 7=Rohindra, 8=Dipak
INSERT INTO favorites (user_id, listing_id) VALUES
(5, 1),
(5, 3),
(5, 5),
(6, 1),
(6, 2),
(6, 6),
(7, 3),
(7, 8),
(8, 1),
(8, 2),
(8, 4),
(8, 6);

-- Insert Inquiries
-- Using buyer IDs: 5=Priya Sharma, 6=Vijay Singh, 7=Rohindra, 8=Dipak
INSERT INTO inquiries (user_id, listing_id, message) VALUES
(5, 1, 'Is this apartment pet-friendly? I have a small dog.'),
(6, 2, 'Can I schedule a viewing for this weekend?'),
(7, 3, 'What are the monthly HOA fees for this condo?'),
(5, 5, 'Is the apartment furnished or unfurnished?'),
(8, 1, 'Are utilities included in the price?'),
(6, 6, 'Does the house have a finished basement?'),
(8, 4, 'What year was this townhouse built?'),
(5, 3, 'Is parking available? If so, how many spaces?'),
(7, 8, 'Are the kitchen appliances included with the purchase?'),
(6, 2, 'I am very interested. Can we discuss financing options?');

-- Insert Property Images
INSERT INTO property_images (listing_id, image_url) VALUES
(1, 'https://picsum.photos/300/200?random=1'),
(1, 'https://picsum.photos/300/200?random=2'),
(1, 'https://picsum.photos/300/200?random=3'),
(2, 'https://picsum.photos/300/200?random=4'),
(2, 'https://picsum.photos/300/200?random=5'),
(2, 'https://picsum.photos/300/200?random=6'),
(3, 'https://picsum.photos/300/200?random=7'),
(3, 'https://picsum.photos/300/200?random=8'),
(4, 'https://picsum.photos/300/200?random=9'),
(4, 'https://picsum.photos/300/200?random=10'),
(5, 'https://picsum.photos/300/200?random=11'),
(6, 'https://picsum.photos/300/200?random=12'),
(6, 'https://picsum.photos/300/200?random=13'),
(6, 'https://picsum.photos/300/200?random=14'),
(7, 'https://picsum.photos/300/200?random=15'),
(8, 'https://picsum.photos/300/200?random=16'),
(9, 'https://picsum.photos/300/200?random=17'),
(10, 'https://picsum.photos/300/200?random=18');

-- Display summary of inserted data
SELECT 'Data insertion complete!' AS Status;
SELECT COUNT(*) AS total_users FROM users;
SELECT COUNT(*) AS total_locations FROM locations;
SELECT COUNT(*) AS total_properties FROM properties;
SELECT COUNT(*) AS total_listings FROM listings;
SELECT COUNT(*) AS total_favorites FROM favorites;
SELECT COUNT(*) AS total_inquiries FROM inquiries;
SELECT COUNT(*) AS total_images FROM property_images;
