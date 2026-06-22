def add(a: int, b: int) -> int:
    return a + b


def demo_arg_type_mismatch() -> int:
    return add("1", 2)
