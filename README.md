# AMBA AHB-Lite Verilog Design

This repository contains a Verilog implementation of the **AMBA AHB-Lite (Advanced High-performance Bus Lite)** protocol, a simplified subset of the AMBA AHB protocol used in ARM-based SoCs. It is suitable for learning, simulation, and integration into custom SoC designs.

---

## 📦 Repository Structure

AHB Master: Initiates read/write transactions and manages burst transfers.

Decoder: Selects slaves based on address decoding.

Slaves: Memory-backed modules handling data storage and response generation.

Multiplexor: Routes read data and responses from slaves to the master.

---

## 📖 Protocol Overview

**AMBA AHB-Lite** is a high-performance, pipelined bus protocol designed for efficient communication between a single master and multiple slaves. Key features:
- Single master, multiple slave architecture
- 32 data buses
- Burst and single transfers
- Address and data phases are pipelined
- Ready/valid handshaking via `HREADY` and `HRESP`

## 📖 Features
-Burst Transfers: Supports INCR4, WRAP4, INCR8, and other burst types.

-Configurable Slaves: Four slaves with 32-bit memory arrays.

-Error Handling: Slaves generate OKAY/ERROR responses.

-Parameterized Design: Configurable data/address widths 

