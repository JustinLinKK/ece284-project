# ECE284 Project: 2-D Systolic Array Accelerator

This repository contains the implementation and analysis of a 2-D systolic array accelerator for Deep Neural Networks. The project evolves from a baseline weight-stationary architecture to a reconfigurable, SIMD-supported design with advanced optimizations.

## Table of Contents
- [Introduction](#introduction-2-d-systolic-array)
- [Project Structure](#project-structure)
  - [Part 1: Vanilla Weight Stationary](#part-1-vanilla-weight-stationary-array)
  - [Part 2: SIMD Support](#part-2-simd-support)
  - [Part 3: Reconfigurable Array](#part-3-reconfigurable-array)
  - [Part 4: Poster](#part-4-poster)
  - [Part 5: Alpha Enhancements](#part-5-alpha-enhancements)
  - [Reports](#part-6--7-reports)
- [Getting Started](#getting-started)

## Introduction: 2-D Systolic Array

The core of this project is a 2-D systolic array architecture designed to accelerate matrix multiplications, the dominant operation in DNN inference. The array consists of a grid of Processing Elements (PEs) that pass data rhythmically (systolically) across the grid, maximizing data reuse and minimizing expensive memory accesses.

## Project Structure

### Part 1: Vanilla Weight Stationary Array
**Location:** `Part1_Vanilla/`

This section establishes the baseline architecture:
*   **Weight Stationary (WS) Dataflow**: Weights are pre-loaded into PEs and stay stationary while inputs flow through.
*   **Benchmark**: We trained a quantized VGG16 model on the CIFAR-10 dataset to serve as the workload.
*   **Implementation**: The hardware design implements a specific layer of the VGG16 model to validate the systolic array functionality.

### Part 2: SIMD Support
**Location:** `Part2_SIMD/`

This section enhances the array with SIMD (Single Instruction, Multiple Data) capabilities:
*   **Low Precision Support**: Enables the array to operate on 2-bit data (INT2) in addition to the baseline 4-bit (INT4).
*   **Throughput**: By packing two 2-bit operations into the datapath of a single 4-bit MAC, the effective throughput is doubled for lower precision workloads.

### Part 3: Reconfigurable Array
**Location:** `Part3_Reconfigurable/`

This section introduces flexibility to the dataflow:
*   **Output Stationary (OS) Mode**: Adds support for Output Stationary dataflow, where partial sums accumulate within the PEs.
*   **Reconfigurability**: The array can switch modes to adapt to different layer shapes or operational requirements, supporting both Weight Stationary and Output Stationary dataflows.

### Part 4: Poster
**Location:** `Part4_Poster/`

Contains the presentation poster summarizing the project architecture and results.

### Part 5: Alpha Enhancements
**Location:** `Part5_Alpha/`

This section explores advanced architectural features and optimizations ("Alpha" features):

1.  **Optimized Training for Quantized VGG** (`Alpha1_optimized_training_for_quantized_vgg`)
    *   **Objective**: Recover accuracy loss from aggressive quantization.
    *   **Method**: Replaces the traditional Stochastic Gradient Descent (SGD) with Momentum and manual learning rate scheduler with the **Adam optimizer** and a **cosine weight scheduler**.
    *   **Regularization**: Incorporates label smoothing to prevent model overfitting.

2.  **Coarse-to-Fine (C2F) Pruning** (`Alpha2_c2f_pruning_method`)
    *   **Objective**: Reduce model complexity and computation requirements.
    *   **Method**: Implements a mixed pruning strategy to maximize sparsity while maintaining original performance.
    *   **Integration**: Designed to be compatible with the 2-D array architecture in Alpha3.

3.  **Gating & Power Saving** (`Alpha3_output_stationary_skip_optimization`)
    *   **Objective**: Reduce dynamic power consumption.
    *   **Method**: Implements skip logic (e.g., zero-skipping) and clock gating during sparse operations, specifically optimized for Output Stationary mode.

4.  **Multi-Tiling Design** (`Alpha4_scalable_multi_cores_tiling`)
    *   **Objective**: Enable parallelism across larger workloads.
    *   **Method**: Scales the architecture to support multiple cores/tiles.

### Part 6 & 7: Reports
**Location:** `Part6_Report/` and `Part7_ProgressReport/`

Contains the final project report and progress updates.

## Getting Started

### Prerequisites
*   **Hardware Simulation**: Verilog simulator (e.g., ModelSim, VCS, or Icarus Verilog).
*   **Software Modeling**: Python 3.x, PyTorch (for training notebooks), and Jupyter Notebook.

### Running the Project
1.  **Hardware**: Navigate to the `hardware/sim` directory in the desired part (e.g., `Part1_Vanilla/hardware/sim`) and run the testbench.
2.  **Software**: Open the Jupyter notebooks in the `software/` directories to view the training and quantization flows.
