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
  delay(1);
  digitalWrite(A0, (addr & 0b0000000000000001) >> 0);
  digitalWrite(A1, (addr & 0b0000000000000010) >> 1);
  digitalWrite(A2, (addr & 0b0000000000000100) >> 2);
  digitalWrite(A3, (addr & 0b0000000000001000) >> 3);
  digitalWrite(A4, (addr & 0b0000000000010000) >> 4);
  digitalWrite(A5, (addr & 0b0000000000100000) >> 5);
  digitalWrite(A6, (addr & 0b0000000001000000) >> 6);
  digitalWrite(A7, (addr & 0b0000000010000000) >> 7);
  digitalWrite(A8, (addr & 0b0000000100000000) >> 8);
  digitalWrite(A9, (addr & 0b0000001000000000) >> 9);
  digitalWrite(A10, (addr & 0b0000010000000000) >> 10);
  digitalWrite(A11, (addr & 0b0000100000000000) >> 11);
  digitalWrite(A12, (addr & 0b0001000000000000) >> 12);
  digitalWrite(A13, (addr & 0b0010000000000000) >> 13);
  digitalWrite(A14, (addr & 0b0100000000000000) >> 14);
  digitalWrite(A15, (addr & 0b1000000000000000) >> 15);
  delay(1);
}


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

void printContents() {
  int on_15 = 1;
  for (int base = 0 + on_15*(1<<15); base < 512 + on_15*(1<<15); base += 16) {
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



void setup() {
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

  pinMode(D0, INPUT);
  pinMode(D1, INPUT);
  pinMode(D2, INPUT);
  pinMode(D3, INPUT);
  pinMode(D4, INPUT);
  pinMode(D5, INPUT);
  pinMode(D6, INPUT);
  pinMode(D7, INPUT);

  pinMode(CE, OUTPUT);
  pinMode(OE, OUTPUT);

  //read mode
  digitalWrite(CE, 0);
  digitalWrite(OE, 0);

  delay(1000);

  Serial.begin(9600);
  Serial.print('\n');
  printContents();
  Serial.println("DONE");


}

void loop() {
}
