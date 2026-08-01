`timescale 1ns / 1ps

module alu #(
    parameter int ALU_WIDTH = 8
)(
    input  logic                 sub_n, // 0: sub, 1:add
    input  logic [ALU_WIDTH-1:0] operand_a,   
    input  logic [ALU_WIDTH-1:0] operand_b,
    output logic [ALU_WIDTH-1:0] alu_out,     
    output logic                 carry_out,    
    output logic                 zero    
);

    logic [ALU_WIDTH:0] full_result; 

    always_comb begin
        if (sub_n) begin
            full_result = operand_a + operand_b;
        end else begin
            full_result = operand_a + (~operand_b) + 1'b1;
        end
        
        alu_out   = full_result[ALU_WIDTH-1:0]; 
        carry_out = full_result[ALU_WIDTH];   
        
        zero = (alu_out == '0);
    end

endmodule