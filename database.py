import json
import os
from datetime import datetime

class JSONDatabase:
    def __init__(self):
        self.files = {
            'users': 'data/users.json',
            'accounts': 'data/accounts.json', 
            'transfers': 'data/transfers.json'
        }
        self._init_files()
    
    def _init_files(self):
        """Initialize all JSON files with empty structure"""
        for file_type, filename in self.files.items():
            if not os.path.exists(filename):
                default_data = []
                self._write_file(filename, default_data)
    
    def _read_file(self, filename):
        """Read data from a JSON file"""
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                data = json.load(f)
                # Ensure we always return a list
                return data if isinstance(data, list) else []
        except (FileNotFoundError, json.JSONDecodeError):
            return []
    
    def _write_file(self, filename, data):
        """Write data to a JSON file"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    
    def _get_next_id(self, data_list):
        """Get next available ID from a list of items"""
        if not data_list or not isinstance(data_list, list):
            return 1
        
        # Filter out items that don't have 'id' field
        valid_items = [item for item in data_list if isinstance(item, dict) and 'id' in item]
        
        if not valid_items:
            return 1
            
        return max(item['id'] for item in valid_items) + 1

    # User methods
    def create_user(self, username, hashed_password):
        """Create new user"""
        users = self._read_file(self.files['users'])
        
        # Check if username already exists
        if any(isinstance(user, dict) and user.get('username') == username for user in users):
            return None
        
        user = {
            'id': self._get_next_id(users),
            'username': username,
            'password': hashed_password,
            'created_at': datetime.now().isoformat()
        }
        
        users.append(user)
        self._write_file(self.files['users'], users)
        return user

    def get_user_by_username(self, username):
        """Get user by username"""
        users = self._read_file(self.files['users'])
        for user in users:
            if isinstance(user, dict) and user.get('username') == username:
                return user
        return None

    def get_user_by_id(self, user_id):
        """Get user by ID"""
        users = self._read_file(self.files['users'])
        for user in users:
            if isinstance(user, dict) and user.get('id') == user_id:
                return user
        return None

    # Account methods
    def create_account(self, user_id, customer_id, initial_deposit):
        """Create new account"""
        accounts = self._read_file(self.files['accounts'])
        
        account = {
            'id': self._get_next_id(accounts),
            'user_id': user_id,
            'customer_id': customer_id,
            'balance': initial_deposit,
            'created_at': datetime.now().isoformat()
        }
        
        accounts.append(account)
        self._write_file(self.files['accounts'], accounts)
        return account

    def get_account(self, account_id):
        """Get account by ID"""
        accounts = self._read_file(self.files['accounts'])
        for account in accounts:
            if isinstance(account, dict) and account.get('id') == account_id:
                return account
        return None

    def get_user_accounts(self, user_id):
        """Get all user accounts"""
        accounts = self._read_file(self.files['accounts'])
        return [acc for acc in accounts if isinstance(acc, dict) and acc.get('user_id') == user_id]

    def update_account_balance(self, account_id, new_balance):
        """Update account balance"""
        accounts = self._read_file(self.files['accounts'])
        
        for account in accounts:
            if isinstance(account, dict) and account.get('id') == account_id:
                account['balance'] = new_balance
                self._write_file(self.files['accounts'], accounts)
                return True
        return False

    # Transfer methods
    def create_transfer(self, from_account_id, to_account_id, amount):
        """Create new transfer record"""
        transfers = self._read_file(self.files['transfers'])
        
        transfer = {
            'id': self._get_next_id(transfers),
            'from_account_id': from_account_id,
            'to_account_id': to_account_id,
            'amount': amount,
            'timestamp': datetime.now().isoformat()
        }
        
        transfers.append(transfer)
        self._write_file(self.files['transfers'], transfers)
        return transfer

    def get_account_transfers(self, account_id):
        """Get all transfers for an account"""
        transfers = self._read_file(self.files['transfers'])
        return [t for t in transfers if isinstance(t, dict) and 
                (t.get('from_account_id') == account_id or t.get('to_account_id') == account_id)]

    def get_all_transfers(self):
        """Get complete transfer history"""
        return self._read_file(self.files['transfers'])