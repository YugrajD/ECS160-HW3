## Machine Specs
2024 M4 Macbook Air  
**CPU:** Apple M4 Chip (10-core CPU with 4 performance cores and 6 efficiency cores, ARM64 architecture, 16-core Neural Engine)  
**GPU:** 10-core GPU  
**Memory:** 16 GB unified memory (120 GB/s memory bandwidth)  
**OS:** macOS Tahoe 26.0.1  

## Part B: Running the application with the AFL++ fuzzer

**Without any seeds**  
When running with the AFL++ fuzzer and no seeds, there were no crashes at all. The throughput seems to be very high with it being 2136.31 execs/sec. We believe this is due to the input changes being very small and not being able to find a valid input whatsoever. There may be undetected behavior happening since it is unable to detect it and crash instead of allowing it to happen. As for the coverage, there was 0.03%/0.03% bit map coverage and 1 new edge having 100%.  

- **Number of crashes found:** 0 (0 saved)  
- **Coverage:** 0.03%/0.03% bit map coverage and 1 new edge (100%)  
- **Execution Throughput:** 2136.31 execs/sec  

**With seeds (10 sample PNG files)**
When running with the AFL++ fuzzer and 10 seeds, there were a large number of crashes, 1.33 million, with 41 of them being saved. The throughput seems to be high with it being 1354.18 execs/sec. We believe this is due to the AFL++ fuzzer prioritizing the seeds that run the quickest while rarely choosing the seeds that take longer to run. As for the coverage, there was 4.36%/13.28% bit map coverage at the end with 32 new edges having 6.53%.  

- **Number of crashes found:** 1.33M (41 saved)  
- **Coverage:** 4.36%/13.28% bit map coverage and 32 new edges (6.53%)  
- **Execution Throughput:** 1354.18 execs/sec  

## Part C: Running the application with the AFL++ fuzzer and the ASAN and UBSAN sanitizers enabled

**With seeds (10 sample PNG files) and ASAN and UBSAN sanitizers enabled**
When running with the AFL++ fuzzer, 10 seeds, ASAN, and UBSAN sanitizers enabled, there were a small number of crashes, 1053, with 23 of them being saved. The throughput seems to be very low with it being 30.03 execs/sec. We believe this is due to the overhead added by the ASAN sanitizer inserting red zones and checking the shadow memory as well as the UBSAN sanitizer adding checks around operations with undefined behavior. As for the coverage, there was 7.93%/13.29% bit map coverage at the end with 30 new edges having 7.63%.  

- **Number of crashes found:** 1053 (23 saved)  
- **Coverage:** 7.93%/13.29% bit map coverage and 30 new edges (7.63%)  
- **Execution Throughput:** 30.03 execs/sec  

## Part D: Write a custom mutator for LibPNG (Extra-Credit)
When running our custom mutator, 10 seeds, ASAN, and UBSAN sanitizers enblaed, there was a big number of crashes, 672k, with 5 of them being saved. The throughput seems to be a decent rate with it being 496.45 execs/sec. We believe this is due to the overhead added by our custom mutation logic. As for the coverage, there was 6.51%/12.92% bit map coverage at the end with 18 new edges having 3.23%.  

- **Number of crashes found:** 672k (5 saved)  
- **Coverage:** 6.51%/12.92% bit map coverage and 18 new edges (3.23%)  
- **Execution Throughput:** 496.45 execs/sec  

**Mutation Logic:** 
Our mutator works by allowing setting a 20MB buffer to handle an image, and mutates PNG chunks. It mutates the headers and data in each chunk half of the time randomly. For the header, it increases the width or height to the maximum dimension. For the data, it replaces it with a random value. The last part of our mutating code makes sure the CRC checksum is valid by fixing it so the LIBPNG functions can be tested.
