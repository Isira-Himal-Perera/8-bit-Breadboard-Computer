`timescale 1ns / 1ps

module alu_system #(
    parameter int WIDTH = 8
)(
    input  logic             clock,
    input  logic             reset_n,
    
    //control signals
    input  logic             output_enable_alu_n,
    input  logic             output_enable_a_n,
    input  logic             output_enable_b_n,
    input  logic             write_enable_a_n,
    input  logic             write_enable_b_n,
    input  logic             write_enable_flag_n,
    input  logic             sub_n,
    
    //data   
    inout  wire  [WIDTH-1:0] bus,
    
    //flags   
    output logic [1:0]       flag   
);
    
    //data
    logic [WIDTH-1:0] internal_alu_out;
    logic [WIDTH-1:0] internal_a_out; 
    logic [WIDTH-1:0] internal_b_out;
    
    //flags 
    logic             internal_z_flag; //zero flag
    logic             internal_c_flag; //carry out flag

    //ALU
    alu #(
        .ALU_WIDTH(WIDTH)
    ) alu_inst (
        .sub_n(sub_n),   
        .operand_a(internal_a_out),   
        .operand_b(internal_b_out),
        .alu_out(internal_alu_out),     
        .carry_out(internal_c_flag),    
        .zero(internal_z_flag)    
    );
    
    tri_state_buffer #(
        .BUFFER_WIDTH(WIDTH)
    ) alu_buffer (
        .output_enable_n(output_enable_alu_n),
        .data_in(internal_alu_out),
        .data_out(bus)
    );
    
    //A Register
    register #(
        .REGISTER_WIDTH(WIDTH)
    ) register_a (
        .clock(clock),
        .reset_n(reset_n),
        .write_enable_n(write_enable_a_n),
        .data_in(bus),
        .data_out(internal_a_out) 
    );
    
    tri_state_buffer #(
        .BUFFER_WIDTH(WIDTH)
    ) buffer_a (
        .output_enable_n(output_enable_a_n),
        .data_in(internal_a_out),
        .data_out(bus)
    );
    
    //B Register
    register #(
        .REGISTER_WIDTH(WIDTH)
    ) register_b (
        .clock(clock),
        .reset_n(reset_n),
        .write_enable_n(write_enable_b_n),
        .data_in(bus),
        .data_out(internal_b_out) 
    );
    
    tri_state_buffer #(
        .BUFFER_WIDTH(WIDTH)
    ) buffer_b (
        .output_enable_n(output_enable_b_n),
        .data_in(internal_b_out),
        .data_out(bus)
    );
    
    //Flag Registers
    register #(
        .REGISTER_WIDTH(2)
    ) register_flag (
        .clock(clock),
        .reset_n(reset_n),
        .write_enable_n(write_enable_flag_n),
        .data_in({internal_z_flag, internal_c_flag}),
        .data_out(flag) 
    );

endmodule