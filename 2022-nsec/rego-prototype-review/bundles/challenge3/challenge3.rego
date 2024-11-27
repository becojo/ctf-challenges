package challenge3

default correct_flag = false

parts = split(input.flag, "FLAG-")

flag = split(parts[1], "")

f(s) = sp {
	c := flag[s.i]
	g[s.s][0] == c
	j := count({x | array.slice(flag, 0, s.i)[x] == c})
	sp := {"i": s.i + 1, "s": g[s.s][2][j]}
}

g = [["y", 1, [11]], ["n", 1, [13]], ["-", 3, [12, 10, 9]], ["h", 1, [2]], ["u", 1, [9]], ["l", 1, [8]], ["b", 1, [13]], ["t", 1, [3]], ["i", 2, [7, 4]], ["m", 3, [13, 0, null]], ["w", 1, [8]], ["c", 2, [12, 13]], ["o", 2, [9, 1]], ["e", 4, [11, 2, 2, 5]]]

hash := crypto.sha256(parts[1])

correct_flag {
	g[s][0] == flag[0]
	f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f({"i": 0, "s": s})))))))))))))))))))))))).i == count(flag)
}
