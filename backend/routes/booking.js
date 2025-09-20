const express = require('express');
const { getAllBookings } = require('../controllers/bookingController');
const router = express.Router();

// GET /api/bookings - fetch all bookings
router.get('/', getAllBookings);

module.exports = router;
