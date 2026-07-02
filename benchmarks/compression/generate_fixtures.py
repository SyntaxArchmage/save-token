#!/usr/bin/env python3
"""Generate deterministic test fixtures for compression benchmarking.

Creates realistic data for each content type at multiple sizes.
All output is deterministic (seeded random) for reproducibility.
"""
import json, os, random, textwrap

DIR = os.path.dirname(os.path.abspath(__file__))
random.seed(42)

def write(name, content):
    path = os.path.join(DIR, name)
    with open(path, "w") as f:
        f.write(content)
    print(f"  {name}: {len(content):,} bytes, {content.count(chr(10))} lines")


# ── Code fixtures ────────────────────────────────────────────────────────────

def gen_code_small():
    return textwrap.dedent('''\
    """Binary search with edge cases and validation."""
    from typing import List, Optional


    def binary_search(arr: List[int], target: int) -> Optional[int]:
        """Find target in sorted array. Returns index or None."""
        if not arr:
            return None
        left, right = 0, len(arr) - 1
        while left <= right:
            mid = (left + right) // 2
            if arr[mid] == target:
                return mid
            elif arr[mid] < target:
                left = mid + 1
            else:
                right = mid - 1
        return None


    def binary_search_recursive(arr: List[int], target: int,
                                 left: int = 0, right: int = None) -> Optional[int]:
        """Recursive binary search variant."""
        if right is None:
            right = len(arr) - 1
        if left > right:
            return None
        mid = (left + right) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            return binary_search_recursive(arr, target, mid + 1, right)
        else:
            return binary_search_recursive(arr, target, left, mid - 1)


    class SearchResult:
        """Container for search results with metadata."""

        def __init__(self, index: Optional[int], comparisons: int):
            self.index = index
            self.comparisons = comparisons
            self.found = index is not None

        def __repr__(self):
            status = f"found at {self.index}" if self.found else "not found"
            return f"SearchResult({status}, {self.comparisons} comparisons)"


    if __name__ == "__main__":
        import sys
        test_cases = [
            ([], 5, None),
            ([1], 1, 0),
            ([1, 3, 5, 7, 9], 5, 2),
            ([1, 3, 5, 7, 9], 4, None),
            (list(range(100)), 73, 73),
        ]
        passed = 0
        for arr, target, expected in test_cases:
            result = binary_search(arr, target)
            assert result == expected, f"Expected {expected}, got {result}"
            passed += 1
        print(f"All {passed} tests passed.")
    ''')


