#!/bin/bash

# Property Listing Application Setup Script
# This script helps you set up the entire application

echo "🏠 Property Listing Application Setup"
echo "====================================="
echo ""

# Check Node.js
echo "Checking prerequisites..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    echo "   Download from: https://nodejs.org/"
    exit 1
fi
echo "✓ Node.js is installed ($(node --version))"

# Check npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed."
    exit 1
fi
echo "✓ npm is installed ($(npm --version))"

# Check MySQL
if ! command -v mysql &> /dev/null; then
    echo "⚠️  MySQL command not found. Make sure MySQL is installed."
    echo "   You can still continue if MySQL is running."
else
    echo "✓ MySQL is installed"
fi

echo ""
echo "Step 1: Setting up backend..."
echo "------------------------------"

# Navigate to backend directory
cd backend || exit

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit backend/.env with your MySQL credentials"
    echo ""
    read -p "Press Enter after you've updated the .env file..."
fi

# Install backend dependencies
echo "Installing backend dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "✓ Backend dependencies installed successfully"
else
    echo "❌ Failed to install backend dependencies"
    exit 1
fi

# Go back to root
cd ..

echo ""
echo "Setup Complete! 🎉"
echo "=================="
echo ""
echo "Next Steps:"
echo "1. Make sure your MySQL database is set up:"
echo "   mysql -u root -p < schema.sql"
echo "   mysql -u root -p property_listing_db < sample_data.sql"
echo ""
echo "2. Start the backend server:"
echo "   cd backend && npm start"
echo ""
echo "3. Open the frontend in your browser:"
echo "   http://localhost:3000/index.html"
echo ""
echo "4. For detailed instructions, see FRONTEND_README.md"
echo ""
