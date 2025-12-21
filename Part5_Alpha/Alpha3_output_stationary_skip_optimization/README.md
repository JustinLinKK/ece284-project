# Alpha 3: Output Stationary Skip Optimization

## Overview
This module implements hardware optimizations to leverage the sparsity introduced by pruning (Alpha 2) and the ReLU activation function. By skipping ineffectual operations (multiplications by zero), dynamic power consumption is significantly reduced.

## Hardware Design

### Zero-Skipping Logic
*   **Mechanism**: The hardware detects when an input activation or weight is zero.
*   **Action**: If a zero is detected, the MAC operation is gated (disabled). The switching activity in the multiplier is suppressed, saving dynamic power.

### Clock Gating
*   **Implementation**: Fine-grained clock gating is applied to registers and functional units.
*   **Trigger**: When a PE is idle or performing a skipped operation, its clock is disabled.

### Output Stationary Optimization
*   **Focus**: These optimizations are specifically tuned for the Output Stationary (OS) mode introduced in Part 3.
*   **Benefit**: In OS mode, partial sums stay local. Skipping updates to these local accumulators reduces the toggle rate of high-capacitance internal nets.
