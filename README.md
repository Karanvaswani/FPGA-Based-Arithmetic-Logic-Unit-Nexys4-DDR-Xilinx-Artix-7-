# ALU-FPGA-Nexys4-VHDL

A 32-operation Arithmetic Logic Unit (ALU) designed in structural VHDL and deployed on the **Nexys4 DDR FPGA board (Xilinx Artix-7)**. Results are displayed in real-time on the board's 8-digit multiplexed 7-segment display.

---

## Operations

| Opcode | Operation | Unit |
|--------|-----------|------|
| 00000–00111 | Transfer, Add, Subtract, Increment, Decrement | Arithmetic |
| 01000–01111 | Clear, Toggle, Set, Concatenate | Set & Clear |
| 10000–10111 | NOT, AND, OR, NAND, NOR, XOR, XNOR | Logic |
| 11000–11111 | SLL, SRL, SLA, SRA, ROL, ROR | Shift & Rotate |

---

## Architecture

- 4 independent functional units: Arithmetic, Logic, Shift/Rotate, Set/Clear
- Central 4-to-1 output MUX driven by `Sel[4:3]`
- Clock-driven frequency dividers: 100 KHz display refresh + 10-second rotation
- 8-digit multiplexed 7-segment display with BCD decimal conversion

---

## Files

| File | Description |
|------|-------------|
| `PBL_062.vhd` | Top-level ALU entity (structural VHDL) |
| `testbench.vhd` | VHDL testbench — cycles all 32 opcodes |
| `constraints.ucf` | Pin constraint file (LVCMOS33, Nexys4 DDR) |

---

## Tools

- Xilinx ISE Design Suite
- Nexys4 DDR — Artix-7 XC7A100T
- VHDL (Structural Style)

---

## Verification

- Simulated via VHDL testbench cycling all 32 select inputs
- Synthesised and implemented in Xilinx ISE
- Verified with live hardware demonstration on physical Nexys4 DDR board
