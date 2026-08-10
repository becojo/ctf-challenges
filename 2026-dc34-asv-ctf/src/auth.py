import os

GUEST_API_KEY = "api-key-guest-user-limited-access"

KEYS = {
    f"api-key-{os.urandom(32).hex()}": "admin",
    GUEST_API_KEY: "guest",
}


def validate_api_key(api_key: str | None) -> str:
    return KEYS.get(api_key, "")


def create_api_key(name: str, role: str) -> None:
    KEYS[name] = role


def print_admin_keys() -> None:
    for key, role in KEYS.items():
        if role == "admin":
            print("ADMIN KEY:", key)
