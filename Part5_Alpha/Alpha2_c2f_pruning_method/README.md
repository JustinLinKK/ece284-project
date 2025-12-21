# Alpha 2: Coarse-to-Fine (C2F) Pruning Method

## Overview
This module implements a Coarse-to-Fine (C2F) pruning strategy to reduce the model size and computational complexity. Pruning removes less important connections (weights) from the neural network.

## Methodology

### Mixed Pruning Strategy
*   **Concept**: Instead of a one-step aggressive pruning, the model undergoes a gradual pruning process.
*   **Coarse Phase**: Initial pruning removes blocks or groups of weights that contribute least to the output. This is more hardware-friendly as it maintains some regularity.
*   **Fine Phase**: Subsequent pruning targets individual weights to further increase sparsity without significant accuracy loss.

### Hardware Alignment
*   **Design Goal**: The pruning pattern is designed to be compatible with the 2-D systolic array architecture (specifically the Alpha 3 design).
*   **Benefit**: Structured sparsity allows the hardware to skip computations effectively, translating theoretical FLOPs reduction into actual speedup and energy savings.