def gen_code_medium():
    lines = [
        '"""Flask REST API with authentication, rate limiting, and database access."""',
        'import hashlib, hmac, json, os, time, functools, logging',
        'from datetime import datetime, timedelta',
        'from typing import Any, Dict, List, Optional, Tuple',
        '',
        'from flask import Flask, jsonify, request, abort, g',
        'from flask_sqlalchemy import SQLAlchemy',
        'from werkzeug.security import generate_password_hash, check_password_hash',
        '',
        'app = Flask(__name__)',
        "app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///app.db')",
        "app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-key-change-me')",
        'db = SQLAlchemy(app)',
        'logger = logging.getLogger(__name__)',
        '',
    ]
    models = [
        'class User(db.Model):',
        '    """User model with authentication support."""',
        '    __tablename__ = "users"',
        '    id = db.Column(db.Integer, primary_key=True)',
        '    username = db.Column(db.String(80), unique=True, nullable=False)',
        '    email = db.Column(db.String(120), unique=True, nullable=False)',
        '    password_hash = db.Column(db.String(256), nullable=False)',
        '    created_at = db.Column(db.DateTime, default=datetime.utcnow)',
        '    is_active = db.Column(db.Boolean, default=True)',
        '    role = db.Column(db.String(20), default="user")',
        '    last_login = db.Column(db.DateTime)',
        '',
        '    def set_password(self, password: str) -> None:',
        '        self.password_hash = generate_password_hash(password)',
        '',
        '    def check_password(self, password: str) -> bool:',
        '        return check_password_hash(self.password_hash, password)',
        '',
        '    def to_dict(self) -> Dict[str, Any]:',
        '        return {',
        '            "id": self.id, "username": self.username,',
        '            "email": self.email, "role": self.role,',
        '            "created_at": self.created_at.isoformat(),',
        '            "is_active": self.is_active,',
        '        }',
        '',
        '',
        'class Task(db.Model):',
        '    """Task model linked to users."""',
        '    __tablename__ = "tasks"',
        '    id = db.Column(db.Integer, primary_key=True)',
        '    title = db.Column(db.String(200), nullable=False)',
        '    description = db.Column(db.Text)',
        '    status = db.Column(db.String(20), default="pending")',
        '    priority = db.Column(db.Integer, default=0)',
        '    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)',
        '    created_at = db.Column(db.DateTime, default=datetime.utcnow)',
        '    due_date = db.Column(db.DateTime)',
        '    completed_at = db.Column(db.DateTime)',
        '',
        '    user = db.relationship("User", backref=db.backref("tasks", lazy=True))',
        '',
        '    def to_dict(self) -> Dict[str, Any]:',
        '        return {',
        '            "id": self.id, "title": self.title,',
        '            "description": self.description, "status": self.status,',
        '            "priority": self.priority, "user_id": self.user_id,',
        '            "created_at": self.created_at.isoformat(),',
        '            "due_date": self.due_date.isoformat() if self.due_date else None,',
        '        }',
        '',
    ]
    decorators = [
        '# ── Rate limiting ──────────────────────────────────────────────────────',
        'rate_limit_store: Dict[str, List[float]] = {}',
        '',
        'def rate_limit(max_requests: int = 60, window: int = 60):',
        '    """Decorator for rate limiting endpoints."""',
        '    def decorator(f):',
        '        @functools.wraps(f)',
        '        def wrapper(*args, **kwargs):',
        '            client_ip = request.remote_addr or "unknown"',
        '            now = time.time()',
        '            key = f"{client_ip}:{f.__name__}"',
        '            timestamps = rate_limit_store.get(key, [])',
        '            timestamps = [t for t in timestamps if now - t < window]',
        '            if len(timestamps) >= max_requests:',
        '                abort(429)',
        '            timestamps.append(now)',
        '            rate_limit_store[key] = timestamps',
        '            return f(*args, **kwargs)',
        '        return wrapper',
        '    return decorator',
        '',
        '',
        'def require_auth(f):',
        '    """Decorator requiring valid authentication token."""',
        '    @functools.wraps(f)',
        '    def wrapper(*args, **kwargs):',
        '        token = request.headers.get("Authorization", "").replace("Bearer ", "")',
        '        if not token:',
        '            return jsonify({"error": "Missing token"}), 401',
        '        user = User.query.filter_by(username=token).first()',
        '        if not user or not user.is_active:',
        '            return jsonify({"error": "Invalid token"}), 401',
        '        g.current_user = user',
        '        return f(*args, **kwargs)',
        '    return wrapper',
        '',
    ]
    routes = [
        '# ── Routes ────────────────────────────────────────────────────────────',
        '@app.route("/api/users", methods=["GET"])',
        '@rate_limit(max_requests=100)',
        '@require_auth',
        'def list_users():',
        '    """List all users with pagination."""',
        '    page = request.args.get("page", 1, type=int)',
        '    per_page = min(request.args.get("per_page", 20, type=int), 100)',
        '    users = User.query.paginate(page=page, per_page=per_page)',
        '    return jsonify({',
        '        "users": [u.to_dict() for u in users.items],',
        '        "total": users.total,',
        '        "page": page,',
        '        "pages": users.pages,',
        '    })',
        '',
        '',
        '@app.route("/api/users", methods=["POST"])',
        '@rate_limit(max_requests=10)',
        'def create_user():',
        '    """Create a new user."""',
        '    data = request.get_json()',
        '    if not data or not all(k in data for k in ("username", "email", "password")):',
        '        return jsonify({"error": "Missing required fields"}), 400',
        '    if User.query.filter_by(username=data["username"]).first():',
        '        return jsonify({"error": "Username taken"}), 409',
        '    user = User(username=data["username"], email=data["email"])',
        '    user.set_password(data["password"])',
        '    db.session.add(user)',
        '    db.session.commit()',
        '    logger.info(f"Created user {user.username}")',
        '    return jsonify(user.to_dict()), 201',
        '',
        '',
        '@app.route("/api/tasks", methods=["GET"])',
        '@require_auth',
        'def list_tasks():',
        '    """List tasks for current user with filtering."""',
        '    status = request.args.get("status")',
        '    query = Task.query.filter_by(user_id=g.current_user.id)',
        '    if status:',
        '        query = query.filter_by(status=status)',
        '    tasks = query.order_by(Task.priority.desc(), Task.created_at.desc()).all()',
        '    return jsonify({"tasks": [t.to_dict() for t in tasks]})',
        '',
        '',
        '@app.route("/api/tasks", methods=["POST"])',
        '@require_auth',
        'def create_task():',
        '    """Create a task for current user."""',
        '    data = request.get_json()',
        '    if not data or "title" not in data:',
        '        return jsonify({"error": "Title required"}), 400',
        '    task = Task(',
        '        title=data["title"],',
        '        description=data.get("description", ""),',
        '        priority=data.get("priority", 0),',
        '        user_id=g.current_user.id,',
        '    )',
        '    db.session.add(task)',
        '    db.session.commit()',
        '    return jsonify(task.to_dict()), 201',
        '',
        '',
        '@app.route("/api/tasks/<int:task_id>", methods=["PUT"])',
        '@require_auth',
        'def update_task(task_id: int):',
        '    """Update a task."""',
        '    task = Task.query.get_or_404(task_id)',
        '    if task.user_id != g.current_user.id:',
        '        abort(403)',
        '    data = request.get_json()',
        '    for field in ("title", "description", "status", "priority"):',
        '        if field in data:',
        '            setattr(task, field, data[field])',
        '    if data.get("status") == "completed":',
        '        task.completed_at = datetime.utcnow()',
        '    db.session.commit()',
        '    return jsonify(task.to_dict())',
        '',
    ]
    lines.extend(models)
    lines.extend(decorators)
    lines.extend(routes)
    return "\n".join(lines)


