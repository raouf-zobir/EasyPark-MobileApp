const Admin = require('../models/Admin'); // Correct path to your Admin model
const bcrypt = require('bcryptjs');       // For hashing and comparing passwords
const jwt = require('jsonwebtoken');      // For creating and verifying JWTs

exports.signup = async (req, res) => {
  try {
    const { fullName, email, phone, password, dateOfBirth } = req.body;

    // Check if an admin with the given email already exists
    const exist = await Admin.findOne({ email });
    if (exist) {
      return res.status(400).json({ message: "Admin already exists with this email" });
    }

    // Hash the password before saving it to the database
    const hashedPassword = await bcrypt.hash(password, 10); // 10 is the salt rounds

    // Create a new Admin instance and save it
    const admin = new Admin({ fullName, email, phone, password: hashedPassword, dateOfBirth });
    await admin.save();

    // Generate a JSON Web Token (JWT) for the new admin
    // Use a strong secret from your .env file in a real application
    const token = jwt.sign({ id: admin._id, role: "admin" }, process.env.JWT_SECRET || "supersecretjwtkey", { expiresIn: "1d" });

    // Send back the token upon successful signup
    res.status(201).json({ access_token: token, message: "Admin registered successfully" });

  } catch (err) {
    console.error("Signup error:", err); // Log the error for debugging
    res.status(500).json({ message: "Server error during signup" });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if admin exists
    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // Compare provided password with hashed password in DB
    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // Generate JWT for the authenticated admin
    const token = jwt.sign({ id: admin._id, role: "admin" }, process.env.JWT_SECRET || "supersecretjwtkey", { expiresIn: "1d" });

    // Send back the token
    res.status(200).json({ access_token: token, message: "Logged in successfully" });

  } catch (err) {
    console.error("Login error:", err); // Log the error for debugging
    res.status(500).json({ message: "Server error during login" });
  }
};

// Get all admins
exports.getAllAdmins = async (req, res) => {
  try {
    const admins = await Admin.find().select('-password');
    res.json(admins);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch admins' });
  }
};