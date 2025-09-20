const express = require('express');
const { signup, login, getAllAdmins } = require('../controllers/adminController'); // Correctly import both functions
const authAdmin = require('../middleware/authAdmin'); // Correct path to middleware

const router = express.Router();

// Public routes for signup and login
router.post('/signup', signup);
router.post('/login', login);

// GET /api/admins - fetch all admins
router.get('/', getAllAdmins);

// Protected route - only accessible by authenticated admins
router.get('/dashboard', authAdmin, (req, res) => {
  // req.admin will contain { id: admin._id, role: "admin" } from the authAdmin middleware
  res.json({ message: "Welcome to the Admin Dashboard!", adminId: req.admin.id });
});

module.exports = router;