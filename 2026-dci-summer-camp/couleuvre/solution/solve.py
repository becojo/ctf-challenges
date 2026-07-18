import sys
import subprocess


file = sys.argv[1]

with open(file, "rb") as f:
    bytecode = f.read()


def patch_exec(bytecode: bytes) -> bytes:
    """
    Replace exec(...) with print(...).
    """
    return bytecode.replace(b"\x04exec", b"\x05print")


patched = patch_exec(bytecode)

with open("patched.pyc", "wb") as f:
    f.write(patched)

output = subprocess.check_output([sys.executable, "patched.pyc"], input=b"bad")
output = output.decode()

start = output.find("x = [") + len("x = [")
end = output.find("]", start)
x_str = output[start:end]
x = list(map(int, x_str.split(", ")))
flag_hash = "0c6812c4abee918609d0cf5771ab837008f70df4"

for i in range(len(x)):
    x[i] ^= i ^ ord(flag_hash[i])

print(bytearray(x))
