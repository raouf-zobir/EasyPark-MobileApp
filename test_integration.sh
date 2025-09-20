#!/bin/bash

echo "🚀 EasyPark Integration Test Script"
echo "=================================="
echo ""

# Check if backend is running
echo "📡 Checking backend connection..."
curl -s http://localhost:3000/health > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Backend is running!"
    
    # Test health endpoint
    echo ""
    echo "🔍 Testing health endpoint..."
    curl -s http://localhost:3000/health | python -m json.tool
    
    echo ""
    echo "📊 Available test accounts:"
    echo "   📧 admin@easypark.com : AdminPass123 (Admin)"
    echo "   📧 john.doe@example.com : UserPass123 (User)"  
    echo "   📧 jane.smith@example.com : UserPass456 (User)"
    
    echo ""
    echo "🧪 Testing signup endpoint..."
    curl -s -X POST http://localhost:3000/api/auth/signup \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Test User",
        "email": "test@easypark.com",
        "password": "TestPass123",
        "confirmPassword": "TestPass123"
      }' | python -m json.tool
    
    echo ""
    echo "🧪 Testing login endpoint..."
    curl -s -X POST http://localhost:3000/api/auth/login \
      -H "Content-Type: application/json" \
      -d '{
        "email": "john.doe@example.com",
        "password": "UserPass123"
      }' | python -m json.tool
    
else
    echo "❌ Backend is not running!"
    echo ""
    echo "💡 To start the backend:"
    echo "   cd backend"
    echo "   npm run dev"
    echo ""
    echo "🔧 If you haven't set up the backend yet:"
    echo "   cd backend"
    echo "   setup.bat    (Windows)"
    echo "   npm install && npm run init-db && npm run dev    (Manual)"
fi

echo ""
echo "📱 Flutter App Integration:"
echo "   1. Make sure backend is running on http://localhost:3000"
echo "   2. Run: flutter pub get"
echo "   3. Run: flutter run"
echo ""
echo "🎯 Test the following in the app:"
echo "   • Create new account with signup form"
echo "   • Login with existing test accounts"
echo "   • Check error handling with invalid credentials"
echo "   • Verify navigation to main app after login"