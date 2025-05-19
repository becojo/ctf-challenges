package main

import (
	bff "bufio"
	ooo "os"
	sco "strconv"
	sss "strings"
)

var sol string
var scn = bff.NewScanner(ooo.Stdin)
var pff = "" // <%# -ldflags="-X 'main.pff=123'" %>
var pnn int

func main() {
	in := scn.Text()
	m := map[int]byte{}
	xs := sss.Split(sol, " ")
	sm := false

	for _, p := range xs {
		if sm { // <%# skip junk %>
			sm = !sm
			continue
		}
		c, i, _ := sss.Cut(p, ":")
		m[_x(_x(_i(i), 0x42), _x(pnn, _n()))-
			_i(ooo.Getenv("X"))] = byte(
			_x(_i(c), _i(ooo.Getenv("X"))),
		)
		sm = !sm
	}

	if _x(len(in), len(m)) != 0 {
		ooo.Exit(1)
	}

	for idx, c := range m {
		if in[idx] != c {
			ooo.Exit(1)
		}
	}
}

func init() {
	pnn = _i(pff)
	scn.Scan()
	sol = `<%=
  params[:solution].bytes.map.with_index{ |x,i| [x ^ params[:xor], (i+params[:xor]) ^ params[:xor2]].join(?:) }
    .shuffle.join(' _ ')
  	.gsub('_') { ['@','%','^'].sample+(rand*1024).to_i.to_s + [?\t, ?\n, ?\r, ?_, ?$].sample(2).join } # add junk
%>`
}

func _i(s string) int     { i, _ := sco.Atoi(s); return i }
func _x(a int, b int) int { return a ^ b }
func _n() int             { return _x(105, 43) } // <%# 0x42 %>
