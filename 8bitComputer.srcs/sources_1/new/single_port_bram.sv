`timescale 1ns / 1ps

module single_port_bram #(
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 4  
)(
    input  logic                  clock,
    input  logic                  we_n,   
    input  logic [ADDR_WIDTH-1:0] addr, 
    input  logic [DATA_WIDTH-1:0] din,  
    output logic [DATA_WIDTH-1:0] dout  
);

    logic [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

    always_ff @(posedge clock) begin
        if (!we_n) begin
            ram[addr] <= din;
        end
    end
    
    assign dout = ram[addr];
    
endmodule