
CONTAINER = webdav

ROOT = /home/layer/webdav-root

build: Dockerfile
	docker build -t $(CONTAINER) .

Dockerfile: Dockerfile.in
	sed -e 's/__USER__/$(USER)/g' \
	    -e 's/__UID__/$(shell id -u)/g' \
	    -e 's/__GID__/$(shell id -g)/g' \
	    < $< > $@

start: FORCE
ifndef WEBDAV_USER
	@echo WEBDAV_USER is not defined; exit 1
endif
ifndef WEBDAV_PASS
	@echo WEBDAV_PASS is not defined; exit 1
endif
	-docker stop $(CONTAINER)
	-docker rm $(CONTAINER)
	docker run --restart unless-stopped --name $(CONTAINER) \
		-v $(ROOT):/var/lib/dav \
		-e USERNAME=$(WEBDAV_USER) \
		-e PASSWORD=$(WEBDAV_PASS) \
		-e AUTH_TYPE=Digest \
		--publish 80:80 -d webdav

FORCE:
