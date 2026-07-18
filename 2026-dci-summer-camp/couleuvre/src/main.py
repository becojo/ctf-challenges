import hashlib

flag = "S3s7uG4rD3r1S3kR3t_54f59c29e2"


def main():
    flag_hash = h(flag)

    with open("code.py", "r") as f:
        target_code = f.read().replace("{hash}", flag_hash)

    obfuscated = obfuscate_code(target_code)

    with open("prelude.py", "r") as f:
        prelude = f.read().replace("{hash}", flag_hash)

    print(prelude)
    print(obfuscated)


def h(s):
    return hashlib.sha1(s.encode()).hexdigest()


def to_ellipsis_math(n):
    """Converts an integer into a safe, compact chain of (...==...) blocks."""
    if n == 0:
        return "((...==...)-(...==...))"
    if n == 1:
        return "(...==...)"

    base_two = "((...==...)--(...==...))"

    if n % 2 == 0:
        return f"({base_two}*{to_ellipsis_math(n // 2)})"
    else:
        return f"({base_two}*{to_ellipsis_math(n // 2)}--(...==...))"


def obfuscate_code(target_code: str) -> str:
    # 1. Get the ASCII integer values for every character
    ascii_values = [ord(char) for char in target_code]

    # 2. Build the format string template multiplier safely
    num_chars = len(target_code)
    multiplier_str = to_ellipsis_math(num_chars)
    template_str = f"('%c'*{multiplier_str})"

    # 3. Convert each ASCII integer into its ellipsis-math equivalent
    tuple_elements = [to_ellipsis_math(val) for val in ascii_values]
    tuple_str = f"({','.join(tuple_elements)},)"

    # 4. Wrap everything in exec()
    return f"exec({template_str}%{tuple_str})"


if __name__ == "__main__":
    main()
