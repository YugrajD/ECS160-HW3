Machine Specs
2024 M4 Macbook Air
CPU: Apple M4 Chip (10-core CPU with 4 performance cores and 6 efficiency cores, ARM64 architecture, 16-core Neural Engine)
GPU: 10-core GPU
Memory: 16 GB unified memory (120 GB/s memory bandwidth)
OS: macOS Tahoe 26.0.1

Part B: Running the application with the AFL++ fuzzer

Without any seeds
Number of crashes found: 0 (0 saved)
Coverage: 0.03%/0.03% bit map coverage and 1 new edge (100%)
Execution Throughput: 2136.31 execs/sec

With seeds (10 sample PNG files)
Number of crashes found: 1.33M (41 saved)
Coverage: 4.36%/13.28% bit map coverage and 32 new edges (6.53%)
Execution Throughput: 1354.18 execs/sec

Part C: Running the application with the AFL++ fuzzer and the ASAN and UBSAN sanitizers enabled

With seeds (10 sample PNG files) and ASAN and UBSAN sanitizers enabled
Number of crashes found: 1053 (23 saved)
Coverage: 7.93%/13.29% bit map coverage and 30 new edges (7.63%)
Execution Throughput: 30.03 execs/sec

Part D: Write a custom mutator for LibPNG (Extra-Credit)

Number of crashes found: 672k (5 saved)
Coverage: 6.51%/12.92% bit map coverage and 18 new edges (3.23%)
Execution Throughput: 496.45 execs/sec