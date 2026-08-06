# Glassbox 8-Bit Breadboard Computer & SystemVerilog Core

An 8-bit breadboard computer architecture built using discrete 74LS series logic gates, paired with a custom SystemVerilog behavioral model and cycle-accurate FPGA testbenches.

---

## 📸 System Overview

<p align="center">
  <img src="media/breadboard-computer-full-build.jpeg" alt="Hardware Build" width="600"/>
</p>

### 🎥 Video Demonstrations
* 🎬 [Watch Full Hardware Demonstrations on Google Drive](https://drive.google.com/drive/folders/1IrLNDTSDMo6EOYNiwFZ3eUsqzV11bv9V?usp=sharing)

---

## 🏗️ Architecture & Features

* **Bus Architecture:** 8-bit single bidirectional shared bus structure.
* **Control Unit:** EEPROM-based microcode decoder supporting multi-cycle instructions.
* **Registers:** Dedicated 8-bit registers ($A$, $B$, Instruction Register, Output Register).
* **Execution:** Hardware ALU capable of addition, subtraction, and status flag generation ($Z$, $C$).
* **Simulation & Hardware Verification:** Fully modeled in Logisim and SystemVerilog with Vivado timing waveforms.

---

## 📜 Instruction Set Architecture (ISA)

| Opcode (Bin) | Mnemonic | Description |
| :---: | :---: | :--- |
| `0000` | `NOP` | No Operation |
| `0001` | `LDA` | Load Memory into Register A |
| `0010` | `ADD` | Add Memory contents to Register A |
| `0011` | `SUB` | Subtract Memory contents from Register A |
| `0100` | `STA` | Store Register A to Memory |
| `0101` | `LDI` | Load Immediate value into Register A |
| `0110` | `JMP` | Unconditional Jump |
| `0111` | `JC`  | Jump if Carry Flag is set |
| `1000` | `JZ`  | Jump if Zero Flag is set |
| `1110` | `OUT` | Output Register A contents to Display |
| `1111` | `HLT` | Halt Clock Execution |

---

## 💻 Sample Programs

### Fibonacci Sequence Generator
Generates the Fibonacci sequence up to 8-bit rollover limits.

```assembly
; Fibonacci Sequence Generator
LDI 0x0    ; A = 0
STA 0xE    ; Store term 1 at RAM[14]
LDI 0x1    ; A = 1
STA 0xF    ; Store term 2 at RAM[15]
OUT        ; Display term
LDA 0xE    ; Load term 1
ADD 0xF    ; Add term 2
JC  0xD    ; Halt on overflow
STA 0xD    ; Temporary save
LDA 0xF    ; Shift term 2 -> term 1
STA 0xE
LDA 0xD    ; Shift sum -> term 2
STA 0xD
JMP 0x4    ; Repeat loop
HLT        ; Stop
