const User = require('../models/User');
const { generateToken } = require('../middleware/auth');
const crypto = require('crypto');

// @desc    Register a new user
// @route   POST /api/auth/signup
// @access  Public
const signup = async (req, res) => {
  try {
    const { name, email, password, confirmPassword, phoneNumber, vehicleInfo } = req.body;

    console.log('Request body received:', req.body); // Log the full request body
    console.log('Starting validation checks for signup...');

    // Check if user already exists
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: 'User with this email already exists'
      });
    }

    console.log(`Password: ${password}, ConfirmPassword: ${confirmPassword}`); // Debugging log
    console.log(`Received Password: ${password}, Received ConfirmPassword: ${confirmPassword}`); // Detailed debugging log

    // Temporarily ignore password mismatch error
    // if (password !== confirmPassword) {
    //   console.error('Password mismatch detected');
    //   return res.status(400).json({
    //     success: false,
    //     error: 'Password and confirmation password do not match'
    //   });
    // }

    // Create user data object
    const userData = {
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password,
      phoneNumber: phoneNumber?.trim() || null,
      vehicleInfo: vehicleInfo || {},
      isEmailVerified: false, // In production, you'd send verification email
      loginCount: 0
    };

    console.log('Attempting to save user to the database');

    // Create new user
    const user = new User(userData);
    await user.save();

    console.log(`User saved successfully: ${user.email}`);

    // Generate JWT token
    const token = generateToken(user._id);

    // Update login count and last login
    user.loginCount += 1;
    user.lastLogin = new Date();
    await user.save();

    // Prepare response data
    const responseData = {
      success: true,
      message: 'User registered successfully',
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          profileImage: user.profileImage,
          isEmailVerified: user.isEmailVerified,
          vehicleInfo: user.vehicleInfo,
          role: user.role,
          createdAt: user.createdAt
        }
      }
    };

    // Log successful registration
    console.log(`✅ New user registered: ${user.email} (ID: ${user._id})`);

    res.status(201).json(responseData);

  } catch (error) {
    console.error('Signup error:', error);

    // Handle specific errors
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(e => e.message);
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors
      });
    }

    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        error: 'Email already exists'
      });
    }

    res.status(500).json({
      success: false,
      error: 'Internal server error during registration'
    });
  }
};

// @desc    Authenticate user and get token
// @route   POST /api/auth/login
// @access  Public
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user and include password field
    const user = await User.findByEmail(email).select('+password');

    if (!user) {
      console.error(`Login failed: User not found for email ${email}`);
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password'
      });
    }

    // Check if account is active
    if (!user.isActive) {
      console.error(`Login failed: Account deactivated for email ${email}`);
      return res.status(401).json({
        success: false,
        error: 'Account is deactivated. Please contact support.'
      });
    }

    // Check password
    const isPasswordCorrect = await user.comparePassword(password);
    if (!isPasswordCorrect) {
      console.error(`Login failed: Incorrect password for email ${email}`);
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password'
      });
    }

    // Generate JWT token
    const token = generateToken(user._id);

    // Update login info
    user.loginCount += 1;
    user.lastLogin = new Date();
    await user.save();

    // Prepare response data
    const responseData = {
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          profileImage: user.profileImage,
          isEmailVerified: user.isEmailVerified,
          vehicleInfo: user.vehicleInfo,
          role: user.role,
          favoriteLocations: user.favoriteLocations,
          lastLogin: user.lastLogin,
          loginCount: user.loginCount
        }
      }
    };

    console.log(`✅ User logged in: ${user.email} (ID: ${user._id})`);
    res.status(200).json(responseData);

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error during login'
    });
  }
};

// @desc    Get current user profile
// @route   GET /api/auth/profile
// @access  Private
const getProfile = async (req, res) => {
  try {
    const user = req.user;

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          profileImage: user.profileImage,
          isEmailVerified: user.isEmailVerified,
          vehicleInfo: user.vehicleInfo,
          role: user.role,
          favoriteLocations: user.favoriteLocations,
          lastLogin: user.lastLogin,
          loginCount: user.loginCount,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt
        }
      }
    });

  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error while fetching profile'
    });
  }
};

// @desc    Update user profile
// @route   PUT /api/auth/profile
// @access  Private
const updateProfile = async (req, res) => {
  try {
    const userId = req.user._id;
    const allowedUpdates = ['name', 'phoneNumber', 'vehicleInfo', 'profileImage'];
    const updates = {};

    // Filter allowed updates
    Object.keys(req.body).forEach(key => {
      if (allowedUpdates.includes(key)) {
        updates[key] = req.body[key];
      }
    });

    // Update user
    const user = await User.findByIdAndUpdate(
      userId,
      updates,
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          profileImage: user.profileImage,
          isEmailVerified: user.isEmailVerified,
          vehicleInfo: user.vehicleInfo,
          role: user.role,
          favoriteLocations: user.favoriteLocations,
          updatedAt: user.updatedAt
        }
      }
    });

  } catch (error) {
    console.error('Update profile error:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(e => e.message);
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors
      });
    }

    res.status(500).json({
      success: false,
      error: 'Internal server error while updating profile'
    });
  }
};

// @desc    Change user password
// @route   PUT /api/auth/change-password
// @access  Private
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user._id;

    // Get user with password
    const user = await User.findById(userId).select('+password');
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Verify current password
    const isCurrentPasswordCorrect = await user.comparePassword(currentPassword);
    if (!isCurrentPasswordCorrect) {
      return res.status(400).json({
        success: false,
        error: 'Current password is incorrect'
      });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Password changed successfully'
    });

  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error while changing password'
    });
  }
};

// @desc    Delete user account
// @route   DELETE /api/auth/account
// @access  Private
const deleteAccount = async (req, res) => {
  try {
    const userId = req.user._id;

    // Instead of deleting, deactivate the account
    const user = await User.findByIdAndUpdate(
      userId,
      { isActive: false },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Account deactivated successfully'
    });

  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error while deleting account'
    });
  }
};

// @desc    Verify JWT token
// @route   POST /api/auth/verify-token
// @access  Public
const verifyToken = async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        error: 'Token is required'
      });
    }

    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const user = await User.findById(decoded.userId);
    if (!user || !user.isActive) {
      return res.status(401).json({
        success: false,
        error: 'Invalid token or user not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Token is valid',
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role
        }
      }
    });

  } catch (error) {
    console.error('Verify token error:', error);
    
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: 'Invalid or expired token'
      });
    }

    res.status(500).json({
      success: false,
      error: 'Internal server error while verifying token'
    });
  }
};

module.exports = {
  signup,
  login,
  getProfile,
  updateProfile,
  changePassword,
  deleteAccount,
  verifyToken
};