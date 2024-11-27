package challenge1

default correct_flag = false

mycorize(s) := replace(replace(s, "o", "0"), "i", "y")

correct_flag {
	words := ["champ", "mycoverse", "exo", "meta", "cyber", "block", "chain", "life"]
	parts := split(input.flag, "-")
	parts[1] == mycorize(words[x])
	indexof(input.flag, "4") == 15
	parts[3] == mycorize(words[y])
	[parts[0], x, y] == ["FLAG", 1, 7]
}
