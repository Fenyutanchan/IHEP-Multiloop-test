# Copyright (c) 2025 Quan-feng WU <wuquanfeng@ihep.ac.cn>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Minimal Fermat CAS Docker Image
# Fermat is a Computer Algebra System for polynomial and matrix computations

FROM debian:bookworm-slim

LABEL maintainer="Fenyutanchan"
LABEL description="Minimal Docker image for Fermat CAS"

# Install minimal dependencies (only needed for downloading)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/fermat

# Download Fermat 7.8 (pre-compiled static binary)
# Official website: https://home.bway.net/lewis/
RUN wget -q https://home.bway.net/lewis/fermat64/Ferl7.tar.gz && \
    tar -xzf Ferl7.tar.gz && \
    rm Ferl7.tar.gz

# Add Fermat executables to PATH
ENV PATH="/opt/fermat/Ferl7:${PATH}"

# Set default working directory for user
WORKDIR /workspace

# Default command - run Fermat 7 (fer64 is the main executable)
CMD ["fer64"]

