#!/bin/bash

echo "=== 🏦 Bank API Additional Tests ==="
echo "========================================"

# Test variables
BASE_URL="http://localhost:5000"

echo "=== 1. Registration Tests ==="

echo "1.1 ✅ Valid registration:"
curl -X POST $BASE_URL/register \
  -H "Content-Type: application/json" \
  -d '{"username": "newuser1", "password": "password123", "customer_id": "cust_new1", "initial_deposit": 1000.0}'
echo ""
echo ""

echo "1.2 ✅ Valid registration without optional fields:"
curl -X POST $BASE_URL/register \
  -H "Content-Type: application/json" \
  -d '{"username": "newuser2", "password": "password123"}'
echo ""
echo ""

echo "1.3 🔴 Registration - missing username:"
curl -X POST $BASE_URL/register \
  -H "Content-Type: application/json" \
  -d '{"password": "password123"}'
echo ""
echo ""

echo "1.4 🔴 Registration - missing password:"
curl -X POST $BASE_URL/register \
  -H "Content-Type: application/json" \
  -d '{"username": "newuser3"}'
echo ""
echo ""

echo "1.5 🔴 Registration - short password:"
curl -X POST $BASE_URL/register \
  -H "Content-Type: application/json" \
  -d '{"username": "newuser4", "password": "short"}'
echo ""
echo ""

echo "1.6 🔴 Registration - duplicate username:"
curl -X POST $BASE_URL/register \
  -H "Content-Type: application/json" \
  -d '{"username": "test", "password": "password123"}'
echo ""
echo ""

echo "1.7 🔴 Registration - negative deposit:"
curl -X POST $BASE_URL/register \
  -H "Content-Type: application/json" \
  -d '{"username": "newuser5", "password": "password123", "initial_deposit": -100.0}'
echo ""
echo ""

echo "=== 2. Login Tests ==="

echo "2.1 ✅ Valid login:"
curl -X POST $BASE_URL/login \
  -H "Content-Type: application/json" \
  -d '{"username": "test", "password": "password"}'
echo ""
echo ""

echo "2.2 🔴 Login - wrong password:"
curl -X POST $BASE_URL/login \
  -H "Content-Type: application/json" \
  -d '{"username": "test", "password": "wrongpassword"}'
echo ""
echo ""

echo "2.3 🔴 Login - non-existent user:"
curl -X POST $BASE_URL/login \
  -H "Content-Type: application/json" \
  -d '{"username": "nonexistent", "password": "password"}'
echo ""
echo ""

echo "2.4 🔴 Login - missing username:"
curl -X POST $BASE_URL/login \
  -H "Content-Type: application/json" \
  -d '{"password": "password"}'
echo ""
echo ""

echo "2.5 🔴 Login - missing password:"
curl -X POST $BASE_URL/login \
  -H "Content-Type: application/json" \
  -d '{"username": "test"}'
echo ""
echo ""

echo "=== 3. Account Creation Tests ==="

# Get token for new user
echo "Getting token for new user..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/login \
  -H "Content-Type: application/json" \
  -d '{"username": "test", "password": "password"}')
# השתמש ב-Token מההרשמה של test (שורה 1.6)
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjozLCJ1c2VybmFtZSI6InRlc3QiLCJleHAiOjE3NTc0MDY2MzF9.XuGRwBpGKn6wGI-5NQ4kpRKCVhzjucM4Y2s5MWZRlME"

echo "3.1 ✅ Create account with valid data:"
curl -X POST $BASE_URL/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"customer_id": "cust_test_new", "initial_deposit": 500.0}'
echo ""
echo ""

echo "3.2 ✅ Create account with zero deposit:"
curl -X POST $BASE_URL/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"customer_id": "cust_test_zero", "initial_deposit": 0.0}'
echo ""
echo ""

echo "3.3 🔴 Create account - missing customer_id:"
curl -X POST $BASE_URL/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"initial_deposit": 100.0}'
echo ""
echo ""

echo "3.4 🔴 Create account - negative deposit:"
curl -X POST $BASE_URL/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"customer_id": "cust_test_neg", "initial_deposit": -50.0}'
echo ""
echo ""

echo "=== 4. Transfer Edge Cases ==="

echo "4.1 🔴 Transfer - insufficient funds:"
curl -X POST $BASE_URL/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 3, "amount": 1000000.0}'
echo ""
echo ""

echo "4.2 🔴 Transfer - from account doesn't exist:"
curl -X POST $BASE_URL/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 9999, "to_account_id": 3, "amount": 100.0}'
echo ""
echo ""

echo "4.3 🔴 Transfer - to account doesn't exist:"
curl -X POST $BASE_URL/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 9999, "amount": 100.0}'
echo ""
echo ""

echo "4.4 🔴 Transfer - both accounts don't exist:"
curl -X POST $BASE_URL/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 9998, "to_account_id": 9999, "amount": 100.0}'
echo ""
echo ""

echo "4.5 🔴 Transfer - missing from_account_id:"
curl -X POST $BASE_URL/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"to_account_id": 3, "amount": 100.0}'
echo ""
echo ""

echo "4.6 🔴 Transfer - missing to_account_id:"
curl -X POST $BASE_URL/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "amount": 100.0}'
echo ""
echo ""

echo "4.7 🔴 Transfer - missing amount:"
curl -X POST $BASE_URL/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 3}'
echo ""
echo ""

echo "4.8 🔴 Transfer - invalid amount (string):"
curl -X POST $BASE_URL/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 3, "amount": "invalid"}'
echo ""
echo ""

echo "=== 5. Access Control Tests ==="

echo "5.1 🔴 Access other user's account transfers:"
curl -X GET $BASE_URL/accounts/1/transfers \
  -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "5.2 🔴 Transfer from other user's account:"
curl -X POST $BASE_URL/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 1, "to_account_id": 2, "amount": 100.0}'
echo ""
echo ""

echo "=== 6. Data Validation Tests ==="

echo "6.1 🔴 Get non-existent account:"
curl -X GET $BASE_URL/accounts/9999 \
  -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "6.2 🔴 Get transfers for non-existent account:"
curl -X GET $BASE_URL/accounts/9999/transfers \
  -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "=== 7. Health Check ==="
curl -X GET $BASE_URL/health
echo ""
echo ""

echo "=== 🎉 Additional Tests Completed! ==="
echo "✅ Registration validation"
echo "✅ Login validation" 
echo "✅ Account creation validation"
echo "✅ Transfer validation"
echo "✅ Access control"
echo "✅ Error handling"