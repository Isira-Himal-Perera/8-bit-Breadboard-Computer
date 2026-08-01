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
