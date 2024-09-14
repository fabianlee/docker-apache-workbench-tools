# docker-apache-workbench-tool
Docker image based on tiny-tools with additional network tools and Apache workbench for load testing

Image is based on alpine and is ~ 8Mb

# Prerequisites
* docker
* sudo apt-get install make

# Makefile targets
* docker-build (builds image)
* docker-run-fg (runs container in foreground, ctrl-C to exit)
* docker-run-bg (runs container in background)
