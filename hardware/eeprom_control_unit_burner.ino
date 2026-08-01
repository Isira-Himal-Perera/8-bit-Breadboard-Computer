// ============================================================================
// Microcode Generator & EEPROM Programmer
// Description: Generates and programs control unit microcode tables for the 
//              Glassbox 8-Bit Breadboard Computer into dual EEPROMs.
// ============================================================================

#include <Arduino.h>

// Pin Definitions - Data Lines
#define D0 30
#define D1 31
#define D2 32
#define D3 33
#define D4 34
#define D5 35
#define D6 36
#define D7 37

// Pin Definitions - EEPROM Control Signals
#define OE 8
#define CE 9

// ----------------------------------------------------------------------------
// Control Word Bitmasks (Active High Definitions)
// ----------------------------------------------------------------------------
#define BI  0b1000000000000000  // B Register In
#define AI  0b0100000000000000  // A Register In
#define MI  0b0010000000000000  // Memory Address Register In
#define II  0b0001000000000000  // Instruction Register In
#define OI  0b0000100000000000  // Output Register In
#define FI  0b0000010000000000  // Flags Register In
#define C   0b0000001000000000  // Program Counter Enable
#define J   0b0000001100000000  // Jump (Load Program Counter)

#define CO  0b0000000010000000  // Program Counter Out
#define AD  0b0000000001000000  // ALU Add Mode
#define EO  0b0000000000100000  // ALU Output Enable
#define AO  0b0000000000010000  // A Register Out
#define RI  0b0000000000001000  // RAM Data In
#define RO  0b0000000000000100  // RAM Data Out
#define IO  0b0000000000000010  // Instruction Register Out
#define HLT 0b0000000000000001  // Halt Clock Signal

// Flag Index Mappings
#define FLAGS_Z0C0 0
#define FLAGS_Z1C0 1
#define FLAGS_Z0C1 2
#define FLAGS_Z1C1 3

// Opcode Mnemonics
#define JC 0b0111
#define JZ 0b1000

// ----------------------------------------------------------------------------
// Microcode Instruction Step Template [Opcode][Step 0..7]
// ----------------------------------------------------------------------------
uint16_t UCODE_TEMPLATE[16][8] = {
  { MI|CO, RO|II|C, 0,        0,        0,            0, 0, 0 },  // 0000 - NOP
  { MI|CO, RO|II|C, IO|MI,    RO|AI,    0,            0, 0, 0 },  // 0001 - LDA
  { MI|CO, RO|II|C, IO|MI,    RO|BI,    EO|AI|AD|FI,  0, 0, 0 },  // 0010 - ADD
  { MI|CO, RO|II|C, IO|MI,    RO|BI,    EO|AI|FI,     0, 0, 0 },  // 0011 - SUB
  { MI|CO, RO|II|C, IO|MI,    AO|RI,    0,            0, 0, 0 },  // 0100 - STA
  { MI|CO, RO|II|C, IO|AI,    0,        0,            0, 0, 0 },  // 0101 - LDI
  { MI|CO, RO|II|C, IO|J,     0,        0,            0, 0, 0 },  // 0110 - JMP
  { MI|CO, RO|II|C, 0,        0,        0,            0, 0, 0 },  // 0111 - JC
  { MI|CO, RO|II|C, 0,        0,        0,            0, 0, 0 },  // 1000 - JZ
  { MI|CO, RO|II|C, 0,        0,        0,            0, 0, 0 },  // 1001
  { MI|CO, RO|II|C, 0,        0,        0,            0, 0, 0 },  // 1010
  { MI|CO, RO|II|C, 0,        0,        0,            0, 0, 0 },  // 1011
  { MI|CO, RO|II|C, 0,        0,        0,            0, 0, 0 },  // 1100
  { MI|CO, RO|II|C, 0,        0,        0,            0, 0, 0 },  // 1101
  { MI|CO, RO|II|C, AO|OI,    0,        0,            0, 0, 0 },  // 1110 - OUT
  { MI|CO, RO|II|C, HLT,      0,        0,            0, 0, 0 },  // 1111 - HLT
};

uint16_t ucode[4][16][8];

// ----------------------------------------------------------------------------
// Initialize Flag-Dependent Microcode Matrices
// ----------------------------------------------------------------------------
void initUCode() {
  // ZF = 0, CF = 0
  memcpy(ucode[FLAGS_Z0C0], UCODE_TEMPLATE, sizeof(UCODE_TEMPLATE));

  // ZF = 1, CF = 0
  memcpy(ucode[FLAGS_Z1C0], UCODE_TEMPLATE, sizeof(UCODE_TEMPLATE));
  ucode[FLAGS_Z1C0][JZ][2] = IO | J;

  // ZF = 0, CF = 1
  memcpy(ucode[FLAGS_Z0C1], UCODE_TEMPLATE, sizeof(UCODE_TEMPLATE));
  ucode[FLAGS_Z0C1][JC][2] = IO | J;

  // ZF = 1, CF = 1
  memcpy(ucode[FLAGS_Z1C1], UCODE_TEMPLATE, sizeof(UCODE_TEMPLATE));
  ucode[FLAGS_Z1C1][JC][2] = IO | J;
  ucode[FLAGS_Z1C1][JZ][2] = IO | J;
}

