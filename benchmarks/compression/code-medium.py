"""Flask REST API with authentication, rate limiting, and database access."""
import hashlib, hmac, json, os, time, functools, logging
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional, Tuple

from flask import Flask, jsonify, request, abort, g
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///app.db')
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-key-change-me')
db = SQLAlchemy(app)
logger = logging.getLogger(__name__)

class User(db.Model):
    """User model with authentication support."""
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)
    role = db.Column(db.String(20), default="user")
    last_login = db.Column(db.DateTime)

    def set_password(self, password: str) -> None:
        self.password_hash = generate_password_hash(password)

    def check_password(self, password: str) -> bool:
        return check_password_hash(self.password_hash, password)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id, "username": self.username,
            "email": self.email, "role": self.role,
            "created_at": self.created_at.isoformat(),
            "is_active": self.is_active,
        }


class Task(db.Model):
    """Task model linked to users."""
    __tablename__ = "tasks"
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(20), default="pending")
    priority = db.Column(db.Integer, default=0)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    due_date = db.Column(db.DateTime)
    completed_at = db.Column(db.DateTime)

    user = db.relationship("User", backref=db.backref("tasks", lazy=True))

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id, "title": self.title,
            "description": self.description, "status": self.status,
            "priority": self.priority, "user_id": self.user_id,
            "created_at": self.created_at.isoformat(),
            "due_date": self.due_date.isoformat() if self.due_date else None,
        }

# ── Rate limiting ──────────────────────────────────────────────────────
rate_limit_store: Dict[str, List[float]] = {}

def rate_limit(max_requests: int = 60, window: int = 60):
    """Decorator for rate limiting endpoints."""
    def decorator(f):
        @functools.wraps(f)
        def wrapper(*args, **kwargs):
            client_ip = request.remote_addr or "unknown"
            now = time.time()
            key = f"{client_ip}:{f.__name__}"
            timestamps = rate_limit_store.get(key, [])
            timestamps = [t for t in timestamps if now - t < window]
            if len(timestamps) >= max_requests:
                abort(429)
            timestamps.append(now)
            rate_limit_store[key] = timestamps
            return f(*args, **kwargs)
        return wrapper
    return decorator


def require_auth(f):
    """Decorator requiring valid authentication token."""
    @functools.wraps(f)
    def wrapper(*args, **kwargs):
        token = request.headers.get("Authorization", "").replace("Bearer ", "")
        if not token:
            return jsonify({"error": "Missing token"}), 401
        user = User.query.filter_by(username=token).first()
        if not user or not user.is_active:
            return jsonify({"error": "Invalid token"}), 401
        g.current_user = user
        return f(*args, **kwargs)
    return wrapper

# ── Routes ────────────────────────────────────────────────────────────
@app.route("/api/users", methods=["GET"])
@rate_limit(max_requests=100)
@require_auth
def list_users():
    """List all users with pagination."""
    page = request.args.get("page", 1, type=int)
    per_page = min(request.args.get("per_page", 20, type=int), 100)
    users = User.query.paginate(page=page, per_page=per_page)
    return jsonify({
        "users": [u.to_dict() for u in users.items],
        "total": users.total,
        "page": page,
        "pages": users.pages,
    })


@app.route("/api/users", methods=["POST"])
@rate_limit(max_requests=10)
def create_user():
    """Create a new user."""
    data = request.get_json()
    if not data or not all(k in data for k in ("username", "email", "password")):
        return jsonify({"error": "Missing required fields"}), 400
    if User.query.filter_by(username=data["username"]).first():
        return jsonify({"error": "Username taken"}), 409
    user = User(username=data["username"], email=data["email"])
    user.set_password(data["password"])
    db.session.add(user)
    db.session.commit()
    logger.info(f"Created user {user.username}")
    return jsonify(user.to_dict()), 201


@app.route("/api/tasks", methods=["GET"])
@require_auth
def list_tasks():
    """List tasks for current user with filtering."""
    status = request.args.get("status")
    query = Task.query.filter_by(user_id=g.current_user.id)
    if status:
        query = query.filter_by(status=status)
    tasks = query.order_by(Task.priority.desc(), Task.created_at.desc()).all()
    return jsonify({"tasks": [t.to_dict() for t in tasks]})


@app.route("/api/tasks", methods=["POST"])
@require_auth
def create_task():
    """Create a task for current user."""
    data = request.get_json()
    if not data or "title" not in data:
        return jsonify({"error": "Title required"}), 400
    task = Task(
        title=data["title"],
        description=data.get("description", ""),
        priority=data.get("priority", 0),
        user_id=g.current_user.id,
    )
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201


@app.route("/api/tasks/<int:task_id>", methods=["PUT"])
@require_auth
def update_task(task_id: int):
    """Update a task."""
    task = Task.query.get_or_404(task_id)
    if task.user_id != g.current_user.id:
        abort(403)
    data = request.get_json()
    for field in ("title", "description", "status", "priority"):
        if field in data:
            setattr(task, field, data[field])
    if data.get("status") == "completed":
        task.completed_at = datetime.utcnow()
    db.session.commit()
    return jsonify(task.to_dict())
