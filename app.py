from flask import Flask, request, jsonify
from database import JSONDatabase
from auth import hash_password, check_password, generate_token, token_required

app = Flask(__name__)
db = JSONDatabase()



@app.route('/register', methods=['POST'])
def register():
    """Register a new user and create first account"""
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        customer_id = data.get('customer_id', f"cust_{username}")
        initial_deposit = float(data.get('initial_deposit', 0))
        
        if not username or not password:
            return jsonify({"error": "Username and password are required"}), 400
        
        if len(password) < 6:
            return jsonify({"error": "Password must be at least 6 characters"}), 400
        
        if initial_deposit < 0:
            return jsonify({"error": "Initial deposit cannot be negative"}), 400
        
        # Hash password
        hashed_password = hash_password(password)
        
        # Create user
        user = db.create_user(username, hashed_password)
        if not user:
            return jsonify({"error": "Username already exists"}), 409
        
        # Create first account automatically
        account = db.create_account(user['id'], customer_id, initial_deposit)
        
        # Generate token
        token = generate_token(user['id'], username)
        
        return jsonify({
            "message": "User registered and account created successfully",
            "token": token,
            "user_id": user['id'],
            "account": account
        }), 201
        
    except ValueError:
        return jsonify({"error": "Invalid initial deposit amount"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500
@app.route('/login', methods=['POST'])
def login():
    """Login user"""
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({"error": "Username and password are required"}), 400
        
        # Get user from database
        user = db.get_user_by_username(username)
        if not user:
            return jsonify({"error": "Invalid credentials"}), 401
        
        # Check password
        if not check_password(password, user['password']):
            return jsonify({"error": "Invalid credentials"}), 401
        
        # Generate token
        token = generate_token(user['id'], username)
        
        return jsonify({
            "message": "Login successful",
            "token": token,
            "user_id": user['id']
        }), 200
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Add this route after the login route
@app.route('/accounts', methods=['POST'])
@token_required
def create_account():
    """Create a new bank account for the authenticated user"""
    try:
        data = request.get_json()
        customer_id = data.get('customer_id')
        initial_deposit = float(data.get('initial_deposit', 0))
        
        if not customer_id:
            return jsonify({"error": "Customer ID is required"}), 400
        
        if initial_deposit < 0:
            return jsonify({"error": "Initial deposit cannot be negative"}), 400
        
        # Create account for the logged-in user
        account = db.create_account(request.user_id, customer_id, initial_deposit)
        return jsonify({
            "message": "Account created successfully",
            "account": account
        }), 201
    
    except ValueError:
        return jsonify({"error": "Invalid initial deposit amount"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/my-accounts', methods=['GET'])
@token_required
def get_my_accounts():
    """Get all accounts for the authenticated user"""
    accounts = db.get_user_accounts(request.user_id)
    return jsonify(accounts)
@app.route('/accounts', methods=['GET'])
@token_required
def get_user_accounts():
    """Get all accounts for the authenticated user"""
    accounts = db.get_user_accounts(request.user_id)
    return jsonify(accounts)

@app.route('/accounts/<int:account_id>', methods=['GET'])
@token_required
def get_account_balance(account_id):
    """Get account balance (only if owned by user)"""
    account = db.get_account(account_id)
    if not account:
        return jsonify({"error": "Account not found"}), 404
    
    if account['user_id'] != request.user_id:
        return jsonify({"error": "Access denied"}), 403
    
    return jsonify({
        "account_id": account["id"],
        "balance": account["balance"]
    })
# Add these routes before the health check endpoint

@app.route('/transfers', methods=['POST'])
@token_required
def create_transfer():
    """Transfer money between two accounts"""
    try:
        data = request.get_json()
        from_account_id = int(data.get('from_account_id'))
        to_account_id = int(data.get('to_account_id'))
        amount = float(data.get('amount'))
        
        if amount <= 0:
            return jsonify({"error": "Transfer amount must be positive"}), 400
        
        # Check if accounts exist
        from_account = db.get_account(from_account_id)
        to_account = db.get_account(to_account_id)
        
        if not from_account or not to_account:
            return jsonify({"error": "One or both accounts not found"}), 404
        
        # Verify user owns the from_account
        if from_account['user_id'] != request.user_id:
            return jsonify({"error": "Access denied"}), 403
        
        # Check sufficient balance
        if from_account["balance"] < amount:
            return jsonify({"error": "Insufficient funds"}), 400
        
        # Execute transfer
        new_from_balance = from_account["balance"] - amount
        new_to_balance = to_account["balance"] + amount
        
        if not db.update_account_balance(from_account_id, new_from_balance):
            return jsonify({"error": "Failed to update sender account"}), 500
        
        if not db.update_account_balance(to_account_id, new_to_balance):
            # In case of failure - return money to sender account
            db.update_account_balance(from_account_id, from_account["balance"])
            return jsonify({"error": "Failed to update recipient account"}), 500
        
        # Record the transfer
        transfer = db.create_transfer(from_account_id, to_account_id, amount)
        
        return jsonify({
            "message": "Transfer completed successfully",
            "transfer_id": transfer["id"],
            "new_balance": new_from_balance
        }), 201
    
    except ValueError:
        return jsonify({"error": "Invalid account ID or amount"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/accounts/<int:account_id>/transfers', methods=['GET'])
@token_required
def get_transfer_history(account_id):
    """Returns transfer history for an account"""
    account = db.get_account(account_id)
    if not account:
        return jsonify({"error": "Account not found"}), 404
    
    # Verify user owns the account
    if account['user_id'] != request.user_id:
        return jsonify({"error": "Access denied"}), 403
    
    transfers = db.get_account_transfers(account_id)
    return jsonify(transfers)
    
# Health check (public)
@app.route('/health', methods=['GET'])
def health_check():
    """Check if system is active"""
    return jsonify({"status": "OK", "message": "Bank API is running"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)