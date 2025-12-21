# Part 2: SIMD Support

## Overview
This part enhances the baseline systolic array with Single Instruction, Multiple Data (SIMD) capabilities. This allows the hardware to support lower precision operations (2-bit) efficiently by packing multiple operations into a single MAC unit, effectively doubling the throughput for reduced precision workloads.

## Hardware Architecture Enhancements

### SIMD MAC Unit (`mac.v`)
The MAC unit is modified to support a `mode` signal:
*   **Mode 0 (4-bit)**: Performs standard 4-bit multiplication and accumulation.
*   **Mode 1 (2-bit SIMD)**: Splits the 4-bit datapath to perform two independent 2-bit multiplications simultaneously.
    *   **Input Splitting**: The 4-bit inputs `a` and `b` are treated as two 2-bit values (`a0, a1` and `b0, b1`).
    *   **Parallel Execution**: 
        *   `prod0 = a0 * b0`
        *   `prod1 = a1 * b1`
    *   **Accumulation**: The results are combined and added to the partial sum.

### MAC Tile (`mac_tile.v`)
*   **Registers**: Added registers to store split weights (`b_q0`, `b_q1`) and activations (`a_q0`, `a_q1`).
*   **Control**: The `mode` input controls whether the tile operates in standard or SIMD mode.
*   **Loading**: The loading logic is updated to handle the packing of 2-bit weights into the 4-bit storage.

## Benefits
*   **Throughput**: Doubled peak performance (OPS) for 2-bit quantized models.
*   **Flexibility**: Dynamic switching between high-precision (4-bit) and high-throughput (2-bit) modes based on application requirements.
