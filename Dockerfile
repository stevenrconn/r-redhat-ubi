FROM registry.access.redhat.com/ubi9/ubi:latest AS build

ENV R_RELEASE_MAJOR "4"
ENV R_RELEASE_MINOR "3.3"
ENV R_URL           "https://cloud.r-project.org/src/base/R-${R_RELEASE_MAJOR}/R-${R_RELEASE_MAJOR}.${R_RELEASE_MINOR}.tar.gz"
ENV R_HASH          "80851231393b85bf3877ee9e39b282e750ed864c5ec60cbd68e6e139f0520330"

WORKDIR /build

RUN set -o xtrace && \
    dnf --assumeyes upgrade && \
    dnf --assumeyes install gcc gcc-gfortran make perl perl-Digest-SHA diffutils \
                    libX11-devel libXt-devel zlib-devel bzip2-devel xz-devel \
                    pcre2-devel libcurl-devel libjpeg-turbo-devel libpng-devel


RUN set -o xtrace && \
    curl --location --output r.tar.gz ${R_URL} && \
    echo "${R_HASH}  r.tar.gz" | shasum --check && \
    tar --extract --gunzip --strip-components=1 --file=r.tar.gz

RUN set -o xtrace && \
    ./configure --prefix=/opt/r --without-readline --disable-java && \
    make && \
    make test && \
    make install





