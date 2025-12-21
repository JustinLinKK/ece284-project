# Part 1: Vanilla Weight Stationary Array

## Overview
This part implements the baseline 2-D systolic array architecture using a Weight Stationary (WS) dataflow. In this configuration, weights are pre-loaded into the Processing Elements (PEs) and remain stationary while input activations flow horizontally across the array and partial sums accumulate vertically.

## Hardware Architecture

### Core Components
*   **MAC Tile (`mac_tile.v`)**: The fundamental building block containing a Multiply-Accumulate (MAC) unit.
    *   **Inputs**: Activation (`in_w`), Partial Sum (`in_n`), Instructions (`inst_w`).
    *   **Outputs**: Activation (`out_e`), Partial Sum (`out_s`), Instructions (`inst_e`).
    *   **Operation**: 
        1.  **Loading**: Weights are loaded into the tile when `inst_w[0]` is high.
        2.  **Execution**: When `inst_w[1]` is high, the tile performs `psum = activation * weight + psum_in`.
        3.  **Dataflow**: Activations are passed to the east (`out_e`), and partial sums are passed to the south (`out_s`).
*   **MAC Array (`mac_array.v`)**: A grid of MAC tiles (e.g., 8x8) connected in a systolic manner.
*   **L0 Buffer (`l0.v`)**: Input buffer for activations.
*   **Output FIFO (`ofifo.v`)**: Buffer for storing final results.
*   **Core (`core.v`)**: The top-level module integrating the array, buffers, and control logic.

### Dataflow: Weight Stationary
1.  **Weight Loading**: Weights are streamed into the array and stored in local registers within each MAC tile.
2.  **Execution**: Input activations stream horizontally from the L0 buffer. Each PE multiplies the incoming activation with its stored weight and adds the result to the partial sum arriving from the north.
3.  **Output**: The result flows south to the next PE or to the Output FIFO.

## Software & Benchmark
*   **Workload**: A specific layer of the VGG16 model.
*   **Dataset**: CIFAR-10.
*   **Quantization**: 4-bit integer (INT4) weights and activations.
*   **Training**: The model is trained using quantization-aware training (QAT) to minimize accuracy loss.
