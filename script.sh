#!/bin/bash
set -e

echo "[*] ECS160 HW3 – macOS AFL++ + libpng build"

# Check if MacOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is macOS-only."
  exit 1
fi

# Homebrew Dependencies 
brew install llvm git autoconf automake libtool pkg-config zlib || true

export LLVM_CONFIG="$(brew --prefix llvm)/bin/llvm-config"
export PATH="$(brew --prefix llvm)/bin:$PATH"
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

ROOT="$(pwd)"

# Build AFL++
if [ ! -d AFLplusplus ]; then
  echo "Cloning AFL++"
  git clone https://github.com/AFLplusplus/AFLplusplus.git
fi

cd AFLplusplus
make -j$(sysctl -n hw.ncpu)
cd "$ROOT"

export AFL_PATH="$ROOT/AFLplusplus"
export PATH="$ROOT/AFLplusplus:$PATH"
echo "AFL++ built"

# Clone libpng
if [ ! -d libpng ]; then
  echo "Cloning libpng"
  git clone https://github.com/pnggroup/libpng.git
fi

# PART B
echo "Building Part B (AFL only)"

rm -rf libpng-partb
cp -r libpng libpng-partb
cd libpng-partb

autoreconf -fi
CC=afl-clang-fast ./configure --disable-shared
make -j$(sysctl -n hw.ncpu)

cd "$ROOT"

afl-clang-fast \
  -Ilibpng-partb \
  testharness.c \
  libpng-partb/.libs/libpng18.a \
  -lz -lm \
  -o harness_partb

echo "Part B built"

# PART C
echo "Building Part C (AFL + ASAN + UBSAN)"

rm -rf libpng-partc
cp -r libpng libpng-partc
cd libpng-partc

autoreconf -fi
export AFL_USE_ASAN=1
export AFL_USE_UBSAN=1

CC=afl-clang-fast ./configure --disable-shared
make -j$(sysctl -n hw.ncpu)

unset AFL_USE_ASAN
unset AFL_USE_UBSAN

cd "$ROOT"

afl-clang-fast \
  -fsanitize=address,undefined \
  -fno-omit-frame-pointer \
  -Ilibpng-partc \
  testharness.c \
  libpng-partc/.libs/libpng18.a \
  -lz -lm \
  -o harness_partc

echo "[+] Part C built"

# PART D 
echo "[*] Building Part D custom mutator"

clang -shared -fPIC \
  -o mutator.dylib \
  mutator.c

echo "[+] Part D mutator built"

# Fuzzing directories
mkdir -p no_seed
mkdir -p output_partb_noseed
mkdir -p output_partb_seed
mkdir -p output_partc
mkdir -p output_partd

printf "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\x0A\x49\x44\x41\x54\x78\x9C\x63\x00\x01\x00\x00\x05\x00\x01\x0D\x0A\x2D\xB4\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82" > no_seed/pixel.png

echo ""
echo "======================================"
echo "BUILD COMPLETE"
echo "======================================"
echo ""
echo "Binaries:"
echo "  ./harness_partb"
echo "  ./harness_partc"
echo "  ./mutator.dylib"
echo ""
echo "Run this command to add afl-fuzz to your path FIRST:"
echo "  export PATH=\"$ROOT/AFLplusplus:\$PATH\""
echo ""
echo "Run fuzzing manually:"
echo ""
echo "Part B (no seeds):"
echo "  afl-fuzz -i no_seed -o output_partb_noseed -- ./harness_partb @@ /tmp/out.png"
echo ""
echo "Part B (with seeds):"
echo "  afl-fuzz -i seeds -o output_partb_seed -- ./harness_partb @@ /tmp/out.png"
echo ""
echo "Part C (ASAN + UBSAN):"
echo "  afl-fuzz -i seeds -o output_partc -- ./harness_partc @@ /tmp/out.png"
echo ""
echo "Part D (Custom mutator):"
echo "  export AFL_CUSTOM_MUTATOR_LIBRARY=\$PWD/mutator.dylib"
echo "  afl-fuzz -i seeds -o output_partd -- ./harness_partc @@ /tmp/out.png"
echo "======================================"
