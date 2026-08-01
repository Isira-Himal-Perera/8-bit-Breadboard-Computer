`timescale 1ns / 1ps

module counter #(
    parameter int COUNTER_WIDTH = 8
)(
    input  logic                     clock,
    input  logic                     reset_n,        
    input  logic                     count_enable_n,
    input  logic                     up_down,        //1: up, 0: down
    input  logic                     load_enable_n,
    input  logic [COUNTER_WIDTH-1:0] data_in,
    output logic [COUNTER_WIDTH-1:0] count_out
);

    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            count_out <= '0;
        end else if (!load_enable_n) begin
            count_out <= data_in;
        end else if (!count_enable_n) begin
            if (up_down) begin
                count_out <= count_out + 1'b1;
            end else begin
                count_out <= count_out - 1'b1;
            end
        end
    end

endmodule