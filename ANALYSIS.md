Machine Specs
2024 M4 Macbook Air
CPU: Apple M4 Chip (10-core CPU with 4 performance cores and 6 efficiency cores, ARM64 architecture, 16-core Neural Engine)
GPU: 10-core GPU
Memory: 16 GB unified memory (120 GB/s memory bandwidth)
OS: macOS Tahoe 26.0.1

Part B: Running the application with the AFL++ fuzzer

Without any seeds
Number of crashes found: 0
Coverage: 0.03%
Execution Throughput: 2136.31 execs/sec

With seeds (10 sample PNG files)
Number of crashes found: 41
Coverage: 13.28%
Execution Throughput: 1354.18 execs/sec

Part C: Running the application with the AFL++ fuzzer and the ASAN and UBSAN sanitizers enabled

With seeds (10 sample PNG files) and ASAN and UBSAN sanitizers enabled
Number of crashes found: 23
Coverage: 13.29%
Execution Throughput: 30.03 execs/sec

Part D: Write a custom mutator for LibPNG (Extra-Credit)

Number of crashes found: 
Coverage: %
Execution Throughput: # execs/sec