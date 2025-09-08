from flask import Flask
from routes.auth_routes import auth_bp
from routes.account_routes import account_bp
from routes.transfer_routes import transfer_bp

app = Flask(__name__)

# Register blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(account_bp)
app.register_blueprint(transfer_bp)

@app.route('/health', methods=['GET'])
def health_check():
    return {"status": "OK", "message": "Bank API is running"}

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
