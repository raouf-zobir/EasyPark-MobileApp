# Network Connection Troubleshooting Guide

## Common Timeout Issues and Solutions

### 1. Android Emulator Connection Issues

If you're seeing timeout errors when trying to login:

#### **For Android Emulator:**
- The app should use `http://10.0.2.2:3000` (which it already does)
- Make sure your backend server is running on port 3000

#### **For Real Android Devices:**
- You need to use your computer's actual IP address
- Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Update the API service to use your IP: `http://192.168.1.XXX:3000`

### 2. Quick Checks

1. **Backend Server Status:**
   ```bash
   cd backend
   npm start
   ```

2. **Test Server Connection:**
   ```bash
   curl http://localhost:3000/health
   ```

3. **Check Port Usage:**
   ```bash
   netstat -an | findstr :3000
   ```

### 3. Development Solutions

#### **Option A: Use Test Connection Button**
- The login screen has a "Test Connection" button
- Use this to verify server connectivity before login attempts

#### **Option B: Manual IP Configuration**
If using a real Android device:
1. Find your computer's IP address
2. In `api_service.dart`, temporarily change the baseUrl to use your IP
3. Example: `return 'http://192.168.1.100:3000/api/auth';`

#### **Option C: Use ADB Port Forwarding**
For real devices, you can forward ports:
```bash
adb reverse tcp:3000 tcp:3000
```

### 4. Backend Configuration

The backend now supports these origins:
- `http://localhost:3000`
- `http://10.0.2.2:3000` (Android emulator)
- `http://127.0.0.1:3000`

### 5. Timeout Settings

Updated timeout values:
- Connection timeout: 10 seconds
- Request timeout: 15 seconds

These should provide better reliability while still being responsive.

### 6. Debug Information

The app now provides detailed logging:
- Connection test results
- API endpoint being used
- Specific error types (network, timeout, socket)

### 7. Testing Credentials

For testing, you can use:
- Email: `john.doe@example.com`
- Password: `UserPass123`

Or create a new account through the signup screen.