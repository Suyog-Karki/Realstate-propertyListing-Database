const express = require('express');
const router = express.Router();
const db = require('../config/database');
const authRoutes = require('./auth');

// Import auth middleware
const verifyToken = authRoutes.verifyToken;
const checkRole = authRoutes.checkRole;

// GET all favorites for a user
router.get('/user/:userId', async (req, res) => {
    try {
        const [favorites] = await db.query(`
            SELECT 
                l.id,
                l.price,
                l.status,
                p.type as property_type,
                p.description,
                loc.city,
                loc.area,
                f.created_at as favorited_at
            FROM favorites f
            INNER JOIN listings l ON f.listing_id = l.id
            INNER JOIN properties p ON l.property_id = p.id
            INNER JOIN locations loc ON l.location_id = loc.id
            WHERE f.user_id = ?
            ORDER BY f.created_at DESC
        `, [req.params.userId]);
        res.json(favorites);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST add favorite (Protected - Buyers only)
router.post('/', verifyToken, checkRole(['buyer', 'seller', 'agent', 'admin']), async (req, res) => {
    try {
        const { listing_id } = req.body;
        const user_id = req.user.id;

        // Check if already favorited
        const [existing] = await db.query(
            'SELECT * FROM favorites WHERE user_id = ? AND listing_id = ?',
            [user_id, listing_id]
        );

        if (existing.length > 0) {
            return res.status(400).json({ error: 'Already in favorites' });
        }

        // Add favorite
        await db.query(
            'INSERT INTO favorites (user_id, listing_id) VALUES (?, ?)',
            [user_id, listing_id]
        );

        res.json({ message: 'Added to favorites successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE remove favorite (Protected)
router.delete('/', verifyToken, async (req, res) => {
    try {
        const { listing_id } = req.body;
        const user_id = req.user.id;

        const [result] = await db.query(
            'DELETE FROM favorites WHERE user_id = ? AND listing_id = ?',
            [user_id, listing_id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Favorite not found' });
        }

        res.json({ message: 'Removed from favorites successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET check if listing is favorited by user
router.get('/check/:userId/:listingId', async (req, res) => {
    try {
        const [favorites] = await db.query(
            'SELECT * FROM favorites WHERE user_id = ? AND listing_id = ?',
            [req.params.userId, req.params.listingId]
        );

        res.json({ isFavorited: favorites.length > 0 });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
