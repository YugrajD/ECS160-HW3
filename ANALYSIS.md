## Machine Specs
2024 M4 Macbook Air  
**CPU:** Apple M4 Chip (10-core CPU with 4 performance cores and 6 efficiency cores, ARM64 architecture, 16-core Neural Engine)  
**GPU:** 10-core GPU  
**Memory:** 16 GB unified memory (120 GB/s memory bandwidth)  
**OS:** macOS Tahoe 26.0.1  

## Part B: Running the application with the AFL++ fuzzer
For the first part of Part B, there were some issues with running it with a 1 byte file. We were able to run it on our file outside of compiling with the shell script but were unable to after compiling with the shell script. As such, we separated the analysis into two sections, one where we used the 1 byte file and the other where we used a 67 byte file. The macOS shell script generates the 67 byte file for the person running it while the 1 byte file will be included in our submission.  

**Without any seeds and 1 byte file**  
When running with the AFL++ fuzzer and no seeds, there were no crashes at all. The throughput seems to be very high with it being 2136.31 execs/sec. We believe this is due to the input changes being very small and not being able to find a valid input whatsoever. There may be undetected behavior happening since it is unable to detect it and crash instead of allowing it to happen. As for the coverage, there was 0.03% bit map coverage and 1 new edge having 100%.  

- **Number of crashes found:** 0 (0 saved)  
- **Coverage:** 0.03% bit map coverage and 1 new edge (100%)  
- **Execution Throughput:** 2136.31 execs/sec  

**Without any seeds and 67 byte file**  
When running with the AFL++ fuzzer and no seeds, there were 423k crashes, with 21 of them being saved. The throughput seems to be low with it being 159.09 execs/sec. As for the coverage, there was 8.16% bit map coverage and 26 new edge having 55.32%.  

- **Number of crashes found:** 423k (21 saved)  
- **Coverage:** 8.16% bit map coverage and 26 new edge (55.32%)  
- **Execution Throughput:** 159.09 execs/sec  

**With seeds (10 sample PNG files)**
When running with the AFL++ fuzzer and 10 seeds, there were a large number of crashes, 1.33 million, with 41 of them being saved. The throughput seems to be high with it being 1354.18 execs/sec. We believe this is due to the AFL++ fuzzer prioritizing the seeds that run the quickest while rarely choosing the seeds that take longer to run. As for the coverage, there was 13.28% bit map coverage at the end with 32 new edges having 6.53%.  

- **Number of crashes found:** 1.33M (41 saved)  
- **Coverage:** 13.28% bit map coverage and 32 new edges (6.53%)  
- **Execution Throughput:** 1354.18 execs/sec  

## Part C: Running the application with the AFL++ fuzzer and the ASAN and UBSAN sanitizers enabled

**With seeds (10 sample PNG files) and ASAN and UBSAN sanitizers enabled**
When running with the AFL++ fuzzer, 10 seeds, ASAN, and UBSAN sanitizers enabled, there were a small number of crashes, 1053, with 23 of them being saved. The throughput seems to be very low with it being 30.03 execs/sec. We believe this is due to the overhead added by the ASAN sanitizer inserting red zones and checking the shadow memory as well as the UBSAN sanitizer adding checks around operations with undefined behavior. As for the coverage, there was 13.29% bit map coverage at the end with 30 new edges having 7.63%.  

- **Number of crashes found:** 1053 (23 saved)  
- **Coverage:** 13.29% bit map coverage and 30 new edges (7.63%)  
- **Execution Throughput:** 30.03 execs/sec  

## Part D: Write a custom mutator for LibPNG (Extra-Credit)
When running our custom mutator, 10 seeds, ASAN, and UBSAN sanitizers enabled, there was a big number of crashes, 672k, with 5 of them being saved. The throughput seems to be a decent rate with it being 496.45 execs/sec. We believe this is due to the overhead added by our custom mutation logic and sanitizer checks. As for the coverage, there was 12.92% bit map coverage at the end with 18 new edges having 3.23%.  

- **Number of crashes found:** 672k (5 saved)  
- **Coverage:** 12.92% bit map coverage and 18 new edges (3.23%)  
- **Execution Throughput:** 496.45 execs/sec  

**Mutation Logic:** 
Our mutator works by allowing setting a 20MB buffer to handle an image, and mutates PNG chunks. It mutates the headers and data in each chunk half of the time randomly. For the header, it increases the width or height to the maximum dimension. For the data, it replaces it with a random value. The last part of our mutating code makes sure the CRC checksum is valid by fixing it so the LIBPNG functions can be tested.
