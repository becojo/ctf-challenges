# Couleuvre

## Write-up (english)

As the file name implies, the binary is a compiled Python 3.14 bytecode file. It can be disassembled/decompiled using various tools. Using `xdis` is the most straightforward approach, as many tools fail to analyze 3.14 bytecode at the moment:

```
uv run --with xdis pydisasm -S -F extended couleuvre.cpython-314.pyc
```

A large chunk of the program is spent building a string using Ellipsis objects (`...`) that is then passed to `exec`.

```
 53:         104 LOAD_NAME            (exec)
             106 PUSH_NULL
             108 LOAD_CONST           ("%c")
             110 LOAD_CONST           (Ellipsis)
             112 LOAD_CONST           (Ellipsis)
             114 COMPARE_OP           (==) ; TOS = Ellipsis == Ellipsis
             118 LOAD_CONST           (Ellipsis)
             120 LOAD_CONST           (Ellipsis)
             122 COMPARE_OP           (==) ; TOS = Ellipsis == Ellipsis
             126 UNARY_NEGATIVE

[snip]

            86998 COMPARE_OP           (==) ; TOS = Ellipsis == Ellipsis
            87002 UNARY_NEGATIVE
            87004 BINARY_OP            (-) ; TOS = Ellipsis == Ellipsis -
            87016 BINARY_OP            (*) ; TOS = Ellipsis == Ellipsis * Ellipsis == Ellipsis -  * Ellipsis == Ellipsis * Ellipsis == Ellipsis -
            87028 LIST_APPEND          1
            87030 CALL_INTRINSIC_1     (INTRINSIC_LIST_TO_TUPLE)
            87032 BINARY_OP            (%)
            87044 CALL                 (1 positional)
```

To obtain the source code that is executed, the bytecode can be patched so the code is printed instead of executed.

```
def patch_exec(bytecode: bytes) -> bytes:
    """
    Replace exec(...) with print(...).
    """
    return bytecode.replace(b"\x04exec", b"\x05print")
```

Doing so and executing the program will output the following Python code:

```python
if h(s) == hf:
    sr(s)
else:
    x = [99, 81, 71, 12, 64, 112, 81, 65, 45, 88, 29, 95, 102, 15, 93, 107, 19, 92, 41, 22, 67, 21, 22, 25, 76, 26, 66, 28, 22]
    ok = True
    for i in range(len(s)):
        if ord(s[i]) != x[i] ^ ord(hf[i]) ^ i:
            ok = False
            break
    if ok:
        sr(s)

r("nope")
```

This code references variables that are defined in the original bytecode. The relevant variables are:

```
hf = "0c6812c4abee918609d0cf5771ab837008f70df4"
102 STORE_NAME           (hf) ; hf = 0c6812c4abee918609d0cf5771ab837008f70df4

s = input("> ")
51:         84 LOAD_NAME            (input)
            86 PUSH_NULL
            88 LOAD_CONST           ("> ")
            90 CALL                 (1 positional) ; TOS = input("> ")
            98 STORE_NAME           (s)
```

By analyzing the obfuscated Python snippet, we can see the program checks whether the user input string `s` matches the XOR of `x[i]`, `hf[i]`, and `i` for each character, so the expected string can be obtained by reversing this operation:

```python
hf = "0c6812c4abee918609d0cf5771ab837008f70df4"
x = [99, 81, 71, 12, 64, 112, 81, 65, 45, 88, 29, 95, 102, 15, 93, 107, 19, 92, 41, 22, 67, 21, 22, 25, 76, 26, 66, 28, 22]
s = ""
for i in range(len(x)):
    s += chr(x[i] ^ ord(hf[i]) ^ i)
print(s)
```

This program outputs `S3s7uG4rD3r1S3kR3t_54f59c29e2`. When this string is provided to the original program, it indicates the input is correct and prints the flag.

```
The flag is DCI{S3s7uG4rD3r1S3kR3t_54f59c29e2}
```

## Write-up (français)

