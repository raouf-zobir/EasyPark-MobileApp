const express = require('express');
const { getAllZones } = require('../controllers/zoneController');
const router = express.Router();

// GET /api/zones - fetch all zones
router.get('/', getAllZones);

module.exports = router;
