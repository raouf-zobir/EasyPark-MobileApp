# EasyPark Backend API Documentation

A comprehensive Node.js backend system for the EasyPark mobile application with MongoDB database.

## 🚀 Quick Start

### Prerequisites

- Node.js 16.0 or higher
- MongoDB 4.4 or higher (running locally)
- npm or yarn package manager

### Installation

1. **Clone and navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` file with your configuration:
   ```env
   NODE_ENV=development
   PORT=3000
   MONGODB_URI=mongodb://localhost:27017/easypark
   JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
   JWT_EXPIRE=7d
   BCRYPT_ROUNDS=12
   ```

4. **Start MongoDB locally:**
   ```bash
   # On Windows (if MongoDB is installed as a service)
   net start MongoDB
   
   # Or start manually
   mongod --dbpath "C:\data\db"
   ```

5. **Start the server:**
   ```bash
   # Development mode with auto-reload
   npm run dev
   
   # Production mode
   npm start
   ```

6. **Verify the server is running:**
   Visit `http://localhost:3000/health` in your browser or use curl:
   ```bash
   curl http://localhost:3000/health
   ```

## 📚 API Endpoints

### Base URL
```
http://localhost:3000/api/auth
```

### Health Check
```http
GET /health
```
**Response:**
```json
{
  "status": "OK",
  "message": "EasyPark Backend Server is running",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "environment": "development"
}
```

---

## 🔐 Authentication Endpoints

### 1. User Signup

**Endpoint:** `POST /api/auth/signup`

**Description:** Register a new user account with email and password.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "password": "SecurePass123",
  "confirmPassword": "SecurePass123",
  "phoneNumber": "+1234567890",
  "vehicleInfo": {
    "plateNumber": "ABC123",
    "vehicleType": "car",
    "color": "Blue",
    "model": "Toyota Camry"
  }
}
```

**Required Fields:**
- `name` (string, 2-50 characters, letters/spaces/hyphens/apostrophes only)
- `email` (string, valid email format)
- `password` (string, min 8 chars, must contain uppercase, lowercase, and number)
- `confirmPassword` (string, must match password)

**Optional Fields:**
- `phoneNumber` (string, valid phone number format)
- `vehicleInfo` (object with plateNumber, vehicleType, color, model)

**Success Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "phoneNumber": "+1234567890",
      "profileImage": null,
      "isEmailVerified": false,
      "vehicleInfo": {
        "plateNumber": "ABC123",
        "vehicleType": "car",
        "color": "Blue",
        "model": "Toyota Camry"
      },
      "role": "user",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

**Error Responses:**
```json
// Validation Error (400)
{
  "success": false,
  "error": "Validation failed",
  "details": [
    {
      "field": "email",
      "message": "Please provide a valid email address",
      "value": "invalid-email"
    }
  ]
}

// User Already Exists (400)
{
  "success": false,
  "error": "User with this email already exists"
}
```

---

### 2. User Login

**Endpoint:** `POST /api/auth/login`

**Description:** Authenticate user with email and password.

**Request Body:**
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "phoneNumber": "+1234567890",
      "profileImage": null,
      "isEmailVerified": false,
      "vehicleInfo": {
        "plateNumber": "ABC123",
        "vehicleType": "car",
        "color": "Blue",
        "model": "Toyota Camry"
      },
      "role": "user",
      "favoriteLocations": [],
      "lastLogin": "2024-01-15T10:30:00.000Z",
      "loginCount": 5
    }
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "error": "Invalid email or password"
}
```

---

### 3. Get User Profile

**Endpoint:** `GET /api/auth/profile`

**Description:** Get current authenticated user's profile information.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "phoneNumber": "+1234567890",
      "profileImage": null,
      "isEmailVerified": false,
      "vehicleInfo": {
        "plateNumber": "ABC123",
        "vehicleType": "car",
        "color": "Blue",
        "model": "Toyota Camry"
      },
      "role": "user",
      "favoriteLocations": [],
      "lastLogin": "2024-01-15T10:30:00.000Z",
      "loginCount": 5,
      "createdAt": "2024-01-15T08:00:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

---

### 4. Update User Profile

**Endpoint:** `PUT /api/auth/profile`

**Description:** Update current authenticated user's profile information.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Request Body (all fields optional):**
```json
{
  "name": "John Smith",
  "phoneNumber": "+1987654321",
  "vehicleInfo": {
    "plateNumber": "XYZ789",
    "vehicleType": "motorcycle",
    "color": "Red",
    "model": "Honda CBR"
  },
  "profileImage": "https://example.com/profile.jpg"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "name": "John Smith",
      "email": "john.doe@example.com",
      "phoneNumber": "+1987654321",
      "profileImage": "https://example.com/profile.jpg",
      "isEmailVerified": false,
      "vehicleInfo": {
        "plateNumber": "XYZ789",
        "vehicleType": "motorcycle",
        "color": "Red",
        "model": "Honda CBR"
      },
      "role": "user",
      "favoriteLocations": [],
      "updatedAt": "2024-01-15T11:00:00.000Z"
    }
  }
}
```

---

### 5. Change Password

**Endpoint:** `PUT /api/auth/change-password`

