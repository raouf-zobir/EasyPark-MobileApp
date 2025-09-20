const jwt = require('jsonwebtoken');

function authAdmin(req, res, next) {
  // Get token from header (e.g., "Bearer YOUR_TOKEN")
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) {
    return res.status(401).json({ message: "No authentication token provided" });
  }

  try {
    // Verify the token using the secret key
    const decoded = jwt.verify(token, process.env.JWT_SECRET || "supersecretjwtkey");

    // Check if the decoded token has the 'admin' role
    if (decoded.role !== "admin") {
      return res.status(403).json({ message: "Access denied: Not an administrator" });
    }

    // Attach the decoded admin payload to the request for further use
    req.admin = decoded;
    next(); // Proceed to the next middleware/route handler
  } catch (err) {
    console.error("Token verification error:", err); // Log the error for debugging
    return res.status(401).json({ message: "Invalid or expired token" });
  }
}

module.exports = authAdmin;