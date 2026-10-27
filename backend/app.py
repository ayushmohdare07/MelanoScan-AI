from flask import Flask
from flask_cors import CORS

from routes.health import health_bp
from routes.predict import predict_bp

app = Flask(__name__)

# Allow Flutter Web / Chrome to communicate with Flask
CORS(app)

app.register_blueprint(health_bp)
app.register_blueprint(predict_bp)

app.config["MAX_CONTENT_LENGTH"] = 10 * 1024 * 1024


@app.route("/", methods=["GET"])
def home():
    return {
        "status": "ok",
        "message": "MelanoScan AI API is running"
    }, 200


if __name__ == "__main__":
    print("=" * 60)
    print("MELANOSCAN AI BACKEND")
    print("=" * 60)
    print("Server starting...")
    print("Health: http://127.0.0.1:5000/health")
    print("API:    http://127.0.0.1:5000/predict")

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )