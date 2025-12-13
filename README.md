# ECS160 HW3 - AFL++ LibPNG Fuzzing

## Prerequisites

- macOS
- [Homebrew](https://brew.sh/)

## Files

- `script.sh` - Build script
- `testharness.c` - Test harness for libpng
- `mutator.c` - Custom mutator (Part D)
- `seeds/` - 10 PNG seed files

## Setup

```bash
chmod +x script.sh
./script.sh
```

This builds:
- `harness_partb` - AFL++ instrumentation only
- `harness_partc` - AFL++ with ASAN and UBSAN
- `mutator.dylib` - Custom mutator library

## Running Fuzzing

First, add AFL++ to your path:

```bash
export PATH="$PWD/AFLplusplus:$PATH"
```

Run each experiment for 1 hour:

**Part B (no seeds):**
```bash
afl-fuzz -i no_seed -o output_partb_noseed -- ./harness_partb @@ /tmp/out.png
```

**Part B (with seeds):**
```bash
afl-fuzz -i seeds -o output_partb_seed -- ./harness_partb @@ /tmp/out.png
```

**Part C (ASAN + UBSAN):**
```bash
afl-fuzz -i seeds -o output_partc -- ./harness_partc @@ /tmp/out.png
```

**Part D (Custom mutator):**
```bash
export AFL_CUSTOM_MUTATOR_LIBRARY=$PWD/mutator.dylib
afl-fuzz -i seeds -o output_partd -- ./harness_partc @@ /tmp/out.png
```

## Output

Results are saved in:
- `output_partb_noseed/`
- `output_partb_seed/`
- `output_partc/`
- `output_partd/`

Check `fuzzer_stats` in each output directory for crashes, coverage, and throughput.
