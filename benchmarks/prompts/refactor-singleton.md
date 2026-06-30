# Refactor Singleton to DI

Given this Python singleton:

```python
class Database:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance.connection = "real_connection"
        return cls._instance

    def query(self, sql):
        return f"Executing {sql} on {self.connection}"
```

Refactor to use dependency injection. The caller should be able to pass a connection, making it testable without modifying global state.
