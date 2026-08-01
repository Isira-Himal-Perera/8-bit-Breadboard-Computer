# 🛠️ Hardware Schematics & EEPROM Utilities

This directory contains hardware configuration details, digital circuit schematics, and Arduino Mega programming utilities for the **Glassbox 8-Bit Breadboard Computer**.

---

## 📟 EEPROM Chip Specification

The control unit and output display decoder use **Winbond W27C512-45Z** electrically erasable Programmable Read-Only Memory (EEPROM) ICs:
* **Capacity:** 512 Kb (64K $\times$ 8-bit)
* **Access Time:** 45 ns
* **Package:** 28-pin DIP / PLCC
* **Programmer Interface:** Custom Arduino Mega 2560 pin breakout ($A_0 - A_{15}$ address bus, $D_0 - D_7$ data bus, active-low $\overline{\text{CE}}$ and $\overline{\text{OE}}$ control lines)

---

## 📂 EEPROM Arduino Mega Utilities (`.ino`)

All sketches are designed to run on an **Arduino Mega 2560** connected directly to the W27C512 address and data lines:

* **`eeprom_control_unit_burner.ino`**  
  Generates the 16-bit microcode control word matrix (opcodes, flags, and micro-steps) and programs active-low control signals into dual W27C512 EEPROMs (low-byte and high-byte split across address space).

* **`eeprom_display_programmer.ino`**  
  Programs lookup tables into the output module EEPROM for rendering 8-bit numbers on 7-segment displays across multiple representation modes:
  * Unsigned Decimal ($0$ to $255$)
  * Signed Two's Complement ($-128$ to $+127$)
  * Unsigned / Signed Binary
  * Unsigned / Signed Octal
  * Unsigned / Signed Hexadecimal

* **`eeprom_microcode_reader.ino`**  
  Reads back and dumps the full 16-bit address space ($A_0 - A_{15}$) of the W27C512 via Serial monitor in hex format to verify burned microcode integrity.

* **`eeprom_address_tester.ino`**  
  Cycles address lines and toggles control signals to debug physical breadboard jumper wiring and timing delays.

* **`eeprom_chip_erase.ino`**  
  Executes the electrical chip erase sequence on the Winbond W27C512 to clear memory contents back to `0xFF`.