// ----------------------------------------------------------------------------
// Set Address Lines (A0 - A15)
// ----------------------------------------------------------------------------
void set_address(int addr) {
  delayMicroseconds(2);
  digitalWrite(A0,  (addr & 0b0000000000000001) >> 0);
  digitalWrite(A1,  (addr & 0b0000000000000010) >> 1);
  digitalWrite(A2,  (addr & 0b0000000000000100) >> 2);
  digitalWrite(A3,  (addr & 0b0000000000001000) >> 3);
  digitalWrite(A4,  (addr & 0b0000000000010000) >> 4);
  digitalWrite(A5,  (addr & 0b0000000000100000) >> 5);
  digitalWrite(A6,  (addr & 0b0000000001000000) >> 6);
  digitalWrite(A7,  (addr & 0b0000000010000000) >> 7);
  digitalWrite(A8,  (addr & 0b0000000100000000) >> 8);
  digitalWrite(A9,  (addr & 0b0000001000000000) >> 9);
  digitalWrite(A10, (addr & 0b0000010000000000) >> 10);
  digitalWrite(A11, (addr & 0b0000100000000000) >> 11);
  digitalWrite(A12, (addr & 0b0001000000000000) >> 12);
  digitalWrite(A13, (addr & 0b0010000000000000) >> 13);
  digitalWrite(A14, (addr & 0b0100000000000000) >> 14);
  digitalWrite(A15, (addr & 0b1000000000000000) >> 15);
  delayMicroseconds(10);
}

// ----------------------------------------------------------------------------
// Output Data Line Driver (D0 - D7)
// ----------------------------------------------------------------------------
void set_data_output(int data) {
  digitalWrite(D0, (data & 0x01));
  digitalWrite(D1, (data & 0x02) >> 1);
  digitalWrite(D2, (data & 0x04) >> 2);
  digitalWrite(D3, (data & 0x08) >> 3);
  digitalWrite(D4, (data & 0x10) >> 4);
  digitalWrite(D5, (data & 0x20) >> 5);
  digitalWrite(D6, (data & 0x40) >> 6);
  digitalWrite(D7, (data & 0x80) >> 7);
  delayMicroseconds(10);
}

// ----------------------------------------------------------------------------
// Write Byte to Active EEPROM Target
// ----------------------------------------------------------------------------
void writeEEPROM(uint16_t addr, uint8_t data) {
  set_address(addr);
  set_data_output(data);
  delayMicroseconds(2);

  digitalWrite(CE, LOW);
  delayMicroseconds(30);
  digitalWrite(CE, HIGH);

  delayMicroseconds(10);
}

// ----------------------------------------------------------------------------
// Arduino Setup Block
// ----------------------------------------------------------------------------
void setup() {
  // Address Pin Initialization
  pinMode(A0, OUTPUT);
  pinMode(A1, OUTPUT);
  pinMode(A2, OUTPUT);
  pinMode(A3, OUTPUT);
  pinMode(A4, OUTPUT);
  pinMode(A5, OUTPUT);
  pinMode(A6, OUTPUT);
  pinMode(A7, OUTPUT);
  pinMode(A8, OUTPUT);
  pinMode(A9, OUTPUT);
  pinMode(A10, OUTPUT);
  pinMode(A11, OUTPUT);
  pinMode(A12, OUTPUT);
  pinMode(A13, OUTPUT);
  pinMode(A14, OUTPUT);
  pinMode(A15, OUTPUT);

  // Data Pin Initialization
  pinMode(D0, OUTPUT);
  pinMode(D1, OUTPUT);
  pinMode(D2, OUTPUT);
  pinMode(D3, OUTPUT);
  pinMode(D4, OUTPUT);
  pinMode(D5, OUTPUT);
  pinMode(D6, OUTPUT);
  pinMode(D7, OUTPUT);

  // Control Pin Setup
  digitalWrite(CE, HIGH);
  digitalWrite(OE, HIGH);
  pinMode(CE, OUTPUT);
  pinMode(OE, OUTPUT);

  Serial.begin(9600);
  delay(1000);

  // Build Microcode Lookup Table
  initUCode();

  // Program LOW-byte EEPROM (Active Low Inverted Words)
  for (int address = 0; address < 512; address++) {
    int flags       = (address & 0b0110000000) >> 7;
    int instruction = (address & 0b0001111000) >> 3;
    int step        = (address & 0b0000000111);

    uint16_t data = ucode[flags][instruction][step];
    writeEEPROM(address, ~(uint8_t)(data & 0xFF));
  }

  // Program HIGH-byte EEPROM (Offset to A15)
  for (int address = 0; address < 512; address++) {
    int flags       = (address & 0b0110000000) >> 7;
    int instruction = (address & 0b0001111000) >> 3;
    int step        = (address & 0b0000000111);

    uint16_t data = ucode[flags][instruction][step];
    writeEEPROM(address + (1 << 15), ~(uint8_t)(data >> 8));
  }

  Serial.print("DONE\n");
}

// ----------------------------------------------------------------------------
// Arduino Main Loop
// ----------------------------------------------------------------------------
void loop() {
  // Execution complete
}
