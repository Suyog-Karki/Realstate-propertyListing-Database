const express = require('express');
const router = express.Router();
const db = require('../config/database');
const authRoutes = require('./auth');

// Import auth middleware
const verifyToken = authRoutes.verifyToken;
const checkRole = authRoutes.checkRole;

// GET all inquiries for a listing
router.get('/listing/:listingId', async (req, res) => {
    try {
        const [inquiries] = await db.query(`
            SELECT 
                i.id,
                i.message,
                i.created_at,
                u.name as user_name,
                u.email as user_email
            FROM inquiries i
            INNER JOIN users u ON i.user_id = u.id
            WHERE i.listing_id = ?
            ORDER BY i.created_at DESC
        `, [req.params.listingId]);
        res.json(inquiries);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET all inquiries from a user
router.get('/user/:userId', async (req, res) => {
    try {
        const [inquiries] = await db.query(`
            SELECT 
                i.id,
                i.message,
                i.created_at,
                l.id as listing_id,
                p.type as property_type,
                loc.city,
                l.price
            FROM inquiries i
            INNER JOIN listings l ON i.listing_id = l.id
            INNER JOIN properties p ON l.property_id = p.id
            INNER JOIN locations loc ON l.location_id = loc.id
            WHERE i.user_id = ?
            ORDER BY i.created_at DESC
        `, [req.params.userId]);
        res.json(inquiries);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST create inquiry (Protected - Buyers only)
router.post('/', verifyToken, checkRole(['buyer', 'seller', 'agent', 'admin']), async (req, res) => {
    try {
        const { listing_id, message } = req.body;
        const user_id = req.user.id;

        if (!user_id || !listing_id || !message) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        // Check if listing exists and is active
        const [listings] = await db.query(
            'SELECT status FROM listings WHERE id = ?',
            [listing_id]
        );

        if (listings.length === 0) {
            return res.status(404).json({ error: 'Listing not found' });
        }

        if (listings[0].status !== 'active') {
            return res.status(400).json({ error: 'Listing is not active' });
        }

        // Create inquiry
        const [result] = await db.query(
            'INSERT INTO inquiries (user_id, listing_id, message) VALUES (?, ?, ?)',
            [user_id, listing_id, message]
        );

        res.json({
            message: 'Inquiry created successfully',
            inquiry_id: result.insertId
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