def gen_code_large():
    parts = [gen_code_medium(), "\n\n"]
    test_class = [
        '# ── Test suite ─────────────────────────────────────────────────────────',
        'import unittest',
        'from unittest.mock import patch, MagicMock',
        '',
        'class TestUserAPI(unittest.TestCase):',
        '    """Comprehensive tests for user management endpoints."""',
        '',
        '    def setUp(self):',
        '        app.config["TESTING"] = True',
        '        app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///:memory:"',
        '        self.client = app.test_client()',
        '        with app.app_context():',
        '            db.create_all()',
        '',
        '    def tearDown(self):',
        '        with app.app_context():',
        '            db.session.remove()',
        '            db.drop_all()',
        '',
    ]
    methods = [
        ("test_create_user_success", [
            '        response = self.client.post("/api/users", json={',
            '            "username": "testuser", "email": "test@example.com",',
            '            "password": "securepass123"',
            '        })',
            '        self.assertEqual(response.status_code, 201)',
            '        data = response.get_json()',
            '        self.assertEqual(data["username"], "testuser")',
        ]),
        ("test_create_user_duplicate", [
            '        self.client.post("/api/users", json={',
            '            "username": "dup", "email": "dup@example.com", "password": "pass"',
            '        })',
            '        response = self.client.post("/api/users", json={',
            '            "username": "dup", "email": "dup2@example.com", "password": "pass"',
            '        })',
            '        self.assertEqual(response.status_code, 409)',
        ]),
        ("test_create_user_missing_fields", [
            '        response = self.client.post("/api/users", json={"username": "only"})',
            '        self.assertEqual(response.status_code, 400)',
        ]),
        ("test_list_users_unauthorized", [
            '        response = self.client.get("/api/users")',
            '        self.assertEqual(response.status_code, 401)',
        ]),
        ("test_list_users_pagination", [
            '        with app.app_context():',
            '            for i in range(25):',
            '                u = User(username=f"user{i}", email=f"u{i}@test.com")',
            '                u.set_password("pass")',
            '                db.session.add(u)',
            '            db.session.commit()',
            '        response = self.client.get("/api/users?page=2&per_page=10",',
            '                                  headers={"Authorization": "Bearer user0"})',
            '        data = response.get_json()',
            '        self.assertEqual(len(data["users"]), 10)',
            '        self.assertEqual(data["total"], 25)',
        ]),
    ]
    for name, body in methods:
        test_class.append(f'    def {name}(self):')
        test_class.extend(body)
        test_class.append('')

    # Add more test classes to reach ~500 lines
    task_tests = [
        '',
        'class TestTaskAPI(unittest.TestCase):',
        '    """Tests for task management endpoints."""',
        '',
        '    def setUp(self):',
        '        app.config["TESTING"] = True',
        '        self.client = app.test_client()',
        '        with app.app_context():',
        '            db.create_all()',
        '            u = User(username="taskuser", email="task@test.com")',
        '            u.set_password("pass")',
        '            db.session.add(u)',
        '            db.session.commit()',
        '',
    ]
    task_methods = [
        ("test_create_task", [
            '        response = self.client.post("/api/tasks", json={"title": "Test task"},',
            '                                   headers={"Authorization": "Bearer taskuser"})',
            '        self.assertEqual(response.status_code, 201)',
        ]),
        ("test_create_task_no_title", [
            '        response = self.client.post("/api/tasks", json={},',
            '                                   headers={"Authorization": "Bearer taskuser"})',
            '        self.assertEqual(response.status_code, 400)',
        ]),
        ("test_list_tasks_filter", [
            '        headers = {"Authorization": "Bearer taskuser"}',
            '        self.client.post("/api/tasks", json={"title": "A", "status": "done"}, headers=headers)',
            '        self.client.post("/api/tasks", json={"title": "B", "status": "pending"}, headers=headers)',
            '        response = self.client.get("/api/tasks?status=pending", headers=headers)',
            '        data = response.get_json()',
            '        self.assertGreater(len(data["tasks"]), 0)',
        ]),
        ("test_update_task", [
            '        headers = {"Authorization": "Bearer taskuser"}',
            '        create = self.client.post("/api/tasks", json={"title": "Update me"}, headers=headers)',
            '        task_id = create.get_json()["id"]',
            '        response = self.client.put(f"/api/tasks/{task_id}",',
            '                                  json={"status": "completed"}, headers=headers)',
            '        self.assertEqual(response.status_code, 200)',
            '        self.assertEqual(response.get_json()["status"], "completed")',
        ]),
        ("test_update_task_forbidden", [
            '        headers = {"Authorization": "Bearer taskuser"}',
            '        create = self.client.post("/api/tasks", json={"title": "Mine"}, headers=headers)',
            '        task_id = create.get_json()["id"]',
            '        with app.app_context():',
            '            u2 = User(username="other", email="other@test.com")',
            '            u2.set_password("pass")',
            '            db.session.add(u2)',
            '            db.session.commit()',
            '        response = self.client.put(f"/api/tasks/{task_id}",',
            '                                  json={"status": "done"},',
            '                                  headers={"Authorization": "Bearer other"})',
            '        self.assertEqual(response.status_code, 403)',
        ]),
    ]
    for name, body in task_methods:
        task_tests.append(f'    def {name}(self):')
        task_tests.extend(body)
        task_tests.append('')

    task_tests.append('')
    task_tests.append('if __name__ == "__main__":')
    task_tests.append('    unittest.main()')

    parts.append("\n".join(test_class))
    parts.append("\n".join(task_tests))
    return "".join(parts)


