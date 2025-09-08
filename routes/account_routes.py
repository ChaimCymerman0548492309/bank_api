from flask import Blueprint, request, jsonify
from database import JSONDatabase
from auth import token_required

db = JSONDatabase()
account_bp = Blueprint('account_bp', __name__)

@account_bp.route('/accounts', methods=['POST'])
@token_required
def create_account():
    data = request.get_json()
    customer_id = data.get('customer_id')
    initial_deposit = float(data.get('initial_deposit', 0))

    if not customer_id:
        return {"error": "Customer ID is required"}, 400
    if initial_deposit < 0:
        return {"error": "Initial deposit cannot be negative"}, 400

    account = db.create_account(request.user_id, customer_id, initial_deposit)
    return {"message": "Account created successfully", "account": account}, 201

@account_bp.route('/accounts', methods=['GET'])
@token_required
def get_user_accounts():
    accounts = db.get_user_accounts(request.user_id)
    return accounts

@account_bp.route('/accounts/<int:account_id>', methods=['GET'])
@token_required
def get_account_balance(account_id):
    account = db.get_account(account_id)
    if not account:
        return {"error": "Account not found"}, 404
    if account['user_id'] != request.user_id:
        return {"error": "Access denied"}, 403
    return {"account_id": account["id"], "balance": account["balance"]}

@account_bp.route('/accounts/<int:account_id>/deposit', methods=['POST'])
@token_required
def deposit(account_id):
    data = request.get_json()
    amount = float(data.get('amount', 0))
    if amount <= 0:
        return {"error": "Deposit amount must be positive"}, 400

    account = db.get_account(account_id)
    if not account:
        return {"error": "Account not found"}, 404
    if account['user_id'] != request.user_id:
        return {"error": "Access denied"}, 403

    new_balance = account['balance'] + amount
    db.update_account_balance(account_id, new_balance)
    return {"message": "Deposit successful", "account_id": account_id, "new_balance": new_balance}, 200

@account_bp.route('/accounts/<int:account_id>/withdraw', methods=['POST'])
@token_required
def withdraw(account_id):
    data = request.get_json()
    amount = float(data.get('amount', 0))
    if amount <= 0:
        return {"error": "Withdrawal amount must be positive"}, 400

    account = db.get_account(account_id)
    if not account:
        return {"error": "Account not found"}, 404
    if account['user_id'] != request.user_id:
        return {"error": "Access denied"}, 403
    if account['balance'] < amount:
        return {"error": "Insufficient funds"}, 400

    new_balance = account['balance'] - amount
    db.update_account_balance(account_id, new_balance)
    return {"message": "Withdrawal successful", "account_id": account_id, "new_balance": new_balance}, 200
