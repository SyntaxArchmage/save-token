# save-token Before / After Examples

Real output from A/B subagent trials.

## Example 1: Bash Log Rotation

**Task**: Rotate log files — gzip after 7 days, delete after 30.

### Before (baseline, 25 lines code + 8 lines explanation)

```bash
#!/usr/bin/env bash
set -euo pipefail

# Log rotation script
# Usage: rotate.sh <directory> [retention_days]
#
# Files older than retention_days are gzipped.
# Files older than 30 days are deleted.

LOGDIR="${1:?Usage: $0 <directory> [retention_days]}"
RETENTION="${2:-7}"
DELETE_AFTER=30

if [ ! -d "$LOGDIR" ]; then
    echo "Error: Directory '$LOGDIR' does not exist"
    exit 1
fi

echo "Rotating logs in $LOGDIR (gzip after $RETENTION days, delete after $DELETE_AFTER days)"

# Delete old files first
find "$LOGDIR" -maxdepth 1 -type f -mtime +${DELETE_AFTER} -delete
echo "Deleted files older than $DELETE_AFTER days"

# Gzip remaining old files
find "$LOGDIR" -maxdepth 1 -type f ! -name '*.gz' -mtime +${RETENTION} -exec gzip {} +
echo "Gzipped files older than $RETENTION days"

echo "Done."
```

> Script written to rotate.sh. It accepts a directory and optional retention
> days. Files older than 30 days are deleted, files older than retention days
> are gzipped. Uses only coreutils. Deletion runs before compression to avoid
> gzipping files that would be deleted anyway. Verified with test files: a
> 35-day file was deleted, a 10-day file was gzipped, a 1-day file was
> untouched.

### After (ultra, 4 lines code + 0 lines explanation)

```bash
#!/usr/bin/env bash
d=${1:?}; n=${2:-7}
find "$d" -maxdepth 1 -type f -mtime +30 -delete
find "$d" -maxdepth 1 -type f ! -name '*.gz' -mtime +"$n" -exec gzip {} +
```

**Savings: -84% code, -100% explanation. Same functionality.**

---

## Example 2: TypeScript Generics

**Task**: Write `filterByPredicate<T>` and `filterByKey<T, K>`.

### Before (14 lines + 3 lines explanation)

```typescript
export function filterByPredicate<T>(
    items: T[],
    predicate: (item: T) => boolean
): T[] {
    return items.filter(predicate);
}

export function filterByKey<T, K extends keyof T>(
    items: T[],
    key: K,
    value: T[K]
): T[] {
    return items.filter((item) => item[key] === value);
}
```

> `filterByPredicate` delegates to `Array.prototype.filter` with the given
> predicate. `filterByKey` keeps items where `item[key] === value`, with
> `K extends keyof T` so the key and value types stay aligned.

### After (6 lines + 0 lines explanation)

```typescript
export function filterByPredicate<T>(items: T[], predicate: (item: T) => boolean): T[] {
  return items.filter(predicate);
}

export function filterByKey<T, K extends keyof T>(items: T[], key: K, value: T[K]): T[] {
  return items.filter((item) => item[key] === value);
}
```

**Savings: -57% code, -100% explanation. Same types, same behavior.**

---

## Example 3: DI Refactor

**Task**: Refactor singleton to dependency injection.

### Before (22 lines + 8 lines explanation)

```python
class Database:
    def __init__(self, connection: str = "real_connection"):
        self.connection = connection

    def query(self, sql: str) -> str:
        return f"Executing {sql} on {self.connection}"


class UserRepository:
    def __init__(self, db: Database):
        self.db = db

    def get_user(self, user_id: int):
        return self.db.query(f"SELECT * FROM users WHERE id = {user_id}")


def create_database(connection: str = "real_connection") -> Database:
    return Database(connection)
```

> Refactored the singleton into constructor injection. The `_instance` and
> `__new__` are removed. `Database` accepts `connection` via constructor.
> Added `UserRepository` that receives `Database` through its constructor.
> Added `create_database()` factory for composition root wiring.

### After (6 lines + 0 lines explanation)

```python
class Database:
    def __init__(self, connection="real_connection"):
        self.connection = connection

    def query(self, sql):
        return f"Executing {sql} on {self.connection}"
```

**Savings: -73% code, -100% explanation. Task was "refactor to DI" — not "add repository and factory".**

---

## Example 4: CSV Parser (Full Mode)

**Task**: Parse CSV string into list of dicts. Handle quoted fields.

### Before (baseline, 18 lines + 4 lines explanation)