Comme le nom du fichier l'indique, le binaire est un fichier de bytecode Python 3.14 compilé. Il peut être désassemblé/décompilé avec différents outils. Utiliser `xdis` est l'approche la plus directe, car de nombreux outils ne supportent pas encore le bytecode 3.14 :

```
uv run --with xdis pydisasm -S -F extended couleuvre.cpython-314.pyc
```

Une grande partie du programme est consacrée à la construction d'une chaîne de caractères à l'aide d'objets Ellipsis (`...`), qui est ensuite passée à `exec`.

```
 53:         104 LOAD_NAME            (exec)
             106 PUSH_NULL
             108 LOAD_CONST           ("%c")
             110 LOAD_CONST           (Ellipsis)
             112 LOAD_CONST           (Ellipsis)
             114 COMPARE_OP           (==) ; TOS = Ellipsis == Ellipsis
             118 LOAD_CONST           (Ellipsis)
             120 LOAD_CONST           (Ellipsis)
             122 COMPARE_OP           (==) ; TOS = Ellipsis == Ellipsis
             126 UNARY_NEGATIVE

[snip]

            86998 COMPARE_OP           (==) ; TOS = Ellipsis == Ellipsis
            87002 UNARY_NEGATIVE
            87004 BINARY_OP            (-) ; TOS = Ellipsis == Ellipsis -
            87016 BINARY_OP            (*) ; TOS = Ellipsis == Ellipsis * Ellipsis == Ellipsis -  * Ellipsis == Ellipsis * Ellipsis == Ellipsis -
            87028 LIST_APPEND          1
            87030 CALL_INTRINSIC_1     (INTRINSIC_LIST_TO_TUPLE)
            87032 BINARY_OP            (%)
            87044 CALL                 (1 positional)
```

Pour obtenir le code source exécuté, on peut patcher le bytecode afin que le code soit affiché au lieu d'être exécuté.

```
def patch_exec(bytecode: bytes) -> bytes:
    """
    Replace exec(...) with print(...).
    """
    return bytecode.replace(b"\x04exec", b"\x05print")
```

En procédant ainsi puis en exécutant le programme, on obtient le code Python suivant :

```python
if h(s) == hf:
    sr(s)
else:
    x = [99, 81, 71, 12, 64, 112, 81, 65, 45, 88, 29, 95, 102, 15, 93, 107, 19, 92, 41, 22, 67, 21, 22, 25, 76, 26, 66, 28, 22]
    ok = True
    for i in range(len(s)):
        if ord(s[i]) != x[i] ^ ord(hf[i]) ^ i:
            ok = False
            break
    if ok:
        sr(s)

r("nope")
```

Ce code fait référence à des variables définies dans le bytecode d'origine. Les variables pertinentes sont :

```
hf = "0c6812c4abee918609d0cf5771ab837008f70df4"
102 STORE_NAME           (hf) ; hf = 0c6812c4abee918609d0cf5771ab837008f70df4

s = input("> ")
51:         84 LOAD_NAME            (input)
            86 PUSH_NULL
            88 LOAD_CONST           ("> ")
            90 CALL                 (1 positional) ; TOS = input("> ")
            98 STORE_NAME           (s)
```

En analysant l'extrait Python obfusqué, on voit que le programme vérifie si la chaîne saisie par l'utilisateur `s` correspond au XOR de `x[i]`, `hf[i]` et `i` pour chaque caractère. La chaîne attendue peut donc être obtenue en inversant cette opération :

```python
hf = "0c6812c4abee918609d0cf5771ab837008f70df4"
x = [99, 81, 71, 12, 64, 112, 81, 65, 45, 88, 29, 95, 102, 15, 93, 107, 19, 92, 41, 22, 67, 21, 22, 25, 76, 26, 66, 28, 22]
s = ""
for i in range(len(x)):
    s += chr(x[i] ^ ord(hf[i]) ^ i)
print(s)
```

Ce programme affiche `S3s7uG4rD3r1S3kR3t_54f59c29e2`. Lorsque cette chaîne est fournie au programme d'origine, il indique que l'entrée est correcte et affiche le flag.

```
The flag is DCI{S3s7uG4rD3r1S3kR3t_54f59c29e2}
```
