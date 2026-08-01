`timescale 1ns / 1ps

module memory_system_tb;

    // Parameters
    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 4;
    parameter int CLK_PERIOD = 10; // 100 MHz clock

    // Testbench Signals
    logic                  clock;
    logic                  reset_n;
    logic                  program_we_n;
    logic                  control_we_n;
    logic                  oe_n;
    logic                  address_in_n;
    logic                  program_run;
    logic [ADDR_WIDTH-1:0] address_from_bus;
    logic [ADDR_WIDTH-1:0] program_address;
    logic [DATA_WIDTH-1:0] program_data;
    
    // Bi-directional bus handling
    wire  [DATA_WIDTH-1:0] bus_data;
    logic [DATA_WIDTH-1:0] tb_bus_drive;
    logic                  tb_drive_en;

    // Model the tri-state driving from the testbench side
    assign bus_data = tb_drive_en ? tb_bus_drive : 'z;

    // Instantiate the Unit Under Test (UUT)
    memory_system #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clock(clock),
        .reset_n(reset_n),
        .program_we_n(program_we_n),
        .control_we_n(control_we_n),
        .oe_n(oe_n),
        .address_in_n(address_in_n),
        .program_run(program_run),
        .program_address(program_address),
        .program_data(program_data),
        .bus_data(bus_data)
    );

    // Clock Generation
    always #(CLK_PERIOD/2.0) clock = ~clock;

    // Stimulus Block
    initial begin
        // --- 1. Initialize Signals ---
        clock = 0;
        reset_n = 0;
        program_we_n = 1;     // Active low, disabled
        control_we_n = 1;     // Active low, disabled
        oe_n = 1;             // Active low, disabled
        address_in_n = 1;     // Active low, disabled
        program_run = 0;
        address_from_bus = 0;
        program_address = 0;
        program_data = 0;
        tb_bus_drive = 0;
        tb_drive_en = 0;

        // Hold reset for 2 clock cycles
        #(CLK_PERIOD*2);
        reset_n = 1;
        #(CLK_PERIOD);

        $display("=== Starting Memory System Tests ===");

        // --- 2. Programming Mode Execution ---
        // Write data 0xAA to address 0x4 and 0xBB to address 0x5 directly
        $display("[Mode: Program] Writing initialization data to RAM...");
        program_run = 1; 
        
        // Write to Addr 4
        program_address = 4'h4;
        program_data = 8'hAA;
        program_we_n = 0; // Trigger write
        #(CLK_PERIOD);
        
        // Write to Addr 5
        program_address = 4'h5;
        program_data = 8'hBB;
        program_we_n = 0;
        #(CLK_PERIOD);
        
        // Disable programming writes
        program_we_n = 1;
        program_run = 0;
        #(CLK_PERIOD);

        // --- 3. System Run Mode: Load MAR (Memory Address Register) ---
        // We will load address 0x4 into the MAR from the bus address lines
        $display("[Mode: Run] Loading address 0x4 into MAR...");
        address_from_bus = 4'h4;
        address_in_n = 0; // Enable MAR write
        #(CLK_PERIOD);
        address_in_n = 1; // Latch and disable
        #(CLK_PERIOD);

        // --- 4. System Run Mode: Read Content from RAM ---
        // Read out the data from the address currently held in the MAR (0x4)
        $display("[Mode: Run] Reading from RAM address held in MAR (Expected: 0xAA)...");
        oe_n = 0; // Enable tri-state buffer to drive the bus
        #(CLK_PERIOD);
        $display("Bus Data Readout: 0x%h", bus_data);
        oe_n = 1; // Release the bus
        #(CLK_PERIOD);

        // --- 5. System Run Mode: Write to RAM via Bus ---
        // Change MAR to point to address 0x5, then overwrite it using the bus
        $display("[Mode: Run] Loading address 0x5 into MAR...");
        address_from_bus = 4'h5;
        address_in_n = 0;
        #(CLK_PERIOD);
        address_in_n = 1;
        #(CLK_PERIOD);

        $display("[Mode: Run] Overwriting address 0x5 with 0xCC via Bus...");
        tb_bus_drive = 8'hCC; // Testbench prepares data
        tb_drive_en = 1;      // Testbench captures the bus
        control_we_n = 0;     // Pulse write enable to RAM
        #(CLK_PERIOD);
        control_we_n = 1;     // Turn off RAM write
        tb_drive_en = 0;      // Release the bus from testbench side
        #(CLK_PERIOD);

        // --- 6. Verify Overwritten Data ---
        $display("[Mode: Run] Verifying new data at address 0x5 (Expected: 0xCC)...");
        oe_n = 0; // System drives the bus
        #(CLK_PERIOD);
        $display("Bus Data Readout: 0x%h", bus_data);
        oe_n = 1;
        #(CLK_PERIOD);

        $display("=== Memory System Tests Complete ===");
        $finish;
    end

endmodule