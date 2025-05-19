# ISKRA
ISKRA - Investigation Set of Cryptographic Robust Algorithms

## Burya family of hash functions

### Burya32
A simple 32-bit custom hash function.

How it works:
1. Input: Decimal string (max 64-bit number)
2. Converts number into up to 8 little-endian bytes
3. Two 16-bit registers (A and D ) are updated per byte:
    - A += byte
    - D ^= rotated byte
    - D = left rotate(D, 1)
    - D ^= A
    - Swap A and D
4. Output: 8-character string from obfuscated A and D

### Burya64  
A simple 64-bit custom hash function.

How it works:  
1. Input: Decimal string (max 64-bit number)  
2. Converts number into up to 8 little-endian bytes  
3. Four 16-bit registers (A-D) are updated per byte:  
   - A += byte  
   - B = left rotate(B, byte % 16)  
   - C ^= byte  
   - D ^= byte  
   - Cycle registers: A→B, B→C, C→D, D→A  
4. Output: 16-character string from obfuscated A-D  

### Burya128  
A simple 128-bit custom hash function.

How it works:  
1. Input: Decimal string (max 64-bit number)  
2. Converts number into up to 8 little-endian bytes  
3. Eight 16-bit registers (A–H) are updated per byte: 
   - A += byte + F  
   - B = left rotate(B, byte % 16) ^ H  
   - C ^= byte ^ E  
   - D += byte ^ G  
   - E += rotated byte + C  
   - F ^= (byte ^ 0xAA) ^ B  
   - G = right rotate(G, byte % 16) + D  
   - H += ~byte + A  
   - Cycle registers: A→B→C→D→E→F→G→H→A  
4. Output: 32-character string from obfuscated A–H  