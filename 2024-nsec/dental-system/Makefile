REMOTE=nsec-ctf
CONTAINER=$(REMOTE):ctn-bcotejodoin-kv

bundle.tar.gz: $(shell find opa -type f)
	opa build -b opa

deploy: bundle.tar.gz.deploy app.deploy

bundle.tar.gz.deploy: bundle.tar.gz
	incus file push bundle.tar.gz $(CONTAINER)/bundle.tar.gz

app.deploy:
	cd app && make
	incus exec $(CONTAINER) -- systemctl stop app
	incus file push app/app.js $(CONTAINER)/app.js
	incus exec $(CONTAINER) -- systemctl start app
