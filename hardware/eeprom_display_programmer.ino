// #define A0 A0
// #define A1 A1
// #define A2 A2
// #define A3 A3
// #define A4 A4
// #define A5 A5
// #define A6 A6
// #define A7 A7
// #define A8 A8
// #define A9 A9
// #define A10 A10
// #define A11 A11
// #define A12 A12
// #define A13 A13
// #define A14 A14
// #define A15 A15

#define D0 30
#define D1 31
#define D2 32
#define D3 33
#define D4 34
#define D5 35
#define D6 36
#define D7 37

#define OE 8
#define CE 9


void set_address(int addr) {
  delayMicroseconds(2);
  digitalWrite(A0, (addr & 0b0000000000001) >> 0);
  digitalWrite(A1, (addr & 0b0000000000010) >> 1);
  digitalWrite(A2, (addr & 0b0000000000100) >> 2);
  digitalWrite(A3, (addr & 0b0000000001000) >> 3);
  digitalWrite(A4, (addr & 0b0000000010000) >> 4);
  digitalWrite(A5, (addr & 0b0000000100000) >> 5);
  digitalWrite(A6, (addr & 0b0000001000000) >> 6);
  digitalWrite(A7, (addr & 0b0000010000000) >> 7);
  digitalWrite(A8, (addr & 0b0000100000000) >> 8);
  digitalWrite(A9, (addr & 0b0001000000000) >> 9);
  digitalWrite(A10, (addr & 0b0010000000000) >> 10);
  digitalWrite(A11, (addr & 0b0100000000000) >> 11);
  digitalWrite(A12, (addr & 0b1000000000000) >> 12);
  delayMicroseconds(10);
}

void set_data_output(int dat) {
  delayMicroseconds(10);
  digitalWrite(D0, (dat & 0b0000000000001) >> 0);
  digitalWrite(D1, (dat & 0b0000000000010) >> 1);
  digitalWrite(D2, (dat & 0b0000000000100) >> 2);
  digitalWrite(D3, (dat & 0b0000000001000) >> 3);
  digitalWrite(D4, (dat & 0b0000000010000) >> 4);
  digitalWrite(D5, (dat & 0b0000000100000) >> 5);
  digitalWrite(D6, (dat & 0b0000001000000) >> 6);
  digitalWrite(D7, (dat & 0b0000010000000) >> 7);
  delayMicroseconds(10);
}

void writeEEPROM(uint16_t addr, uint8_t data) {
  set_address(addr);
  set_data_output(data);
  delayMicroseconds(2);

  digitalWrite(CE, 0);
  delayMicroseconds(30);
  digitalWrite(CE, 1);

  delayMicroseconds(10);
}

