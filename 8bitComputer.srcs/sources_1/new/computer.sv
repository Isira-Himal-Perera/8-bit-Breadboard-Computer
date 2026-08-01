`timescale 1ns / 1ps

module computer(
    input  logic       clock_in,
    input  logic       reset_n,
    input  logic       run,
    input  logic       write_n,
    input  logic       program_run,
    input  logic [3:0] manual_address,
    input  logic [7:0] manual_data,
    output logic [7:0] output_data
);

    // active low control signals 
    logic BI;
    logic AI;
    logic MI;
    logic II;
    logic OI;
    logic FI;
    logic C;
    logic J; 
    
    logic CO;
    logic SUB; //ADD: 1, SUB: 0
    logic EO;
    logic AO;
    logic RI;
    logic RO;
    logic IO;
    logic HLT; // Active Low: 1 = Run, 0 = Halt
    
    logic [15:0] control_signals;

    assign {BI, AI, MI, II, OI, FI, C, J, CO, SUB, EO, AO, RI, RO, IO, HLT} = control_signals;
    
    //control unit addr
    logic [3:0] opcode;
    logic [2:0] upc;
    logic [1:0] flag;
    
    // clock
    logic clock_gated;  // This is the glitch-free raw gated signal
    logic clock;        // This is the clean, buffered clock distributed to modules
    logic clock_n;
    
    wire [7:0] bus; // data bus
    
    // FPGA Hardware-Safe Clock Gating
    // 1. Combine your run and active-low halt condition into a target gate signal
    assign clock_gated = HLT & run; 

    // 2. Instantiate a primitive hardware clock buffer (AMD Xilinx style)
    // This allows glitchless gating without altering any sub-blocks.
    BUFGCE clk_gate_buffer (
        .I(clock_in),       // Clock input
        .CE(clock_gated),   // Active-high clock enable
        .O(clock)           // Clean, glitch-free output clock
    );

    assign clock_n = ~clock;
    assign (weak0, weak1) bus = 8'h00;
    
    //ALU
    alu_system #(
        .WIDTH(8)
    ) alu_inst (
        .clock(clock),       
        .reset_n(reset_n),
        .output_enable_alu_n(EO),
        .output_enable_a_n(AO),
        .output_enable_b_n(1'b1),
        .write_enable_a_n(AI),
        .write_enable_b_n(BI),
        .write_enable_flag_n(FI),
        .sub_n(SUB),
        .bus(bus),
        .flag(flag)
    );
    
    //output data
    register #(
        .REGISTER_WIDTH(8)
    ) output_register (
        .clock(clock),       
        .reset_n(reset_n),
        .write_enable_n(OI),
        .data_in(bus),
        .data_out(output_data) 
    );
    
    //memory system 
    memory_system #(
        .DATA_WIDTH(8),   
        .ADDR_WIDTH(4)    
    ) ram_system (
        .clock(clock),
        .reset_n(reset_n),
        .program_we_n(write_n), 
        .control_we_n(RI),            
        .oe_n(RO),            
        .address_in_n(MI),            
        .program_run(program_run),
        .program_address(manual_address),  
        .program_data(manual_data),        
        .bus_data(bus)  
    );

    //PC
    tri_state_counter #(
        .WIDTH(4)
    ) program_counter (
        .clock(clock),       
        .reset_n(reset_n),        
        .count_enable_n(C),
        .up_down(1'b1),
        .load_enable_n(J),
        .output_enable_n(CO),
        .data_in(bus[3:0]),
        .bus_out(bus[3:0])
    );  
    
    counter #(
        .COUNTER_WIDTH(3)
    ) micro_program_counter (
        .clock(clock_n),     
        .reset_n(reset_n),        
        .count_enable_n(1'b0),
        .up_down(1'b1),        
        .load_enable_n(1'b1),
        .data_in(3'b000),
        .count_out(upc)
    );
    
    instruction_register #(
        .OPCODE_WIDTH(4),   
        .OPERAND_WIDTH(4)
    ) ir_inst (              
        .clock(clock),       
        .reset_n(reset_n),         
        .write_enable_n(II),  
        .output_enable_n(IO), 
        .bus(bus),         
        .opcode(opcode)
    );
    
    control_unit cu (
        .opcode(opcode),          
        .upc(upc),              
        .flag(flag),
        .control_signals(control_signals)  
    );
        
endmodule