**Description:** Change the current authenticated user's password.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "currentPassword": "OldSecurePass123",
  "newPassword": "NewSecurePass456",
  "confirmNewPassword": "NewSecurePass456"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

**Error Response (400):**
```json
{
  "success": false,
  "error": "Current password is incorrect"
}
```

---

### 6. Verify Token

**Endpoint:** `POST /api/auth/verify-token`

**Description:** Verify if a JWT token is valid and active.

**Request Body:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Token is valid",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "role": "user"
    }
  }
}
```

---

### 7. Get Authentication Status

**Endpoint:** `GET /api/auth/status`

**Description:** Check if the current user is authenticated.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User is authenticated",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "role": "user",
      "isActive": true,
      "lastLogin": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

---

### 8. Delete Account

**Endpoint:** `DELETE /api/auth/account`

**Description:** Deactivate the current authenticated user's account.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Account deactivated successfully"
}
```

---

## 🔒 Authentication & Authorization

### JWT Token Usage

All protected routes require a valid JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

### Token Expiration

Tokens expire after 7 days by default (configurable via `JWT_EXPIRE` environment variable).

---

## 📊 Data Models

### User Model

```javascript
{
  _id: ObjectId,
  name: String (required, 2-50 chars),
  email: String (required, unique, valid email),
  password: String (required, hashed, min 8 chars),
  profileImage: String (optional),
  phoneNumber: String (optional),
  isEmailVerified: Boolean (default: false),
  isActive: Boolean (default: true),
  role: String (enum: ['user', 'admin'], default: 'user'),
  favoriteLocations: [{
    name: String,
    latitude: Number,
    longitude: Number,
    address: String
  }],
  vehicleInfo: {
    plateNumber: String,
    vehicleType: String (enum: ['car', 'motorcycle', 'truck', 'van']),
    color: String,
    model: String
  },
  lastLogin: Date,
  loginCount: Number (default: 0),
  deviceTokens: [{
    token: String,
    device: String,
    createdAt: Date
  }],
  createdAt: Date (default: Date.now),
  updatedAt: Date (default: Date.now)
}
```

---

## 🚨 Error Handling

### Common Error Responses

**Validation Error (400):**
```json
{
  "success": false,
  "error": "Validation failed",
  "details": [
    {
      "field": "email",
      "message": "Please provide a valid email address",
      "value": "invalid-email"
    }
  ]
}
```

**Authentication Error (401):**
```json
{
  "success": false,
  "error": "Access denied. No token provided."
}
```

**Authorization Error (403):**
```json
{
  "success": false,
  "error": "Access denied. Admin privileges required."
}
```

**Not Found Error (404):**
```json
{
  "success": false,
  "error": "Route not found"
}
```

**Server Error (500):**
```json
{
  "success": false,
  "error": "Internal Server Error"
}
```

---

## 🛡️ Security Features

- **Password Hashing:** bcrypt with 12 salt rounds
- **JWT Authentication:** Secure token-based authentication
- **Input Validation:** Comprehensive validation using express-validator
- **Rate Limiting:** 100 requests per 15 minutes per IP
- **CORS Protection:** Configurable cross-origin resource sharing
- **Helmet Security:** Security headers protection
- **Environment Variables:** Sensitive data protection

---

## 🧪 Testing the API

### Using curl

**Signup:**
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "TestPass123",
    "confirmPassword": "TestPass123"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123"
  }'
```

**Get Profile (replace TOKEN with actual JWT):**
```bash
curl -X GET http://localhost:3000/api/auth/profile \
  -H "Authorization: Bearer TOKEN"
```

---

## 📝 Environment Configuration

Create a `.env` file in the backend directory:

```env
# Server Configuration
NODE_ENV=development
PORT=3000

# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/easypark

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=7d

# Security Configuration
BCRYPT_ROUNDS=12

# API Configuration
API_PREFIX=/api/v1
```

---

## 🗄️ Database Setup

1. **Install MongoDB:**
   - Download from [MongoDB Community Server](https://www.mongodb.com/try/download/community)
   - Follow installation instructions for your OS

2. **Start MongoDB:**
   ```bash
   # Windows (as service)
   net start MongoDB
   
   # Or manually
   mongod --dbpath "C:\data\db"
   ```

3. **Create Database:**
   The database will be created automatically when the first user registers.

4. **MongoDB Shell Access:**
   ```bash
   mongosh mongodb://localhost:27017/easypark
   ```

---

## 🔄 Integration with Flutter App

### Update Flutter App to Use Node.js Backend

1. **Replace Firebase endpoints** with Node.js API calls
2. **Update authentication logic** to use JWT tokens
3. **Modify signup/login flows** to match the new API structure

### Example Flutter HTTP Client Setup:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/auth';
  
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': password,
        'phoneNumber': phoneNumber,
      }),
    );
    
    return jsonDecode(response.body);
  }
}
```

---

## 📞 Support

For technical support or questions about the API:
- Check the error messages in server logs
- Verify MongoDB is running
- Ensure environment variables are properly configured
- Check network connectivity and CORS settings

---

## 📄 License

This project is licensed under the MIT License.