# ── JSON fixtures ────────────────────────────────────────────────────────────

def gen_json(n):
    statuses = ["active", "inactive", "suspended", "pending_verification"]
    departments = ["engineering", "product", "design", "marketing", "sales", "support"]
    roles = ["admin", "editor", "viewer", "manager", "contributor"]
    users = []
    for i in range(n):
        users.append({
            "id": i + 1,
            "username": f"user_{i+1:04d}",
            "email": f"user{i+1}@company.example.com",
            "full_name": f"User {random.choice(['Alice','Bob','Charlie','Diana','Eve','Frank','Grace','Hank'])} {random.choice(['Smith','Jones','Brown','Davis','Wilson','Taylor'])}",
            "status": random.choice(statuses),
            "department": random.choice(departments),
            "role": random.choice(roles),
            "created_at": f"2026-{random.randint(1,6):02d}-{random.randint(1,28):02d}T{random.randint(0,23):02d}:{random.randint(0,59):02d}:00Z",
            "last_login": f"2026-07-{random.randint(1,2):02d}T{random.randint(0,23):02d}:{random.randint(0,59):02d}:00Z",
            "metadata": {
                "login_count": random.randint(1, 500),
                "api_calls_today": random.randint(0, 100),
                "storage_used_mb": round(random.uniform(0, 5000), 1),
                "preferences": {
                    "theme": random.choice(["light", "dark", "auto"]),
                    "language": random.choice(["en", "zh", "ja", "es", "de", "fr"]),
                    "notifications": random.choice([True, False]),
                },
            },
        })
    return json.dumps({"users": users, "total": n, "page": 1, "per_page": n}, indent=2)


# ── Log fixtures ─────────────────────────────────────────────────────────────

