`timescale 1ns / 1ps
`include "config.v"
module ifetch (
    input wire rst,
    input wire clk,
    
    input wire[`Addrlen - 1 : 0] pc_i,
    output reg[`Addrlen - 1 : 0] pc_o,

    input wire[1 : 0] if_status,
    input wire[`Instlen - 1 : 0] data_from_mem,
    output reg if_readwrite,
    output reg[`Instlen - 1 : 0] inst,

    //input wire[5 : 0] stall,
    output reg if_stall_req

);

always @(*) begin
    if (rst == `ResetEnable) begin
        pc_o = `ZeroWord;
        if_readwrite = 1'b0;
        inst = `ZeroWord;
        if_stall_req = 1'b0;
    end
    else begin
        if (if_status == `Done) begin
            pc_o = pc_i;
            if_readwrite = 1'b0;
            inst = data_from_mem;
            if_stall_req = 1'b0;
        end
        else if (if_status == `Init) begin
            pc_o = pc_i;
            if_readwrite = 1'b1;
            inst = `ZeroWord;
            if_stall_req = 1'b1;
        end
        else begin
            pc_o = pc_i;
            if_readwrite = 1'b1;
            inst = `ZeroWord;
            if_stall_req = 1'b1;
        end
    end
end    

endmodule