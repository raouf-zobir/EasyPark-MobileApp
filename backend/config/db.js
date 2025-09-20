const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // Make sure your .env file has MONGO_URI, e.g., MONGO_URI="mongodb://127.0.0.1:27017/easypark"
    await mongoose.connect(process.env.MONGO_URI || "mongodb://127.0.0.1:27017/easypark");
    console.log("✅ MongoDB Connected");
  } catch (err) {
    console.error("❌ MongoDB Error:", err.message);
    process.exit(1); // Exit process with failure
  }
};

module.exports = connectDB;