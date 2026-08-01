`timescale 1ns / 1ps

module computer_tb;

    // Inputs to the UUT (Unit Under Test)
    logic       clock_in;
    logic       reset_n;
    logic       run;
    logic       write_n;
    logic       program_run;
    logic [3:0] manual_address;
    logic [7:0] manual_data;

    // Outputs from the UUT
    logic [7:0] output_data;
    
    // --- Internal Signal Monitor Wires ---
    wire  [7:0]  tb_bus;
    wire         tb_clock;
    wire  [15:0] tb_control_signals;
    wire  [2:0]  tb_upc; 
    wire  [3:0]  tb_opcode; // Opcode Probe Wires
    
    // Individual Control Signal Decodes for Easy Waveform Viewing
    wire tb_BI, tb_AI, tb_MI, tb_II, tb_OI, tb_FI, tb_C, tb_J;
    wire tb_CO, tb_SUB, tb_EO, tb_AO, tb_RI, tb_RO, tb_IO, tb_HLT;

    // Hierarchical references to peek inside the UUT
    assign tb_bus             = uut.bus;
    assign tb_clock           = uut.clock;
    assign tb_control_signals = uut.control_signals;
    assign tb_upc             = uut.upc; 
    assign tb_opcode          = uut.opcode; // Pulling current opcode out of computer module

    // Unpack control signals for easier tracking in the waveform
    assign {tb_BI, tb_AI, tb_MI, tb_II, tb_OI, tb_FI, tb_C, tb_J, 
            tb_CO, tb_SUB, tb_EO, tb_AO, tb_RI, tb_RO, tb_IO, tb_HLT} = tb_control_signals;
    
    // Instantiate the Unit Under Test (UUT)
    computer uut (
        .clock_in(clock_in),
        .reset_n(reset_n),
        .run(run),
        .write_n(write_n),
        .program_run(program_run),
        .manual_address(manual_address),
        .manual_data(manual_data),
        .output_data(output_data)
    );

    // Generate 50MHz clock system (20ns period)
    always begin
        #10 clock_in = ~clock_in;
    end

    // Task to program individual memory cells safely
    task automatic write_memory(
        input logic [3:0] addr,
        input logic [7:0] data
    );
        begin
            @(negedge clock_in);
            manual_address = addr;
            manual_data = data;
            write_n = 1'b0; // Pull active-low write enable down
            @(negedge clock_in);
            write_n = 1'b1; // Pull write back up
        end
    endtask 

    // Monitors for Console Logging
    always @(output_data) begin
        $display("[OUTPUT REGISTER CHANGED]: %d (Hex: 8'h%h)", output_data, output_data);
    end
    
    always @(tb_bus) begin
        $display("[BUS ACTIVITY at %t]: Hex: 8'h%h", $time, tb_bus);
    end

    // Log whenever control unit, UPC, or Opcode updates
    always @(tb_control_signals or tb_upc or tb_opcode) begin
        if (!program_run && run) begin
            $display("[CONTROL UNIT at %t]: Opcode = 4'b%b (Hex: 4'h%h) | uPC Step = %d | Signals = %b (HLT=%b, OUT_EN=%b, ALU_EN=%b)", 
                     $time, tb_opcode, tb_opcode, tb_upc, tb_control_signals, tb_HLT, tb_OI, tb_EO);
        end
    end

    initial begin
        // --- Step 1: Initialize signals ---
        clock_in = 0;
        reset_n = 0;
        run = 0;
        write_n = 1;
        program_run = 1'b1; // 1 to activate programming hardware path
        manual_address = 4'b0000;
        manual_data = 8'b0000_0000;

        // Hold system in reset state for a few clock cycles
        #40;
        reset_n = 1;
        #20;

        // --- Step 2: Flash program data into RAM via Manual Interface ---
        $display("[TB] Starting Manual Flash Programming...");
        
        // Instructions
        write_memory(4'h0, 8'b0001_1100); // LDA 12
        write_memory(4'h1, 8'b0010_1110); // ADD 14
        write_memory(4'h2, 8'b0100_1100); // STA 12
        write_memory(4'h3, 8'b0001_1111); // LDA 15
        write_memory(4'h4, 8'b0011_1101); // SUB 13
        write_memory(4'h5, 8'b0100_1111); // STA 15
        write_memory(4'h6, 8'b1000_1000); // JZ 8
        write_memory(4'h7, 8'b0110_0000); // JMP 0
        write_memory(4'h8, 8'b0001_1100); // LDA 12
        write_memory(4'h9, 8'b1110_0000); // OUT
        write_memory(4'hA, 8'b1111_0000); // HLT
        write_memory(4'hB, 8'b0000_0000); // NOP

        // Data Variables & Constants
        write_memory(4'hC, 8'b0000_0000); // Variable: Total (0)
        write_memory(4'hD, 8'b0000_0001); // Constant: 1
        write_memory(4'hE, 8'b0000_1111); // Variable: X (1)
        write_memory(4'hF, 8'b0000_1111); // Variable: Y (5)

        $display("[TB] Programming Complete.");
        @(negedge clock_in);
        
        // --- Step 3: Switch Modes to Execution ---
        program_run = 1'b0; // Pull low to connect internal CPU address buses
        run = 1'b1;         // Enable clock gating system
        $display("[TB] Execution started. Processing math loop...");

        // Run simulation until a safe termination buffer time
        #200; 
        $display("[TB] Simulation window complete. Final checking output value: %d", output_data);
        $finish;
    end

endmodule 