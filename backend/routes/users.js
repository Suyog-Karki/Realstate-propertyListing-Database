const express = require('express');
const router = express.Router();
const db = require('../config/database');

// GET all users
router.get('/', async (req, res) => {
    try {
        const [users] = await db.query(`
            SELECT id, name, email, role, created_at 
            FROM users 
            ORDER BY created_at DESC
        `);
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single user by ID
router.get('/:id', async (req, res) => {
    try {
        const [users] = await db.query(
            'SELECT id, name, email, role, created_at FROM users WHERE id = ?',
            [req.params.id]
        );

        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.json(users[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET user activity report
router.get('/:id/activity', async (req, res) => {
    try {
        const userId = req.params.id;

        // Get user info
        const [users] = await db.query(
            'SELECT id, name, email, role, created_at FROM users WHERE id = ?',
            [userId]
        );

        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Get favorites
        const [favorites] = await db.query(`
            SELECT 
                l.id,
                p.type,
                loc.city,
                l.price,
                f.created_at
            FROM favorites f
            INNER JOIN listings l ON f.listing_id = l.id
            INNER JOIN properties p ON l.property_id = p.id
            INNER JOIN locations loc ON l.location_id = loc.id
            WHERE f.user_id = ?
            ORDER BY f.created_at DESC
        `, [userId]);

        // Get inquiries
        const [inquiries] = await db.query(`
            SELECT 
                i.id,
                i.message,
                i.created_at,
                l.id as listing_id,
                p.type,
                loc.city
            FROM inquiries i
            INNER JOIN listings l ON i.listing_id = l.id
            INNER JOIN properties p ON l.property_id = p.id
            INNER JOIN locations loc ON l.location_id = loc.id
            WHERE i.user_id = ?
            ORDER BY i.created_at DESC
        `, [userId]);

        // Get properties (if seller)
        const [properties] = await db.query(`
            SELECT 
                p.id,
                p.type,
                p.description,
                COUNT(l.id) as listing_count
            FROM properties p
            LEFT JOIN listings l ON p.id = l.property_id
            WHERE p.owner_id = ?
            GROUP BY p.id, p.type, p.description
        `, [userId]);

        res.json({
            user: users[0],
            favorites: favorites,
            inquiries: inquiries,
            properties: properties,
            stats: {
                favorite_count: favorites.length,
                inquiry_count: inquiries.length,
                property_count: properties.length
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET users by role
router.get('/role/:role', async (req, res) => {
    try {
        const [users] = await db.query(
            'SELECT id, name, email, role, created_at FROM users WHERE role = ?',
            [req.params.role]
        );
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
