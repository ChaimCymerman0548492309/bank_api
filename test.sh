#!/bin/bash

TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6InRlc3R1c2VyIiwiZXhwIjoxNzU3NDA3OTU2fQ.hYEYgRr_6AArQ9Bp4ihbnHnze6tP85kxrgLU69Cqc-0"
ACCOUNT_ID=1

curl -X POST http://127.0.0.1:5000/register \
     -H "Content-Type: application/json" \
     -d '{
           "username": "testuser",
           "password": "secret123",
           "initial_deposit": 500
         }'

curl -X POST http://127.0.0.1:5000/login \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser","password":"secret123"}'


echo "---- Deposit 200 ----"
curl -s -X POST http://127.0.0.1:5000/accounts/$ACCOUNT_ID/deposit \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"amount": 200}'

echo ""
echo "---- Withdraw 50 ----"
curl -s -X POST http://127.0.0.1:5000/accounts/$ACCOUNT_ID/withdraw \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"amount": 50}'

echo ""
echo "---- Check Balance ----"
curl -s -X GET http://127.0.0.1:5000/accounts/$ACCOUNT_ID \
     -H "Authorization: Bearer $TOKEN"
echo ""


echo "=== 1. Get User Accounts ==="
curl -X GET http://localhost:5000/my-accounts -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

echo "=== 2. Check Account Balances ==="
echo "Account 2:"
curl -X GET http://localhost:5000/accounts/2 -H "Authorization: Bearer $TOKEN"
echo ""


echo "=== 3. Money Transfer (between my accounts) ==="
curl -X POST http://localhost:5000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"from_account_id": 2, "to_account_id": 3, "amount": 200.0}'
echo ""
echo ""



echo "=== 5. Transfer History ==="
echo "Account 2 History:"
curl -X GET http://localhost:5000/accounts/2/transfers -H "Authorization: Bearer $TOKEN"
echo ""

echo "=== 8. Final Balances ==="
echo "Account 2 Final:"
curl -X GET http://localhost:5000/accounts/2 -H "Authorization: Bearer $TOKEN"
echo ""