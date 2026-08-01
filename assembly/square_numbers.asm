; ==============================================================================
; Program: Square Numbers Sequence Generator
; Description: Calculates and displays perfect squares (1, 4, 9, 16, 25...).
;              Uses the odd-number summation property (N^2 = sum of first N odd numbers)
;              by adding (2 * E + 1) to the running square total at 0xF.
;              Exits when addition produces an 8-bit overflow (Carry flag set).
;
; RAM Allocation / Data Mapping:
;   0xD : Step Increment Constant (1)
;   0xE : Root Counter / Odd Step Tracker (initialized to 1)
;   0xF : Running Square Total (initialized to 0)
; ==============================================================================

; Address | Opcode / Operand | Comment
; ------------------------------------------------------------------------------
  0x0     | LDA 0xF          ; Load current square total [0xF] into Accumulator
  0x1     | ADD 0xE          ; Add current term E
  0x2     | ADD 0xE          ; Add term E again (computes total + 2*E)
  0x3     | ADD 0xD          ; Add 1 (computes total + 2*E + 1)
  0x4     | JC  0xB          ; Jump to Halt (0xB) if overflow occurs (>255)
  0x5     | OUT              ; Display next square number on 7-segment display
  0x6     | STA 0xF          ; Save new square total back into RAM [0xF]
  0x7     | LDA 0xE          ; Load root counter E into Accumulator
  0x8     | ADD 0xD          ; Increment root counter by 1
  0x9     | STA 0xE          ; Save updated root counter back into RAM [0xE]
  0xA     | JMP 0x0          ; Loop back to calculate next square number
  0xB     | HLT              ; Halt execution (overflow exit point)

; --- Data Section (RAM Initialization) ---
  0xC     | 0x00             ; Unused 
  0xD     | 0x01             ; [Constant] Step increment value (1)
  0xE     | 0x01             ; [Root Counter] Initialized to 1
  0xF     | 0x00             ; [Square Total] Initialized to 0
