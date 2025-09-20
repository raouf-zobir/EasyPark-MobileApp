const mongoose = require('mongoose');

const spotSchema = new mongoose.Schema({
  code: { type: String, required: true, unique: true },
  zoneId: { type: mongoose.Schema.Types.ObjectId, ref: 'Zone', required: true },
  status: { type: String, enum: ['free', 'occupied', 'reserved'], default: 'free' },
  position: {
    x: { type: Number, required: true },
    y: { type: Number, required: true }
  }
}, { timestamps: true });

module.exports = mongoose.model("Spot", spotSchema);
