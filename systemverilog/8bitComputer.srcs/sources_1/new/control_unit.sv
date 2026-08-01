`timescale 1ns / 1ps

module control_unit (
    input  logic [3:0]  opcode,           // 4-bit Instruction Opcode
    input  logic [2:0]  upc,              // 3-bit Microprogram Counter (step)
    input  logic [1:0]  flag,             // 2-bit Flags [ZF, CF]
    
    output logic [15:0] control_signals   // 16-bit ACTIVE-LOW Control Signals
);

    // --- Control Signal Bit Definitions (Internal Masks) ---
    localparam logic [15:0] BI  = 16'b1000_0000_0000_0000;
    localparam logic [15:0] AI  = 16'b0100_0000_0000_0000;
    localparam logic [15:0] MI  = 16'b0010_0000_0000_0000;
    localparam logic [15:0] II  = 16'b0001_0000_0000_0000;
    
    localparam logic [15:0] OI  = 16'b0000_1000_0000_0000;
    localparam logic [15:0] FI  = 16'b0000_0100_0000_0000;
    localparam logic [15:0] C   = 16'b0000_0010_0000_0000;
    localparam logic [15:0] J   = 16'b0000_0011_0000_0000; 
    
    localparam logic [15:0] CO  = 16'b0000_0000_1000_0000;
    localparam logic [15:0] SUB = 16'b0000_0000_0100_0000;
    localparam logic [15:0] EO  = 16'b0000_0000_0010_0000;
    localparam logic [15:0] AO  = 16'b0000_0000_0001_0000;
    
    localparam logic [15:0] RI  = 16'b0000_0000_0000_1000;
    localparam logic [15:0] RO  = 16'b0000_0000_0000_0100;
    localparam logic [15:0] IO  = 16'b0000_0000_0000_0010;
    localparam logic [15:0] HLT = 16'b0000_0000_0000_0001;

    // --- Flag Aliases ---
    logic z_flag;
    logic c_flag;

    assign z_flag = flag[1];
    assign c_flag = flag[0];

    // Internal active-high signal buffer
    logic [15:0] sigs_active_high;

    always_comb begin
        // Default assignment: no signals active
        sigs_active_high = '0;

        // Fetch Cycle
        if (upc == 3'd0) begin
            sigs_active_high = MI | CO;
        end 
        else if (upc == 3'd1) begin
            sigs_active_high = RO | II | C;
        end 
        // Execution Cycle
        else begin
            case (opcode)
                4'b0000: sigs_active_high = '0; // NOP
                
                4'b0001: begin // LDA
                    if (upc == 3'd2) sigs_active_high = IO | MI;
                    else if (upc == 3'd3) sigs_active_high = RO | AI;
                end
                
                4'b0010: begin // ADD
                    if (upc == 3'd2) sigs_active_high = IO | MI;
                    else if (upc == 3'd3) sigs_active_high = RO | BI;
                    else if (upc == 3'd4) sigs_active_high = EO | AI | FI;
                end
                
                4'b0011: begin // SUB
                    if (upc == 3'd2) sigs_active_high = IO | MI;
                    else if (upc == 3'd3) sigs_active_high = RO | BI;
                    else if (upc == 3'd4) sigs_active_high = EO | AI | SUB | FI;
                end
                
                4'b0100: begin // STA
                    if (upc == 3'd2) sigs_active_high = IO | MI;
                    else if (upc == 3'd3) sigs_active_high = AO | RI;
                end
                
                4'b0101: begin // LDI
                    if (upc == 3'd2) sigs_active_high = IO | AI;
                end
                
                4'b0110: begin // JMP
                    if (upc == 3'd2) sigs_active_high = IO | J;
                end
                
                4'b0111: begin // JC
                    if (upc == 3'd2 && c_flag) sigs_active_high = IO | J;
                end
                
                4'b1000: begin // JZ
                    if (upc == 3'd2 && z_flag) sigs_active_high = IO | J;
                end
                
                4'b1110: begin // OUT
                    if (upc == 3'd2) sigs_active_high = AO | OI;
                end
                
                4'b1111: begin // HLT
                    if (upc == 3'd2) sigs_active_high = HLT;
                end
                
                default: sigs_active_high = '0;
            endcase
        end

        control_signals = ~sigs_active_high;
    end

endmodule