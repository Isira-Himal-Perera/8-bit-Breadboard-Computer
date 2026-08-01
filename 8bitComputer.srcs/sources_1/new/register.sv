`timescale 1ns / 1ps

module register #(
    parameter int REGISTER_WIDTH = 8
)(
    input  logic                    clock,
    input  logic                    reset_n,         
    input  logic                    write_enable_n,  
    input  logic [REGISTER_WIDTH-1:0] data_in,
    output logic [REGISTER_WIDTH-1:0] data_out
);

    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= '0;
        end else if (!write_enable_n) begin 
            data_out <= data_in;
        end
    end
    
endmodule