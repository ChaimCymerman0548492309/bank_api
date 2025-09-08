from flask import Blueprint, request, jsonify
from database import JSONDatabase
from auth import hash_password, check_password, generate_token

db = JSONDatabase()
auth_bp = Blueprint('auth_bp', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    customer_id = data.get('customer_id', f"cust_{username}")
    initial_deposit = float(data.get('initial_deposit', 0))

    if not username or not password:
        return {"error": "Username and password are required"}, 400
    if len(password) < 6:
        return {"error": "Password must be at least 6 characters"}, 400
    if initial_deposit < 0:
        return {"error": "Initial deposit cannot be negative"}, 400

    hashed_password = hash_password(password)
    user = db.create_user(username, hashed_password)
    if not user:
        return {"error": "Username already exists"}, 409

    account = db.create_account(user['id'], customer_id, initial_deposit)
    token = generate_token(user['id'], username)

    return {
        "message": "User registered and account created successfully",
        "token": token,
        "user_id": user['id'],
        "account": account
    }, 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return {"error": "Username and password are required"}, 400

    user = db.get_user_by_username(username)
    if not user or not check_password(password, user['password']):
        return {"error": "Invalid credentials"}, 401

    token = generate_token(user['id'], username)
    return {"message": "Login successful", "token": token, "user_id": user['id']}, 200