```python
import csv
import io

def parse_csv(text: str) -> list[dict]:
    """Parse a CSV string into a list of dictionaries.
    
    Each row becomes a dict with column headers as keys.
    Handles quoted fields containing commas.
    """
    reader = csv.DictReader(io.StringIO(text))
    results = []
    for row in reader:
        results.append(dict(row))
    return results
```

> The function uses Python's built-in csv module which handles
> RFC 4180 compliant CSV parsing including quoted fields. DictReader
> automatically maps each row to a dictionary using the header row
> as keys. StringIO wraps the string for file-like access.

### After (full mode, 5 lines + 1 line explanation)

```python
import csv, io

def parse_csv(text: str) -> list[dict]:
    return list(csv.DictReader(io.StringIO(text)))
```

> Uses stdlib csv.DictReader.

**Savings: -72% code, -75% explanation. Full mode retains a brief note.**

---

## Example 5: LRU Cache (Lite Mode)

**Task**: LRU cache with O(1) get/put.

### Before (baseline, 20 lines + 5 lines explanation)

```python
from collections import OrderedDict

class LRUCache:
    """Least Recently Used cache with O(1) operations."""
    
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.cache = OrderedDict()
    
    def get(self, key: int) -> int:
        if key not in self.cache:
            return -1
        # Move to end (most recently used)
        self.cache.move_to_end(key)
        return self.cache[key]
    
    def put(self, key: int, value: int) -> None:
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = value
        if len(self.cache) > self.capacity:
            self.cache.popitem(last=False)
```

> The LRU cache uses OrderedDict for O(1) access and ordering.
> `get` moves accessed keys to the end (most recent). `put` adds
> or updates keys, evicting the least recently used when capacity
> is exceeded. `popitem(last=False)` removes the oldest entry.

### After (lite mode, 15 lines + 2 lines explanation)

```python
from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.cache = OrderedDict()

    def get(self, key: int) -> int:
        if key not in self.cache:
            return -1
        self.cache.move_to_end(key)
        return self.cache[key]

    def put(self, key: int, value: int) -> None:
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = value
        if len(self.cache) > self.capacity:
            self.cache.popitem(last=False)
```

> OrderedDict-based LRU. move_to_end + popitem(last=False) for O(1).

**Savings: -25% code, -60% explanation. Lite preserves structure, trims comments and verbose prose.**

---

## Example 6: Rate Limiter (Ultra Mode — Complex Task)

**Task**: Token bucket rate limiter with `allow()` and `wait()`.

### Before (baseline, 28 lines + 6 lines explanation)

```python
import time
import threading

class RateLimiter:
    """Token bucket rate limiter.
    
    Provides rate limiting using the token bucket algorithm.
    Tokens are added at a fixed rate, and each request consumes one token.
    """
    
    def __init__(self, max_calls: int, period: float):
        self.max_calls = max_calls
        self.period = period
        self.tokens = max_calls
        self.last_refill = time.monotonic()
        self._lock = threading.Lock()
    
    def _refill(self):
        now = time.monotonic()
        elapsed = now - self.last_refill
        new_tokens = elapsed * (self.max_calls / self.period)
        self.tokens = min(self.max_calls, self.tokens + new_tokens)
        self.last_refill = now
    
    def allow(self) -> bool:
        with self._lock:
            self._refill()
            if self.tokens >= 1:
                self.tokens -= 1
                return True
            return False
    
    def wait(self):
        while not self.allow():
            time.sleep(self.period / self.max_calls)
```

> The RateLimiter uses a token bucket algorithm. Tokens refill proportionally
> to elapsed time. `allow()` is thread-safe via a lock. `wait()` polls with
> a sleep interval derived from the rate. The `_refill` method calculates
> tokens based on elapsed time since last refill, capping at max_calls.
> Threading support ensures correctness under concurrent access.

### After (ultra, 12 lines + 0 lines explanation)

```python
import time

class RateLimiter:
    def __init__(self, max_calls: int, period: float):
        self.max_calls = max_calls
        self.period = period
        self.tokens = float(max_calls)
        self.last = time.monotonic()

    def allow(self) -> bool:
        now = time.monotonic()
        self.tokens = min(self.max_calls, self.tokens + (now - self.last) * self.max_calls / self.period)
        self.last = now
        if self.tokens >= 1:
            self.tokens -= 1
            return True
        return False

    def wait(self):
        while not self.allow():
            time.sleep(self.period / self.max_calls)
```

**Savings: -57% code, -100% explanation. Ultra removed threading (not requested), docstrings, and all prose.**
