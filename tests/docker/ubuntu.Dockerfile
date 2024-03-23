FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        python3.11 \
        python3-pip \
        pkg-config \
        ccache \
        clang \
        g++ \
        ninja-build \
        cmake \
        libjsoncpp-dev \
        libexpected-dev \
        libgtest-dev \
        libfmt-dev \
        libcxxopts-dev
RUN apt-get clean
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.11 10

# Install meson from pip
RUN python -m pip install -U meson==0.64.1

# Copy code
WORKDIR /workarea
COPY ./ ./

ARG cc=gcc
ARG cxx=g++
ARG setup_options=

# Workaround Ubuntu broken ASan
RUN sysctl vm.mmap_rnd_bits=28

# Build cps-config and tests
ENV CC="ccache $cc" CXX="ccache $cxx"
ENV CCACHE_DIR=/ccache
RUN meson setup builddir $setup_options
RUN --mount=type=cache,target=/ccache,sharing=locked \
    ninja -C builddir
