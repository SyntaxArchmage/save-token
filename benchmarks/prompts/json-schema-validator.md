Write Python: `validate(data: dict, schema: dict) -> list[str]`
Validate a dict against a simple schema. Schema format:
`{"field_name": {"type": "str|int|float|bool", "required": True|False}}`
Return list of error strings. Use only stdlib.
