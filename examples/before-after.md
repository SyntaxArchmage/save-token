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
