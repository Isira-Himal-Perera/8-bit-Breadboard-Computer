`timescale 1ns / 1ps

module instruction_register #(
    parameter int OPCODE_WIDTH = 4,
    parameter int OPERAND_WIDTH = 4
)(
    input  logic                                 clock,
    input  logic                                 reset_n,         
    input  logic                                 write_enable_n,  
    input  logic                                 output_enable_n, 
    inout  wire  [OPCODE_WIDTH+OPERAND_WIDTH-1:0] bus,         
    output logic [OPCODE_WIDTH-1:0]              opcode      
);

    localparam int TOTAL_WIDTH = OPCODE_WIDTH + OPERAND_WIDTH;

    // Internal logic signals
    logic [TOTAL_WIDTH-1:0]   ir_value;
    logic [OPERAND_WIDTH-1:0] operand; 

    // 1. Storage Register
    register #(
        .REGISTER_WIDTH(TOTAL_WIDTH)
    ) reg_inst (
        .clock(clock),
        .reset_n(reset_n),
        .write_enable_n(write_enable_n),
        .data_in(bus),
        .data_out(ir_value) 
    );

    // 2. Internal Slicing
    assign opcode  = ir_value[TOTAL_WIDTH-1 : OPERAND_WIDTH];
    assign operand = ir_value[OPERAND_WIDTH-1 : 0];

    // 3. Tri-state output buffer back to the shared bus
    tri_state_buffer #(
        .BUFFER_WIDTH(OPERAND_WIDTH)
    ) buffer_inst (
        .output_enable_n(output_enable_n),
        .data_in(operand),
        .data_out(bus[OPERAND_WIDTH-1:0])
    );
    
endmodule