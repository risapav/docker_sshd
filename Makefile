.PHONY: clean exec pull run ssh stop
.PHONY: help
############################### Native Makefile ###############################

MAKER_NAME ?= "docker_sshd"

RSA_KEY ?= $(shell cat ~/.ssh/id_rsa.pub)
IMAGE_NAME := risapav/docker_sshd:latest
CONTAINER_NAME := sshd
SSH_PORT := 8022
HOSTNAME := sshd_server

# remove docker container image
clean:
	docker rmi $(IMAGE_NAME)
	docker sys prune

# pull request to Docker Hub site
pull:
	docker pull $(IMAGE_NAME)

# stop docker container and purge it from memory
stop: 
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)

# start docker container
run:
	docker run \
		--name $(CONTAINER_NAME) \
		-p $(SSH_PORT):22 \
		--hostname $(HOSTNAME) \
		$(IMAGE_NAME)
		
# exec command inside running docker container    
exec:
	docker exec \
		$(CONTAINER_NAME) \
		user_account.sh $(USER) "$(RSA_KEY)"

# to run remote shell with user privileges
ssh:
	ssh $(USER)@localhost -p $(SSH_PORT)

help:
	@echo "Commands for working with $(MAKER_NAME):"
	@echo "  clean   - Remove docker container image"
	@echo "  exec    - Exec command inside running docker container"
	@echo "  pull    - Pull request to Docker Hub site"
	@echo "  run     - Start docker container"
	@echo "  ssh     - Remote ssh prompt with user privileges"
	@echo "  stop    - Stop docker container and purge it from memory"
	@echo
	@echo	
	@echo "Constants:"
	@echo "  RSA_KEY=$(RSA_KEY)"
	@echo "  IMAGE_NAME=$(IMAGE_NAME)"
	@echo "  CONTAINER_NAME=$(CONTAINER_NAME)"
	@echo "  SSH_PORT=$(SSH_PORT)"
	@echo "  HOSTNAME=$(HOSTNAME)"
	@echo
