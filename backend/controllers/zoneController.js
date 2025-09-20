const Zone = require('../models/Zone');

// Get all zones
exports.getAllZones = async (req, res) => {
  try {
    const zones = await Zone.find();
    res.json(zones);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch zones' });
  }
};
