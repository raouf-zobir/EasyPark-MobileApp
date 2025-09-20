const mongoose = require('mongoose');

const zoneSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  capacity: { type: Number, required: true },
  location: {
    lat: { type: Number, required: true },
    lng: { type: Number, required: true }
  },
  pricePerHour: { type: Number, required: true }
}, { timestamps: true });

module.exports = mongoose.model("Zone", zoneSchema);
