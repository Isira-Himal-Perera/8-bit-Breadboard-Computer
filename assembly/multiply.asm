; ==============================================================================
; Program: Multiplication via Repeated Addition (Result = X * Y)
; Description: Multiplies value at 0xE (X) by value at 0xF (Y) using a loop counter.
;
; RAM Allocation / Data Mapping:
;   0xC : Product Accumulator (starts at 0)
;   0xD : Constant Decrement Step (1)
;   0xE : Multiplicand X
;   0xF : Loop Counter Y (decrements down to 0)
; ==============================================================================

; Address | Opcode / Operand | Comment
; ------------------------------------------------------------------------------
  0x0     | LDA 0xC          ; Load current running total (0xC) into Accumulator
  0x1     | ADD 0xE          ; Add multiplicand X (0xE) to total
  0x2     | STA 0xC          ; Store updated running total back into RAM [0xC]
  0x3     | LDA 0xF          ; Load remaining counter Y (0xF) into Accumulator
  0x4     | SUB 0xD          ; Subtract 1 (from 0xD) to decrement counter
  0x5     | STA 0xF          ; Store updated counter back into RAM [0xF]
  0x6     | JZ  0x8          ; Jump to 0x8 if Zero flag set (Loop condition is False)
  0x7     | JMP 0x0          ; Otherwise, loop back to start next addition cycle
  0x8     | LDA 0xC          ; Load final product from RAM [0xC] into Accumulator
  0x9     | OUT              ; Display final product on 7-segment display
  0xA     | HLT              ; Halt execution

; --- Data Section (RAM Initialization) ---
  0xB     | 0x00             ; Unused
  0xC     | 0x00             ; [Product Accumulator] Initialized to 0
  0xD     | 0x01             ; [Constant] Value 1 used for decrementing counter
  0xE     | 0x05             ; [Multiplicand X] Example value (e.g., 5)
  0xF     | 0x03             ; [Multiplier Y]   Example loop count (e.g., 3)
