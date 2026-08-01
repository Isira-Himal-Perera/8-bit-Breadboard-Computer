`timescale 1ns / 1ps

module tri_state_buffer #(
    parameter int BUFFER_WIDTH = 8
)(
    input  logic                    output_enable_n, 
    input  logic [BUFFER_WIDTH-1:0] data_in,         
    output logic [BUFFER_WIDTH-1:0] data_out         
);

    assign data_out = (!output_enable_n) ? data_in : 'z;

endmodule