def gen_logs(n):
    levels = ["INFO"] * 15 + ["DEBUG"] * 5 + ["WARN"] * 3 + ["ERROR"] * 2
    modules = ["app.server", "db.connection", "auth.middleware", "api.handler",
               "cache.redis", "worker.queue", "scheduler.cron", "storage.s3"]
    info_msgs = [
        "Request processed successfully",
        "Database query completed in {ms}ms",
        "Cache hit for key={key}",
        "User {uid} authenticated via OAuth",
        "Background job {jid} enqueued",
        "Health check passed",
        "Connection pool: {n}/50 active",
        "Rate limit check: {n}/100 requests in window",
        "File uploaded: {size}KB to bucket {bucket}",
        "Session created for user {uid}",
    ]
    error_msgs = [
        "Connection refused: db-primary:5432",
        "Timeout after 30s waiting for response from upstream",
        "IntegrityError: duplicate key value violates unique constraint",
        "PermissionDenied: user {uid} cannot access resource {rid}",
        "OutOfMemoryError: heap space exhausted (used: {n}MB / 512MB)",
    ]
    lines = []
    for i in range(n):
        ts = f"2026-07-02 {10 + i * 8 // n:02d}:{(i * 37) % 60:02d}:{(i * 13) % 60:02d}.{random.randint(100,999)}"
        level = random.choice(levels)
        module = random.choice(modules)
        if level == "ERROR":
            msg = random.choice(error_msgs).format(uid=random.randint(1000,9999),
                rid=random.randint(1,100), n=random.randint(200,500))
            lines.append(f"[{ts}] {level}  {module} - {msg}")
            if random.random() < 0.5:
                lines.append(f"  Traceback (most recent call last):")
                lines.append(f'    File "/app/{module.replace(".", "/")}.py", line {random.randint(50,300)}, in handle_request')
                lines.append(f"      result = process(data)")
                lines.append(f'    File "/app/core/processor.py", line {random.randint(10,100)}, in process')
                lines.append(f"      raise {random.choice(['ValueError', 'RuntimeError', 'ConnectionError'])}('{msg[:40]}')")
        elif level == "WARN":
            lines.append(f"[{ts}] {level}  {module} - Slow query detected: {random.randint(200,5000)}ms for SELECT on {random.choice(['users','tasks','events','logs'])}")
        else:
            msg = random.choice(info_msgs).format(ms=random.randint(1,50),
                key=f"user:{random.randint(1,999)}", uid=random.randint(1000,9999),
                jid=f"job-{random.randint(1,99999):05d}", n=random.randint(5,45),
                size=random.randint(10,5000), bucket=random.choice(["uploads","assets","backups"]))
            lines.append(f"[{ts}] {level}  {module} - {msg}")
    return "\n".join(lines) + "\n"


# ── Diff fixtures ────────────────────────────────────────────────────────────

