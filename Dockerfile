# syntax=docker/dockerfile:1

ARG GOIMAGE
ARG DISTRO=ubuntu
ARG SUITE=jammy
ARG VERSION_ID=22.04
ARG BUILD_IMAGE=${DISTRO}:${SUITE}

#FROM ${IMAGE} AS build_image

FROM ${BUILD_IMAGE} as goimage

# Remove diverted man binary to prevent man-pages being replaced with "minimized" message.

RUN if  [ "$(dpkg-divert --truename /usr/bin/man)" = "/usr/bin/man.REAL" ]; then \
    rm -f /usr/bin/man; \
    dpkg-divert --quiet --remove --rename /usr/bin/man; \
    fi

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl devscripts equivs git

#ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin
    
ARG COMMON_FILES
COPY --link ${COMMON_FILES} /root/build-deb/debian
RUN apt-get update \
    && mk-build-deps -t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" -i /root/build-deb/debian/control

COPY --link sources/ /sources

ARG DISTRO
ARG SUITE
ARG VERSION_ID
ENV DISTRO=${DISTRO}
ENV SUITE=${SUITE}
ENV VERSION_ID=${VERSION_ID}

WORKDIR /root/build-deb
COPY build-deb /root/build-deb/build-deb

ENTRYPOINT ["/root/build-deb/build-deb"]
