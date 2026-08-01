`timescale 1ns / 1ps

module tri_state_counter #(
    parameter int WIDTH = 8
)(
    input  logic             clock,
    input  logic             reset_n,        
    input  logic             count_enable_n,
    input  logic             up_down,
    input  logic             load_enable_n,
    input  logic             output_enable_n,
    input  logic [WIDTH-1:0] data_in,
    output wire  [WIDTH-1:0] bus_out
);
    
    logic [WIDTH-1:0] counter_to_buffer;
    
    counter #(
        .COUNTER_WIDTH(WIDTH)
    ) counter_inst (
        .clock(clock),
        .reset_n(reset_n),        
        .count_enable_n(count_enable_n),
        .up_down(up_down),
        .load_enable_n(load_enable_n),
        .data_in(data_in),
        .count_out(counter_to_buffer)
    );
    
    tri_state_buffer #(
        .BUFFER_WIDTH(WIDTH)
    ) buffer_inst (
        .output_enable_n(output_enable_n),
        .data_in(counter_to_buffer),
        .data_out(bus_out)
    );
    
endmodule