# Part 3: Reconfigurable Array

## Overview
This part introduces a reconfigurable architecture that supports both Weight Stationary (WS) and Output Stationary (OS) dataflows. This flexibility allows the accelerator to adapt to different layer geometries (e.g., different ratios of weights to activations) to optimize for data reuse and energy efficiency.

## Hardware Architecture Enhancements

### Reconfigurable MAC Tile (`mac_tile.v`)
The tile is significantly redesigned to support two modes of operation:

1.  **Weight Stationary (WS) Mode** (`mode = 0`):
    *   Behaves like the Part 1/2 architecture.
    *   Weights are stationary in `b_q`.
    *   Partial sums flow vertically (`out_s`).

2.  **Output Stationary (OS) Mode** (`mode = 1`):
    *   **Accumulation**: Partial sums accumulate locally in the tile (`OS_tile0`, `OS_tile1`) instead of flowing south immediately.
    *   **Weight Streaming**: Weights flow vertically through the array.
    *   **Output**: Once accumulation is complete (determined by `acc_counter` and `loop` signals), the final result is read out.
    *   **Double Buffering**: Uses two accumulator registers (`OS_tile0`, `OS_tile1`) to allow computation to proceed on one tile while the other is being read out, hiding latency.

### Control Logic
*   **Loop Control**: Added `loop` and `acc_counter` to manage the accumulation cycles in OS mode.
*   **Output Valid**: `OS_out_valid` signals when a valid output is ready to be read from the stationary accumulators.
*   **Datapath Muxing**: Multiplexers select the correct data sources for `out_s` and internal registers based on the active mode.

## Benefits
*   **Adaptability**: Can choose the optimal dataflow for specific convolution or fully connected layers.
*   **Efficiency**: Reduces global buffer accesses by maximizing local data reuse (weights in WS, psums in OS).
