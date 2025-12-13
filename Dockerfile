FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install Dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    clang \
    llvm \
    llvm-dev \
    python3-dev \
    automake \
    libtool \
    zlib1g-dev \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Clone and Build AFL++
WORKDIR /fuzzing_tools
RUN git clone https://github.com/AFLplusplus/AFLplusplus.git
WORKDIR /fuzzing_tools/AFLplusplus
RUN make distrib
RUN make install

# Clone LibPNG
WORKDIR /app
RUN git clone https://github.com/pnggroup/libpng.git

ENV CC=/usr/local/bin/afl-cc
ENV CXX=/usr/local/bin/afl-c++
# Fixes AFL warning
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CPU_GOVERNOR=1
# Fixes "Pipe at beginning of core_pattern" error
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1
ENV AFL_SKIP_CPUFREQ=1

WORKDIR /app
COPY testharness.c /app/testharness.c
COPY mutator.c /app/mutator.c
COPY run_experiments.sh /app/run_experiments.sh
COPY seeds/ /app/inputs/

RUN sed -i 's/\r$//' /app/run_experiments.sh && \
    chmod +x /app/run_experiments.sh

CMD ["/bin/bash"]