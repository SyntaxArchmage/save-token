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
