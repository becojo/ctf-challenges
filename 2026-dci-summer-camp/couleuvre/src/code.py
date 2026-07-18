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
