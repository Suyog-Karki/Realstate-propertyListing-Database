const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// ============================================
// AUTHENTICATION MIDDLEWARE
// ============================================

// Middleware to verify JWT token
const verifyToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1] || req.cookies?.token;
    
    if (!token) {
        return res.status(401).json({ error: 'No token provided' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ error: 'Invalid token' });
    }
};

// Middleware to check user role
const checkRole = (allowedRoles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ error: 'Not authenticated' });
        }
        if (!allowedRoles.includes(req.user.role)) {
            return res.status(403).json({ error: 'Access denied. Insufficient permissions.' });
        }
        next();
    };
};

// ============================================
// REGISTRATION ROUTE
// ============================================
router.post('/register', async (req, res) => {
    try {
        const { name, email, password, phone, address, role } = req.body;

        // Validation
        if (!name || !email || !password) {
            return res.status(400).json({ error: 'Name, email, and password are required' });
        }

        if (password.length < 6) {
            return res.status(400).json({ error: 'Password must be at least 6 characters' });
        }

        // Check if user already exists
        const [existingUser] = await db.query(
            'SELECT id FROM users WHERE email = ?',
            [email]
        );

        if (existingUser.length > 0) {
            return res.status(409).json({ error: 'Email already registered' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert user
        const userRole = role || 'buyer'; // Default role
        await db.query(
            'INSERT INTO users (name, email, password, phone, address, role, is_active) VALUES (?, ?, ?, ?, ?, ?, TRUE)',
            [name, email, hashedPassword, phone || null, address || null, userRole]
        );

        // Fetch the newly created user
        const [newUser] = await db.query(
            'SELECT id, name, email, role, created_at FROM users WHERE email = ?',
            [email]
        );

        // Create JWT token
        const token = jwt.sign(
            { id: newUser[0].id, email: newUser[0].email, role: newUser[0].role },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.status(201).json({
            message: 'Registration successful',
            token: token,
            user: newUser[0]
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================
// LOGIN ROUTE
// ============================================
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validation
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        // Find user
        const [users] = await db.query(
            'SELECT id, name, email, password, role, is_active FROM users WHERE email = ?',
            [email]
        );

        if (users.length === 0) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const user = users[0];

        // Check if user is active
        if (!user.is_active) {
            return res.status(403).json({ error: 'Account is deactivated' });
        }

        // Compare password
        const passwordMatch = await bcrypt.compare(password, user.password);

        if (!passwordMatch) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        // Create JWT token
        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        // Return user data without password
        const { password: _, ...userWithoutPassword } = user;

        res.json({
            message: 'Login successful',
            token: token,
            user: userWithoutPassword
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================
// GET CURRENT USER (Protected Route)
// ============================================
router.get('/me', verifyToken, async (req, res) => {
    try {
        const [users] = await db.query(
            'SELECT id, name, email, phone, address, role, is_active, created_at, updated_at FROM users WHERE id = ?',
            [req.user.id]
        );

        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.json(users[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================
// LOGOUT ROUTE
// ============================================
router.post('/logout', verifyToken, (req, res) => {
    // JWT is stateless, so logout is client-side
    // Client should delete the stored token
    res.json({ message: 'Logout successful' });
});

// ============================================
// UPDATE USER PROFILE (Protected Route)
// ============================================
router.put('/profile', verifyToken, async (req, res) => {
    try {
        const { name, phone, address } = req.body;
        const userId = req.user.id;

        // Update user
        await db.query(
            'UPDATE users SET name = ?, phone = ?, address = ? WHERE id = ?',
            [name || null, phone || null, address || null, userId]
        );

        // Fetch updated user
        const [updatedUser] = await db.query(
            'SELECT id, name, email, phone, address, role, is_active, created_at, updated_at FROM users WHERE id = ?',
            [userId]
        );

        res.json({
            message: 'Profile updated successfully',
            user: updatedUser[0]
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================
// CHANGE PASSWORD (Protected Route)
// ============================================
router.put('/change-password', verifyToken, async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;
        const userId = req.user.id;

        if (!currentPassword || !newPassword) {
            return res.status(400).json({ error: 'Current and new passwords are required' });
        }

        if (newPassword.length < 6) {
            return res.status(400).json({ error: 'New password must be at least 6 characters' });
        }

        // Get user
        const [users] = await db.query(
            'SELECT password FROM users WHERE id = ?',
            [userId]
        );

        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Verify current password
        const passwordMatch = await bcrypt.compare(currentPassword, users[0].password);
        if (!passwordMatch) {
            return res.status(401).json({ error: 'Current password is incorrect' });
        }

        // Hash new password
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        // Update password
        await db.query(
            'UPDATE users SET password = ? WHERE id = ?',
            [hashedPassword, userId]
        );

        res.json({ message: 'Password changed successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================
// ADMIN ROUTES
// ============================================

// GET all users (Admin only)
router.get('/admin/users', verifyToken, checkRole(['admin']), async (req, res) => {
    try {
        const [users] = await db.query(`
            SELECT id, name, email, phone, address, role, is_active, created_at, updated_at 
            FROM users 
            ORDER BY created_at DESC
        `);
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// UPDATE user role (Admin only)
router.put('/admin/users/:id/role', verifyToken, checkRole(['admin']), async (req, res) => {
    try {
        const { role } = req.body;
        const userId = req.params.id;

        if (!['buyer', 'seller', 'agent', 'admin'].includes(role)) {
            return res.status(400).json({ error: 'Invalid role' });
        }

        await db.query(
            'UPDATE users SET role = ? WHERE id = ?',
            [role, userId]
        );

        const [updatedUser] = await db.query(
            'SELECT id, name, email, role FROM users WHERE id = ?',
            [userId]
        );

        res.json({
            message: 'User role updated successfully',
            user: updatedUser[0]
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DEACTIVATE/ACTIVATE user (Admin only)
router.put('/admin/users/:id/status', verifyToken, checkRole(['admin']), async (req, res) => {
    try {
        const { is_active } = req.body;
        const userId = req.params.id;

        await db.query(
            'UPDATE users SET is_active = ? WHERE id = ?',
            [is_active, userId]
        );

        const [updatedUser] = await db.query(
            'SELECT id, name, email, role, is_active FROM users WHERE id = ?',
            [userId]
        );

        res.json({
            message: `User ${is_active ? 'activated' : 'deactivated'} successfully`,
            user: updatedUser[0]
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE user (Admin only)
router.delete('/admin/users/:id', verifyToken, checkRole(['admin']), async (req, res) => {
    try {
        const userId = req.params.id;

        // Prevent deleting yourself
        if (userId == req.user.id) {
            return res.status(400).json({ error: 'Cannot delete your own account' });
        }

        const [user] = await db.query(
            'SELECT name FROM users WHERE id = ?',
            [userId]
        );

        if (user.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        await db.query('DELETE FROM users WHERE id = ?', [userId]);

        res.json({
            message: 'User deleted successfully',
            deletedUser: user[0]
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Export middleware for use in other routes
router.verifyToken = verifyToken;
router.checkRole = checkRole;

module.exports = router;
