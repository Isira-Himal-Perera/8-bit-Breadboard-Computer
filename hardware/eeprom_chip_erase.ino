// ============================================================================
// EEPROM Chip Erase Utility
// Description: Pulses control and data pins to execute a chip erase cycle on 
//              parallel EEPROMs (e.g., 27SF512 / W27C512).
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
// Execute Chip Erase Sequence
// ----------------------------------------------------------------------------
void chipErease() {
  // Set data lines to HIGH (0xFF)
  for (int pin = D0; pin <= D7; pin++) {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, HIGH);
  }

  // Set address lines (A0 - A15) to LOW (0x0000)
  for (int pin = A0; pin <= A15; pin++) {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, LOW);
  }

  digitalWrite(CE, HIGH);
  Serial.println("\nStart Erase...");
  delay(1000);

  // Pulse CE LOW to initiate erase cycle
  digitalWrite(CE, LOW);
  delay(100);
  digitalWrite(CE, HIGH);
  delay(1000);

  // Reset data lines back to input mode
  for (int pin = D0; pin <= D7; pin++) {
    pinMode(pin, INPUT);
  }
}

// ----------------------------------------------------------------------------
// Arduino Setup Block
// ----------------------------------------------------------------------------
void setup() {
  Serial.begin(9600);

  digitalWrite(CE, HIGH);
  pinMode(CE, OUTPUT);

  chipErease();
  Serial.println("DONE");
}

// ----------------------------------------------------------------------------
// Arduino Main Loop
// ----------------------------------------------------------------------------
void loop() {
  // Execution complete
}
