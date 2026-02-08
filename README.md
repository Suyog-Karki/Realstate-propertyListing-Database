# 🏠 Property Listing Database Project

A full-stack property listing platform with MySQL database, Node.js/Express API, and responsive web frontend. Features role-based authentication (Admin, Seller, Buyer, Agent), property management, favorites system, and inquiry handling.

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Environment Configuration](#environment-configuration)
- [Running the Project](#running-the-project)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [API Endpoints](#api-endpoints)
- [Features & Roles](#features--roles)
- [Development](#development)
- [Deployment](#deployment)

---

## 🎯 Project Overview

A modern real estate listing platform that connects property owners, sellers, and buyers with a secure, role-based system for managing property listings, favorites, and inquiries.

### Key Technologies
- **Backend**: Node.js 14+ with Express.js
- **Database**: MySQL 5.7+
- **Frontend**: Vanilla JavaScript, HTML5, CSS3
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: bcryptjs for password hashing

### Highlights
- 🔐 **Secure Authentication**: JWT-based with role-based access control
- 🎨 **Responsive Design**: Works on desktop, tablet, and mobile
- 📊 **Multiple Dashboards**: Customized for Admin, Seller, and Buyer roles
- 🔍 **Advanced Search**: Filter by location, property type, and price range
- ❤️ **Favorites System**: Bookmark properties of interest
- 📧 **Inquiries Management**: Direct communication between buyers and sellers

---

## 🏗️ Architecture

```
Property Listing Platform
├── Database Layer (MySQL)
│   ├── Users (Admin, Seller, Buyer, Agent)
│   ├── Properties & Listings
│   ├── Locations
│   ├── Favorites (Many-to-Many)
│   ├── Inquiries
│   └── Property Images
│
├── API Layer (Node.js/Express)
│   ├── Authentication & Authorization
│   ├── CRUD Operations
│   ├── Search & Filter
│   ├── Favorites Management
│   └── Inquiry System
│
└── Presentation Layer (Frontend)
    ├── Public Pages (Home, Search, Statistics)
    ├── Login/Register
    └── Dashboards
        ├── Admin (view all, manage users)
        ├── Seller (list properties, view inquiries)
        └── Buyer (browse, favorite, inquire)
```

---

## � Prerequisites

- **Node.js** 14 or higher ([download](https://nodejs.org/))
- **npm** (comes with Node.js)
- **MySQL** 5.7 or higher ([download](https://www.mysql.com/downloads/))
- **Git** (for cloning the repository)

---

## 📥 Installation & Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd property-listing-db
```

### 2. Database Setup

Create a MySQL database and load the schema:

```bash
# Login to MySQL
mysql -u <your_username> -p

# Create database
CREATE DATABASE property_listing_db;
USE property_listing_db;
EXIT;

# Load schema from SQL files (in order)
mysql -u <your_username> -p property_listing_db < schema.sql
mysql -u <your_username> -p property_listing_db < auth_setup.sql
mysql -u <your_username> -p property_listing_db < sample_data.sql
```

Verify installation:

```bash
mysql -u <your_username> -p property_listing_db -e "SHOW TABLES;"
```

Should display 7 tables:
- users
- properties
- locations
- listings
- favorites
- inquiries
- property_images

### 3. Install Backend Dependencies

```bash
cd backend
npm install
```

This installs:
- **express** - Web framework
- **mysql2** - MySQL database driver
- **cors** - Cross-origin request handling
- **bcryptjs** - Password hashing (10+ salt rounds)
- **jsonwebtoken** - JWT authentication
- **dotenv** - Environment variable management
- **body-parser** - Request body parsing

---

## 🔐 Environment Configuration

Create a `.env` file in the `backend/` directory:

```env
# MySQL Database Configuration
DB_HOST=localhost
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=property_listing_db
DB_PORT=3306

# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your_secret_key_here_change_in_production
JWT_EXPIRATION=7d

# Logging
LOG_LEVEL=debug
```

**Important**: Never commit `.env` to version control. Add it to `.gitignore`

---

## 🚀 Running the Project

### Start the Backend Server

```bash
cd backend
npm start
```

Server will start on: **http://localhost:3000**

**Expected Output:**
```
Server is running on port 3000
Connected to MySQL database
```

### Access the Frontend

Open your browser:
```
http://localhost:3000/login.html
```

### Test the API

```bash
# Check if server is running
curl http://localhost:3000/api

# Fetch all listings
curl http://localhost:3000/api/listings | jq

# User login (with your credentials)
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"yourpassword"}'
```

### Stop the Server

Press `Ctrl+C` in the terminal running the server

---

---

## 📁 Project Structure

```
property-listing-db/
│
├── README.md                      # This file
├── .gitignore                     # Git ignore rules
├── package.json                   # Project metadata
│
├── backend/
│   ├── server.js                  # Express server entry point
│   ├── package.json               # Backend dependencies
│   ├── .env                       # Environment variables (NOT in git)
│   ├── config/
│   │   └── database.js            # MySQL connection configuration
│   └── routes/
│       ├── auth.js                # User authentication & authorization
│       ├── listings.js            # Property listing CRUD operations
│       ├── favorites.js           # Favorites management
│       ├── inquiries.js           # Inquiry system
│       ├── search.js              # Search & filter functionality
│       └── users.js               # Admin user management
│
├── frontend/
│   ├── index.html                 # Home page
│   ├── login.html                 # Login & registration
│   ├── search.html                # Property search
│   ├── statistics.html            # Market statistics
│   ├── listing-detail.html        # Property detail view
│   ├── admin-dashboard.html       # Admin panel
│   ├── seller-dashboard.html      # Seller panel
│   ├── buyer-dashboard.html       # Buyer panel
│   ├── css/
│   │   └── styles.css             # Global styling
│   └── js/
│       ├── config.js              # Frontend API configuration
│       ├── app.js                 # Home page logic
│       ├── search.js              # Search functionality
│       ├── statistics.js          # Statistics page
│       ├── detail.js              # Detail page logic
│       ├── dashboard.js           # Dashboard utilities
│       └── auth.js                # Authentication helpers
│
└── database/
    ├── schema.sql                 # Database structure & tables
    ├── auth_setup.sql             # Initial user setup
    ├── sample_data.sql            # Sample property data
    ├── queries.sql                # Example queries & usage patterns
    ├── views_procedures.sql       # Database views & stored procedures
    └── triggers_constraints.sql   # Database triggers & constraints
```

---

## 🗄️ Database Schema

### 7 Core Tables

#### **users**
```sql
- id (Primary Key)
- name
- email (Unique)
- password (bcrypt hashed)
- phone
- address
- role (admin, seller, buyer, agent)
- is_active
- created_at, updated_at
```

#### **properties**
```sql
- id (Primary Key)
- owner_id (Foreign Key → users)
- type (Apartment, House, Condo, Townhouse, etc.)
- description
- created_at
```

#### **locations**
```sql
- id (Primary Key)
- city
- area
- address
```

#### **listings**
```sql
- id (Primary Key)
- property_id (Foreign Key → properties)
- location_id (Foreign Key → locations)
- price
- status (active, pending, sold, inactive)
- created_at, updated_at
```

#### **favorites**
```sql
- user_id (Foreign Key → users)
- listing_id (Foreign Key → listings)
- Composite Primary Key: (user_id, listing_id)
```

#### **inquiries**
```sql
- id (Primary Key)
- user_id (Foreign Key → users)
- listing_id (Foreign Key → listings)
- message
- status
- created_at
```

#### **property_images**
```sql
- id (Primary Key)
- listing_id (Foreign Key → listings)
- image_url
```

### Database Relationships

```
users ──(1:M)──> properties
properties ──(1:M)──> listings
locations ──(1:M)──> listings
listings ──(M:M)──> users (via favorites)
listings ──(1:M)──> inquiries
listings ──(1:M)──> property_images
```

### Normalization
- ✅ **First Normal Form (1NF)**: All attributes are atomic
- ✅ **Second Normal Form (2NF)**: No partial dependencies
- ✅ **Third Normal Form (3NF)**: No transitive dependencies

---

---

## ✨ Features

### For All Users
- 🏠 **Browse Properties**: View all available properties
- 🔍 **Advanced Search**: Filter by location, type, price range, status
- 📊 **Market Statistics**: View property market trends and analysis
- 🔐 **Secure Authentication**: JWT-based login and registration
- 👤 **User Profiles**: Manage personal information and preferences

### For Sellers
- 📝 **Create Listings**: Add new properties with details and images
- ✏️ **Manage Properties**: Edit and delete your listings
- 📧 **View Inquiries**: See inquiries from interested buyers
- 📊 **Analytics**: Track favorites and inquiry statistics
- 🎯 **Property Status**: Mark properties as active, pending, sold, or inactive

### For Buyers
- ❤️ **Favorites System**: Bookmark properties of interest
- 💬 **Send Inquiries**: Contact sellers directly about properties
- 📋 **Track Inquiries**: Monitor inquiry status and responses
- 🔔 **Notifications**: Get updates on favorite properties
- 🗂️ **Organize Wishlist**: Manage saved properties

### For Admins
- 👥 **User Management**: Create, edit, and manage all users
- 📊 **View All Listings**: Complete overview of all properties
- 🔍 **Search & Filter**: Advanced filtering and search capabilities
- 📈 **Platform Statistics**: Monitor platform usage and trends
- 🛡️ **System Control**: Full administrative access

---

## 🎨 Features & Dashboards

### Role-Based Access Control (RBAC)

The platform supports 4 user roles with different permissions:

#### **Admin Dashboard**
- View all property listings
- Manage all users (create, edit, delete)
- View all inquiries across the platform
- Platform statistics and analytics
- Search and filter all data

#### **Seller Dashboard**
- List your own properties
- Create new listings with details
- Edit and delete your listings
- View inquiries from buyers
- Track favorites on your properties
- Property statistics

#### **Buyer Dashboard**
- Browse all available properties
- Search with advanced filters
- Add properties to favorites
- Send inquiries to sellers
- Track sent inquiries
- View favorite properties

---

## 📡 API Endpoints

### Authentication Routes

```
POST   /api/auth/register              Register new user account
POST   /api/auth/login                 User login (returns JWT token)
GET    /api/auth/me                    Get current user profile
PUT    /api/auth/profile               Update user profile
PUT    /api/auth/change-password       Change user password
```

### Admin Routes

```
GET    /api/auth/admin/users           Get all users (admin only)
PUT    /api/auth/admin/users/:id/role  Update user role (admin only)
DELETE /api/auth/admin/users/:id       Delete user (admin only)
```

### Property Listings Routes

```
GET    /api/listings                   Get all listings (paginated)
GET    /api/listings/:id               Get specific listing details
GET    /api/listings/seller/my-listings Get seller's listings
POST   /api/listings                   Create new listing (seller/admin)
PUT    /api/listings/:id               Update listing (seller/admin)
DELETE /api/listings/:id               Delete listing (seller/admin)
```

### Favorites Routes

```
GET    /api/favorites                  Get user's favorite listings
POST   /api/favorites                  Add listing to favorites
DELETE /api/favorites/listing/:id      Remove from favorites
```

### Inquiries Routes

```
GET    /api/inquiries                  Get user's inquiries
GET    /api/inquiries/listing/:id      Get inquiries for specific listing
POST   /api/inquiries                  Send inquiry to seller
```

### Search Route

```
GET    /api/search?city=&type=&minPrice=&maxPrice=&status=
       Advanced search with optional filters
```

---

## 🔐 Security Features

- ✅ **Password Hashing**: bcryptjs with 10+ salt rounds
- ✅ **JWT Authentication**: Secure token-based auth with expiration
- ✅ **Role-Based Access**: Granular permissions per role
- ✅ **Protected Routes**: Dashboard pages require authentication
- ✅ **CORS Security**: Configured for safe cross-origin requests
- ✅ **Input Validation**: Server-side validation on all inputs
- ✅ **SQL Injection Prevention**: Parameterized queries

---

## 🐛 Troubleshooting

### Server Won't Start / Port 3000 Already in Use

```bash
# Find and kill the process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use a different port by modifying backend/server.js
```

### MySQL Connection Error

```bash
# Verify MySQL is running
mysql -u <username> -p -e "SELECT 1"

# Verify database exists
mysql -u <username> -p -e "SHOW DATABASES LIKE 'property_listing_db';"

# Verify credentials in .env file match MySQL setup
```

### Module Not Found Error

```bash
# Reinstall dependencies
cd backend
rm -rf node_modules package-lock.json
npm install
```

### CORS Error

Ensure your frontend is making requests to `http://localhost:3000`

Check `backend/server.js` for CORS configuration:

```javascript
app.use(cors({
  origin: 'http://localhost:3000',
  credentials: true
}));
```

### JWT Token Errors

- Make sure `.env` file has `JWT_SECRET` configured
- Check if token is being sent in Authorization header: `Bearer <token>`
- Verify JWT expiration setting in `.env`

---

## 📚 Sample Data

The project includes sample data SQL files to help you get started:

- **auth_setup.sql**: Creates user accounts with different roles
- **sample_data.sql**: Populates the database with property listings, images, inquiries, and favorites

To reset to original state:

```bash
mysql -u <username> -p property_listing_db < schema.sql
mysql -u <username> -p property_listing_db < auth_setup.sql
mysql -u <username> -p property_listing_db < sample_data.sql
```

---

## 🔧 Development

### Code Structure

**Backend** (`backend/routes/auth.js`):
- User registration with password hashing
- JWT token generation and validation
- Role-based middleware for protected routes
- Admin user management endpoints

**Frontend** (`frontend/js/`):
- Modular JavaScript with separate files per page
- Token storage in localStorage
- API calls with proper error handling
- Role-based UI rendering

### Making API Requests

Example using `fetch()`:

```javascript
// Get all listings
fetch('http://localhost:3000/api/listings')
  .then(res => res.json())
  .then(data => console.log(data));

// Create new listing (requires auth)
const token = localStorage.getItem('token');
fetch('http://localhost:3000/api/listings', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    property_id: 1,
    location_id: 1,
    price: 5000000,
    status: 'active'
  })
})
.then(res => res.json())
.then(data => console.log(data));
```

---

## 🚢 Deployment

### Prepare for Production

1. **Update Environment Variables**
   ```bash
   # Set secure JWT_SECRET
   JWT_SECRET=your_very_secure_random_string_here
   
   # Use production database credentials
   DB_USER=prod_user
   DB_PASSWORD=secure_password
   
   # Set NODE_ENV to production
   NODE_ENV=production
   ```

2. **Install Production Dependencies**
   ```bash
   cd backend
   npm install --production
   ```

3. **Run Database Migrations**
   ```bash
   mysql -u <username> -p property_listing_db < schema.sql
   ```



---

## 📋 Checklist Before Deployment

- [ ] Database schema loaded successfully
- [ ] MySQL credentials configured in `.env`
- [ ] JWT_SECRET set to secure random value
- [ ] All dependencies installed (`npm install`)
- [ ] Backend server starts without errors (`npm start`)
- [ ] API endpoints respond correctly
- [ ] Frontend can connect to backend
- [ ] Login/registration works
- [ ] Role-based access control functional
- [ ] `.env` file is in `.gitignore`
- [ ] `.env` file is NOT committed to git
- [ ] NODE_ENV set appropriately
- [ ] CORS configured for your domain

---

## 📄 License

MIT License - Feel free to use this project for learning and development.

---

## 📞 Support

For issues, questions, or suggestions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review the API endpoint documentation
3. Check the database schema and relationships
4. Create an issue in the repository

---

## 🎉 Summary

A complete, production-ready property listing platform featuring:

| Component | Technology | Status |
|-----------|-----------|--------|
| Backend API | Node.js + Express | ✅ Complete |
| Database | MySQL 5.7+ | ✅ Normalized (3NF) |
| Frontend | HTML5 + CSS3 + JavaScript | ✅ Responsive |
| Authentication | JWT + bcryptjs | ✅ Secure |
| Features | 20+ API endpoints | ✅ Full CRUD |
| User Roles | Admin, Seller, Buyer, Agent | ✅ RBAC Implemented |

---

**Happy coding! 🚀**
# Realstate-propertyListing-Database