def gen_diff(n_hunks):
    files = [
        ("src/api/handler.py", "python"),
        ("src/models/user.py", "python"),
        ("src/utils/cache.py", "python"),
        ("tests/test_api.py", "python"),
        ("config/settings.yaml", "yaml"),
    ]
    lines = []
    for fname, lang in files[:max(1, n_hunks // 3)]:
        lines.append(f"diff --git a/{fname} b/{fname}")
        lines.append(f"index {random.randint(1000000,9999999):07x}..{random.randint(1000000,9999999):07x} 100644")
        lines.append(f"--- a/{fname}")
        lines.append(f"+++ b/{fname}")
        for h in range(max(1, n_hunks // len(files))):
            start = 20 + h * 30
            lines.append(f"@@ -{start},12 +{start},15 @@ def handle_{random.choice(['request','response','error','auth'])}():")
            for _ in range(random.randint(2, 5)):
                lines.append(f"     {random.choice(['result = process(data)', 'logger.info(msg)', 'return response', 'db.session.commit()', 'cache.set(key, value)'])}")
            lines.append(f"-    old_value = get_config('deprecated_key')")
            lines.append(f"-    if old_value:")
            lines.append(f"-        process_legacy(old_value)")
            lines.append(f"+    new_value = get_config('updated_key', default=None)")
            lines.append(f"+    if new_value is not None:")
            lines.append(f"+        process_modern(new_value)")
            lines.append(f"+        metrics.record('config_migration', 1)")
            for _ in range(random.randint(1, 3)):
                lines.append(f"     {random.choice(['validate(result)', 'cleanup()', 'return True', 'emit_event(event)'])}")
    return "\n".join(lines) + "\n"


# ── HTML fixtures ────────────────────────────────────────────────────────────

def gen_html(n_sections):
    sections = []
    for i in range(n_sections):
        title = random.choice(["Getting Started", "Installation", "Configuration",
            "API Reference", "Deployment", "Troubleshooting", "FAQ", "Contributing",
            "Architecture", "Security", "Performance", "Testing"])
        paragraphs = "\n".join(
            f"        <p>{random.choice(['This section covers', 'Here we describe', 'Learn about', 'Understand how to use'])} "
            f"the {random.choice(['core', 'advanced', 'basic', 'essential'])} "
            f"{random.choice(['features', 'concepts', 'patterns', 'workflows'])} "
            f"of the {random.choice(['system', 'platform', 'framework', 'application'])}. "
            f"{'It integrates with ' + random.choice(['Redis', 'PostgreSQL', 'Docker', 'Kubernetes', 'AWS S3']) + ' for ' + random.choice(['caching', 'storage', 'deployment', 'orchestration']) + '.' if random.random() < 0.3 else ''}</p>"
            for _ in range(random.randint(2, 4))
        )
        code_block = ""
        if random.random() < 0.4:
            code_block = f"""
        <pre><code class="language-python">
def {random.choice(['setup', 'configure', 'initialize', 'deploy'])}():
    config = load_config("settings.yaml")
    db = Database(config["database_url"])
    return App(config=config, db=db)
        </code></pre>"""
        sections.append(f"""      <section id="section-{i}" class="content-section">
        <h2>{title}</h2>
{paragraphs}{code_block}
      </section>""")

    nav_items = "\n".join(f'          <li><a href="#section-{i}">Section {i+1}</a></li>' for i in range(n_sections))
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Documentation - Project</title>
    <link rel="stylesheet" href="/assets/css/main.css">
    <link rel="stylesheet" href="/assets/css/prism.css">
    <script defer src="/assets/js/app.js"></script>
</head>
<body>
    <header class="site-header">
      <nav class="main-nav" role="navigation" aria-label="Main">
        <div class="nav-brand"><a href="/">ProjectName</a></div>
        <ul class="nav-links">
          <li><a href="/docs">Docs</a></li>
          <li><a href="/api">API</a></li>
          <li><a href="/blog">Blog</a></li>
          <li><a href="https://github.com/org/project" target="_blank">GitHub</a></li>
        </ul>
      </nav>
    </header>
    <main class="documentation">
      <aside class="sidebar">
        <nav class="toc" aria-label="Table of contents">
          <ol>
{nav_items}
          </ol>
        </nav>
      </aside>
      <article class="doc-content">
{chr(10).join(sections)}
      </article>
    </main>
    <footer class="site-footer">
      <div class="footer-content">
        <p>&copy; 2026 ProjectName. Released under MIT License.</p>
        <nav class="footer-links">
          <a href="/privacy">Privacy</a>
          <a href="/terms">Terms</a>
          <a href="/contact">Contact</a>
        </nav>
      </div>
    </footer>
</body>
</html>
"""


# ── Search result fixtures ───────────────────────────────────────────────────

def gen_search(n_matches):
    files = [f"src/{d}/{f}.py" for d in ["api","models","utils","core","tests"]
             for f in ["handler","model","helpers","config","fixtures"]]
    patterns = ["def ", "class ", "import ", "return ", "raise ", "if ", "for ", "async def "]
    lines = []
    for i in range(n_matches):
        f = random.choice(files)
        line_no = random.randint(1, 500)
        indent = "    " * random.randint(0, 3)
        pattern = random.choice(patterns)
        rest = random.choice([
            "process_request(self, data: dict) -> Response:",
            "UserService:", "ValidationError(f'Invalid: {value}')",
            "flask, jsonify, request", "cached_result",
            "item in collection:", "handle_webhook(payload):",
        ])
        lines.append(f"{f}:{line_no}:{indent}{pattern}{rest}")
    return "\n".join(lines) + "\n"


# ── Text (markdown) fixtures ─────────────────────────────────────────────────

def gen_text(n_lines):
    sections = []
    headings = ["Overview", "Architecture", "Data Model", "API Design",
                "Authentication", "Error Handling", "Caching Strategy",
                "Deployment", "Monitoring", "Testing Strategy",
                "Performance", "Security Considerations", "Migration Guide"]
    for h in headings[:max(1, n_lines // 30)]:
        section = [f"## {h}", ""]
        for _ in range(random.randint(3, 6)):
            section.append(
                f"{'The' if random.random() < 0.5 else 'Our'} "
                f"{random.choice(['system', 'service', 'component', 'module'])} "
                f"{random.choice(['handles', 'processes', 'manages', 'orchestrates'])} "
                f"{random.choice(['incoming requests', 'data transformations', 'user authentication', 'cache invalidation', 'background jobs'])} "
                f"using {random.choice(['a pub/sub model', 'event-driven architecture', 'layered middleware', 'repository pattern'])}. "
                f"{'This ensures ' + random.choice(['high availability', 'data consistency', 'low latency', 'horizontal scalability']) + '.' if random.random() < 0.4 else ''}"
            )
            section.append("")
        if random.random() < 0.3:
            section.extend([
                "```python",
                f"config = load('{h.lower().replace(' ', '_')}.yaml')",
                f"service = {h.replace(' ', '')}Service(config)",
                f"service.start()",
                "```",
                "",
            ])
        if random.random() < 0.3:
            section.extend([
                f"| {'Metric':<20} | {'Value':<15} | {'Target':<15} |",
                f"|{'-'*22}|{'-'*17}|{'-'*17}|",
                f"| {'p99 latency':<20} | {random.randint(10,200)}ms{'':<10} | <100ms{'':<9} |",
                f"| {'throughput':<20} | {random.randint(100,10000)} rps{'':<6} | >1000 rps{'':<6} |",
                f"| {'error rate':<20} | {random.uniform(0,1):.2f}%{'':<9} | <0.1%{'':<10} |",
                "",
            ])
        sections.append("\n".join(section))
    header = "# Technical Design Document\n\n> Last updated: 2026-07-02\n\n"
    body = "\n".join(sections)
    # Pad to approximate target
    while body.count("\n") < n_lines - 5:
        body += f"\nAdditional context: the system processes approximately {random.randint(1,100)}M requests per day across {random.randint(3,20)} regions."
    return header + body + "\n"


# ── Tool output fixtures ─────────────────────────────────────────────────────

def gen_tool_output(n_lines):
    lines = ["$ npm install", ""]
    pkgs = ["react", "next", "typescript", "eslint", "prettier", "jest",
            "tailwindcss", "postcss", "autoprefixer", "lodash", "axios",
            "zustand", "swr", "zod", "@tanstack/react-query"]
    for p in pkgs[:max(3, n_lines // 4)]:
        ver = f"{random.randint(1,20)}.{random.randint(0,15)}.{random.randint(0,30)}"
        lines.append(f"added {p}@{ver}")
        for _ in range(random.randint(1, 3)):
            dep = f"@{random.choice(['types','babel','webpack'])}/{random.choice(['core','runtime','config'])}"
            lines.append(f"  + {dep}@{random.randint(1,10)}.{random.randint(0,20)}.{random.randint(0,10)}")
    lines.append("")
    lines.append(f"added {random.randint(100,800)} packages in {random.randint(5,30)}s")
    lines.append("")
    # pytest output
    lines.append("$ python -m pytest tests/ -v")
    lines.append(f"{'='*70}")
    lines.append("test session starts")
    lines.append(f"platform linux -- Python 3.12.1, pytest-8.1.0")
    lines.append(f"collected {n_lines // 2} items")
    lines.append("")
    for i in range(n_lines // 2):
        name = f"test_{random.choice(['create','read','update','delete','list','validate','parse'])}_{random.choice(['user','task','config','auth','cache','event'])}"
        status = random.choice(["PASSED"] * 18 + ["FAILED"] * 1 + ["SKIPPED"] * 1)
        lines.append(f"tests/test_{random.choice(['api','models','utils'])}.py::{name} {status}")
    lines.append("")
    passed = n_lines // 2 - 2
    lines.append(f"{'='*70}")
    lines.append(f"{passed} passed, 1 failed, 1 skipped in {random.uniform(1,10):.2f}s")
    return "\n".join(lines) + "\n"


# ── History (conversation) fixtures ──────────────────────────────────────────

def gen_history(n_turns):
    messages = []
    user_msgs = [
        "Fix the bug in the authentication middleware",
        "Add pagination to the /api/users endpoint",
        "Write tests for the rate limiter",
        "Refactor the database connection pooling",
        "Update the deployment configuration for Kubernetes",
        "Add input validation to the create_task endpoint",
        "Optimize the slow query on the events table",
        "Set up CI/CD pipeline with GitHub Actions",
    ]
    for i in range(n_turns):
        msg = random.choice(user_msgs)
        messages.append({"role": "user", "content": msg})
        # Assistant response with tool calls
        tool_calls = []
        for _ in range(random.randint(1, 3)):
            tool_calls.append({
                "type": "tool_use",
                "name": random.choice(["read_file", "write_file", "search", "shell"]),
                "input": {
                    "path": f"src/{random.choice(['api','models','utils'])}/{random.choice(['handler','model','helpers'])}.py",
                    "content": f"# Modified line {random.randint(1,200)}\n" * random.randint(1, 5),
                },
            })
        code = f"def {random.choice(['fix','update','refactor','optimize'])}_{random.choice(['handler','model','config'])}():\n"
        code += f"    # Implementation for: {msg}\n"
        code += f"    result = process(data)\n    return result\n"
        messages.append({
            "role": "assistant",
            "content": f"I'll {msg.lower()}.\n\n```python\n{code}```\n\nDone. The changes are in `src/api/handler.py`.",
            "tool_calls": tool_calls,
        })
    return "\n".join(json.dumps(m) for m in messages) + "\n"


# ── Metadata (YAML) fixtures ────────────────────────────────────────────────

def gen_metadata(n_services):
    services = []
    for i in range(n_services):
        name = random.choice(["api-server", "worker", "scheduler", "gateway",
                              "auth-service", "notification-service", "search-service",
                              "analytics", "billing", "cdn-proxy"])
        services.append(f"""  {name}-{i}:
    image: registry.example.com/{name}:v{random.randint(1,5)}.{random.randint(0,20)}.{random.randint(0,99)}
    replicas: {random.choice([1, 2, 3, 5])}
    resources:
      cpu: "{random.choice(['250m', '500m', '1000m', '2000m'])}"
      memory: "{random.choice(['256Mi', '512Mi', '1Gi', '2Gi'])}"
    env:
      DATABASE_URL: "postgresql://db:5432/{name.replace('-','_')}"
      REDIS_URL: "redis://cache:6379/{i}"
      LOG_LEVEL: "{random.choice(['info', 'debug', 'warn'])}"
      ENABLE_METRICS: "{random.choice(['true', 'false'])}"
    ports:
      - {8000 + i}:{8000 + i}
    healthcheck:
      path: /health
      interval: {random.choice([10, 15, 30])}s
      timeout: 5s
    depends_on:
      - database
      - redis""")
    return f"""# Deployment configuration
# Environment: {random.choice(['production', 'staging', 'development'])}
# Last updated: 2026-07-02

version: "3.8"

services:
{"".join(services)}

  database:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    env:
      POSTGRES_PASSWORD: "${{DB_PASSWORD}}"

  redis:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru

volumes:
  pgdata:
    driver: local
"""


# ── Generate all ─────────────────────────────────────────────────────────────

print("Generating compression benchmark fixtures...")
print()

print("Code:")
write("code-small.py", gen_code_small())
write("code-medium.py", gen_code_medium())
write("code-large.py", gen_code_large())

print("\nJSON:")
write("json-small.json", gen_json(10))
write("json-medium.json", gen_json(50))
write("json-large.json", gen_json(200))

print("\nLogs:")
write("logs-small.log", gen_logs(50))
write("logs-medium.log", gen_logs(200))
write("logs-large.log", gen_logs(1000))

print("\nDiffs:")
write("diff-small.diff", gen_diff(3))
write("diff-medium.diff", gen_diff(10))
write("diff-large.diff", gen_diff(30))

print("\nHTML:")
write("html-small.html", gen_html(3))
write("html-medium.html", gen_html(10))
write("html-large.html", gen_html(30))

print("\nSearch results:")
write("search-small.txt", gen_search(20))
write("search-medium.txt", gen_search(100))
write("search-large.txt", gen_search(500))

print("\nText (markdown):")
write("text-small.md", gen_text(50))
write("text-medium.md", gen_text(200))
write("text-large.md", gen_text(500))

print("\nTool output:")
write("tool-small.txt", gen_tool_output(30))
write("tool-medium.txt", gen_tool_output(100))
write("tool-large.txt", gen_tool_output(500))

print("\nConversation history:")
write("history-small.jsonl", gen_history(10))
write("history-medium.jsonl", gen_history(50))
write("history-large.jsonl", gen_history(200))

print("\nMetadata (YAML):")
write("metadata-small.yaml", gen_metadata(3))
write("metadata-large.yaml", gen_metadata(15))

print("\nDone. All fixtures generated.")
