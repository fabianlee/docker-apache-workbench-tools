OWNER := fabianlee
PROJECT := docker-apache-workbench-tools
VERSION := $(shell cat VERSION)
OPV := $(OWNER)/$(PROJECT):$(VERSION)

# linux capabilities
CAPS := 
#CAPS := --cap-add SYS_TIME --cap-add SYS_NICE
# --cap-add CAP_SYS_RESOURCE (not needed)

# chrony config file
VOL_FLAG := 
#VOL_FLAG := -v $(shell pwd)/chrony.conf:/etc/chrony/chrony.conf:ro

# you may need to change to "sudo docker" if not a member of 'docker' group
# add user to docker group: sudo usermod -aG docker $USER
DOCKERCMD := docker

BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
# unique id from last git commit
MY_GITREF := $(shell git rev-parse --short HEAD)


## builds docker image
docker-build:
	@echo MY_GITREF is $(MY_GITREF)
	$(DOCKERCMD) build --progress plain -f Dockerfile -t $(OPV) .

## cleans docker image
clean:
	$(DOCKERCMD) image rm $(OPV) | true

## runs container in foreground, testing a couple of override values
docker-run-fg: docker-stop
	$(DOCKERCMD) run -it --network host $(CAPS) -p $(EXPOSEDPORT) $(VOL_FLAG) --rm $(OPV)

## runs container in foreground, override entrypoint to use use shell
docker-debug:
	$(DOCKERCMD) run -it --rm --entrypoint "/bin/sh" $(OPV)

## run container in background, override /etc/chrony/chrony.conf using volume (not mandatory)
docker-run-bg: docker-stop
	$(DOCKERCMD) run -d --network host $(CAPS) -p $(EXPOSEDPORT) $(VOL_FLAG) --rm --name $(PROJECT) $(OPV)

## get into console of container running in background
docker-cli-bg: docker-stop
	$(DOCKERCMD) exec -it $(PROJECT) /bin/sh

## tails $(DOCKERCMD)logs
docker-logs:
	$(DOCKERCMD) logs -f $(PROJECT)

## stops container running in background
docker-stop:
	$(DOCKERCMD) stop $(PROJECT) | true

## pushes to $(DOCKERCMD)hub
docker-push:
	$(DOCKERCMD) push $(OPV)

## pushes to kubernetes cluster
k8s-apply:
	sed -e 's/1.0.0/$(VERSION)/' k8s-chrony-alpine.yaml | kubectl apply -f -
	@echo ""
	@echo "Use this debian slim container as a test client: https://github.com/fabianlee/docker-debian-bullseye-slim-ntpclient/blob/main/k8s-debian-slim.yaml"

k8s-delete:
	kubectl delete -f k8s-chrony-alpine.yaml

## scan for vulnerabilities
## (install first) https://aquasecurity.github.io/trivy
trivy-scan:
	trivy image $(OPV)