void setup() {
  // put your setup code here, to run once:
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

  pinMode(D0, OUTPUT);
  pinMode(D1, OUTPUT);
  pinMode(D2, OUTPUT);
  pinMode(D3, OUTPUT);
  pinMode(D4, OUTPUT);
  pinMode(D5, OUTPUT);
  pinMode(D6, OUTPUT);
  pinMode(D7, OUTPUT);

  digitalWrite(CE, 1);
  digitalWrite(OE, 1);

  pinMode(CE, OUTPUT);
  pinMode(OE, OUTPUT);


  Serial.begin(9600);

  delay(1000);

  // Bit patterns for the digits 0..f
  byte digits[] = { 0x7e, 0x30, 0x6d, 0x79, 0x33, 0x5b, 0x5f, 0x70,
                    0x7f, 0x7b, 0x77, 0x1f, 0x4e, 0x3d, 0x4f, 0x47, 0x01 };


  // decimal
  Serial.println("Programming ones place");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value, digits[value % 10]);
  }
  Serial.println("Programming tens place");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 256, digits[(value / 10) % 10]);
  }
  Serial.println("Programming hundreds place");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 512, digits[(value / 100) % 10]);
  }
  Serial.println("Programming sign");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 768, 0);
  }

  Serial.println("Programming ones place (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 1024, digits[abs(value) % 10]);
  }
  Serial.println("Programming tens place (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 1280, digits[abs(value / 10) % 10]);
  }
  Serial.println("Programming hundreds place (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 1536, digits[abs(value / 100) % 10]);
  }
  Serial.println("Programming sign (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 1792, value < 0 ? 0x01 : 0);
  }


  // binary
  Serial.println("Programming ones place");
  for (int value = 0; value <= 15; value++) {
    writeEEPROM(value + 2048, digits[value % 2]);
  }
  Serial.println("Programming twos place");
  for (int value = 0; value <= 15; value++) {
    writeEEPROM(value + 2304, digits[(value / 2) % 2]);
  }
  Serial.println("Programming fours place");
  for (int value = 0; value <= 15; value++) {
    writeEEPROM(value + 2560, digits[(value / 4) % 2]);
  }
  Serial.println("Programming eights place");
  for (int value = 0; value <= 15; value++) {
    writeEEPROM(value + 2816, digits[(value / 8) % 2]);
  }

  // Binary overflow (unsigned): show ----
  for (int value = 16; value <= 255; value++) {
    writeEEPROM(value + 2048, 0x01);
    writeEEPROM(value + 2304, 0x01);
    writeEEPROM(value + 2560, 0x01);
    writeEEPROM(value + 2816, 0x01);
  }


  Serial.println("Programming signed binary (two's complement)");

  for (int value = -128; value <= 127; value++) {
    byte v = (byte)value;

    writeEEPROM(v + 3072, digits[(v >> 0) & 1]);
    writeEEPROM(v + 3328, digits[(v >> 1) & 1]);
    writeEEPROM(v + 3584, digits[(v >> 2) & 1]);
    writeEEPROM(v + 3840, digits[(v >> 3) & 1]);
  }


  // Binary overflow (two's complement): show ----
  for (int value = -128; value <= 127; value++) {
    if (value < -8 || value > 7) {
      byte addr = (byte)value;
      writeEEPROM(addr + 3072, 0x01);
      writeEEPROM(addr + 3328, 0x01);
      writeEEPROM(addr + 3584, 0x01);
      writeEEPROM(addr + 3840, 0x01);
    }
  }


  // octal
  Serial.println("Programming 1s place");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 4096, digits[value % 8]);
  }
  Serial.println("Programming 8s place");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 4352, digits[(value / 8) % 8]);
  }
  Serial.println("Programming 64s place");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 4608, digits[(value / 64) % 8]);
  }
  Serial.println("Programming sign");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 4864, 0);
  }

  Serial.println("Programming 1s place (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 5120, digits[abs(value) % 8]);
  }
  Serial.println("Programming 8s place (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 5376, digits[abs(value / 8) % 8]);
  }
  Serial.println("Programming 64s place (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 5632, digits[abs(value / 64) % 8]);
  }
  Serial.println("Programming sign (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 5888, value < 0 ? 0x01 : 0);
  }


  // hex
  Serial.println("Programming 1s place");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 6144, digits[value % 16]);
  }
  Serial.println("Programming 16s place");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 6400, digits[(value / 16) % 16]);
  }
  Serial.println("Programming 256s place");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 6656, digits[(value / 256) % 16]);
  }
  Serial.println("Programming sign");
  for (int value = 0; value <= 255; value++) {
    writeEEPROM(value + 6912, 0);
  }

  Serial.println("Programming 1s place (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 7168, digits[abs(value) % 16]);   // FIXED
  }
  Serial.println("Programming 16s place (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 7424, digits[abs(value / 16) % 16]); // FIXED
  }
  Serial.println("Programming 256s place (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 7680, digits[abs(value / 256) % 16]);
  }
  Serial.println("Programming sign (twos complement)");
  for (int value = -128; value <= 127; value++) {
    writeEEPROM((byte)value + 7936, value < 0 ? 0x01 : 0);
  }
  Serial.println("DONE");

}

void loop() {
  // put your main code here, to run repeatedly:
}




