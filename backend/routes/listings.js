const express = require('express');
const router = express.Router();
const db = require('../config/database');
const authRoutes = require('./auth');

// Import auth middleware
const verifyToken = authRoutes.verifyToken;
const checkRole = authRoutes.checkRole;

// GET all listings
router.get('/', async (req, res) => {
    try {
        const [listings] = await db.query(`
            SELECT 
                l.id,
                l.price,
                l.status,
                l.created_at,
                p.type as property_type,
                p.description,
                loc.city,
                loc.area,
                loc.address,
                u.name as owner_name,
                COUNT(DISTINCT pi.id) as image_count,
                COUNT(DISTINCT f.user_id) as favorite_count,
                (SELECT image_url FROM property_images WHERE listing_id = l.id LIMIT 1) as image_url
            FROM listings l
            INNER JOIN properties p ON l.property_id = p.id
            INNER JOIN users u ON p.owner_id = u.id
            INNER JOIN locations loc ON l.location_id = loc.id
            LEFT JOIN property_images pi ON l.id = pi.listing_id
            LEFT JOIN favorites f ON l.id = f.listing_id
            GROUP BY l.id, l.price, l.status, l.created_at, p.type, p.description, 
                     loc.city, loc.area, loc.address, u.name
            ORDER BY l.created_at DESC
        `);
        res.json(listings);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single listing by ID
router.get('/:id', async (req, res) => {
    try {
        const [listings] = await db.query(`
            SELECT 
                l.id,
                l.price,
                l.status,
                l.created_at,
                p.id as property_id,
                p.type as property_type,
                p.description,
                loc.city,
                loc.area,
                loc.address,
                u.id as owner_id,
                u.name as owner_name,
                u.email as owner_email
            FROM listings l
            INNER JOIN properties p ON l.property_id = p.id
            INNER JOIN users u ON p.owner_id = u.id
            INNER JOIN locations loc ON l.location_id = loc.id
            WHERE l.id = ?
        `, [req.params.id]);

        if (listings.length === 0) {
            return res.status(404).json({ error: 'Listing not found' });
        }

        // Get images for this listing
        const [images] = await db.query(
            'SELECT id, image_url FROM property_images WHERE listing_id = ?',
            [req.params.id]
        );

        // Get inquiries count
        const [inquiries] = await db.query(
            'SELECT COUNT(*) as count FROM inquiries WHERE listing_id = ?',
            [req.params.id]
        );

        // Get favorites count
        const [favorites] = await db.query(
            'SELECT COUNT(*) as count FROM favorites WHERE listing_id = ?',
            [req.params.id]
        );

        const listing = {
            ...listings[0],
            images: images,
            inquiry_count: inquiries[0].count,
            favorite_count: favorites[0].count
        };

        res.json(listing);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET active listings only
router.get('/status/active', async (req, res) => {
    try {
        const [listings] = await db.query(`
            SELECT 
                l.id,
                l.price,
                l.status,
                p.type as property_type,
                p.description,
                loc.city,
                loc.area,
                u.name as owner_name
            FROM listings l
            INNER JOIN properties p ON l.property_id = p.id
            INNER JOIN users u ON p.owner_id = u.id
            INNER JOIN locations loc ON l.location_id = loc.id
            WHERE l.status = 'active'
            ORDER BY l.created_at DESC
        `);
        res.json(listings);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET listings by city
router.get('/city/:city', async (req, res) => {
    try {
        const [listings] = await db.query(`
            SELECT 
                l.id,
                l.price,
                l.status,
                p.type as property_type,
                p.description,
                loc.city,
                loc.area,
                loc.address
            FROM listings l
            INNER JOIN properties p ON l.property_id = p.id
            INNER JOIN locations loc ON l.location_id = loc.id
            WHERE loc.city = ? AND l.status = 'active'
            ORDER BY l.price
        `, [req.params.city]);
        res.json(listings);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET images for a listing
router.get('/:id/images', async (req, res) => {
    try {
        const [images] = await db.query(
            'SELECT * FROM property_images WHERE listing_id = ?',
            [req.params.id]
        );
        res.json(images);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================
// PROTECTED ROUTES (REQUIRE AUTHENTICATION)
// ============================================

// CREATE listing (Sellers only)
router.post('/', verifyToken, checkRole(['seller', 'admin']), async (req, res) => {
    try {
        const { property_id, location_id, price, status } = req.body;
        const sellers_id = req.user.id;

        if (!property_id || !location_id || !price) {
            return res.status(400).json({ error: 'property_id, location_id, and price are required' });
        }

        // Verify ownership of property (only seller can list their own properties, admin can list any)
        if (req.user.role === 'seller') {
            const [property] = await db.query(
                'SELECT owner_id FROM properties WHERE id = ?',
                [property_id]
            );

            if (property.length === 0 || property[0].owner_id !== sellers_id) {
                return res.status(403).json({ error: 'You can only list your own properties' });
            }
        }

        const listingStatus = status || 'active';

        const [result] = await db.query(
            'INSERT INTO listings (property_id, location_id, price, status) VALUES (?, ?, ?, ?)',
            [property_id, location_id, price, listingStatus]
        );

        res.status(201).json({
            message: 'Listing created successfully',
            id: result.insertId
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// UPDATE listing (Sellers own properties, Admin all)
router.put('/:id', verifyToken, checkRole(['seller', 'admin']), async (req, res) => {
    try {
        const { price, status } = req.body;
        const listingId = req.params.id;
        const userId = req.user.id;

        // Get listing and verify ownership
        const [listings] = await db.query(
            'SELECT p.owner_id FROM listings l INNER JOIN properties p ON l.property_id = p.id WHERE l.id = ?',
            [listingId]
        );

        if (listings.length === 0) {
            return res.status(404).json({ error: 'Listing not found' });
        }

        if (req.user.role === 'seller' && listings[0].owner_id !== userId) {
            return res.status(403).json({ error: 'You can only edit your own listings' });
        }

        const updateFields = [];
        const updateValues = [];

        if (price !== undefined) {
            updateFields.push('price = ?');
            updateValues.push(price);
        }

        if (status !== undefined) {
            updateFields.push('status = ?');
            updateValues.push(status);
        }

        if (updateFields.length === 0) {
            return res.status(400).json({ error: 'No fields to update' });
        }

        updateValues.push(listingId);

        const query = `UPDATE listings SET ${updateFields.join(', ')} WHERE id = ?`;
        await db.query(query, updateValues);

        res.json({ message: 'Listing updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE listing (Sellers own properties, Admin all)
router.delete('/:id', verifyToken, checkRole(['seller', 'admin']), async (req, res) => {
    try {
        const listingId = req.params.id;
        const userId = req.user.id;

        // Get listing and verify ownership
        const [listings] = await db.query(
            'SELECT p.owner_id FROM listings l INNER JOIN properties p ON l.property_id = p.id WHERE l.id = ?',
            [listingId]
        );

        if (listings.length === 0) {
            return res.status(404).json({ error: 'Listing not found' });
        }

        if (req.user.role === 'seller' && listings[0].owner_id !== userId) {
            return res.status(403).json({ error: 'You can only delete your own listings' });
        }

        await db.query('DELETE FROM listings WHERE id = ?', [listingId]);

        res.json({ message: 'Listing deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET seller's listings
router.get('/seller/my-listings', verifyToken, checkRole(['seller', 'admin']), async (req, res) => {
    try {
        const userId = req.user.id;
        let query, params;

        if (req.user.role === 'admin') {
            // Admin can see all listings
            query = `
                SELECT 
                    l.id,
                    l.price,
                    l.status,
                    l.created_at,
                    p.type as property_type,
                    p.description,
                    loc.city,
                    loc.area,
                    u.name as owner_name,
                    COUNT(DISTINCT f.user_id) as favorite_count,
                    COUNT(DISTINCT i.id) as inquiry_count
                FROM listings l
                INNER JOIN properties p ON l.property_id = p.id
                INNER JOIN users u ON p.owner_id = u.id
                INNER JOIN locations loc ON l.location_id = loc.id
                LEFT JOIN favorites f ON l.id = f.listing_id
                LEFT JOIN inquiries i ON l.id = i.listing_id
                GROUP BY l.id, l.price, l.status, l.created_at, p.type, p.description, loc.city, loc.area, u.name
                ORDER BY l.created_at DESC
            `;
            params = [];
        } else {
            // Sellers see only their listings
            query = `
                SELECT 
                    l.id,
                    l.price,
                    l.status,
                    l.created_at,
                    p.type as property_type,
                    p.description,
                    loc.city,
                    loc.area,
                    COUNT(DISTINCT f.user_id) as favorite_count,
                    COUNT(DISTINCT i.id) as inquiry_count
                FROM listings l
                INNER JOIN properties p ON l.property_id = p.id
                INNER JOIN locations loc ON l.location_id = loc.id
                LEFT JOIN favorites f ON l.id = f.listing_id
                LEFT JOIN inquiries i ON l.id = i.listing_id
                WHERE p.owner_id = ?
                GROUP BY l.id, l.price, l.status, l.created_at, p.type, p.description, loc.city, loc.area
                ORDER BY l.created_at DESC
            `;
            params = [userId];
        }

        const [listings] = await db.query(query, params);
        res.json(listings);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
