-- ============================================
-- Authentication Setup - User Login Configuration
-- ============================================
-- This file sets up users with authentication credentials
-- Using bcrypt-hashed passwords for security

-- Clear existing users (optional - uncomment to reset)
-- TRUNCATE TABLE users;

-- Insert Users with proper roles
-- Passwords will be populated by the Node.js backend initialization script
-- All passwords are initially set to a temporary hash and should be updated

-- ADMIN USER
INSERT INTO users (name, email, password, phone, address, role, is_active) VALUES
('Admin User', 'admin@propertylisting.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9841234567', 'Admin Office, Kathmandu', 'admin', TRUE);

-- SELLER USERS
INSERT INTO users (name, email, password, phone, address, role, is_active) VALUES
('Raj Kumar', 'raj.kumar@email.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9841111111', 'Thamel, Kathmandu', 'seller', TRUE),
('Neeta Verma', 'neeta.verma@email.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9842222222', 'Patan, Lalitpur', 'seller', TRUE),
('Jennifer Malla', 'jennifer.malla@email.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9843333333', 'Lakeside, Pokhara', 'seller', TRUE);

-- BUYER USERS
INSERT INTO users (name, email, password, phone, address, role, is_active) VALUES
('Priya Sharma', 'priya.sharma@email.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9844444444', 'Bhaktapur Durbar, Bhaktapur', 'buyer', TRUE),
('Vijay Singh', 'vijay.singh@email.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9845555555', 'Janakpur', 'buyer', TRUE),
('Rohindra Kharel', 'rohindra.kharel@email.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9846666666', 'Biratnagar Main Road', 'buyer', TRUE),
('Dipak Gurung', 'dipak.gurung@email.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9847777777', 'Dharan, Bazaar Area', 'buyer', TRUE);

-- AGENT USERS
INSERT INTO users (name, email, password, phone, address, role, is_active) VALUES
('Ajay Pandey', 'ajay.pandey@email.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9848888888', 'Kathmandu', 'agent', TRUE),
('Divya Nepali', 'divya.nepali@email.com', '$2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK', '9849999999', 'Pokhara', 'agent', TRUE);

-- NOTE: Default password for all users above is: password123
-- Hash: $2a$10$J34RUs3H8RJ5rOre.IepVurwHh.skFs/2grf.LviDFz0pAoaIlSnK (bcrypt)

-- ============================================
-- User Role Permissions
-- ============================================
-- ADMIN: Can see all users, properties, inquiries, and manage the system
-- SELLER: Can create/edit/delete their own properties and listings
-- BUYER: Can view properties, favorite listings, and send inquiries
-- AGENT: Can view and search properties (similar to buyer but professional)

-- ============================================
-- Index for better query performance
-- ============================================
ALTER TABLE users ADD INDEX idx_role_active (role, is_active);
ALTER TABLE users ADD INDEX idx_email_role (email, role);
