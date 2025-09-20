const mongoose = require('mongoose');

const adminSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email:    { type: String, required: true, unique: true }, // Ensure email is unique
  phone:    { type: String, required: true },
  password: { type: String, required: true }, // Store hashed password
  dateOfBirth: { type: Date, required: true }
}, { timestamps: true }); // Automatically adds createdAt and updatedAt fields

module.exports = mongoose.model("Admin", adminSchema);