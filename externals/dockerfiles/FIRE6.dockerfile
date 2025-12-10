# Copyright (c) 2025 Quan-feng WU <wuquanfeng@ihep.ac.cn>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Copied from https://gitlab.srcc.msu.ru/feynmanintegrals/fire/-/blob/ae0808df5f38926b6e69d3f3299b963528ca449d/ with minor modifications (under GPLv2)


# Builder stage for FIRE6 compilation
FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    PATH=/root/.cargo/bin:$PATH

# Install build dependencies
RUN apt update \
    && apt install -y \
        g++ \
        curl \
        wget \
        cmake \
        libtool \
        build-essential \
        zlib1g-dev \
        git \
        autoconf \
        automake \
        mpich \
    && export RUSTUP_INIT_SKIP_PATH_CHECK=yes \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && export RUSTUP_INIT_SKIP_PATH_CHECK=yes \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Clone and build FIRE6
WORKDIR /src
RUN git clone --recurse-submodules https://gitlab.com/feynmanIntegrals/fire.git && \
    cd fire/FIRE6 && \
    ./configure --enable-zlib --enable-zstd --enable-snappy --enable-tcmalloc --enable_lthreads --enable-flint --enable-symbolica && \
    make dep -j$(nproc) && \
    make -j$(nproc) && \
    make mpi -j$(nproc) && \
    cd .. && \
    cp -r FIRE6 /

# Runtime stage
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC

ARG FIRE_VERSION=FIRE6

# Install runtime dependencies only
RUN apt update && \
    apt install -y libstdc++6 mpich zlib1g && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Copy built FIRE6 from builder stage
RUN mkdir -p /FIRE6
COPY --from=builder /FIRE6 /FIRE6

# Set library path
ENV LD_LIBRARY_PATH=/FIRE6/usr/lib:/FIRE6/extra/fuel/usr/lib \
    PATH=/FIRE6/bin:$PATH

WORKDIR /work

CMD ["/FIRE6/bin/FIRE6"]
