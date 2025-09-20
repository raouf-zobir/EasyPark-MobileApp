# MongoDB Setup Instructions for Windows

## Option 1: Download and Install MongoDB (Recommended)

1. **Download MongoDB Community Server:**
   - Go to: https://www.mongodb.com/try/download/community
   - Select Windows and download the MSI installer
   - Run the installer and choose "Complete" installation
   - Make sure to check "Install MongoDB as a Service"

2. **Start MongoDB Service:**
   ```powershell
   # Run PowerShell as Administrator
   net start MongoDB
   ```

3. **Verify MongoDB is running:**
   ```powershell
   # Test connection
   mongosh
   ```

## Option 2: Use MongoDB with Docker (Alternative)

1. **Install Docker Desktop**
2. **Run MongoDB in Docker:**
   ```bash
   docker run -d -p 27017:27017 --name mongodb mongo:latest
   ```

## Option 3: Quick Fix - Start MongoDB Manually

1. **Find MongoDB installation directory** (usually in Program Files)
2. **Create data directory:**
   ```powershell
   mkdir C:\data\db
   ```

3. **Start MongoDB manually:**
   ```powershell
   "C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" --dbpath C:\data\db
   ```

## Option 4: Use MongoDB Atlas (Cloud - Free Tier)

1. **Go to:** https://www.mongodb.com/atlas
2. **Create free account**
3. **Create cluster**
4. **Update .env file** with Atlas connection string

## Quick Test Commands

After MongoDB is running, test with:
```bash
cd backend
npm run init-db
npm run dev
```

## Troubleshooting

- **Port 27017 in use:** Kill process using `netstat -ano | findstr :27017`
- **Permission denied:** Run PowerShell as Administrator
- **Path not found:** Verify MongoDB installation path