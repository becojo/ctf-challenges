CONTAINERS = $(shell find . -name "*.rb" -maxdepth 1 -type f)

all: $(subst .rb,.tar,$(CONTAINERS))

clean:
	rm -f $(subst .rb,.tar,$(CONTAINERS))

%.tar: %.rb
	bin/build $(subst .tar,.rb,$@)
	docker save $(subst .tar,,$@) > $@

deploy:
	mv *.tar ../files
