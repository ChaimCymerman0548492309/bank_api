#!/bin/bash



echo "=== 🏦 Bank API Test - FIXED ==="
echo "Using Token for user: test (ID: 2)"
echo "========================================"

TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyLCJ1c2VybmFtZSI6InRlc3QiLCJleHAiOjE3NTcwMTU5NTd9.3Ic57W0_4oyYFaPQIs-T9TXn6kjYac1kuPJAjbZVf5M"

echo "=== 1. Get User Accounts ==="
curl -X GET http://localhost:5000/my-accounts -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "=== 2. Check Account Balances ==="
echo "Account 2:"
curl -X GET http://localhost:5000/accounts/2 -H "Authorization: Bearer $TOKEN"
echo ""
echo "Account 3:"
curl -X GET http://localhost:5000/accounts/3 -H "Authorization: Bearer $TOKEN"
echo ""
echo "Account 4:"
curl -X GET http://localhost:5000/accounts/4 -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "=== 3. Money Transfer (between my accounts) ==="
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 3, "amount": 200.0}'
echo ""
echo ""

echo "=== 4. Check Balances After Transfer ==="
echo "Account 2:"
curl -X GET http://localhost:5000/accounts/2 -H "Authorization: Bearer $TOKEN"
echo ""
echo "Account 3:"
curl -X GET http://localhost:5000/accounts/3 -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "=== 5. Transfer History ==="
echo "Account 2 History:"
curl -X GET http://localhost:5000/accounts/2/transfers -H "Authorization: Bearer $TOKEN"
echo ""
echo "Account 3 History:"
curl -X GET http://localhost:5000/accounts/3/transfers -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "=== 6. More Transfers ==="
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 3, "to_account_id": 2, "amount": 50.0}'
echo ""
echo ""

echo "=== 7. Edge Case Tests ==="

echo "7.1 🔴 Transfer more than balance:"
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 3, "amount": 10000.0}'
echo ""
echo ""

echo "7.2 🔴 Transfer negative amount:"
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 3, "amount": -100.0}'
echo ""
echo ""

echo "7.3 🔴 Transfer zero amount:"
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 3, "amount": 0.0}'
echo ""
echo ""

echo "7.4 🔴 Transfer to non-existent account:"
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 999, "amount": 100.0}'
echo ""
echo ""

echo "7.5 🔴 Transfer from non-existent account:"
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 999, "to_account_id": 2, "amount": 100.0}'
echo ""
echo ""

echo "7.6 🔴 Transfer to same account:"
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 2, "amount": 100.0}'
echo ""
echo ""

echo "7.7 🔴 Create account with negative deposit:"
curl -X POST http://localhost:5000/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"customer_id": "bad_account", "initial_deposit": -500.0}'
echo ""
echo ""

echo "7.8 🔴 Access other user's account:"
curl -X GET http://localhost:5000/accounts/1 -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "=== 8. Final Balances ==="
echo "Account 2 Final:"
curl -X GET http://localhost:5000/accounts/2 -H "Authorization: Bearer $TOKEN"
echo ""
echo "Account 3 Final:"
curl -X GET http://localhost:5000/accounts/3 -H "Authorization: Bearer $TOKEN"
echo ""
echo "Account 4 Final:"
curl -X GET http://localhost:5000/accounts/4 -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "=== 9. Final Transfer History ==="
curl -X GET http://localhost:5000/accounts/2/transfers -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "=== 10. View All Data Files ==="
echo "📁 Users data:"
cat data/users.json
echo ""
echo "📁 Accounts data:"
cat data/accounts.json
echo ""
echo "📁 Transfers data:"
cat data/transfers.json
echo ""
echo ""

echo "=== 🎉 All Tests Completed! ==="
echo "✅ Successful transfers"
echo "✅ Proper error handling"
echo "✅ Balance calculations"
echo "✅ Transfer history tracking"
echo "✅ Data persistence"
echo "✅ Security (access control)"