const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(require('path').join(__dirname, '../frontend')));

// Import routes
const authRoutes = require('./routes/auth');
const listingRoutes = require('./routes/listings');
const userRoutes = require('./routes/users');
const favoriteRoutes = require('./routes/favorites');
const inquiryRoutes = require('./routes/inquiries');
const searchRoutes = require('./routes/search');

// Use routes
app.use('/api/auth', authRoutes);
app.use('/api/listings', listingRoutes);
app.use('/api/users', userRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/inquiries', inquiryRoutes);
app.use('/api/search', searchRoutes);

// Root endpoint
app.get('/api', (req, res) => {
    res.json({
        message: 'Property Listing API',
        version: '1.0.0',
        endpoints: {
            auth: '/api/auth',
            listings: '/api/listings',
            users: '/api/users',
            favorites: '/api/favorites',
            inquiries: '/api/inquiries',
            search: '/api/search'
        },
        authEndpoints: {
            register: 'POST /api/auth/register',
            login: 'POST /api/auth/login',
            logout: 'POST /api/auth/logout',
            getCurrentUser: 'GET /api/auth/me',
            updateProfile: 'PUT /api/auth/profile',
            changePassword: 'PUT /api/auth/change-password'
        }
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        error: 'Something went wrong!',
        message: err.message
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`📚 API documentation: http://localhost:${PORT}/api`);
});
