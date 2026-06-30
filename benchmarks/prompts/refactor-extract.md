Given this code, extract the repeated logic into a helper function:

```python
def process_users(users):
    results = []
    for u in users:
        name = u.get("name", "").strip().lower()
        if not name:
            continue
        email = u.get("email", "").strip().lower()
        if "@" not in email:
            continue
        results.append({"name": name, "email": email})
    return results

def process_admins(admins):
    results = []
    for a in admins:
        name = a.get("name", "").strip().lower()
        if not name:
            continue
        email = a.get("email", "").strip().lower()
        if "@" not in email:
            continue
        results.append({"name": name, "email": email, "admin": True})
    return results
```
