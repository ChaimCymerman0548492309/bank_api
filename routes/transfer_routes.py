from flask import Blueprint, request, jsonify
from database import JSONDatabase
from auth import token_required

db = JSONDatabase()
transfer_bp = Blueprint('transfer_bp', __name__)

@transfer_bp.route('/transfers', methods=['POST'])
@token_required
def create_transfer():
    data = request.get_json()
    from_account_id = int(data.get('from_account_id'))
    to_account_id = int(data.get('to_account_id'))
    amount = float(data.get('amount'))

    if amount <= 0:
        return {"error": "Transfer amount must be positive"}, 400

    from_account = db.get_account(from_account_id)
    to_account = db.get_account(to_account_id)
    if not from_account or not to_account:
        return {"error": "One or both accounts not found"}, 404
    if from_account['user_id'] != request.user_id:
        return {"error": "Access denied"}, 403
    if from_account["balance"] < amount:
        return {"error": "Insufficient funds"}, 400

    new_from_balance = from_account["balance"] - amount
    new_to_balance = to_account["balance"] + amount
    db.update_account_balance(from_account_id, new_from_balance)
    db.update_account_balance(to_account_id, new_to_balance)
    transfer = db.create_transfer(from_account_id, to_account_id, amount)
    return {"message": "Transfer completed successfully", "transfer_id": transfer["id"], "new_balance": new_from_balance}, 201

@transfer_bp.route('/accounts/<int:account_id>/transfers', methods=['GET'])
@token_required
def get_transfer_history(account_id):
    account = db.get_account(account_id)
    if not account:
        return {"error": "Account not found"}, 404
    if account['user_id'] != request.user_id:
        return {"error": "Access denied"}, 403

    transfers = db.get_account_transfers(account_id)
    return transfers
