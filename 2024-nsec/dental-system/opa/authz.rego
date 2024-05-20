package app.authz

import data.app.authn.verify

default allowed := false

allowed {
	count(deny) == 0
}

user := verify(input.authToken)

deny[msg] {
	not input.authToken
	msg := "authToken not set"
}

deny[msg] {
	not user
	msg := "authToken is invalid"
}

deny[msg] {
	startswith(input.uri, "/app/root-admin")
	user.sub != "admin"
	msg := "non admin user cannot access admin area"
}

deny[msg] {
	startswith(input.uri, "/dashboard/")
	user.sub != "admin"
	msg := "non admin user cannot access the Traefik dashboard"
}

deny[msg] {
	startswith(input.uri, "/api/")
	user.sub != "admin"
	msg := "non admin user cannot access the Traefik dashboard API"
}
