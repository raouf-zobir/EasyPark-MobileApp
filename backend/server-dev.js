const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.'
  }
});

app.use(limiter);
app.use(helmet());
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080', 'http://10.0.2.2:3000'], // Added Android emulator
  credentials: true
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// In-memory storage for development (replace with MongoDB later)
let users = [
  {
    id: '1',
    name: 'John Doe',
    email: 'john.doe@example.com',
    password: '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LeaozLJKPCrMy1.LK', // UserPass123
    phoneNumber: '+1234567890',
    isEmailVerified: true,
    role: 'user',
    vehicleInfo: {},
    favoriteLocations: [],
    lastLogin: new Date(),
    loginCount: 5,
    createdAt: new Date(),
    updatedAt: new Date(),
    isActive: true
  },
  {
    id: '2',
    name: 'Admin User',
    email: 'admin@easypark.com',
    password: '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LeaozLJKPCrMy1.LK', // AdminPass123
    phoneNumber: '+1987654321',
    isEmailVerified: true,
    role: 'admin',
    vehicleInfo: {},
    favoriteLocations: [],
    lastLogin: new Date(),
    loginCount: 10,
    createdAt: new Date(),
    updatedAt: new Date(),
    isActive: true
  }
];

let userIdCounter = 3;

// Utility functions
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const generateToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET || 'dev_secret_key',
    { expiresIn: process.env.JWT_EXPIRE || '7d' }
  );
};

const findUserByEmail = (email) => {
  return users.find(user => user.email.toLowerCase() === email.toLowerCase());
};

const findUserById = (id) => {
  return users.find(user => user.id === id);
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'EasyPark Backend Server is running (Development Mode)',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    mode: 'In-Memory Storage (No MongoDB Required)'
  });
});

// Signup endpoint
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { name, email, password, confirmPassword, phoneNumber, vehicleInfo } = req.body;

    // Basic validation
    if (!name || !email || !password || !confirmPassword) {
      return res.status(400).json({
        success: false,
        error: 'All required fields must be provided'
      });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({
        success: false,
        error: 'Passwords do not match'
      });
    }

    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        error: 'Password must be at least 8 characters long'
      });
    }

    // Check if user exists
    if (findUserByEmail(email)) {
      return res.status(400).json({
        success: false,
        error: 'User with this email already exists'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const newUser = {
      id: userIdCounter.toString(),
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password: hashedPassword,
      phoneNumber: phoneNumber?.trim() || null,
      isEmailVerified: false,
      role: 'user',
      vehicleInfo: vehicleInfo || {},
      favoriteLocations: [],
      lastLogin: new Date(),
      loginCount: 1,
      createdAt: new Date(),
      updatedAt: new Date(),
      isActive: true
    };

    users.push(newUser);
    userIdCounter++;

    // Generate token
    const token = generateToken(newUser.id);

    // Return response (exclude password)
    const { password: _, ...userResponse } = newUser;

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        token,
        user: userResponse
      }
    });

    console.log(`✅ New user registered: ${newUser.email} (ID: ${newUser.id})`);

  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error during registration'
    });
  }
});

// Login endpoint
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Email and password are required'
      });
    }

    // Find user
    const user = findUserByEmail(email);
    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password'
      });
    }

    // Check password
    const isPasswordCorrect = await bcrypt.compare(password, user.password);
    if (!isPasswordCorrect) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password'
      });
    }

    // Update login info
    user.loginCount += 1;
    user.lastLogin = new Date();

    // Generate token
    const token = generateToken(user.id);

    // Return response (exclude password)
    const { password: _, ...userResponse } = user;

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: userResponse
      }
    });

    console.log(`✅ User logged in: ${user.email} (ID: ${user.id})`);

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error during login'
    });
  }
});

// Verify token endpoint
app.post('/api/auth/verify-token', (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        error: 'Token is required'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dev_secret_key');
    const user = findUserById(decoded.userId);

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
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        }
      }
    });

  } catch (error) {
    console.error('Verify token error:', error);
    res.status(401).json({
      success: false,
      error: 'Invalid or expired token'
    });
  }
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error details:', err);
  res.status(err.statusCode || 500).json({
    success: false,
    error: err.message || 'Internal Server Error'
  });
});

// Handle 404 routes
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found'
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 EasyPark Backend Server is running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`⚡ Mode: Development (In-Memory Storage)`);
  console.log(`📊 Test accounts available:`);
  console.log(`   📧 john.doe@example.com : UserPass123`);
  console.log(`   📧 admin@easypark.com : AdminPass123`);
});

module.exports = app;