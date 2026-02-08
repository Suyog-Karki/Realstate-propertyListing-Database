const express = require('express');
const router = express.Router();
const db = require('../config/database');

// POST search listings
router.post('/', async (req, res) => {
    try {
        const { city, propertyType, minPrice, maxPrice, status } = req.body;

        let query = `
            SELECT 
                l.id,
                l.price,
                l.status,
                p.type as property_type,
                p.description,
                loc.city,
                loc.area,
                loc.address,
                u.name as owner_name,
                (SELECT image_url FROM property_images WHERE listing_id = l.id LIMIT 1) as image_url
            FROM listings l
            INNER JOIN properties p ON l.property_id = p.id
            INNER JOIN users u ON p.owner_id = u.id
            INNER JOIN locations loc ON l.location_id = loc.id
            WHERE 1=1
        `;

        const params = [];

        if (city) {
            query += ' AND loc.city = ?';
            params.push(city);
        }

        if (propertyType) {
            query += ' AND p.type = ?';
            params.push(propertyType);
        }

        if (minPrice) {
            query += ' AND l.price >= ?';
            params.push(minPrice);
        }

        if (maxPrice) {
            query += ' AND l.price <= ?';
            params.push(maxPrice);
        }

        if (status) {
            query += ' AND l.status = ?';
            params.push(status);
        } else {
            query += ' AND l.status = "active"';
        }

        query += ' ORDER BY l.created_at DESC';

        const [listings] = await db.query(query, params);
        res.json(listings);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET all cities
router.get('/cities', async (req, res) => {
    try {
        const [cities] = await db.query(`
            SELECT DISTINCT city 
            FROM locations 
            ORDER BY city
        `);
        res.json(cities.map(c => c.city));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET all property types
router.get('/property-types', async (req, res) => {
    try {
        const [types] = await db.query(`
            SELECT DISTINCT type 
            FROM properties 
            ORDER BY type
        `);
        res.json(types.map(t => t.type));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET market statistics
router.get('/statistics', async (req, res) => {
    try {
        const [stats] = await db.query(`
            SELECT 
                COUNT(*) as total_listings,
                COUNT(CASE WHEN status = 'active' THEN 1 END) as active_listings,
                COUNT(CASE WHEN status = 'sold' THEN 1 END) as sold_listings,
                ROUND(AVG(price), 2) as avg_price,
                MIN(price) as min_price,
                MAX(price) as max_price
            FROM listings
        `);

        const [cityStats] = await db.query(`
            SELECT 
                loc.city,
                COUNT(l.id) as listing_count,
                ROUND(AVG(l.price), 2) as avg_price
            FROM locations loc
            LEFT JOIN listings l ON loc.id = l.location_id
            WHERE l.status = 'active'
            GROUP BY loc.city
            ORDER BY listing_count DESC
            LIMIT 5
        `);

        const [typeStats] = await db.query(`
            SELECT 
                p.type,
                COUNT(l.id) as listing_count,
                ROUND(AVG(l.price), 2) as avg_price
            FROM properties p
            LEFT JOIN listings l ON p.id = l.property_id
            WHERE l.status = 'active'
            GROUP BY p.type
            ORDER BY listing_count DESC
        `);

        res.json({
            overview: stats[0],
            topCities: cityStats,
            propertyTypes: typeStats
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
