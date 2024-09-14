FROM alpine:3.20.3

# latest certs
RUN apk add ca-certificates --no-cache && update-ca-certificates

# timezone support
ENV TZ=UTC
RUN apk add --update tzdata --no-cache &&\
    cp /usr/share/zoneinfo/${TZ} /etc/localtime &&\
    echo $TZ > /etc/timezone

# ==additional apk packages==
# https://pkgs.alpinelinux.org/contents?branch=edge&name=bind%2dtools&arch=x86&repo=main
# bind-tools: dig,nslookup for DNS lookup
# netcat-opensbd: nc for netcat
# jq: json parsing
# yq: yaml parsing
# ntpsec: ntpdig for ntp client time query (ntpdig pool.ntp.org)
RUN apk add --update --no-cache \
  wget curl bind-tools netcat-openbsd coreutils jq yq ntpsec

RUN mkdir /usr/src
WORKDIR /usr/src

ARG AB_VERSION=2.4.59
RUN wget http://archive.apache.org/dist/httpd/httpd-${AB_VERSION}.tar.gz &&\
 tar xvfz httpd-*.tar.gz
WORKDIR /usr/src/httpd-${AB_VERSION}

RUN cp support/ab.c support/ab.c.old &&\
 wget https://raw.githubusercontent.com/fabianlee/blogcode/master/haproxy/ab.c -O support/ab.c &&\
 apk add build-base apr-dev apr apr-util apr-util-dev pcre pcre-dev &&\
 ./configure &&\
 make &&\
 cp support/ab /usr/sbin/ab

# standard Docker arguments
ARG TARGETPLATFORM
ARG BUILDPLATFORM
# custom build arguments
ARG BUILD_TIME
ARG GITREF
# persist these build time arguments into container as debug
RUN echo "[$BUILD_TIME] [$GITREF] building on host that is $BUILDPLATFORM, for the target architecture $TARGETPLATFORM" > /build.log

#ENTRYPOINT ["/usr/sbin/ab"]

