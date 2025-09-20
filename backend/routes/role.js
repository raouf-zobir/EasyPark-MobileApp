const express = require('express');
const { getAllRoles } = require('../controllers/roleController');
const router = express.Router();

// GET /api/roles - fetch all roles
router.get('/', getAllRoles);

module.exports = router;
