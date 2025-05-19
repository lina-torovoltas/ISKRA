// ISKRA-Burya64 ver1.0 on C

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// Initial constants for registers A–D used in the hash function
uint16_t A = 0x0782;
uint16_t B = 0x07A9;
uint16_t C = 0x07B1;
uint16_t D = 0x05D4;

// Converts a 16-bit word into a 4-character hexadecimal string with bit rotation for obfuscation
void write_hex_word(uint16_t value, char *buffer) {
    for (int i = 0; i < 4; i++) {
        value = (value << 4) | (value >> 12);
        uint8_t nibble = value & 0xF;
        *buffer++ = nibble < 10 ? ('0' + nibble) : ('a' + nibble - 10);
    }
}

int main() {
    // Buffers for input string, extracted bytes, and final hex output
    char input_buffer[33] = {0};
    uint8_t data_bytes[8] = {0};
    char hex_buffer[17] = {0};

    // Read a decimal number string from stdin
    if (!fgets(input_buffer, sizeof(input_buffer), stdin)) {
        return 1;
    }

    // Parse input, verify digits only, and convert to 64-bit number
    uint64_t number = 0;
    for (int i = 0; input_buffer[i] != '\0' && input_buffer[i] != '\n'; i++) {
        char c = input_buffer[i];
        if (c < '0' || c > '9') {
            return 1;
        }
        number = number * 10 + (c - '0');
    }

    // Break down the number into up to 8 bytes (little-endian)
    size_t byte_count = 0;
    while (number && byte_count < 8) {
        data_bytes[byte_count++] = number & 0xFF;
        number >>= 8;
    }

    // Main loop: process each byte and update registers A–D
    for (size_t i = 0; i < byte_count; i++) {
        uint8_t byte = data_bytes[i];
        A = (A + byte) & 0xFFFF;

        // Rotate B left by (byte mod 16) bits
        uint16_t rot = byte & 15;
        B = ((B << rot) | (B >> (16 - rot))) & 0xFFFF;

        // XOR byte with C and D
        C ^= byte;
        D ^= byte;

        // Cycle registers A, B, C, D to shuffle state
        uint16_t tmpA = A, tmpB = B, tmpC = C, tmpD = D;
        A = tmpB;
        B = tmpC;
        C = tmpD;
        D = tmpA;
    }

    // Compose final hex string from registers A–D
    char *p = hex_buffer;
    write_hex_word(A, p); p += 4;
    write_hex_word(B, p); p += 4;
    write_hex_word(C, p); p += 4;
    write_hex_word(D, p); p += 4;
    *p++ = '\n';
    *p = '\0';

    // Output the result to stdout
    fputs(hex_buffer, stdout);
    return 0;
}