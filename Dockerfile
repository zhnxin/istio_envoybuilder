FROM ubuntu:bionic as builder

WORKDIR /root

ENV EXTRACTED_CLANG_LLVM="clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04" \
    PATH="$HOME/go/bin:/root/${EXTRACTED_CLANG_LLVM}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/llvm-9/bin" \
    CC=clang \
    CXX=clang++

    # BAZEL_BUILD_ARGS="--override_repository=envoy=/root/envoy" \
ARG ENVOY_SHA=79fc5875a60ff73ef14d8f7dc480487317921517
ARG ISTIO_TAG="1.6.7"
ADD bazel_setup_clang.sh /root/bazel_setup_clang.sh

RUN apt-get update &&\
    apt-get install \
    libtool \
    cmake \
    automake \
    autoconf \
    make \
    ninja-build \
    curl \
    wget \
    unzip \
    virtualenv \
    python \
    libc++-10-dev \
    libstdc++-7-dev \
    gnupg \
    git  \
    g++ \
    zlib1g-dev \
    openjdk-11-jdk -y
RUN cd /root  &&\
    wget https://mirrors.huaweicloud.com/bazel/2.2.0/bazel_2.2.0-linux-x86_64.deb &&\
    dpkg -i bazel_2.2.0-linux-x86_64.deb &&\
    wget "https://releases.llvm.org/9.0.0/${EXTRACTED_CLANG_LLVM}.tar.xz" &&\
    tar -xvJf "${EXTRACTED_CLANG_LLVM}.tar.xz" &&\
    rm "${EXTRACTED_CLANG_LLVM}.tar.xz" bazel_2.2.0-linux-x86_64.deb


RUN mkdir -p /root/go/src/istio.io &&\
    cd /root/go/src/istio.io &&\
    git clone https://github.com/istio/proxy.git &&\
    cd proxy &&\
    git checkout "tags/${ISTIO_TAG}" &&\
    bash /root/bazel_setup_clang.sh "/root/${EXTRACTED_CLANG_LLVM}" &&\
    sed -i 's|build_envoy:|fetch_envoy:\n\texport PATH=$(PATH) CC=$(CC) CXX=$(CXX) \&\& bazel $(BAZEL_STARTUP_ARGS) fetch $(BAZEL_BUILD_ARGS) //src/envoy:envoy\n\nbuild_envoy:|g'  Makefile.core.mk &&\
    make fetch_envoy
