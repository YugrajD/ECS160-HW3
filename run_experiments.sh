set -e

echo "==========================================="
echo "      ECS 160 HW3 - Final Automation       "
echo "==========================================="

echo "[*] Initializing LibPNG..."
cd /app/libpng
if [ ! -f ./configure ]; then
    ./autogen.sh
fi

# Part B
echo "[*] Part B: Compiling with standard AFL++..."
mkdir -p /app/build_part_b
cd /app/build_part_b

/app/libpng/configure --disable-shared --with-pic --prefix=/app/build_part_b/install > /dev/null
make clean > /dev/null
# Using -j2 to make sure it doesn't crash
make -j2 > /dev/null
make install > /dev/null

$CC -I/app/build_part_b/install/include \
    -L/app/build_part_b/install/lib \
    -o fuzzer_part_b /app/testharness.c \
    -lpng -lz -lm

echo "   [SUCCESS] Part B binary created"

# Part C
echo "[*] Part C: Compiling with ASAN + UBSAN..."
mkdir -p /app/build_part_c
cd /app/build_part_c

# Disable ASAN for configure to prevent crash
unset AFL_USE_ASAN
unset AFL_USE_UBSAN

/app/libpng/configure --disable-shared --with-pic --prefix=/app/build_part_c/install > /dev/null

# Re-enable ASAN for the actual build
export AFL_USE_ASAN=1
export AFL_USE_UBSAN=1

make clean > /dev/null
# Using -j2 to make sure it doesn't crash
make -j2 > /dev/null
make install > /dev/null

$CC -I/app/build_part_c/install/include \
    -L/app/build_part_c/install/lib \
    -o fuzzer_part_c /app/testharness.c \
    -lpng -lz -lm

# Clean up env for next steps
unset AFL_USE_ASAN
unset AFL_USE_UBSAN

echo "   [SUCCESS] Part C binary created"

# Part D
echo "[*] Part D: Compiling Custom Mutator..."
mkdir -p /app/build_part_d
cd /app/build_part_d

gcc -shared -Wall -O3 /app/mutator.c -o mutator.so -fPIC

echo "   [SUCCESS] Mutator library created"

echo "==========================================="
echo " All targets built successfully!"
echo " Seeds are already located in: /app/inputs"
echo "==========================================="