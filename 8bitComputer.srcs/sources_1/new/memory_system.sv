`timescale 1ns / 1ps

module memory_system #(
    parameter int DATA_WIDTH = 8,   
    parameter int ADDR_WIDTH = 4    
)(
    input  logic                  clock,
    input  logic                  reset_n,
    input  logic                  program_we_n,
    input  logic                  control_we_n,             
    input  logic                  oe_n,                     
    input  logic                  address_in_n,             
    input  logic                  program_run,
    input  logic [ADDR_WIDTH-1:0] program_address,  
    input  logic [DATA_WIDTH-1:0] program_data,  
    inout  wire  [DATA_WIDTH-1:0] bus_data  
);

    logic [DATA_WIDTH-1:0] internal_ram_out;
    logic [DATA_WIDTH-1:0] internal_ram_in;
    logic [ADDR_WIDTH-1:0] internal_address;
    logic [ADDR_WIDTH-1:0] mar_address;
    logic                  we_n;
    logic [ADDR_WIDTH-1:0] address_from_bus;
    logic                  clock_mem;
    
    assign clock_mem = program_run ? (!program_we_n) : clock;
   
    assign address_from_bus = bus_data[ADDR_WIDTH-1:0]; 

    assign we_n = program_run ? 1'b0 : control_we_n;
    assign internal_ram_in = program_run ? program_data : bus_data;
    assign internal_address = program_run ? program_address : mar_address;    
    
    single_port_bram #(
        .DATA_WIDTH(DATA_WIDTH), 
        .ADDR_WIDTH(ADDR_WIDTH)  
    ) ram_inst (
        .clock(clock_mem),
        .we_n(we_n),
        .addr(internal_address),
        .din(internal_ram_in), 
        .dout(internal_ram_out)
    );

    tri_state_buffer #(
        .BUFFER_WIDTH(DATA_WIDTH) 
    ) tri_buf_inst (
        .output_enable_n(oe_n),
        .data_in(internal_ram_out),
        .data_out(bus_data)            
    );
    
    register #(
        .REGISTER_WIDTH(ADDR_WIDTH)
    ) address_reg (
        .clock(clock),
        .reset_n(reset_n),
        .write_enable_n(address_in_n),
        .data_in(address_from_bus),
        .data_out(mar_address) 
    );
  
endmodule