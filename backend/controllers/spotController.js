const Spot = require('../models/Spot');

// Get all spots
exports.getAllSpots = async (req, res) => {
  try {
    const spots = await Spot.find().populate('zoneId');
    res.json(spots);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch spots' });
  }
};
