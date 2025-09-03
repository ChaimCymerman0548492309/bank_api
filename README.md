# Bank API - Complete Documentation

A secure RESTful API for a banking system with JWT authentication, user management, and financial operations.

## 📋 Table of Contents
- [Installation](#installation)
- [API Endpoints](#api-endpoints)
- [Error Handling](#error-handling)
- [Request/Response Examples](#requestresponse-examples)
- [Test Cases](#test-cases)

## 🚀 Installation

### Prerequisites
- Python 3.7+
- pip package manager

### Setup Instructions
```bash
# Clone or create project directory
mkdir bank_api
cd bank_api

# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install Flask==2.3.3 PyJWT==2.8.0 bcrypt==4.0.1

# Run the application
python app.py
```

The server will start at: `http://localhost:5000`

## 📊 API Endpoints

### Authentication Endpoints

#### 1. Register User
**POST** `/register`
```bash
curl -X POST http://localhost:5000/register \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123", "customer_id": "cust123", "initial_deposit": 1000.0}'
```

**Request Body:**
```json
{
  "username": "string (required)",
  "password": "string (required, min 6 chars)",
  "customer_id": "string (optional)",
  "initial_deposit": "number (optional, default: 0)"
}
```

**Response:**
```json
{
  "message": "User registered and account created successfully",
  "token": "jwt_token",
  "user_id": 1,
  "account": {
    "id": 1,
    "user_id": 1,
    "customer_id": "cust123",
    "balance": 1000.0,
    "created_at": "timestamp"
  }
}
```

#### 2. Login User
**POST** `/login`
```bash
curl -X POST http://localhost:5000/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123"}'
```

**Response:**
```json
{
  "message": "Login successful",
  "token": "jwt_token",
  "user_id": 1
}
```

### Account Management (Protected)

#### 3. Create Additional Account
**POST** `/accounts`
```bash
curl -X POST http://localhost:5000/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"customer_id": "cust456", "initial_deposit": 500.0}'
```

#### 4. Get User Accounts
**GET** `/my-accounts`
```bash
curl -X GET http://localhost:5000/my-accounts \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
[
  {
    "id": 1,
    "user_id": 1,
    "customer_id": "cust123",
    "balance": 1000.0,
    "created_at": "timestamp"
  }
]
```

#### 5. Get Account Balance
**GET** `/accounts/{account_id}`
```bash
curl -X GET http://localhost:5000/accounts/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
{
  "account_id": 1,
  "balance": 1000.0
}
```

### Transfer Operations (Protected)

#### 6. Transfer Money
**POST** `/transfers`
```bash
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"from_account_id": 1, "to_account_id": 2, "amount": 200.0}'
```

**Response:**
```json
{
  "message": "Transfer completed successfully",
  "transfer_id": 1,
  "new_balance": 800.0
}
```

#### 7. Get Transfer History
**GET** `/accounts/{account_id}/transfers`
```bash
curl -X GET http://localhost:5000/accounts/1/transfers \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Health Check (Public)

#### 8. Health Check
**GET** `/health`
```bash
curl -X GET http://localhost:5000/health
```

**Response:**
```json
{
  "status": "OK",
  "message": "Bank API is running"
}
```

## 🛡️ Error Handling

### Comprehensive Error Cases Handled

| Error Case | HTTP Status | Response Example | Description |
|------------|-------------|------------------|-------------|
| **Missing required fields** | 400 Bad Request | `{"error": "Username and password are required"}` | Required parameters missing in request |
| **Invalid password length** | 400 Bad Request | `{"error": "Password must be at least 6 characters"}` | Password too short |
| **Negative deposit amount** | 400 Bad Request | `{"error": "Initial deposit cannot be negative"}` | Invalid monetary amount |
| **Invalid amount format** | 400 Bad Request | `{"error": "Invalid initial deposit amount"}` | Non-numeric amount provided |
| **Username already exists** | 409 Conflict | `{"error": "Username already exists"}` | Duplicate username during registration |
| **Invalid credentials** | 401 Unauthorized | `{"error": "Invalid credentials"}` | Wrong username/password |
| **Missing JWT token** | 401 Unauthorized | `{"error": "Token is missing"}` | No authentication token provided |
| **Invalid/Expired token** | 401 Unauthorized | `{"error": "Token is invalid or expired"}` | Malformed or expired JWT token |
| **Account not found** | 404 Not Found | `{"error": "Account not found"}` | Non-existent account ID |
| **Access denied** | 403 Forbidden | `{"error": "Access denied"}` | User trying to access other user's data |
| **Insufficient funds** | 400 Bad Request | `{"error": "Insufficient funds"}` | Not enough balance for transfer |
| **Invalid account ID** | 400 Bad Request | `{"error": "Invalid account ID or amount"}` | Non-numeric or invalid account ID |
| **Transfer amount not positive** | 400 Bad Request | `{"error": "Transfer amount must be positive"}` | Zero or negative transfer amount |
| **One or both accounts not found** | 404 Not Found | `{"error": "One or both accounts not found"}` | Invalid source or destination account |
| **Database update failure** | 500 Internal Error | `{"error": "Failed to update sender account"}` | System-level database error |
| **Unexpected server error** | 500 Internal Error | `{"error": "Internal server error"}` | Generic unexpected error |

## 🔒 Security Features

- **JWT Authentication** - All protected endpoints require valid tokens
- **Password Hashing** - BCrypt encryption for stored passwords
- **Input Validation** - Comprehensive validation for all parameters
- **Access Control** - Users can only access their own accounts
- **Error Sanitization** - Detailed error messages without exposing sensitive data

## 💾 Data Storage

The API uses three separate JSON files:
- `users.json` - User credentials and information
- `accounts.json` - Bank account data
- `transfers.json` - Complete transfer history

## 🧪 Testing

Test the API with the provided curl commands or using tools like:
- Postman
- Thunder Client (VSCode)
- curl (command line)
- httpie

## ⚠️ Limitations

- This is a demo application not suitable for production
- JSON file storage has concurrency limitations
- No data encryption at rest
- No rate limiting implemented
- No password complexity requirements

## 📝 License

This project is for educational and demonstration purposes.