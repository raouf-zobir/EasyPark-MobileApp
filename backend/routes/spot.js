const express = require('express');
const { getAllSpots } = require('../controllers/spotController');
const router = express.Router();

// GET /api/spots - fetch all spots
router.get('/', getAllSpots);

module.exports = router;
