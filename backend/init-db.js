const mongoose = require('mongoose');
require('dotenv').config();

const User = require('./models/User');

// Sample data for testing
const sampleUsers = [
  {
    name: 'Admin User',
    email: 'admin@easypark.com',
    password: 'AdminPass123',
    role: 'admin',
    isEmailVerified: true,
    phoneNumber: '+1234567890',
    vehicleInfo: {
      plateNumber: 'ADMIN001',
      vehicleType: 'car',
      color: 'Black',
      model: 'Tesla Model S'
    }
  },
  {
    name: 'John Doe',
    email: 'john.doe@example.com',
    password: 'UserPass123',
    role: 'user',
    isEmailVerified: true,
    phoneNumber: '+1987654321',
    vehicleInfo: {
      plateNumber: 'USER001',
      vehicleType: 'car',
      color: 'Blue',
      model: 'Toyota Camry'
    },
    favoriteLocations: [
      {
        name: 'Downtown Parking',
        latitude: 40.7128,
        longitude: -74.0060,
        address: '123 Main St, New York, NY'
      }
    ]
  },
  {
    name: 'Jane Smith',
    email: 'jane.smith@example.com',
    password: 'UserPass456',
    role: 'user',
    isEmailVerified: false,
    phoneNumber: '+1555123456',
    vehicleInfo: {
      plateNumber: 'USER002',
      vehicleType: 'motorcycle',
      color: 'Red',
      model: 'Honda CBR600RR'
    }
  }
];

async function initializeDatabase() {
  try {
    console.log('🔄 Connecting to MongoDB...');
    
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ Connected to MongoDB successfully');

    // Clear existing data (optional - remove this in production)
    console.log('🗑️  Clearing existing users...');
    await User.deleteMany({});
    console.log('✅ Existing users cleared');

    // Create sample users
    console.log('👥 Creating sample users...');
    
    for (const userData of sampleUsers) {
      const user = new User(userData);
      await user.save();
      console.log(`✅ Created user: ${userData.email} (${userData.role})`);
    }

    console.log('\n🎉 Database initialization completed successfully!');
    console.log('\n📋 Created Users:');
    console.log('├── admin@easypark.com (Admin) - Password: AdminPass123');
    console.log('├── john.doe@example.com (User) - Password: UserPass123');
    console.log('└── jane.smith@example.com (User) - Password: UserPass456');
    
    console.log('\n🚀 You can now start the server with: npm run dev');
    
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    
    if (error.code === 'ECONNREFUSED') {
      console.error('\n🔍 MongoDB connection refused. Please ensure:');
      console.error('   1. MongoDB is installed and running');
      console.error('   2. MongoDB service is started');
      console.error('   3. Connection URI is correct in .env file');
      console.error('\n🔧 To start MongoDB:');
      console.error('   Windows: net start MongoDB');
      console.error('   Mac/Linux: sudo systemctl start mongod');
    }
    
  } finally {
    // Close the connection
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
    process.exit(0);
  }
}

// Run initialization
if (require.main === module) {
  initializeDatabase();
}

module.exports = initializeDatabase;