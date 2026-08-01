// ============================================================================
// EEPROM Reader & Address Tester
// Description: Utility to read and cycle addresses on EEPROMs (e.g., AT28C16 / 27SF512).
// ============================================================================

// Pin Definitions - Data Lines
#define D0 30
#define D1 31
#define D2 32
#define D3 33
#define D4 34
#define D5 35
#define D6 36
#define D7 37

// Control Lines
#define OE 8
#define CE 9

// ----------------------------------------------------------------------------
// Set Address Lines (A0 - A12)
// ----------------------------------------------------------------------------
void set_address(int addr) {
  delayMicroseconds(1);
  digitalWrite(A0,  (addr & 0b0000000000001) >> 0);
  digitalWrite(A1,  (addr & 0b0000000000010) >> 1);
  digitalWrite(A2,  (addr & 0b0000000000100) >> 2);
  digitalWrite(A3,  (addr & 0b0000000001000) >> 3);
  digitalWrite(A4,  (addr & 0b0000000010000) >> 4);
  digitalWrite(A5,  (addr & 0b0000000100000) >> 5);
  digitalWrite(A6,  (addr & 0b0000001000000) >> 6);
  digitalWrite(A7,  (addr & 0b0000010000000) >> 7);
  digitalWrite(A8,  (addr & 0b0000100000000) >> 8);
  digitalWrite(A9,  (addr & 0b0001000000000) >> 9);
  digitalWrite(A10, (addr & 0b0010000000000) >> 10);
  digitalWrite(A11, (addr & 0b0100000000000) >> 11);
  digitalWrite(A12, (addr & 0b1000000000000) >> 12);
  delayMicroseconds(1);
}

// ----------------------------------------------------------------------------
// Read Single Byte from EEPROM Location
// ----------------------------------------------------------------------------
byte readEEPROM(int address) {
  for (int pin = D0; pin <= D7; pin += 1) {
    pinMode(pin, INPUT);
  }
  
  set_address(address);

  byte data = 0;
  for (int pin = D7; pin >= D0; pin -= 1) {
    data = (data << 1) + digitalRead(pin);
  }
  
  return data;
}

// ----------------------------------------------------------------------------
// Format and Print EEPROM Contents via Serial (Hex Dump)
// ----------------------------------------------------------------------------
void printContents() {
  for (int base = 0; base <= 256; base += 16) {
    byte data[16];
    for (int offset = 0; offset <= 15; offset += 1) {
      data[offset] = readEEPROM(base + offset);
    }

    char buf[80];
    sprintf(buf, "%03x:  %02x %02x %02x %02x %02x %02x %02x %02x   %02x %02x %02x %02x %02x %02x %02x %02x",
            base, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7],
            data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);

    Serial.println(buf);
  }
}

// ----------------------------------------------------------------------------
// Arduino Setup Block
// ----------------------------------------------------------------------------
void setup() {
  // Configure Address Pins
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

  // Configure Data Pins
  pinMode(D0, INPUT);
  pinMode(D1, INPUT);
  pinMode(D2, INPUT);
  pinMode(D3, INPUT);
  pinMode(D4, INPUT);
  pinMode(D5, INPUT);
  pinMode(D6, INPUT);
  pinMode(D7, INPUT);

  // Configure Control Pins (Active-Low Read Mode)
  pinMode(CE, OUTPUT);
  pinMode(OE, OUTPUT);
  digitalWrite(CE, LOW);
  digitalWrite(OE, LOW);

  delay(1000);
  Serial.begin(9600);

  // Address Cycling Loop Test
  int val = 4096;
  for (int i = val; i < val + 256; i++) {
    unsigned long tt = millis();
    while (millis() - tt < 1000) {
      set_address(i);
      delay(5);
      set_address(i + 256);
      delay(5);
      set_address(i + 512);
      delay(5);
      set_address(i + 768);
      delay(5);
    }
  }
}

// ----------------------------------------------------------------------------
// Arduino Main Loop
// ----------------------------------------------------------------------------
void loop() {
  // Idle after setup
}
