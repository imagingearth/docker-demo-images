.PHONY: build dev nuke super-nuke upload

TAG ?= 28515ed64e5e

help:
	@cat Makefile

update-tag:
	./update-dockerfile-includes $(TAG)

build:
	docker build -t jgomezdans/demo .

dev: ARGS?=
dev:
	docker run --rm -it -p 80:8888 jgomezdans/demo $(ARGS)

upload:
	docker push jgomezdans/demo

super-nuke: nuke
	-docker rmi jgomezdans/demo

# Cleanup with fangs
nuke:
	-docker stop `docker ps -aq`
	-docker rm -fv `docker ps -aq`
	-docker images -q --filter "dangling=true" | xargs docker rmi

