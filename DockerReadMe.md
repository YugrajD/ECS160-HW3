# ECS 160 HW3: Automated Fuzzing with AFL++

This repository contains the automation scripts, custom mutators, and Docker configuration for performing fuzzing experiments on `libpng` using AFL++.

The setup includes a completely automated build environment that handles:

  * Fetching and patching `libpng`.
  * Compiling multiple target binaries (Standard, ASAN+UBSAN).
  * Compiling a custom mutator shared object.
  * Downloading seed corpora.
  * Configuring the environment to bypass common AFL++ errors (CPU governor, crash reporting).

## 📂 Project Structure

```text
.
├── Dockerfile             # Defines the Ubuntu-based fuzzing environment
├── run_experiments.sh     # Automation script to compile all targets
├── testharness.c          # The C harness entry point for libpng
├── mutator.c              # Custom mutation logic (Part D)
└── seeds/                 # Folder containing sample PNG images
```

-----

## 🚀 Setup & Installation

This project is designed to run entirely inside Docker to ensure reproducibility and prevent system crashes.

### 1\. Build the Docker Image

Run this command in the root of the repository. This installs all dependencies (clang, llvm, AFL++) and copies the local files into the image.

```bash
docker build -t ecs160-final .
```

### 2\. Enter the Container

Start the container in interactive mode.

  * `--privileged` is **required** for AFL++ to tune system performance.
  * `--rm` ensures the container is cleaned up after you exit.

<!-- end list -->

```bash
docker run -it --rm --privileged ecs160-final
```

-----

## 🛠️ Compilation

Once inside the container, run the provided automation script. This script:

1.  Downloads `libpng` (if not present).
2.  Compiles **Part B** (Standard AFL++ instrumentation).
3.  Compiles **Part C** (With ASAN + UBSAN memory sanitizers).
4.  Compiles **Part D** (The custom `mutator.so` library).
5.  *Note: The script automatically limits compilation to 2 CPU cores (`make -j2`) to prevent memory exhaustion crashes.*

<!-- end list -->

```bash
./run_experiments.sh
```

**Success Indicator:** You will see `[SUCCESS]` messages for Part B, Part C, and the Mutator library.

-----

## 🧪 Running the Experiments

All experiments run for **1 hour**. The seeds are pre-loaded in `/app/inputs`.

### Part B: Standard Fuzzing

Baseline fuzzing using the standard binary.

```bash
afl-fuzz -i inputs -o out_b -- /app/build_part_b/fuzzer_part_b @@ /dev/null
```

### Part C: Sanitizer Fuzzing (ASAN + UBSAN)

Fuzzing with AddressSanitizer and UndefinedBehaviorSanitizer enabled. This finds subtle memory corruption bugs but runs slower than Part B.

```bash
afl-fuzz -i inputs -o out_c -- /app/build_part_c/fuzzer_part_c @@ /dev/null
```

### Part D: Custom Mutator

Fuzzing using the custom `mutator.so` library to manipulate inputs intelligently. This runs against the Part C binary to catch memory errors triggered by the mutations.

```bash
export AFL_CUSTOM_MUTATOR_LIBRARY=/app/build_part_d/mutator.so
afl-fuzz -i inputs -o out_d -- /app/build_part_c/fuzzer_part_c @@ /dev/null
```

-----

## 📊 Analyzing Results

After stopping an experiment (Ctrl+C) or letting it timeout, you can view the results in the output folders:

  * **Crashes:** Found in `out_b/default/crashes` (or `out_c`/`out_d`).
  * **Stats:** View `out_b/default/fuzzer_stats` for detailed metrics like `execs_per_sec` and `bitmap_cvg`.

### Quick Stats Command

To count crashes quickly inside the container:

```bash
ls out_b/default/crashes | wc -l
```

-----

## ⚠️ Troubleshooting

**"Mistyped AFL environment variable" warning**

  * This is normal. The Dockerfile sets variables for the fuzzer that the compiler doesn't recognize. You can safely ignore it.

**"Pipe at the beginning of core\_pattern"**

  * This is fixed automatically by the Dockerfile (`AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1`). If you see this, ensure you rebuilt the image using the latest Dockerfile.

**Docker crashing with "unexpected EOF"**

  * This means Docker ran out of RAM. The `run_experiments.sh` script limits compilation to 2 cores (`make -j2`) to prevent this. Do not change this back to `$(nproc)` unless you have allocated 8GB+ RAM to Docker.