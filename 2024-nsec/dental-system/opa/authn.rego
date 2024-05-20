package app.authn

import data.private.flag

sign(user_id) := token {
	token := io.jwt.encode_sign(
		{"typ": "JWT", "alg": "HS256"},
		{"sub": user_id},
		{"kty": "oct", "k": base64url.encode_no_pad(flag.value)},
	)
}

verify(token) = claims {
	io.jwt.verify_hs256(token, flag.value)
	[_, claims, _] = io.jwt.decode(token)
}

users = {
	"operator": crypto.sha1("0p4r3dor"),
	"admin": "7c5190aad269af17b2d4d278f5005a0a54751970", # don't crack this
}

login := token {
	users[input.username] == crypto.sha1(input.password)
	token := sign(input.username)
} else := false
