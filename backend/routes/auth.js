const express = require('express');
const router = express.Router();

// Import middleware
const { authenticateToken } = require('../middleware/auth');
const {
  validateSignup,
  validateLogin,
  validateProfileUpdate,
  validateChangePassword
} = require('../middleware/validation');

// Import controllers
const {
  signup,
  login,
  getProfile,
  updateProfile,
  changePassword,
  deleteAccount,
  verifyToken
} = require('../controllers/authController');

// @desc    Register a new user
// @route   POST /api/auth/signup
// @access  Public
router.post('/signup', validateSignup, signup);

// @desc    Authenticate user and get token
// @route   POST /api/auth/login
// @access  Public
router.post('/login', validateLogin, login);

// @desc    Verify JWT token
// @route   POST /api/auth/verify-token
// @access  Public
router.post('/verify-token', verifyToken);

// @desc    Get current user profile
// @route   GET /api/auth/profile
// @access  Private
router.get('/profile', authenticateToken, getProfile);

// @desc    Update user profile
// @route   PUT /api/auth/profile
// @access  Private
router.put('/profile', authenticateToken, validateProfileUpdate, updateProfile);

// @desc    Change user password
// @route   PUT /api/auth/change-password
// @access  Private
router.put('/change-password', authenticateToken, validateChangePassword, changePassword);

// @desc    Delete/Deactivate user account
// @route   DELETE /api/auth/account
// @access  Private
router.delete('/account', authenticateToken, deleteAccount);

// @desc    Get authentication status
// @route   GET /api/auth/status
// @access  Private
router.get('/status', authenticateToken, (req, res) => {
  res.status(200).json({
    success: true,
    message: 'User is authenticated',
    data: {
      user: {
        id: req.user._id,
        name: req.user.name,
        email: req.user.email,
        role: req.user.role,
        isActive: req.user.isActive,
        lastLogin: req.user.lastLogin
      }
    }
  });
});

module.exports = router;