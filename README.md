# Matrix-Vector Multiplier Engine

This repository contains an RTL implemention of a matrix-vector multiplier (MVM) engine, similar to those used in FPGA-based deep-learning accelerators such as Microsoft's Project BrainWave.

## Learning Goals

This project focuses on learning RTL design, pipelining, memory management, control logic, and module integration. It has been optimized for high-throughput and is synthesizable on an FPGA target.

## Design Details

The design implements a memory-mapped matrix layout to compute matrix-vector multiplications in parallel, using memory units to store input operands, a fully-pipelined 8-lane dot product unit to support high-throughput computations, and an accumulator unit with control signals to enable data accumulation over multiple cycles.

Within each vector and matrix memory block, each address holds an 8-bit word. Matrix rows are distributed across each output lane in a round-robin fashion to allow calculations to be conducted in parallel. Output data is given in 8 \* VEC_NUM_WORDS \* NUM_OLANES bit chunks.

The SystemVerilog design for the MVM is designed for scalability and can be configured for a different number of output lanes, data widths, and memory sizes depending on tradeoffs for desired throughput, area, and power constraints.

The control signals within the design are managed by a central FSM, which manages loading the vector and matrix memories, read addresses, valid signals, and accumulation signals.

Below is a schematic of the top-level design of the MVM module:

![](assets/20250729_161033_MVM_schematic.jpg)

Credit: Andrew Boutros, Maran Ma
