@echo off
echo ======================================
echo    EasyPark Backend Setup Script
echo ======================================
echo.

echo [1/5] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)
echo ✅ Node.js is installed

echo.
echo [2/5] Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo ✅ Dependencies installed successfully

echo.
echo [3/5] Setting up environment variables...
if not exist .env (
    copy .env.example .env
    echo ✅ Created .env file from template
    echo ⚠️  Please update JWT_SECRET in .env file before production use!
) else (
    echo ✅ .env file already exists
)

echo.
echo [4/5] Checking MongoDB connection...
echo Starting MongoDB service...
net start MongoDB >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Could not start MongoDB service automatically
    echo Please ensure MongoDB is installed and start it manually:
    echo    - As a service: net start MongoDB
    echo    - Manually: mongod --dbpath "C:\data\db"
) else (
    echo ✅ MongoDB service started
)

echo.
echo [5/5] Initializing database with sample data...
call npm run init-db
if %errorlevel% neq 0 (
    echo ⚠️  Database initialization failed
    echo Please ensure MongoDB is running and try again manually:
    echo    npm run init-db
) else (
    echo ✅ Database initialized successfully
)

echo.
echo ======================================
echo       Setup Complete! 🎉
echo ======================================
echo.
echo To start the server:
echo   npm run dev     (development mode)
echo   npm start       (production mode)
echo.
echo Health check URL: http://localhost:3000/health
echo API Base URL: http://localhost:3000/api/auth
echo.
echo Test accounts created:
echo   admin@easypark.com : AdminPass123 (Admin)
echo   john.doe@example.com : UserPass123 (User)
echo   jane.smith@example.com : UserPass456 (User)
echo.
pause