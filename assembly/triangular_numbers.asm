; ==============================================================================
; Program: Triangular Numbers Sequence Generator
; Description: Calculates and displays triangular numbers T_n = n*(n+1)/2.
;              Increments a counter at 0xE and accumulates the sum at 0xF.
;              Exits when addition produces an 8-bit overflow (Carry flag set).
;
; RAM Allocation / Data Mapping:
;   0xD : Step Increment Constant (1)
;   0xE : Step Counter n (1, 2, 3, 4...)
;   0xF : Running Sum / Total (1, 3, 6, 10...)
; ==============================================================================

; Address | Opcode / Operand | Comment
; ------------------------------------------------------------------------------
  0x0     | LDI 0x0          ; Load immediate 0 into Accumulator
  0x1     | STA 0xE          ; Clear step counter RAM [0xE]
  0x2     | STA 0xF          ; Clear running sum RAM [0xF]
  0x3     | LDA 0xE          ; Load current step counter [0xE] into Accumulator
  0x4     | ADD 0xD          ; Add 1 (from 0xD) to increment step counter
  0x5     | STA 0xE          ; Save updated counter (n) back into RAM [0xE]
  0x6     | LDA 0xF          ; Load current running sum [0xF] into Accumulator
  0x7     | ADD 0xE          ; Add step counter (n) to running sum
  0x8     | STA 0xF          ; Save updated triangular total back into RAM [0xF]
  0x9     | JC  0xC          ; Jump to Halt (0xC) if overflow occurs (>255)
  0xA     | OUT              ; Display triangular number on 7-segment display
  0xB     | JMP 0x3          ; Loop back to step 0x3 for next triangular number
  0xC     | HLT              ; Halt execution (overflow exit point)

; --- Data Section (RAM Initialization) ---
  0xD     | 0x01             ; [Constant] Step increment value (1)
  0xE     | 0x00             ; [Counter n] Initialized to 0
  0xF     | 0x00             ; [Total T_n] Initialized to 0
