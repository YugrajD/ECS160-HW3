#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// Can only accept 20MB images
#define MAX_BUFFER_SIZE (20 * 1024 * 1024)

// CRC-32 check to see if valid PNG
uint32_t calculate_crc32(const uint8_t *data, size_t length) {
    uint32_t crc = 0xFFFFFFFF;
    for (size_t i = 0; i < length; i++) {
        crc ^= data[i];
        for (int j = 0; j < 8; j++) {
            if (crc & 1) crc = (crc >> 1) ^ 0xEDB88320;
            else         crc = crc >> 1;
        }
    }
    return ~crc;
}

typedef struct {
    uint8_t *mutated_out;
} my_state_t;

void *afl_custom_init(void *afl, unsigned int seed) {
    srand(seed);
    my_state_t *data = calloc(1, sizeof(my_state_t));
    if (!data) return NULL;
    
    data->mutated_out = malloc(MAX_BUFFER_SIZE);
    if (!data->mutated_out) {
        free(data);
        return NULL;
    }
    return data;
}

void afl_custom_deinit(my_state_t *data) {
    if (data) {
        free(data->mutated_out);
        free(data);
    }
}

size_t afl_custom_fuzz(my_state_t *data, uint8_t *buf, size_t buf_size, uint8_t **out_buf, uint8_t *add_buf, size_t add_buf_size, size_t max_size) {
    // Safety: Prevents fuzzer from overflowing
    if (buf_size > MAX_BUFFER_SIZE) return 0;

    // Check if PNG
    if (buf_size < 8 || memcmp(buf, "\x89PNG", 4) != 0) return 0;

    // Copy input to our buffer
    memcpy(data->mutated_out, buf, buf_size);
    uint8_t *img = data->mutated_out;
    int mutated = 0;

    size_t offset = 8;
    while (offset + 12 <= buf_size) {
        // Read length
        uint32_t chunk_len = (img[offset] << 24) | (img[offset+1] << 16) | (img[offset+2] << 8) | img[offset+3];

        if (offset + 12 + chunk_len > buf_size) break;

        uint8_t *type_ptr = &img[offset + 4];
        uint8_t *data_ptr = &img[offset + 8];

        // Mutate Header (IHDR)
        if (memcmp(type_ptr, "IHDR", 4) == 0 && chunk_len >= 8) {
            if (rand() % 2 == 0) {
                // Set width (0) or height (4)
                int pos = (rand() % 2) ? 0 : 4;
                
                // Big Endian order
                memcpy(data_ptr + pos, "\x7F\xFF\xFF\xFF", 4);
                
                mutated = 1;
            }
        }
        // Mutate Data (IDAT)
        else if (memcmp(type_ptr, "IDAT", 4) == 0 && chunk_len > 0) {
            if (rand() % 2 == 0) {
                // Randomize one byte
                data_ptr[rand() % chunk_len] = rand() % 255;
                mutated = 1;
            }
        }

        // Recalculate CRC
        uint32_t new_crc = calculate_crc32(type_ptr, 4 + chunk_len);
        
        // Use built-in memcpy for Big Endian writing
        uint32_t be_crc = __builtin_bswap32(new_crc);
        memcpy(img + offset + 8 + chunk_len, &be_crc, 4);

        offset += (12 + chunk_len);
    }

    // Skip if no mutation
    if (!mutated) return 0;

    *out_buf = data->mutated_out;
    return buf_size;
}