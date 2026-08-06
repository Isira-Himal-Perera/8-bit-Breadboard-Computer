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
; ==============================================================================
; Program: Fibonacci Sequence Generator
; Description: Generates and displays Fibonacci numbers sequentially.
;              Uses memory locations 0xE and 0xF to store alternating terms.
;              Exits when addition produces an 8-bit overflow (Carry flag set).
;
; RAM Allocation / Data Mapping:
;   0xE : First term (initialized to 0)
;   0xF : Second term (initialized to 1)
; ==============================================================================

; Address | Opcode / Operand | Comment
; ------------------------------------------------------------------------------
  0x0     | LDA 0xE          ; Load term A [0xE] into Accumulator
  0x1     | ADD 0xF          ; Add term B [0xF] to compute next term
  0x2     | STA 0xE          ; Save new term back into RAM [0xE]
  0x3     | JC  0xB          ; Jump to Halt (0xC) if overflow occurs (>255)
  0x4     | OUT              ; Display current Fibonacci term on 7-segment display
  0x5     | LDA 0xF          ; Load term B [0xF] into Accumulator
  0x6     | ADD 0xE          ; Add updated term A [0xE] to compute next term
  0x7     | STA 0xF          ; Save new term back into RAM [0xF]
  0x8     | JC  0xB          ; Jump to Halt (0xC) if overflow occurs (>255)
  0x9     | OUT              ; Display current Fibonacci term on 7-segment display
  0xA     | JMP 0x0          ; Loop back to step 0 to continue sequence
  0xB     | HLT              ; Halt execution (overflow exit point)

; --- Data Section (RAM Initialization) ---
  0xC     | 0x00             ; Unused 
  0xD     | 0x00             ; Unused 
  0xE     | 0x00             ; [Term A] Initialized to 0
  0xF     | 0x01             ; [Term B] Initialized to 1
